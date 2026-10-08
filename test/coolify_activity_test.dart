import 'dart:convert';

import 'package:capidock/features/connections/data/coolify_client.dart';
import 'package:capidock/features/coolify/data/coolify_catalog.dart';
import 'package:capidock/features/coolify/data/coolify_session.dart';
import 'package:capidock/features/coolify/presentation/coolify_activity_list.dart';
import 'package:capidock/features/coolify/presentation/coolify_operation_page.dart';
import 'package:capidock/features/coolify/presentation/coolify_workspace_page.dart';
import 'package:capidock/features/coolify/presentation/coolify_logs_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'coolify_navigation_test.dart' show app, instance, read;

void main() {
  late CoolifyCatalog catalog;
  setUpAll(() async => catalog = await CoolifyCatalog.load());
  test('Activity filters search metadata, never sensitive logs', () {
    expect(formatCoolifyBytes(1024, 'en_GB'), '1 KiB');
    expect(formatCoolifyBytes(1536, 'pt_PT'), '1,5 KiB');
    expect(formatCoolifyBytes(-1, 'en_GB'), '—');
    expect(
      filterCoolifyLogLines(
        '${List.generate(200, (i) => 'line $i').join('\n')}\n',
        '',
        'all',
      ).length,
      200,
    );
    final entries = coolifyActivityEntries({
      'executions': [
        {
          'uuid': 'one',
          'filename': 'db-backup.sql',
          'status': 'success',
          'logs': 'hidden secret',
        },
        {'uuid': 'two', 'filename': 'other.sql', 'status': 'failed'},
      ],
    });
    expect(
      filterCoolifyActivity(entries, 'backup', 'success').single['uuid'],
      'one',
    );
    expect(filterCoolifyActivity(entries, 'hidden secret', null), isEmpty);
    expect(filterCoolifyActivity(entries, '', 'failed').single['uuid'], 'two');
    expect(
      filterCoolifyLogLines(
        'INFO ready\nERROR failed\nWARN low memory',
        '',
        'error',
      ),
      ['ERROR failed'],
    );
    expect(
      filterCoolifyLogLines(
        'INFO ready\nERROR failed\nWARN low memory',
        'memory',
        'warning',
      ),
      ['WARN low memory'],
    );
  });

  testWidgets('On-device pagination and search show only matching entries', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        Scaffold(
          body: SingleChildScrollView(
            child: CoolifyActivityList(
              items: List.generate(12, (i) => {'name': 'Backup $i'}),
              itemBuilder: (item) => Text(item['name'] as String),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Backup 9'), findsOneWidget);
    expect(find.text('Backup 10'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('activity-next')));
    await tester.pump();
    expect(find.text('Backup 10'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('activity-search')),
      'Backup 1',
    );
    await tester.pump();
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == 'Backup 1',
      ),
      findsOneWidget,
    );
    expect(find.text('Backup 10'), findsOneWidget);
    expect(find.text('Backup 0'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'Application deployments page using skip/take and actual deployment UUID',
    (tester) async {
      final queries = <Map<String, String>>[];
      final session = CoolifySession(
        instance,
        createClient: () => CoolifyClient(
          client: MockClient((request) async {
            if (request.url.path == '/api/v1/applications/app') {
              return http.Response(
                '{"uuid":"app","name":"Website","status":"running"}',
                200,
              );
            }
            expect(request.method, 'GET');
            expect(request.url.path, '/api/v1/deployments/applications/app');
            queries.add(request.url.queryParameters);
            final offset = int.parse(request.url.queryParameters['skip']!);
            return http.Response(
              jsonEncode({
                'deployments': List.generate(
                  offset == 0 ? 21 : 2,
                  (i) => {
                    'deployment_uuid': 'deployment-${i + offset}',
                    'id': i + offset,
                    'application_name': 'Release ${i + offset}',
                    'status': 'finished',
                  },
                ),
              }),
              200,
            );
          }),
        ),
      );
      addTearDown(session.dispose);
      await tester.pumpWidget(
        app(
          CoolifyResourcePage(
            session: session,
            catalog: catalog,
            collection: 'applications',
            uuid: 'app',
            name: 'Website',
            onTerminal: () {},
          ),
        ),
      );
      await read(tester, () async {});
      await tester.ensureVisible(
        find.widgetWithText(ChoiceChip, 'Deployments'),
      );
      await read(
        tester,
        () => tester.tap(find.widgetWithText(ChoiceChip, 'Deployments')),
      );
      expect(queries.single, {'skip': '0', 'take': '21'});
      expect(find.byType(CoolifyActivityCard), findsNWidgets(20));
      expect(find.text('Release 20'), findsNothing);
      expect(find.widgetWithText(TextButton, 'Cancel'), findsNothing);
      await tester.ensureVisible(find.byKey(const ValueKey('activity-next')));
      await tester.pumpAndSettle();
      await read(
        tester,
        () => tester.tap(find.byKey(const ValueKey('activity-next'))),
      );
      expect(queries.last, {'skip': '20', 'take': '21'});
      expect(find.byType(CoolifyActivityCard), findsNWidgets(2));
      expect(find.text('Release 20'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(find.byKey(const ValueKey('activity-next')))
            .onPressed,
        isNull,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'Wrapped backup execution history has native cards and denied delete disabled',
    (tester) async {
      final session = CoolifySession(
        instance,
        createClient: () => CoolifyClient(
          client: MockClient((request) async {
            expect(request.method, 'GET');
            return http.Response(
              '{"executions":[{"uuid":"execution","filename":"database.sql","status":"success","size":1024}]}',
              200,
            );
          }),
        ),
      );
      session.access.refused({'write'});
      addTearDown(session.dispose);
      await tester.pumpWidget(
        app(
          CoolifyOperationPage(
            session: session,
            catalog: catalog,
            operation: catalog.find(
              'GET',
              '/databases/{uuid}/backups/{scheduled_backup_uuid}/executions',
            )!,
            pathValues: const {'uuid': 'db', 'scheduled_backup_uuid': 'backup'},
            autoRead: true,
          ),
        ),
      );
      await read(tester, () async {});
      expect(find.byType(CoolifyActivityCard), findsOneWidget);
      expect(find.text('database.sql'), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Remove'))
            .onPressed,
        isNull,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
}
