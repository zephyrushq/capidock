import 'dart:async';
import 'dart:convert';

import 'package:capidock/core/app_theme.dart';
import 'package:capidock/features/instances/domain/server_instance.dart';
import 'package:capidock/features/monitoring/monitor_service.dart';
import 'package:capidock/features/monitoring/monitor_state.dart';
import 'package:capidock/features/workspaces/domain/dock_controller.dart';
import 'package:capidock/features/workspaces/presentation/workspace_overview.dart';
import 'package:capidock/l10n/locale_controller.dart';
import 'package:capidock/l10n/localization.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'monitor_support.dart';
import 'test_support.dart';
import 'widget_test.dart' as helpers;

class OverviewService extends MonitorService {
  MonitorConfig settings = MonitorConfig(
    ids: {'test-production', 'test-staging'},
  );
  Map<String, MonitorState> states = {};
  bool fail = false;
  Completer<(MonitorConfig, Map<String, MonitorState>)>? pending;

  @override
  Future<(MonitorConfig, Map<String, MonitorState>)> workspaceSnapshot(
    List<ServerInstance> instances,
  ) async {
    if (fail) throw StateError('Unavailable');
    if (pending != null) return pending!.future;
    return (
      settings,
      {
        for (final instance in instances)
          if (states.containsKey(instance.id))
            instance.id: states[instance.id]!,
      },
    );
  }
}

Future<DockController> controller() async {
  final value = DockController(
    MemoryWorkspaceStore()..data = fixtureWorkspaces(),
  );
  await value.initialize();
  return value;
}

Future<void> render(
  WidgetTester tester,
  DockController controller,
  OverviewService service, {
  Locale locale = const Locale('en', 'GB'),
  ValueChanged<String>? onSelect,
}) => tester.pumpWidget(
  MaterialApp(
    theme: buildTheme(),
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(
      body: WorkspaceOverview(
        controller: controller,
        service: service,
        onSelect: onSelect ?? (_) {},
        onMonitoring: () {},
      ),
    ),
  ),
);

