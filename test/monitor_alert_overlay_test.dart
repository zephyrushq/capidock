import 'dart:async';
import 'dart:convert';

import 'package:capidock/core/app_theme.dart';
import 'package:capidock/features/monitoring/monitor_alert_overlay.dart';
import 'package:capidock/features/monitoring/monitor_service.dart';
import 'package:capidock/features/monitoring/monitor_state.dart';
import 'package:capidock/features/workspaces/data/workspace_store.dart';
import 'package:capidock/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'connections_test.dart' show coolify;
import 'monitor_support.dart';
import 'test_support.dart';

class DeniedNotificationsBridge extends FakeMonitorBridge {
  @override
  Future<void> notify(int id, String body) async =>
      throw StateError('Unavailable');
}

Widget host(
  Stream<String> events, {
  Locale locale = const Locale('en', 'GB'),
  GlobalKey<NavigatorState>? navigator,
}) => MaterialApp(
  navigatorKey: navigator,
  theme: buildTheme(),
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (_, child) => MonitorAlertOverlay(events: events, child: child!),
  home: const Scaffold(body: Text('Home')),
);

void main() {
  testWidgets('Notices stay above routes, deduplicate, close and expire', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final events = StreamController<String>.broadcast();
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(host(events.stream, navigator: navigator));
    navigator.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Other screen')),
      ),
    );
    await tester.pumpAndSettle();
    events.add('deploymentStarted');
    events.add('deploymentStarted');
    events.add('deploymentSucceeded');
    await tester.pump();
    expect(find.text('Other screen'), findsOneWidget);
    await tester.pump();
    expect(find.text('Deployment started'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('monitor-floating-alert')),
      findsOneWidget,
    );
    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pump();
    expect(find.text('Deployment completed'), findsOneWidget);
    await tester.pump(const Duration(seconds: 8));
    expect(find.byKey(const ValueKey('monitor-floating-alert')), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await events.close();
    semantics.dispose();
  });
  testWidgets(
    'Pause, clear and lock disposal discard events without replay or raw data',
    (tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      final events = StreamController<String>.broadcast();
      await tester.pumpWidget(host(events.stream));
      events.add('down');
      events.add('resource');
      events.add('untrusted-server-secret');
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      events.add('deployment');
      await tester.pump();
      // Paused apps do not render frames. Verify clearing on resume.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(
        find.byKey(const ValueKey('monitor-floating-alert')),
        findsNothing,
      );
      events.add('identity');
      events.add('clear');
      await tester.pump();
      expect(
        find.byKey(const ValueKey('monitor-floating-alert')),
        findsNothing,
      );
      events.add('deployment');
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      events.add('resource');
      await tester.pump(const Duration(seconds: 10));
      expect(tester.takeException(), isNull);
      await events.close();
    },
  );
  for (final locale in [
    const Locale('en', 'GB'),
    const Locale('en', 'US'),
    const Locale('pt', 'PT'),
    const Locale('pt', 'BR'),
    const Locale('es', 'ES'),
  ]) {
    testWidgets('$locale notice fits small screens with larger text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      final events = StreamController<String>.broadcast();
      await tester.pumpWidget(host(events.stream, locale: locale));
      events.add('deploymentSucceeded');
      await tester.pump();
      expect(
        find.byKey(const ValueKey('monitor-floating-alert')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await events.close();
    });
  }
  test(
    'Committed alerts reach the UI even if Android notification delivery fails',
    () async {
      final secrets = MemorySecretStore();
      final bridge = DeniedNotificationsBridge();
      var check = const HealthCheck(Health.up, deployments: {'d': 'queued'});
      final service = MonitorService(
        secrets: secrets,
        bridge: bridge,
        probe: (_) async => check,
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
      await service.run();
      expect(bridge.alerts, isEmpty);
      check = const HealthCheck(Health.up, deployments: {'d': 'in_progress'});
      await service.run();
      expect(bridge.alerts, ['deploymentStarted']);
      await service.run();
      expect(bridge.alerts, ['deploymentStarted']);
      expect(bridge.messages, isEmpty);
      expect(
        (await service.history())[coolify.id]!.events.single['kind'],
        'deploymentStarted',
      );
    },
  );
}
