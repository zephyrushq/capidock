import 'dart:async';
import 'dart:convert';

import 'package:capidock/features/monitoring/foreground_monitor.dart';
import 'package:capidock/features/monitoring/monitor_cancellation.dart';
import 'package:capidock/features/monitoring/monitor_probe.dart';
import 'package:capidock/features/monitoring/monitor_service.dart';
import 'package:capidock/features/monitoring/monitor_state.dart';
import 'package:capidock/features/workspaces/data/workspace_store.dart';
import 'package:capidock/features/workspaces/domain/dock_controller.dart';
import 'package:capidock/features/workspaces/domain/dock_workspace.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'connections_test.dart' show coolify;
import 'monitor_support.dart';
import 'test_support.dart';

class LoopService extends MonitorService {
  LoopService()
    : super(secrets: MemorySecretStore(), bridge: FakeMonitorBridge());
  int calls = 0;
  Health health = Health.up;
  Completer<void>? pending;
  MonitorCancellation? token;
  @override
  Future<void> run({
    bool fast = false,
    bool Function()? isActive,
    MonitorCancellation? cancellation,
    String? locale,
    void Function(HealthCheck)? onCheck,
  }) async {
    expectSync(fast, true);
    calls++;
    token = cancellation;
    await pending?.future;
    if (isActive?.call() == true) onCheck?.call(HealthCheck(health));
  }
}

void main() {
  testWidgets(
    'Rapid rounds follow cadence, stop, and back off on authentication failures',
    (tester) async {
      final service = LoopService();
      final loop = ForegroundMonitorLoop(service, locale: () => 'en-GB');
      loop.start(10);
      await tester.pump();
      expect(service.calls, 1);
      await tester.pump(const Duration(seconds: 9));
      expect(service.calls, 1);
      service.health = Health.authentication;
      await tester.pump(const Duration(seconds: 1));
      expect(service.calls, 2);
      await tester.pump(const Duration(seconds: 59));
      expect(service.calls, 2);
      await tester.pump(const Duration(seconds: 1));
      expect(service.calls, 3);
      loop.stop();
      await tester.pump(const Duration(minutes: 2));
      expect(service.calls, 3);
    },
  );
  testWidgets(
    'Pause cancels transport and resume waits for the previous round',
    (tester) async {
      final service = LoopService()..pending = Completer<void>();
      final loop = ForegroundMonitorLoop(service, locale: () => 'en-GB');
      loop.start(10);
      await tester.pump();
      await tester.pump(const Duration(minutes: 1));
      expect(service.calls, 1);
      var closed = false;
      service.token!.attach(() => closed = true);
      loop.stop();
      expect(closed, true);
      loop.start(10);
      expect(service.calls, 1);
      service.pending!.complete();
      service.pending = null;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));
      expect(service.calls, 2);
      loop.stop();
    },
  );
  test('Deploy transitions deduplicate and rapid observations do not skew uptime samples', () {
    final now = DateTime.utc(2026, 10, 8);
    var state = MonitorState();
    var result = state.record(
      const HealthCheck(
        Health.up,
        deployments: {'d': 'queued'},
        resources: {'r': 'running:healthy'},
      ),
      now,
      'id',
      sampleInterval: const Duration(minutes: 15),
    );
    expect(result.$2, isEmpty);
    state = result.$1;
    for (final status in ['in_progress', 'finished', 'cancelled', 'failed']) {
      result = state.record(
        HealthCheck(Health.up, deployments: {'d': status}),
        now.add(const Duration(seconds: 10)),
        'id',
        sampleInterval: const Duration(minutes: 15),
      );
      expect(result.$2, [
        switch (status) {
          'in_progress' => 'deploymentStarted',
          'finished' => 'deploymentSucceeded',
          'cancelled' => 'deploymentCancelled',
          _ => 'deployment',
        },
      ]);
      state = result.$1;
      expect(state.samples.length, 1);
      expect(
        state
            .record(
              HealthCheck(Health.up, deployments: {'d': status}),
              now.add(const Duration(seconds: 11)),
              'id',
            )
            .$2,
        isEmpty,
      );
    }
    result = state.record(
      const HealthCheck(Health.up, resources: {'r': 'exited'}),
      now.add(const Duration(seconds: 20)),
      'id',
    );
    expect(result.$2, ['resourceChanged']);
    expect(
      state.latest!['at'],
      now.add(const Duration(seconds: 10)).millisecondsSinceEpoch,
    );
    expect(
      normalizedMonitorStatus('secret token', deployments: false),
      'unknown',
    );
    expect(
      normalizedMonitorStatus('cancelled-by-user', deployments: true),
      'cancelled',
    );
  });
  test('Legacy disabled alert groups stay disabled', () {
    final json = MonitorConfig(alerts: {'down'}).toJson()
      ..remove('eventSchema');
    expect(MonitorConfig.fromJson(json).alerts, {'down'});
    json['alerts'] = ['deployment', 'resource'];
    expect(
      MonitorConfig.fromJson(json).alerts,
      containsAll([
        'deploymentStarted',
        'deploymentSucceeded',
        'resourceChanged',
      ]),
    );
  });
  test(
    'Fast cancelled probes cannot commit and SSH is excluded from rapid checks',
    () async {
      final secrets = MemorySecretStore();
      final pending = Completer<HealthCheck>();
      var calls = 0;
      final service = MonitorService(
        secrets: secrets,
        bridge: FakeMonitorBridge(),
        probe: (_) {
          calls++;
          return pending.future;
        },
      );
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
      final cancellation = MonitorCancellation();
      final run = service.run(fast: true, cancellation: cancellation);
      // Flush asynchronous fingerprinting without relying on a fixed delay.
      while (calls == 0) {
        await Future<void>.delayed(Duration.zero);
      }
      cancellation.cancel();
      pending.complete(const HealthCheck(Health.up));
      await run;
      expect(await service.history(), isEmpty);
      final ssh = coolify.toJson()
        ..['type'] = 'ssh'
        ..['host'] = 'localhost'
        ..['username'] = 'test'
        ..['password'] = 'test';
      secrets.values[SecureWorkspaceStore.storageKey] = jsonEncode({
        'version': 3,
        'workspaces': [
          {
            'instances': [ssh],
          },
        ],
      });
      await service.run(fast: true);
      expect(calls, 1);
    },
  );
  testWidgets(
    'Foreground monitoring pauses on lifecycle changes and stops on lock disposal',
    (tester) async {
      final service = LoopService();
      await service.secrets.write(
        MonitorService.configKey,
        jsonEncode(MonitorConfig(ids: {coolify.id}).toJson()),
      );
      final controller = DockController(
        MemoryWorkspaceStore()
          ..data = [
            DockWorkspace(id: 'w', name: 'Test', instances: [coolify]),
          ],
      );
      await controller.initialize();
      await tester.pumpWidget(
        MaterialApp(
          home: ForegroundMonitor(
            controller: controller,
            service: service,
            child: const SizedBox(),
          ),
        ),
      );
      await tester.pump();
      expect(service.calls, 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(minutes: 1));
      expect(service.calls, 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(service.calls, 2);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(minutes: 1));
      expect(service.calls, 2);
      controller.dispose();
    },
  );
}
