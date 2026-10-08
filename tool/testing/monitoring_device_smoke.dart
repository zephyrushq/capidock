// Run only with CAPIDOCK_MONITOR_SMOKE=1 in a debug build. Uses a separate
// Android application ID and a synthetic closed loopback endpoint, never a
// user's vault. No data or credentials are sent to external servers.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:workmanager/workmanager.dart';
import 'package:capidock/features/monitoring/monitor_service.dart';
import 'package:capidock/features/workspaces/data/secret_store.dart';
import 'package:capidock/features/workspaces/data/workspace_store.dart';
import 'package:capidock/features/workspaces/domain/dock_workspace.dart';
import 'package:capidock/features/instances/domain/server_instance.dart';

bool foregroundEngine = false;
const receipt = 'capidock.smoke.headless';

@pragma('vm:entry-point')
void smokeDispatcher() {
  Workmanager().executeTask((_, input) async {
    await MonitorService().run();
    await const AndroidSecretStore().write(
      receipt,
      jsonEncode({'headless': !foregroundEngine}),
    );
    debugPrint('CAPIDOCK_MONITOR_SMOKE: worker headless=${!foregroundEngine}');
    return true;
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kDebugMode ||
      (await PackageInfo.fromPlatform()).packageName !=
          'com.zephyrushq.capidock.monitorcheck') {
    throw StateError('Use the isolated monitoring smoke application ID');
  }
  foregroundEngine = true;
  runApp(const MaterialApp(home: SmokePage()));
}

class SmokePage extends StatefulWidget {
  const SmokePage({super.key});
  @override
  State<SmokePage> createState() => _SmokePageState();
}

class _SmokePageState extends State<SmokePage> {
  String status = 'Preparing isolated monitoring check…';
  @override
  void initState() {
    super.initState();
    unawaited(_run());
  }

  Future<void> _run() async {
    const secrets = AndroidSecretStore();
    final service = MonitorService();
    try {
      await service.erase(secrets.deleteAll);
      await Workmanager().initialize(smokeDispatcher);
      const instance = ServerInstance(
        id: 'smoke',
        name: 'Loopback smoke',
        type: InstanceType.ssh,
        host: '127.0.0.1',
        port: 1,
        username: 'smoke',
        password: 'synthetic-smoke-only',
      );
      await SecureWorkspaceStore().save([
        DockWorkspace(
          id: 'smoke-workspace',
          name: 'Smoke',
          instances: [instance],
        ),
      ]);
      await service.save(
        MonitorConfig(ids: {instance.id}, revision: MonitorService.nonce()),
      );
      await MonitorService.checkSoon();
      final deadline = DateTime.now().add(const Duration(minutes: 3));
      while (DateTime.now().isBefore(deadline)) {
        final snapshot = await service.bridge.transaction(
          () async => (await service.history(), await secrets.read(receipt)),
        );
        if (snapshot.$1[instance.id]?.samples.isNotEmpty == true &&
            snapshot.$2 != null) {
          if (jsonDecode(snapshot.$2!)['headless'] != true) {
            throw StateError('No headless engine was exercised');
          }
          await service.run();
          final state = (await service.history())[instance.id]!;
          if (state.failures < 2 || !state.downAlerted) {
            throw StateError('Failure alert transition not reached');
          }
          debugPrint(
            'CAPIDOCK_MONITOR_SMOKE: encrypted history and alert transition PASS',
          );
          if (!await service.bridge.notificationsAllowed()) {
            throw StateError(
              'Grant notification permission to the smoke package first',
            );
          }
          // Leave one generic alert visible briefly for device inspection.
          await Future<void>.delayed(const Duration(seconds: 5));
          await service.erase(secrets.deleteAll);
          await service.run();
          if ((await secrets.readAll()).isNotEmpty) {
            throw StateError('Erase was not complete');
          }
          debugPrint('CAPIDOCK_MONITOR_SMOKE: erase and disabled worker PASS');
          if (mounted) {
            setState(
              () => status =
                  'PASS · headless worker, encrypted history, alert, erase',
            );
          }
          return;
        }
        await Future<void>.delayed(const Duration(seconds: 1));
      }
      throw StateError('Android did not run the scheduled worker in time');
    } catch (_) {
      debugPrint('CAPIDOCK_MONITOR_SMOKE: FAIL');
      if (mounted) setState(() => status = 'FAIL · inspect the isolated test');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Capidock monitoring smoke')),
    body: Center(
      child: Padding(padding: const EdgeInsets.all(24), child: Text(status)),
    ),
  );
}
