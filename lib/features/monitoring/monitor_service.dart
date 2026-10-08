import 'dart:convert';
import 'dart:async';
import 'dart:math';

import 'package:capidock_monitor_bridge/capidock_monitor_bridge.dart';
import 'package:cryptography/cryptography.dart';
import 'package:workmanager/workmanager.dart';

import '../instances/domain/server_instance.dart';
import '../workspaces/data/secret_store.dart';
import '../workspaces/data/workspace_store.dart';
import 'monitor_probe.dart';
import 'monitor_state.dart';
import 'monitor_cancellation.dart';

@pragma('vm:entry-point')
void monitoringDispatcher() {
  Workmanager().executeTask((task, input) async {
    try {
      await MonitorService().run();
      return true;
    } catch (_) {
      return false;
    } // Never log credentials, API bodies or addresses.
  });
}

class MonitorConfig {
  MonitorConfig({
    this.ids = const {},
    this.interval = 15,
    this.revision = '',
    this.locale = 'en-GB',
    this.fastEnabled = true,
    this.fastInterval = 10,
    this.alerts = const {
      'down',
      'recovery',
      'authentication',
      'identity',
      'unknown',
      'deployment',
      'deploymentStarted',
      'deploymentSucceeded',
      'deploymentCancelled',
      'resource',
      'resourceChanged',
    },
  });
  final Set<String> ids, alerts;
  final int interval, fastInterval;
  final bool fastEnabled;
  final String revision, locale;
  Map<String, dynamic> toJson() => {
    'eventSchema': 2,
    'fastEnabled': fastEnabled,
    'fastInterval': fastInterval,
    'ids': ids.toList(),
    'interval': interval,
    'revision': revision,
    'locale': locale,
    'alerts': alerts.toList(),
  };
  factory MonitorConfig.fromJson(Map<String, dynamic> data) {
    final interval = data['interval'] as int;
    final ids = Set<String>.from(data['ids'] as List);
    if (![15, 30, 60].contains(interval) || ids.length > 20) {
      throw const FormatException('Invalid monitoring config');
    }
    final fastInterval = data['fastInterval'] as int? ?? 10;
    if (![10, 30, 60].contains(fastInterval)) {
      throw const FormatException('Invalid foreground interval');
    }
    final alerts = Set<String>.from(data['alerts'] as List);
    if (data['eventSchema'] != 2) {
      if (alerts.contains('deployment')) {
        alerts.addAll({
          'deploymentStarted',
          'deploymentSucceeded',
          'deploymentCancelled',
        });
      }
      if (alerts.contains('resource')) alerts.add('resourceChanged');
    }
    return MonitorConfig(
      fastEnabled: data['fastEnabled'] as bool? ?? true,
      fastInterval: fastInterval,
      ids: ids,
      interval: interval,
      revision: data['revision'] as String,
      locale: data['locale'] as String,
      alerts: alerts,
    );
  }
}

class MonitorService {
  MonitorService({
    this.secrets = const AndroidSecretStore(),
    MonitorBridge? bridge,
    Future<HealthCheck> Function(ServerInstance)? probe,
    Future<void> Function(MonitorConfig)? scheduleConfig,
    Future<void> Function()? cancelJobs,
  }) : bridge = bridge ?? MonitorBridge(),
       probe = probe ?? probeInstance,
       defaultProbe = probe == null,
       scheduleConfig = scheduleConfig ?? schedule,
       cancelJobs = cancelJobs ?? cancelScheduled;
  final bool defaultProbe;
  static final _changes = StreamController<void>.broadcast();
  static Stream<void> get changes => _changes.stream;
  final SecretStore secrets;
  final MonitorBridge bridge;
  final Future<HealthCheck> Function(ServerInstance) probe;
  final Future<void> Function(MonitorConfig) scheduleConfig;
  final Future<void> Function() cancelJobs;
  static const configKey = 'capidock.monitor.config.v1',
      historyKey = 'capidock.monitor.history.v1',
      leaseKey = 'capidock.monitor.lease.v1';
  static const task = 'capidock.health.v1';
  static String nonce() => List.generate(
    24,
    (_) => Random.secure().nextInt(256),
  ).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  Future<void> _write(String key, Object value) async {
    final encoded = jsonEncode(value);
    await secrets.write(key, encoded);
    if (await secrets.read(key) != encoded) {
      throw StateError('Monitoring data was not saved');
    }
  }

