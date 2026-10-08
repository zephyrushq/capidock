import 'dart:async';
import 'dart:convert';

import 'package:capidock/features/connections/data/coolify_client.dart';
import 'package:capidock/features/coolify/data/coolify_catalog.dart';
import 'package:capidock/features/coolify/data/coolify_session.dart';
import 'package:capidock/features/coolify/presentation/coolify_operation_page.dart';
import 'package:capidock/features/coolify/presentation/coolify_workspace_page.dart';
import 'package:capidock/features/instances/domain/server_instance.dart';
import 'package:capidock/l10n/localization.dart';
import 'package:capidock/core/app_theme.dart';
import 'package:capidock/features/instances/presentation/instance_editor.dart';
import 'package:capidock/features/workspaces/domain/dock_controller.dart';
import 'package:capidock/features/workspaces/domain/dock_workspace.dart';

import 'test_support.dart';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const instance = ServerInstance(
  id: 'coolify',
  name: 'Own Coolify',
  type: InstanceType.coolify,
  host: 'https://coolify.example.com:8443',
  port: 8443,
  apiToken: 'secret-token',
);

Widget app(Widget page) => MaterialApp(
  theme: buildTheme(),
  locale: const Locale('en', 'GB'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: page,
);
Finder visibleText(String text) => find.byWidgetPredicate(
  (w) =>
      w is Text && (w.data?.contains(text) ?? false) ||
      w is SelectableText && (w.data?.contains(text) ?? false),
);
Future<void> execute(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
  await tester.scrollUntilVisible(
    find.byKey(const ValueKey('coolify-execute')),
    500,
    maxScrolls: 150,
    scrollable: find
        .descendant(
          of: find.byType(ListView).first,
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await Scrollable.ensureVisible(
    tester.element(find.byKey(const ValueKey('coolify-execute'))),
    alignment: .5,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('coolify-execute')));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CoolifyCatalog catalog;
  setUpAll(() async => catalog = await CoolifyCatalog.load());

  test(
    'All 291 pinned API operations have usable paths and resolved schemas',
    () {
      expect(catalog.operations.length, 291);
      expect(
        catalog.operations.map((o) => '${o.method} ${o.path}').toSet().length,
        291,
      );
      for (final op in catalog.operations) {
        final paths = {
          for (final p in op.parameters.where((p) => p['in'] == 'path'))
            p['name'] as String: 'my-id',
        };
        expect(op.resolvePath(paths), isNot(contains('{')), reason: op.id);
        expect(
          jsonEncode(op.schema),
          isNot(contains(r'"$ref"')),
          reason: op.id,
        );
      }
      expect(catalog.operations.where((o) => o.upload).length, 2);
      expect(
        catalog.operations.any((o) => o.path.contains('/terminal')),
        isFalse,
      );
    },
  );

  test('Nested secrets and environment values are masked without changing responses', () {
    final data = {
      'name': 'App',
      'value': 'env-secret',
      'nested': {'postgres_password': 'db-secret', 'api_token': 'token'},
      'items': [
        {'private_key': 'key'},
      ],
    };
    final visible = jsonEncode(redactCoolify(data));
    expect(visible, contains('App'));
    for (final value in ['env-secret', 'db-secret', 'token"', 'key"']) {
      expect(visible, isNot(contains(':"$value')));
    }
    expect(data['value'], 'env-secret');
  });

  test(
    'POST/PATCH/DELETE use correct paths, headers, bodies and all 2xx statuses',
    () async {
      final calls = <http.Request>[];
      final client = CoolifyClient(
        client: MockClient((request) async {
          calls.add(request);
          expect(request.followRedirects, isFalse);
          expect(request.headers['Authorization'], 'Bearer secret-token');
          expect(request.url.host, 'coolify.example.com');
          return http.Response(
            request.method == 'DELETE' ? '' : '{"uuid":"job"}',
            request.method == 'DELETE'
                ? 204
                : request.method == 'PATCH'
                ? 201
                : 202,
          );
        }),
      );
      await client.request(
        instance,
        'PATCH',
        '/applications/app-id/envs',
        body: {'key': 'TOKEN', 'value': 'new-secret'},
      );
      await client.request(
        instance,
        'POST',
        '/deploy',
        query: {'uuid': 'app-id', 'force': 'true'},
      );
      expect(
        await client.request(
          instance,
          'DELETE',
          '/applications/app-id/envs/env-id',
        ),
        isNull,
      );
      expect(jsonDecode(calls[0].body), {
        'key': 'TOKEN',
        'value': 'new-secret',
      });
      expect(calls[1].url.queryParameters, {'uuid': 'app-id', 'force': 'true'});
      expect(
        calls.every((r) => !r.url.toString().contains('secret-token')),
        isTrue,
      );
      client.close();
    },
  );

  test(
    'Multipart database backup upload streams the file and preserves upload_id',
    () async {
      final client = CoolifyClient(
        client: MockClient((request) async {
          expect(
            request.headers['content-type'],
            startsWith('multipart/form-data; boundary='),
          );
          expect(request.body, contains('name="upload_id"'));
          expect(request.body, contains('name="file"; filename="backup.sql"'));
          expect(request.body, contains('SELECT 1;'));
          return http.Response('{"upload_id":"import-id"}', 201);
        }),
      );
      expect(
        await client.request(
          instance,
          'POST',
          '/databases/db-id/imports/uploads',
          body: {'upload_id': 'import-id'},
          file: XFile.fromData(utf8.encode('SELECT 1;'), path: 'backup.sql'),
        ),
        {'upload_id': 'import-id'},
      );
      client.close();
    },
  );

  test(
    'Writes never follow redirects or echo server secrets in validation errors',
    () async {
      for (final status in [302, 403, 409, 422]) {
        final client = CoolifyClient(
          client: MockClient((request) async {
            expect(request.followRedirects, isFalse);
            return http.Response(
              'remote-environment-secret',
              status,
              headers: {'location': 'http://attacker.example.com'},
            );
          }),
        );
        await expectLater(
          client.request(
            instance,
            'PATCH',
            '/applications/id',
            body: {'name': 'Updated'},
          ),
          throwsA(
            isA<CoolifyException>().having(
              (e) => e.message,
              'sanitised message',
              isNot(contains('remote-environment-secret')),
            ),
          ),
        );
        client.close();
      }
    },
  );

  test(
    'Oversized responses, HTML and external API paths are refused',
    () async {
      for (final body in ['<html>login</html>', 'x' * (4 * 1024 * 1024 + 1)]) {
        final client = CoolifyClient(
          client: MockClient((_) async => http.Response(body, 200)),
        );
        await expectLater(
          client.request(instance, 'GET', '/resources'),
          throwsA(isA<CoolifyException>()),
        );
        client.close();
      }
      final client = CoolifyClient(
        client: MockClient((_) async => throw StateError('Must not send')),
      );
      for (final path in [
        '//attacker.example.com',
        '/../secrets',
        'https://attacker.example.com',
        '/resources?token=secret',
      ]) {
        await expectLater(
          client.request(instance, 'GET', path),
          throwsArgumentError,
        );
      }
      client.close();
    },
  );

  test('A second mutation is blocked while a write is pending', () async {
    final response = Completer<http.Response>();
    var writes = 0;
    final session = CoolifySession(
      instance,
      createClient: () => CoolifyClient(
        client: MockClient((_) {
          writes++;
          return response.future;
        }),
      ),
    );
    final first = session.request('POST', '/applications/id/restart');
    await expectLater(
      session.request('DELETE', '/applications/id'),
      throwsA(
        isA<CoolifyException>().having(
          (e) => e.message,
          'message',
          'coolifyConflict',
        ),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(writes, 1);
    response.complete(http.Response('{}', 200));
    await first;
    session.dispose();
  });

  test('Backgrounding cancels results and never retries a mutation', () async {
    final response = Completer<http.Response>();
    var writes = 0;
    final session = CoolifySession(
      instance,
      createClient: () => CoolifyClient(
        client: MockClient((_) {
          writes++;
          return response.future;
        }),
      ),
    );
    final pending = session.request('POST', '/applications/id/restart');
    final expectation = expectLater(
      pending,
      throwsA(
        isA<CoolifyException>().having(
          (e) => e.message,
          'message',
          'coolifyCancelled',
        ),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    session.didChangeAppLifecycleState(AppLifecycleState.paused);
    response.complete(http.Response('{}', 200));
    await expectation;
    session.didChangeAppLifecycleState(AppLifecycleState.resumed);
    expect(writes, 1);
    session.dispose();
  });

  testWidgets(
    'Environment editing needs confirmation and sends only required identity and changed value',
    (tester) async {
      final calls = <http.Request>[];
      final session = CoolifySession(
        instance,
        createClient: () => CoolifyClient(
          client: MockClient((r) async {
            calls.add(r);
            return http.Response('{"key":"TOKEN","value":"new-secret"}', 201);
          }),
        ),
      );
      addTearDown(session.dispose);
      await tester.pumpWidget(
        app(
          CoolifyOperationPage(
            session: session,
            operation: catalog.find('PATCH', '/applications/{uuid}/envs')!,
            pathValues: {'uuid': 'app-id'},
            initialValues: {
              'key': 'TOKEN',
              'value': 'old-secret',
              'is_preview': false,
              'is_literal': false,
            },
            target: 'My app',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('coolify-field-body:value')),
        'new-secret',
      );
      await execute(tester);
      expect(calls, isEmpty);
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
      await execute(tester);
      expect(visibleText('new-secret'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('coolify-confirm-action')));
      await tester.pumpAndSettle();
      expect(calls.length, 1);
      expect(jsonDecode(calls.single.body), {
        'key': 'TOKEN',
        'value': 'new-secret',
      });
      expect(visibleText('new-secret'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Deletion requires exact target and cannot send after cancellation',
    (tester) async {
      var writes = 0;
      final session = CoolifySession(
        instance,
        createClient: () => CoolifyClient(
          client: MockClient((_) async {
            writes++;
            return http.Response('', 204);
          }),
        ),
      );
      addTearDown(session.dispose);
      await tester.pumpWidget(
        app(
          CoolifyOperationPage(
            session: session,
            operation: catalog.find('DELETE', '/applications/{uuid}')!,
            pathValues: {'uuid': 'app-id'},
            target: 'My app',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await execute(tester);
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('coolify-confirm-action')),
            )
            .onPressed,
        isNull,
      );
      await tester.enterText(
        find.byKey(const ValueKey('coolify-confirm-target')),
        'wrong',
      );
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const ValueKey('coolify-confirm-action')),
            )
            .onPressed,
        isNull,
      );
      await tester.enterText(
        find.byKey(const ValueKey('coolify-confirm-target')),
        'My app',
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('coolify-confirm-action')));
      await tester.pumpAndSettle();
      expect(writes, 1);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Only edited settings and the storage UUID are sent by PATCH', (
    tester,
  ) async {
    http.Request? sent;
    final session = CoolifySession(
      instance,
      createClient: () => CoolifyClient(
        client: MockClient((r) async {
          sent = r;
          return http.Response('{}', 200);
        }),
      ),
    );
    addTearDown(session.dispose);
    await tester.pumpWidget(
      app(
        CoolifyOperationPage(
          session: session,
          operation: catalog.find('PATCH', '/applications/{uuid}/storages')!,
          pathValues: {'uuid': 'app-id'},
          initialValues: {
            'uuid': 'storage-id',
            'id': 12,
            'type': 'persistent',
            'name': 'Original',
            'mount_path': '/data',
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('coolify-field-body:name')),
      300,
      scrollable: find
          .descendant(
            of: find.byType(ListView).first,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.enterText(
      find.byKey(const ValueKey('coolify-field-body:name')),
      'Renamed',
    );
    await execute(tester);
    await tester.tap(find.byKey(const ValueKey('coolify-confirm-action')));
    await tester.pumpAndSettle();
    expect(jsonDecode(sent!.body), {
      'uuid': 'storage-id',
      'type': 'persistent',
      'name': 'Renamed',
    });
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'Resource environment shows real values only after explicit reveal and clears in background',
    (tester) async {
      final paths = <String>[];
      final session = CoolifySession(
        instance,
        createClient: () => CoolifyClient(
          client: MockClient((r) async {
            paths.add(r.url.path);
            return http.Response(
              r.url.path.endsWith('/envs')
                  ? '[{"uuid":"env-id","key":"TOKEN","value":"remote-secret"}]'
                  : '{"uuid":"app-id","name":"Actual app","status":"running:healthy"}',
              200,
            );
          }),
        ),
      );
      addTearDown(session.dispose);
      await tester.runAsync(() async {
        await tester.pumpWidget(
          app(
            CoolifyResourcePage(
              session: session,
              catalog: catalog,
              collection: 'applications',
              uuid: 'app-id',
              name: 'Actual app',
              onTerminal: () {},
            ),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
      });
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.text('Environment variables'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      });
      await tester.pumpAndSettle();
      expect(paths.last, '/api/v1/applications/app-id/envs');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(visibleText('remote-secret'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('Show value'),
        300,
        scrollable: find
            .descendant(
              of: find.byType(ListView).first,
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await Scrollable.ensureVisible(
        tester.element(find.text('Show value')),
        alignment: .5,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show value'));
      await tester.pumpAndSettle();
      expect(visibleText('remote-secret'), findsOneWidget);
      session.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pumpAndSettle();
      expect(visibleText('remote-secret'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final locale in [
    const Locale('en', 'GB'),
    const Locale('en', 'US'),
    const Locale('pt', 'PT'),
    const Locale('pt', 'BR'),
    const Locale('es', 'ES'),
  ]) {
    testWidgets(
      'Coolify layout supports ${locale.toLanguageTag()} on a small screen with large text',
      (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.runAsync(() async {
          await tester.pumpWidget(
            MaterialApp(
              theme: buildTheme(),
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: Scaffold(
                body: CoolifyWorkspacePage(
                  instance: instance,
                  onEdit: () {},
                  onTerminal: () {},
                ),
              ),
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 10));
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(ListView), const Offset(0, -450));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets(
    'Native restart uses the selected UUID and sends nothing before confirmation',
    (tester) async {
      final calls = <http.Request>[];
      final session = CoolifySession(
        instance,
        createClient: () => CoolifyClient(
          client: MockClient((r) async {
            calls.add(r);
            return http.Response(
              '{"uuid":"actual-app","name":"Actual app"}',
              200,
            );
          }),
        ),
      );
      addTearDown(session.dispose);
      await tester.runAsync(() async {
        await tester.pumpWidget(
          app(
            CoolifyResourcePage(
              session: session,
              catalog: catalog,
              collection: 'applications',
              uuid: 'actual-app',
              name: 'Actual app',
              onTerminal: () {},
            ),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
      });
      await tester.pumpAndSettle();
      await tester.tap(find.text('Restart'));
      await tester.pumpAndSettle();
      expect(calls.where((r) => r.method == 'POST'), isEmpty);
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const ValueKey('coolify-confirm-action')));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      });
      await tester.pumpAndSettle();
      final sent = calls.where((r) => r.method == 'POST').single;
      expect(sent.url.path, '/api/v1/applications/actual-app/restart');
      expect(sent.body, isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'SQL backup run updates its existing schedule instead of creating another',
    (tester) async {
      final calls = <http.Request>[];
      final session = CoolifySession(
        instance,
        createClient: () => CoolifyClient(
          client: MockClient((r) async {
            calls.add(r);
            return http.Response(
              r.url.path.endsWith('/backups')
                  ? '[{"uuid":"schedule-id","frequency":"daily","enabled":true}]'
                  : '{}',
              200,
            );
          }),
        ),
      );
      addTearDown(session.dispose);
      await tester.runAsync(() async {
        await tester.pumpWidget(
          app(
            CoolifyResourcePage(
              session: session,
              catalog: catalog,
              collection: 'databases',
              uuid: 'database-id',
              name: 'Own database',
              onTerminal: () {},
            ),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
      });
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.text('Backups'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      });
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Run backup'),
        300,
        scrollable: find
            .descendant(
              of: find.byType(ListView).first,
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await Scrollable.ensureVisible(
        tester.element(find.text('Run backup')),
        alignment: .5,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Run backup'));
      await tester.pumpAndSettle();
      expect(calls.where((r) => r.method == 'PATCH'), isEmpty);
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const ValueKey('coolify-confirm-action')));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      });
      await tester.pumpAndSettle();
      final sent = calls.where((r) => r.method == 'PATCH').single;
      expect(
        sent.url.path,
        '/api/v1/databases/database-id/backups/schedule-id',
      );
      expect(jsonDecode(sent.body), {'backup_now': true});
      expect(calls.where((r) => r.method == 'POST'), isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Creating a service preserves prefilled project and environment context with one environment identifier',
    (tester) async {
      http.Request? sent;
      final session = CoolifySession(
        instance,
        createClient: () => CoolifyClient(
          client: MockClient((r) async {
            sent = r;
            return http.Response('{}', 201);
          }),
        ),
      );
      addTearDown(session.dispose);
      await tester.pumpWidget(
        app(
          CoolifyOperationPage(
            session: session,
            operation: catalog.find('POST', '/services')!,
            initialValues: {
              'server_uuid': 'server-id',
              'project_uuid': 'project-id',
              'environment_name': 'production',
              'name': 'My stack',
              'docker_compose_raw': 'services: {}',
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await execute(tester);
      await tester.tap(find.byKey(const ValueKey('coolify-confirm-action')));
      await tester.pumpAndSettle();
      expect(jsonDecode(sent!.body), {
        'server_uuid': 'server-id',
        'project_uuid': 'project-id',
        'environment_name': 'production',
        'name': 'My stack',
        'docker_compose_raw': 'services: {}',
      });
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Hidden required fields in a large create form are validated before sending',
    (tester) async {
      var sent = 0;
      final session = CoolifySession(
        instance,
        createClient: () => CoolifyClient(
          client: MockClient((r) async {
            sent++;
            return http.Response('{}', 201);
          }),
        ),
      );
      addTearDown(session.dispose);
      await tester.pumpWidget(
        app(
          CoolifyOperationPage(
            session: session,
            operation: catalog.find('POST', '/applications/public')!,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await execute(tester);
      expect(sent, 0);
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Editing SSH from Coolify preserves the original workspace', (
    tester,
  ) async {
    const ssh = ServerInstance(
      id: 'ssh',
      name: 'Server',
      type: InstanceType.ssh,
      host: 'server.example.com',
      port: 22,
      username: 'deploy',
      password: 'fixture-password',
    );
    final store = MemoryWorkspaceStore()
      ..data = [
        DockWorkspace(
          id: 'coolify-workspace',
          name: 'Coolify',
          instances: [instance],
        ),
        DockWorkspace(id: 'ssh-workspace', name: 'SSH', instances: [ssh]),
      ];
    final controller = DockController(store);
    await controller.initialize();
    await tester.pumpWidget(
      app(
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showInstanceEditor(
                context,
                controller,
                instance: ssh,
                workspaceId: 'ssh-workspace',
              ),
              child: const Text('Edit SSH'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Edit SSH'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('instance-name')),
      'Renamed server',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('save-instance')));
    await tester.tap(find.byKey(const ValueKey('save-instance')));
    await tester.pumpAndSettle();
    expect(controller.workspaces.first.instances.single.id, 'coolify');
    expect(controller.workspaces.last.instances.single.name, 'Renamed server');
    expect(controller.activeWorkspace!.id, 'coolify-workspace');
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
