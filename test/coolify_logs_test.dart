import 'dart:async';
import 'dart:convert';

import 'package:capidock/core/app_theme.dart';
import 'package:capidock/features/connections/data/coolify_client.dart';
import 'package:capidock/features/coolify/data/coolify_session.dart';
import 'package:capidock/features/coolify/data/coolify_catalog.dart';
import 'package:capidock/features/coolify/presentation/coolify_logs_panel.dart';
import 'package:capidock/features/coolify/presentation/coolify_operation_page.dart';
import 'package:capidock/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'connections_test.dart' show coolify;

Widget localized(Widget child) => MaterialApp(
  theme: buildTheme(),
  locale: const Locale('en', 'GB'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: Scaffold(body: ListView(children: [child])),
);

void main() {
  testWidgets('Deployment detail uses the terminal panel for encoded logs', (
    tester,
  ) async {
    final catalog = (await tester.runAsync(CoolifyCatalog.load))!;
    final session = CoolifySession(
      coolify,
      createClient: () => CoolifyClient(
        client: MockClient((request) async {
          expect(request.url.path, '/api/v1/deployments/deployment-uuid');
          return http.Response(
            jsonEncode({
              'deployment_uuid': 'deployment-uuid',
              'status': 'finished',
              'logs': jsonEncode([
                {'timestamp': '12:30', 'output': 'Build completed'},
              ]),
            }),
            200,
          );
        }),
      ),
    );
    addTearDown(session.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        locale: const Locale('en', 'GB'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: CoolifyOperationPage(
          session: session,
          operation: catalog.find('GET', '/deployments/{uuid}')!,
          pathValues: const {'uuid': 'deployment-uuid'},
          autoRead: true,
        ),
      ),
    );
    await tester.runAsync(() async {
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    await tester.pumpAndSettle();
    expect(find.byType(CoolifyLogsPanel), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('logs-reveal')));
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const ValueKey('logs-reveal')));
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    await tester.pump();
    expect(find.text('[12:30] Build completed'), findsOneWidget);
    expect(find.textContaining('"output"'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
  test('Extracts runtime logs and deployment records without API JSON', () {
    expect(coolifyLogText({'logs': 'started\nready'}), 'started\nready');
    expect(
      coolifyLogText({
        'logs': jsonEncode([
          {'timestamp': '12:30', 'output': 'Building', 'hidden': true},
          {'timestamp': '12:31', 'output': 'Ready', 'type': 'stdout'},
        ]),
      }),
      '[12:30] Building\n[12:31] Ready',
    );
    expect(
      coolifyLogText({'logs': '{"level":"info","message":"ready"}'}),
      '{"level":"info","message":"ready"}',
    );
    expect(
      coolifyLogText({
        'logs': [
          {'output': 'one'},
          {'output': 'two'},
        ],
      }),
      'one\ntwo',
    );
    expect(
      coolifyLogText({
        'data': {'logs': 'nested'},
      }),
      'nested',
    );
    expect(coolifyLogText({'password': 'secret', 'status': 'running'}), '');
  });

  test('Strips terminal control sequences and bounds the visible tail', () {
    expect(
      coolifyLogText('\x1b[31mERROR\x1b[0m\n\x1b]52;c;clipboard\x07safe'),
      'ERROR\nsafe',
    );
    final text = coolifyLogText(
      List.generate(2100, (i) => 'line $i').join('\n'),
    );
    expect(text.split('\n').length, 2000);
    expect(text.startsWith('line 100\n'), isTrue);
    expect(text.endsWith('line 2099'), isTrue);
    expect(coolifyLogText('x' * 100000).length, 65536);
  });

  testWidgets('Logs stay private until revealed, poll and can be paused', (
    tester,
  ) async {
    var requests = 0;
    final session = CoolifySession(
      coolify,
      createClient: () => CoolifyClient(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/api/v1/applications/app/logs');
          expect(request.url.queryParameters['lines'], '200');
          requests++;
          return http.Response(jsonEncode({'logs': 'updated $requests'}), 200);
        }),
      ),
    );
    addTearDown(session.dispose);
    await tester.pumpWidget(
      localized(
        CoolifyLogsPanel(
          session: session,
          path: '/applications/app/logs',
          data: const {'logs': 'initial'},
          query: const {'lines': '200'},
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 4));
    expect(requests, 0);
    expect(find.byKey(const ValueKey('logs-output')), findsNothing);
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const ValueKey('logs-reveal')));
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    await tester.pump();
    expect(find.text('updated 1'), findsOneWidget);
    await tester.runAsync(() async {
      await tester.pump(const Duration(seconds: 3));
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    await tester.pump();
    expect(requests, 2);
    await tester.tap(find.byKey(const ValueKey('logs-live')));
    await tester.pump(const Duration(seconds: 6));
    expect(requests, 2);
    session.didChangeAppLifecycleState(AppLifecycleState.paused);
    await tester.pump();
    expect(find.byKey(const ValueKey('logs-output')), findsNothing);
    await tester.pump(const Duration(seconds: 6));
    expect(requests, 2);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'No overlapping fetch or late sensitive result after hiding logs',
    (tester) async {
      var requests = 0;
      final pending = Completer<http.Response>();
      final session = CoolifySession(
        coolify,
        createClient: () => CoolifyClient(
          client: MockClient((_) {
            requests++;
            return pending.future;
          }),
        ),
      );
      addTearDown(session.dispose);
      await tester.pumpWidget(
        localized(
          CoolifyLogsPanel(
            session: session,
            path: '/applications/app/logs',
            data: 'initial',
          ),
        ),
      );
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const ValueKey('logs-reveal')));
        await Future<void>.delayed(const Duration(milliseconds: 30));
      });
      await tester.pump(const Duration(seconds: 9));
      expect(requests, 1);
      await tester.tap(find.byKey(const ValueKey('logs-reveal')));
      await tester.pump();
      await tester.runAsync(() async {
        pending.complete(http.Response('{"logs":"late secret"}', 200));
        await Future<void>.delayed(const Duration(milliseconds: 30));
      });
      await tester.pump();
      expect(find.text('late secret'), findsNothing);
      expect(find.byKey(const ValueKey('logs-output')), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