  Future<Map<String, dynamic>?> _read(String key) async {
    final raw = await secrets.read(key);
    if (raw == null) return null;
    if (raw.length > 12 * 1024 * 1024) {
      throw const FormatException('Monitoring data too large');
    }
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<MonitorConfig> config() async {
    final data = await _read(configKey);
    return data == null ? MonitorConfig() : MonitorConfig.fromJson(data);
  }

  Future<Map<String, MonitorState>> history() async =>
      (await _read(historyKey) ?? {}).map(
        (k, v) => MapEntry(
          k,
          MonitorState.fromJson(Map<String, dynamic>.from(v as Map)),
        ),
      );
  Future<void> save(MonitorConfig config) async {
    await bridge.transaction(() async {
      MonitorConfig.fromJson(config.toJson());
      await _write(configKey, config.toJson());
      final states = await history();
      states.removeWhere((id, _) => !config.ids.contains(id));
      await _write(historyKey, states.map((k, v) => MapEntry(k, v.toJson())));
      await bridge.clear();
    });
    _changes.add(null);
    await scheduleConfig(config);
  }

  static Future<void> initialize() =>
      Workmanager().initialize(monitoringDispatcher);
  static Future<void> schedule(MonitorConfig config) async {
    if (config.ids.isEmpty) {
      await Workmanager().cancelByUniqueName(task);
      return;
    }
    await Workmanager().registerPeriodicTask(
      task,
      task,
      frequency: Duration(minutes: config.interval),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static Future<void> checkSoon() => Workmanager().registerOneOffTask(
    '$task.manual',
    task,
    existingWorkPolicy: ExistingWorkPolicy.keep,
    constraints: Constraints(networkType: NetworkType.connected),
  );
  static Future<void> cancelScheduled() async {
    await Workmanager().cancelByUniqueName(task);
    await Workmanager().cancelByUniqueName('$task.manual');
  }

  Future<void> erase(Future<void> Function() eraseVault) async {
    await bridge.transaction(() async {
      await secrets.delete(configKey);
      await secrets.delete(historyKey);
      await secrets.delete(leaseKey);
      await bridge.clear();
      await eraseVault();
    });
    _changes.add(null);
    try {
      await cancelJobs();
    } catch (_) {
      // Revoked encrypted configuration already prevents future checks/commits.
    }
  }

  Future<Map<String, ServerInstance>> _instances() async {
    final vault = await _read(SecureWorkspaceStore.storageKey);
    if (vault == null) return {};
    if (vault['version'] != 3) throw const FormatException('Unsupported vault');
    return {
      for (final workspace in vault['workspaces'] as List)
        for (final json in (workspace as Map)['instances'] as List)
          (json as Map)['id'] as String: ServerInstance.fromJson(
            Map<String, dynamic>.from(json),
          ),
    };
  }

  Future<String> _fingerprint(ServerInstance instance) async =>
      (await Sha256().hash(utf8.encode(jsonEncode(instance.toJson())))).bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
  Future<void> run({
    bool fast = false,
    bool Function()? isActive,
    MonitorCancellation? cancellation,
    String? locale,
    void Function(HealthCheck)? onCheck,
  }) async {
    bool canRun() =>
        cancellation?.cancelled != true && (isActive?.call() ?? true);
    if (!canRun()) return;
    final lease = nonce();
    final snapshot = await bridge.transaction(() async {
      final settings = await config();
      if (!canRun() ||
          settings.ids.isEmpty ||
          (fast && !settings.fastEnabled)) {
        return null;
      }
      final active = await _read(leaseKey);
      if (active != null &&
          (active['until'] as int) > DateTime.now().millisecondsSinceEpoch) {
        return null;
      }
      final instances = await _instances();
      instances.removeWhere(
        (id, instance) =>
            !settings.ids.contains(id) ||
            instance.isDemo ||
            !instance.hasCredentials ||
            (fast && instance.type != InstanceType.coolify),
      );
      final states = await history();
      final ordered = instances.values.toList()
        ..sort(
          (a, b) => (states[a.id]?.latest?['at'] as int? ?? 0).compareTo(
            states[b.id]?.latest?['at'] as int? ?? 0,
          ),
        );
      await _write(leaseKey, {
        'token': lease,
        'until': DateTime.now()
            .add(const Duration(minutes: 12))
            .millisecondsSinceEpoch,
      });
      return (settings, ordered);
    });
    if (snapshot == null) return;
    final (settings, instances) = snapshot;
    final deadline = DateTime.now().add(Duration(minutes: fast ? 1 : 8));
    try {
      for (final instance in instances) {
        if (!canRun() || DateTime.now().isAfter(deadline)) break;
        final identity = await _fingerprint(instance);
        if (!canRun()) break;
        var check = await bridge.networkAvailable()
            ? await (defaultProbe
                  ? probeInstance(instance, cancellation: cancellation)
                  : probe(instance))
            : const HealthCheck(Health.offline);
        if (check.health == Health.down && !await bridge.networkAvailable()) {
          check = const HealthCheck(Health.offline);
        }
        if (!canRun()) break;
        onCheck?.call(check);
        final now = DateTime.now();
        await bridge.transaction(() async {
          final current = await config();
          final active = await _read(leaseKey);
          if (!canRun() ||
              current.revision != settings.revision ||
              !current.ids.contains(instance.id) ||
              active?['token'] != lease) {
            return;
          }
          final fresh = (await _instances())[instance.id];
          if (fresh == null || await _fingerprint(fresh) != identity) return;
          final states = await history();
          states.removeWhere((id, _) => !current.ids.contains(id));
          final (state, alerts) = (states[instance.id] ?? MonitorState())
              .record(
                check,
                now,
                identity,
                sampleInterval: Duration(minutes: current.interval),
              );
          states[instance.id] = state;
          if (!canRun()) return;
          await _write(
            historyKey,
            states.map((k, v) => MapEntry(k, v.toJson())),
          );
          for (final alert in alerts.where(current.alerts.contains)) {
            if (!canRun()) break;
            final id = int.parse(identity.substring(0, 7), radix: 16);
            // In-app events also reach the UI when a headless worker runs.
            // Delivery is independent of Android notification permission.
            try {
              await bridge.publishAlert(alert);
            } catch (_) {
              /* UI delivery is best effort; never log server data. */
            }
            if (!canRun()) break;
            try {
              await bridge.notify(
                id,
                notificationText(locale ?? current.locale, alert),
              );
            } catch (_) {
              /* A notification failure must not stop other checks. */
            }
          }
        });
      }
    } finally {
      await bridge.transaction(() async {
        if ((await _read(leaseKey))?['token'] == lease) {
          await secrets.delete(leaseKey);
        }
      });
    }
  }
}

String notificationText(String locale, String alert) {
  const messages = {
    'en': {
      'deploymentStarted':
          'A Coolify deployment started. Open Capidock to review.',
      'deploymentSucceeded': 'A Coolify deployment completed successfully.',
      'deploymentCancelled': 'A Coolify deployment was cancelled.',
      'resourceChanged':
          'A Coolify resource changed state. Open Capidock to review.',
      'down': 'A monitored connection failed twice. Open Capidock to review.',
      'recovery': 'A monitored server is reachable again.',
      'authentication': 'A monitored connection needs its credentials or permissions checked.',
      'identity':
          'SSH identity could not be verified. Open Capidock to review.',
      'unknown': 'A monitoring check could not be completed.',
      'deployment': 'A Coolify deployment failed. Open Capidock to review.',
      'resource': 'A Coolify resource is unhealthy. Open Capidock to review.',
    },
    'pt': {
      'deploymentStarted': 'Um deployment do Coolify começou. Abra o Capidock.',
      'deploymentSucceeded': 'Um deployment do Coolify terminou com sucesso.',
      'deploymentCancelled': 'Um deployment do Coolify foi cancelado.',
      'resourceChanged':
          'Um recurso do Coolify mudou de estado. Abra o Capidock.',
      'down': 'Uma ligação monitorizada falhou duas vezes. Abra o Capidock para verificar.',
      'recovery': 'Um servidor monitorizado está novamente acessível.',
      'authentication':
          'Verifique as credenciais ou permissões de uma ligação monitorizada.',
      'identity':
          'Não foi possível verificar a identidade SSH. Abra o Capidock.',
      'unknown': 'Não foi possível concluir uma verificação.',
      'deployment': 'Um deployment do Coolify falhou. Abra o Capidock.',
      'resource': 'Um recurso do Coolify apresenta problemas. Abra o Capidock.',
    },
    'es': {
      'deploymentStarted':
          'Ha comenzado un despliegue de Coolify. Abre Capidock.',
      'deploymentSucceeded':
          'Un despliegue de Coolify ha terminado correctamente.',
      'deploymentCancelled': 'Se ha cancelado un despliegue de Coolify.',
      'resourceChanged':
          'Un recurso de Coolify ha cambiado de estado. Abre Capidock.',
      'down': 'Una conexión supervisada ha fallado dos veces. Abre Capidock.',
      'recovery': 'Un servidor supervisado vuelve a estar accesible.',
      'authentication':
          'Revisa las credenciales o permisos de una conexión supervisada.',
      'identity': 'No se pudo verificar la identidad SSH. Abre Capidock.',
      'unknown': 'No se pudo completar una comprobación.',
      'deployment': 'Ha fallado un despliegue de Coolify. Abre Capidock.',
      'resource': 'Un recurso de Coolify presenta problemas. Abre Capidock.',
    },
  };
  return (messages[locale.split('-').first] ?? messages['en']!)[alert] ??
      messages['en']!['unknown']!;
}
