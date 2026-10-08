import 'dart:convert';

import 'package:capidock/core/app_theme.dart';
import 'package:capidock/features/connections/data/coolify_client.dart';
import 'package:capidock/features/coolify/data/coolify_catalog.dart';
import 'package:capidock/features/coolify/data/coolify_session.dart';
import 'package:capidock/features/coolify/presentation/coolify_cards.dart';
import 'package:capidock/features/coolify/presentation/coolify_hierarchy_page.dart';
import 'package:capidock/features/coolify/presentation/coolify_workspace_page.dart';
import 'package:capidock/features/instances/domain/server_instance.dart';
import 'package:capidock/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const instance = ServerInstance(
  id: 'fixture',
  name: 'Readonly fixture',
  type: InstanceType.coolify,
  host: 'https://fixture.example.com',
  port: 443,
  apiToken: 'fixture',
);
Widget app(Widget child, [Locale locale = const Locale('en', 'GB')]) =>
    MaterialApp(
      theme: buildTheme(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    );
Future<void> read(WidgetTester tester, Future<void> Function() action) async {
  await tester.runAsync(() async {
    await action();
    await tester.pump();
    await Future<void>.delayed(const Duration(milliseconds: 30));
  });
  await tester.pumpAndSettle();
}

Future<void> tapCard(WidgetTester tester, String name) async {
  final finder = find.widgetWithText(CoolifyResourceCard, name);
  await Scrollable.ensureVisible(tester.element(finder), alignment: .5);
  await tester.pumpAndSettle();
  await read(tester, () => tester.tap(finder));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CoolifyCatalog catalog;
  setUpAll(() async {
    catalog = await CoolifyCatalog.load();
  });
  test('Environment relations preserve database types and discard duplicate resources', () {
    final resources = coolifyEnvironmentResources({
      'applications': [
        {'uuid': 'a', 'name': 'Site'},
      ],
      'postgresqls': [
        {'uuid': 'db', 'name': 'PostgreSQL'},
      ],
      'redis': [
        {'uuid': 'redis', 'name': 'Redis'},
      ],
      'services': [
        {'uuid': 's', 'name': 'Stack'},
      ],
      'resources': [
        {'uuid': 'a', 'type': 'application'},
      ],
    });
    expect(resources.length, 4);
    expect(coolifyKind(resources[1]), 'databases');
    expect(coolifyKind(resources[3]), 'services');
  });
  testWidgets(
    'Project opens environments and their typed resource cards without JSON or writes',
    (tester) async {
      final calls = <http.Request>[];
      final session = CoolifySession(
        instance,
        createClient: () => CoolifyClient(
          client: MockClient((r) async {
            calls.add(r);
            final data = switch (r.url.path) {
              '/api/v1/projects/project-id' => {
                'name': 'Example project',
                'description': 'Production services',
              },
              '/api/v1/projects/project-id/environments' => [
                {'uuid': 'env-id', 'name': 'production'},
              ],
              '/api/v1/projects/project-id/env-id' => {
                'name': 'production',
                'applications': [
                  {
                    'uuid': 'app-id',
                    'name': 'Web application',
                    'status': 'running:healthy',
                    'fqdn': 'https://app.example.com',
                  },
                ],
                'postgresqls': [
                  {
                    'uuid': 'db-id',
                    'name': 'PostgreSQL',
                    'status': 'running:healthy',
                  },
                ],
                'redis': [
                  {
                    'uuid': 'redis-id',
                    'name': 'Redis',
                    'status': 'running:healthy',
                  },
                ],
                'services': [],
              },
              '/api/v1/applications/app-id' => {
                'name': 'Web application',
                'status': 'running:healthy',
                'fqdn': 'https://app.example.com',
                'git_branch': 'main',
              },
              _ => <String, dynamic>{},
            };
            return http.Response(jsonEncode(data), 200);
          }),
        ),
      );
      addTearDown(session.dispose);
      await read(
        tester,
        () => tester.pumpWidget(
          app(
            CoolifyHierarchyPage(
              session: session,
              catalog: catalog,
              kind: 'projects',
              uuid: 'project-id',
              name: 'Example project',
              onTerminal: () {},
            ),
          ),
        ),
      );
      expect(
        find.widgetWithText(CoolifyResourceCard, 'production'),
        findsOneWidget,
      );
      expect(calls.any((r) => r.url.path.endsWith('/envs')), isFalse);
      expect(find.text('Details'), findsNothing);
      await tapCard(tester, 'production');
      expect(
        find.widgetWithText(CoolifyResourceCard, 'Web application'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(CoolifyResourceCard, 'PostgreSQL'),
        findsOneWidget,
      );
      expect(find.widgetWithText(CoolifyResourceCard, 'Redis'), findsOneWidget);
      await tapCard(tester, 'Web application');
      expect(find.text('https://app.example.com'), findsOneWidget);
      expect(find.text('Running'), findsOneWidget);
      expect(find.text('Details'), findsNothing);
      expect(find.textContaining('"uuid"'), findsNothing);
      expect(calls.every((r) => r.method == 'GET'), isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'Service component details and logs use their own nested endpoints',
    (tester) async {
      final calls = <http.Request>[];
      final session = CoolifySession(
        instance,
        createClient: () => CoolifyClient(
          client: MockClient((r) async {
            calls.add(r);
            final Object data = r.url.path.endsWith('/applications')
                ? [
                    {
                      'uuid': 'component-id',
                      'name': 'Worker',
                      'status': 'running:healthy',
                    },
                  ]
                : r.url.path.endsWith('/databases')
                ? []
                : r.url.path.endsWith('/logs')
                ? {'logs': 'private runtime output'}
                : {'name': 'Stack', 'status': 'running:healthy'};
            return http.Response(jsonEncode(data), 200);
          }),
        ),
      );
      addTearDown(session.dispose);
      await read(
        tester,
        () => tester.pumpWidget(
          app(
            CoolifyResourcePage(
              session: session,
              catalog: catalog,
              collection: 'services',
              uuid: 'stack-id',
              name: 'Stack',
              onTerminal: () {},
            ),
          ),
        ),
      );
      await tapCard(tester, 'Worker');
      expect(
        calls.last.url.path,
        '/api/v1/services/stack-id/applications/component-id',
      );
      await read(tester, () => tester.tap(find.text('Logs')));
      expect(
        calls.last.url.path,
        '/api/v1/services/stack-id/applications/component-id/logs',
      );
      expect(find.text('private runtime output'), findsNothing);
      expect(calls.every((r) => r.method == 'GET'), isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'Shared variables use the selected environment and indicate values omitted by a readonly token',
    (tester) async {
      final calls = <http.Request>[];
      final session = CoolifySession(
        instance,
        createClient: () => CoolifyClient(
          client: MockClient((r) async {
            calls.add(r);
            return http.Response(
              jsonEncode(
                r.url.path.endsWith('/envs')
                    ? [
                        {'id': 4, 'key': 'SHARED_TOKEN'},
                      ]
                    : {'name': 'production', 'applications': []},
              ),
              200,
            );
          }),
        ),
      );
      addTearDown(session.dispose);
      await read(
        tester,
        () => tester.pumpWidget(
          app(
            CoolifyHierarchyPage(
              session: session,
              catalog: catalog,
              kind: 'environments',
              uuid: 'env-id',
              projectUuid: 'project-id',
              name: 'production',
              onTerminal: () {},
            ),
          ),
        ),
      );
      await read(tester, () => tester.tap(find.text('Shared variables')));
      expect(
        calls.last.url.path,
        '/api/v1/projects/project-id/environments/env-id/envs',
      );
      expect(find.text('SHARED_TOKEN'), findsOneWidget);
      expect(
        find.text('Value protected by token permissions.'),
        findsOneWidget,
      );
      expect(calls.every((r) => r.method == 'GET'), isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final locale in AppLocalizations.supportedLocales.where(
    (l) => l.countryCode != null,
  )) {
    testWidgets(
      'Environment cards support $locale on narrow screens and large text',
      (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final session = CoolifySession(
          instance,
          createClient: () => CoolifyClient(
            client: MockClient(
              (_) async => http.Response(
                '{"name":"production","description":"An environment","applications":[{"uuid":"app","name":"A long application name","status":"running:healthy","fqdn":"https://app.example.com"}]}',
                200,
              ),
            ),
          ),
        );
        addTearDown(session.dispose);
        await read(
          tester,
          () => tester.pumpWidget(
            app(
              CoolifyHierarchyPage(
                session: session,
                catalog: catalog,
                kind: 'environments',
                uuid: 'env-id',
                projectUuid: 'project-id',
                projectName: 'Example',
                name: 'production',
                onTerminal: () {},
              ),
              locale,
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        session.didChangeAppLifecycleState(AppLifecycleState.paused);
        await tester.pumpAndSettle();
        expect(
          find.widgetWithText(CoolifyResourceCard, 'A long application name'),
          findsNothing,
        );
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
