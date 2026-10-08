import 'dart:async';
import 'dart:convert';

import 'package:capidock/features/workspaces/domain/dock_workspace.dart';

import 'package:capidock/core/security/security_controls.dart';

import 'package:capidock/features/monitoring/monitor_service.dart';
import 'package:capidock/features/monitoring/monitor_state.dart';
import 'package:capidock/features/monitoring/monitor_probe.dart';
import 'package:capidock/features/monitoring/monitor_page.dart';
import 'package:capidock/features/workspaces/data/workspace_store.dart';
import 'package:capidock/features/workspaces/domain/dock_controller.dart';
import 'package:capidock/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'connections_test.dart' show coolify;
import 'monitor_support.dart';
import 'test_support.dart';

void main() {
  final now = DateTime.utc(2026, 10, 8);
  test(
    'Two failures alert once; authentication proves recovery, not downtime',
    () {
      var state = MonitorState();
      var result = state.record(const HealthCheck(Health.down), now, 'a');
      expect(result.$2, isEmpty);
      result = result.$1.record(
        const HealthCheck(Health.down),
        now.add(const Duration(minutes: 15)),
        'a',
      );
      expect(result.$2, ['down']);
      result = result.$1.record(
        const HealthCheck(Health.down),
        now.add(const Duration(minutes: 30)),
        'a',
      );
      expect(result.$2, isEmpty);
      result = result.$1.record(
        const HealthCheck(Health.authentication),
        now.add(const Duration(minutes: 45)),
        'a',
      );
      expect(result.$2, ['recovery', 'authentication']);
      expect(result.$1.uptime, 25);
      expect(
        result.$1
            .record(
              const HealthCheck(Health.authentication),
              now.add(const Duration(hours: 1)),
              'a',
            )
            .$2,
        isEmpty,
      );
    },
  );
  test('Offline/unknown and gaps break streaks; unknown checks excluded from uptime', () {
    var state = MonitorState()
        .record(const HealthCheck(Health.down), now, 'a')
        .$1;
    state = state
        .record(
          const HealthCheck(Health.offline),
          now.add(const Duration(minutes: 15)),
          'a',
        )
        .$1;
    var result = state.record(
      const HealthCheck(Health.down),
      now.add(const Duration(minutes: 30)),
      'a',
    );
    expect(result.$2, isEmpty);
    result = result.$1.record(
      const HealthCheck(Health.down),
      now.add(const Duration(hours: 5)),
      'a',
    );
    expect(result.$2, isEmpty);
    expect(
      MonitorState()
          .record(const HealthCheck(Health.offline), now, 'a')
          .$1
          .uptime,
      isNull,
    );
  });
  test('Baseline failures silent; new transitions alert once across paged-out failures', () {
    var result = MonitorState().record(
      const HealthCheck(
        Health.up,
        deployments: {'a': 'failed'},
        resources: {'r': 'unhealthy'},
      ),
      now,
      'x',
    );
    expect(result.$2, isEmpty);
    result = result.$1.record(
      const HealthCheck(
        Health.up,
        deployments: {'a': 'failed', 'b': 'failed'},
        resources: {'r': 'running:healthy'},
      ),
      now,
      'x',
    );
    expect(result.$2, ['deployment', 'resourceChanged']);
    result = result.$1.record(
      const HealthCheck(
        Health.up,
        deployments: {},
        resources: {'r': 'unhealthy'},
      ),
      now,
      'x',
    );
    expect(result.$2, ['resource', 'resourceChanged']);
    result = result.$1.record(
      const HealthCheck(Health.up, deployments: {'a': 'failed'}),
      now,
      'x',
    );
    expect(result.$2, isEmpty);
    expect(
      result.$1
          .record(
            const HealthCheck(Health.up, deployments: {'a': 'failed'}),
            now,
            'new-endpoint',
          )
          .$2,
      isEmpty,
    );
  });
  test('Retention is bounded and state serialization round trips', () {
    final state = MonitorState(
      fingerprint: 'a',
      samples: List.generate(
        3500,
        (_) => {'at': now.millisecondsSinceEpoch, 'health': 'up'},
      ),
      events: List.generate(
        120,
        (_) => {'at': now.millisecondsSinceEpoch, 'kind': 'down'},
      ),
    );
    final recorded = state.record(const HealthCheck(Health.up), now, 'a').$1;
    expect(recorded.samples.length, 3000);
    expect(recorded.events.length, 100);
    expect(
      MonitorState.fromJson(recorded.toJson()).toJson(),
      recorded.toJson(),
    );
    final expired = recorded
        .record(
          const HealthCheck(Health.up),
          now.add(const Duration(days: 31)),
          'a',
        )
        .$1;
    expect(expired.samples.length, 1);
    expect(expired.events, isEmpty);
  });
  test('Coolify monitoring discards names, logs and secrets; malformed response rejected', () {
    expect(
      monitorItems({
        'deployments': [
          {
            'deployment_uuid': 'd',
            'status': 'failed',
            'logs': 'secret',
            'name': 'private',
          },
        ],
      }, deployments: true),
      {'d': 'failed'},
    );
    expect(
      monitorItems([
        {'uuid': 'r', 'status': 'running:unhealthy'},
      ], deployments: false),
      {'r': 'running:unhealthy'},
    );
    expect(
      () => monitorItems({'oops': 'secret'}, deployments: true),
      throwsFormatException,
    );
  });
  for (final scenario in ['disabled', 'removed', 'edited', 'erased']) {
    test('In-flight check cannot commit after $scenario', () async {
      final secrets = MemorySecretStore(), bridge = FakeMonitorBridge();
      final started = Completer<void>(), release = Completer<HealthCheck>();
      final config = MonitorConfig(ids: {coolify.id}, revision: 'first');
      secrets.values[MonitorService.configKey] = jsonEncode(config.toJson());
      secrets.values[SecureWorkspaceStore.storageKey] = jsonEncode({
        'version': 3,
        'workspaces': [
          {
            'instances': [coolify.toJson()],
          },
        ],
      });
      final service = MonitorService(
        secrets: secrets,
        bridge: bridge,
        probe: (_) {
          started.complete();
          return release.future;
        },
      );
      final running = service.run();
      await started.future;
      await bridge.transaction(() async {
        if (scenario == 'erased') {
          await secrets.deleteAll();
        }
        if (scenario == 'disabled') {
          await secrets.write(
            MonitorService.configKey,
            jsonEncode(MonitorConfig(revision: 'next').toJson()),
          );
        }
        if (scenario == 'removed') {
          await secrets.write(
            SecureWorkspaceStore.storageKey,
            jsonEncode({'version': 3, 'workspaces': []}),
          );
        }
        if (scenario == 'edited') {
          await secrets.write(
            SecureWorkspaceStore.storageKey,
            jsonEncode({
              'version': 3,
              'workspaces': [
                {
                  'instances': [
                    {...coolify.toJson(), 'apiToken': 'new-secret'},
                  ],
                },
              ],
            }),
          );
        }
      });
      release.complete(const HealthCheck(Health.down));
      await running;
      expect(secrets.values.containsKey(MonitorService.historyKey), false);
      expect(bridge.messages, isEmpty);
      expect(bridge.alerts, isEmpty);
      if (scenario == 'erased') expect(secrets.values, isEmpty);
    });
  }
  test(
    'Offline creates unknown observation without contacting servers',
    () async {
      final secrets = MemorySecretStore(),
          bridge = FakeMonitorBridge()..online = false;
      secrets.values[MonitorService.configKey] = jsonEncode(
        MonitorConfig(ids: {coolify.id}, revision: 'r').toJson(),
      );
      secrets.values[SecureWorkspaceStore.storageKey] = jsonEncode({
        'version': 3,
        'workspaces': [
          {
            'instances': [coolify.toJson()],
          },
        ],
      });
      var probes = 0;
      final service = MonitorService(
        secrets: secrets,
        bridge: bridge,
        probe: (_) async {
          probes++;
          return const HealthCheck(Health.up);
        },
      );
      await service.run();
      expect(probes, 0);
      expect((await service.history())[coolify.id]!.uptime, isNull);
      expect(bridge.messages, isEmpty);
      expect(bridge.alerts, isEmpty);
    },
  );
  test(
    'Unconfigured worker never reads the workspace vault or writes history',
    () async {
      final secrets = MemorySecretStore()
        ..values[SecureWorkspaceStore.storageKey] = 'invalid';
      final service = MonitorService(
        secrets: secrets,
        bridge: FakeMonitorBridge(),
        probe: (_) async => throw StateError('should not run'),
      );
      await service.run();
      expect(secrets.values.length, 1);
    },
  );
  test(
    'Worker lease prevents overlapping probes and duplicate failure counting',
    () async {
      final secrets = MemorySecretStore(),
          bridge = FakeMonitorBridge(),
          started = Completer<void>(),
          release = Completer<HealthCheck>();
      secrets.values[MonitorService.configKey] = jsonEncode(
        MonitorConfig(ids: {coolify.id}, revision: 'r').toJson(),
      );
      secrets.values[SecureWorkspaceStore.storageKey] = jsonEncode({
        'version': 3,
        'workspaces': [
          {
            'instances': [coolify.toJson()],
          },
        ],
      });
      var count = 0;
      final service = MonitorService(
        secrets: secrets,
        bridge: bridge,
        probe: (_) {
          count++;
          started.complete();
          return release.future;
        },
      );
      final first = service.run();
      await started.future;
      await service.run();
      expect(count, 1);
      release.complete(const HealthCheck(Health.down));
      await first;
      expect((await service.history())[coolify.id]!.failures, 1);
    },
  );
  test('Unverified storage writes never schedule or probe', () async {
    final secrets = MemorySecretStore()..dropWrites = true;
    var scheduled = 0, probes = 0;
    final service = MonitorService(
      secrets: secrets,
      bridge: FakeMonitorBridge(),
      scheduleConfig: (_) async {
        scheduled++;
      },
      probe: (_) async {
        probes++;
        return const HealthCheck(Health.up);
      },
    );
    await expectLater(
      service.save(MonitorConfig(ids: {coolify.id}, revision: 'r')),
      throwsStateError,
    );
    expect(scheduled, 0);
    secrets.values[MonitorService.configKey] = jsonEncode(
      MonitorConfig(ids: {coolify.id}, revision: 'r').toJson(),
    );
    secrets.values[SecureWorkspaceStore.storageKey] = jsonEncode({
      'version': 3,
      'workspaces': [
        {
          'instances': [coolify.toJson()],
        },
      ],
    });
    await expectLater(service.run(), throwsStateError);
    expect(probes, 0);
  });
  for (final accepted in [true, false]) {
    testWidgets(
      'Enabling monitoring requires consent and fresh authentication: $accepted',
      (tester) async {
        final secrets = MemorySecretStore();
        final controller = DockController(
          MemoryWorkspaceStore()
            ..data = [
              DockWorkspace(id: 'w', name: 'Smoke', instances: [coolify]),
            ],
        );
        await controller.initialize();
        var attempts = 0, scheduled = 0;
        final service = MonitorService(
          secrets: secrets,
          bridge: FakeMonitorBridge(),
          scheduleConfig: (_) async {
            scheduled++;
          },
        );
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en', 'GB'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SecurityControls(
              lock: () {},
              clearData: (_) async {},
              reauthenticate: (_) async {
                attempts++;
                return accepted;
              },
              child: MonitorPage(controller: controller, service: service),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(find.text(coolify.name), 200);
        await tester.tap(
          find.byKey(ValueKey('monitor-instance-${coolify.id}')),
        );
        await tester.pumpAndSettle();
        expect(attempts, 0);
        expect(secrets.values, isEmpty);
        await tester.tap(
          find.widgetWithText(FilledButton, 'Enable monitoring'),
        );
        await tester.pumpAndSettle();
        expect(attempts, 1);
        expect(scheduled, accepted ? 1 : 0);
        expect((await service.config()).ids.contains(coolify.id), accepted);
        await tester.pumpWidget(const SizedBox());
        controller.dispose();
      },
    );
  }
  for (final locale in [
    const Locale('en', 'GB'),
    const Locale('en', 'US'),
    const Locale('pt', 'PT'),
    const Locale('pt', 'BR'),
    const Locale('es', 'ES'),
  ]) {
    testWidgets(
      '$locale monitoring fits small screens and does not auto-enable',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final controller = DockController(
          MemoryWorkspaceStore()..data = fixtureWorkspaces(),
        );
        await controller.initialize();
        final secrets = MemorySecretStore();
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MonitorPage(
              controller: controller,
              service: MonitorService(
                secrets: secrets,
                bridge: FakeMonitorBridge(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(secrets.values, isEmpty);
        await tester.scrollUntilVisible(
          find.text(fixtureInstances.first.name),
          200,
        );
        final switches = tester
            .widgetList<SwitchListTile>(find.byType(SwitchListTile))
            .toList();
        expect(
          switches
              .where(
                (s) =>
                    s.key ==
                    ValueKey('monitor-instance-${fixtureInstances.first.id}'),
              )
              .single
              .value,
          false,
        );
        await tester.pumpWidget(const SizedBox());
        controller.dispose();
      },
    );
  }
}