void main() {
  test('Snapshot excludes disabled, foreign and edited instances', () async {
    final secrets = MemorySecretStore();
    final service = MonitorService(
      secrets: secrets,
      bridge: FakeMonitorBridge(),
    );
    final instance = ServerInstance.fromJson({
      ...fixtureInstances.first.toJson(),
      'password': 'fixture-password',
    });
    final fingerprint = (await Sha256().hash(
      utf8.encode(jsonEncode(instance.toJson())),
    )).bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    secrets.values[MonitorService.configKey] = jsonEncode(
      MonitorConfig(ids: {instance.id, 'foreign'}).toJson(),
    );
    secrets.values[MonitorService.historyKey] = jsonEncode({
      instance.id: MonitorState(fingerprint: fingerprint).toJson(),
      'foreign': MonitorState(fingerprint: fingerprint).toJson(),
    });
    expect((await service.workspaceSnapshot([instance])).$2.keys, [
      instance.id,
    ]);
    final edited = ServerInstance.fromJson({
      ...instance.toJson(),
      'password': 'changed',
    });
    expect((await service.workspaceSnapshot([edited])).$2, isEmpty);
    expect(
      (await service.workspaceSnapshot([fixtureInstances.first])).$2,
      isEmpty,
    );
    secrets.values[MonitorService.configKey] = jsonEncode(
      MonitorConfig().toJson(),
    );
    expect((await service.workspaceSnapshot([instance])).$2, isEmpty);
  });

  testWidgets(
    'Overview is the initial destination; cards and return action navigate',
    (tester) async {
      final dock = await helpers.launch(tester, overview: true);
      expect(find.byKey(const ValueKey('workspace-overview')), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('overview-instance-test-production')),
      );
      await tester.pumpAndSettle();
      expect(dock.showingOverview, isFalse);
      expect(find.text('Configurar acesso'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('open-workspace-overview')));
      await tester.pumpAndSettle();
      expect(dock.showingOverview, isTrue);
      await tester.tap(find.byTooltip('Abrir instâncias'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('channel-test-coolify')));
      await tester.pumpAndSettle();
      expect(dock.showingOverview, isFalse);
      expect(dock.selected!.id, 'test-coolify');
      await tester.tap(find.byTooltip('Abrir instâncias'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('sidebar-workspace-overview')),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('workspace-overview')), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'Cards distinguish fresh, stale and disabled checks; events are ordered and open instances',
    (tester) async {
      final dock = await controller();
      final now = DateTime.now().millisecondsSinceEpoch;
      final service = OverviewService()
        ..states = {
          'test-production': MonitorState(
            lastObservation: {'at': now, 'health': 'authentication'},
            events: [
              {'at': now - 1000, 'kind': 'deploymentStarted'},
              {'at': now, 'kind': 'deploymentSucceeded'},
              {
                'at': now - const Duration(days: 31).inMilliseconds,
                'kind': 'identity',
              },
            ],
          ),
          'test-staging': MonitorState(
            lastObservation: {
              'at': now - const Duration(hours: 2).inMilliseconds,
              'health': 'up',
            },
          ),
          'foreign': MonitorState(
            events: [
              {'at': now, 'kind': 'resource'},
            ],
          ),
        };
      String? selected;
      await render(tester, dock, service, onSelect: (id) => selected = id);
      await tester.pumpAndSettle();
      expect(find.text('1 needs attention'), findsOneWidget);
      expect(find.text('1 outdated'), findsOneWidget);
      expect(find.text('Monitoring off'), findsOneWidget);
      expect(find.text('Waiting for a fresh check'), findsOneWidget);
      final context = tester.element(find.byType(WorkspaceOverview));
      final strings = context.l10n;
      await tester.scrollUntilVisible(
        find.text(strings.monitorDeploymentSucceeded),
        300,
      );
      expect(find.text(strings.monitorIdentity), findsNothing);
      expect(find.text(strings.monitorResourceUnhealthy), findsNothing);
      expect(
        tester.getTopLeft(find.text(strings.monitorDeploymentSucceeded)).dy,
        lessThan(
          tester.getTopLeft(find.text(strings.monitorDeploymentStarted)).dy,
        ),
      );
      await tester.tap(find.text(strings.monitorDeploymentSucceeded));
      expect(selected, 'test-production');
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('Failed refresh clears cached states and supports retry', (
    tester,
  ) async {
    final dock = await controller();
    final service = OverviewService();
    await render(tester, dock, service);
    await tester.pumpAndSettle();
    expect(find.text('No checks yet'), findsNWidgets(2));
    service.fail = true;
    await tester.tap(find.text('Refresh'));
    await tester.pumpAndSettle();
    expect(
      find.text('Could not load monitoring data. Refresh to try again.'),
      findsOneWidget,
    );
    expect(find.text('Monitoring off'), findsNothing);
    service.fail = false;
    await tester.tap(find.text('Refresh'));
    await tester.pumpAndSettle();
    expect(find.text('No checks yet'), findsNWidgets(2));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Workspace changes discard pending reads and previous events', (
    tester,
  ) async {
    final dock = await controller();
    final service = OverviewService()..pending = Completer();
    await render(tester, dock, service);
    await tester.pump();
    final oldRead = service.pending!;
    service.pending = null;
    await dock.createWorkspace('Other workspace');
    oldRead.complete((
      service.settings,
      {
        'test-production': MonitorState(
          events: [
            {
              'at': DateTime.now().millisecondsSinceEpoch,
              'kind': 'deploymentSucceeded',
            },
          ],
        ),
      },
    ));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('overview-instance-test-production')),
      findsNothing,
    );
    final strings = tester.element(find.byType(WorkspaceOverview)).l10n;
    expect(find.text(strings.monitorDeploymentSucceeded), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Recent events are bounded to the latest twenty', (tester) async {
    final dock = await controller();
    final now = DateTime.now().millisecondsSinceEpoch;
    final service = OverviewService()
      ..states = {
        'test-production': MonitorState(
          events: [
            for (var index = 0; index < 25; index++)
              {
                'at': now - index * 1000,
                'kind': index < 20 ? 'deploymentSucceeded' : 'identity',
              },
          ],
        ),
      };
    await render(tester, dock, service);
    await tester.pumpAndSettle();
    final strings = tester.element(find.byType(WorkspaceOverview)).l10n;
    await tester.drag(find.byType(ListView), const Offset(0, -10000));
    await tester.pumpAndSettle();
    expect(find.text(strings.monitorIdentity), findsNothing);
    expect(find.text(strings.monitorDeploymentSucceeded), findsWidgets);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Late snapshots cannot repopulate data while backgrounded', (
    tester,
  ) async {
    final dock = await controller();
    final service = OverviewService()..pending = Completer();
    await render(tester, dock, service);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    service.pending!.complete((
      service.settings,
      {
        'test-production': MonitorState(
          events: [
            {
              'at': DateTime.now().millisecondsSinceEpoch,
              'kind': 'deploymentSucceeded',
            },
          ],
        ),
      },
    ));
    await tester.pumpAndSettle();
    final strings = tester.element(find.byType(WorkspaceOverview)).l10n;
    expect(find.text(strings.monitorDeploymentSucceeded), findsNothing);
    await tester.pumpWidget(const SizedBox());
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  testWidgets('Visible overview picks up newly recorded observations', (
    tester,
  ) async {
    final dock = await controller();
    final service = OverviewService();
    await render(tester, dock, service);
    await tester.pumpAndSettle();
    final strings = tester.element(find.byType(WorkspaceOverview)).l10n;
    expect(find.text(strings.monitorUp), findsNothing);
    service.states = {
      'test-production': MonitorState(
        lastObservation: {
          'at': DateTime.now().millisecondsSinceEpoch,
          'health': 'up',
        },
      ),
    };
    await tester.pump(const Duration(seconds: 15));
    await tester.pumpAndSettle();
    expect(find.text(strings.monitorUp), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  for (final language in AppLanguage.values) {
    for (final width in [320.0, 1024.0]) {
      testWidgets(
        'Overview adapts to ${language.locale} at $width with large text',
        (tester) async {
          tester.view.physicalSize = Size(width, 760);
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = 1.8;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final dock = await controller();
          final now = DateTime.now().millisecondsSinceEpoch;
          final service = OverviewService()
            ..states = {
              'test-production': MonitorState(
                lastObservation: {'at': now, 'health': 'authentication'},
                events: [
                  {'at': now, 'kind': 'deploymentSucceeded'},
                ],
              ),
              'test-staging': MonitorState(
                lastObservation: {
                  'at': now - const Duration(hours: 2).inMilliseconds,
                  'health': 'up',
                },
              ),
            };
          await render(tester, dock, service, locale: language.locale);
          await tester.pumpAndSettle();
          await tester.drag(find.byType(ListView), const Offset(0, -1600));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }
}
