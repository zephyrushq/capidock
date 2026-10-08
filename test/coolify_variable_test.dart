import 'dart:convert';

import 'package:capidock/features/connections/data/coolify_client.dart';
import 'package:capidock/features/coolify/data/coolify_catalog.dart';
import 'package:capidock/features/coolify/data/coolify_session.dart';
import 'package:capidock/features/coolify/presentation/coolify_variable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'coolify_navigation_test.dart' as support;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CoolifyCatalog catalog;
  setUpAll(() async => catalog = await CoolifyCatalog.load());
  testWidgets(
    'Normal and preview categories keep equal keys and reveal values independently',
    (tester) async {
      await tester.pumpWidget(
        support.app(
          Scaffold(
            body: SingleChildScrollView(
              child: CoolifyVariableGroups(
                items: const [
                  {
                    'key': 'API_URL',
                    'value': 'normal-secret',
                    'is_preview': false,
                    'id': 1,
                  },
                  {
                    'key': 'API_URL',
                    'value': 'preview-secret',
                    'is_preview': true,
                    'id': 2,
                  },
                ],
                onEdit: (_) {},
                onDelete: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Normal variables'), findsOneWidget);
      expect(find.text('Preview variables'), findsOneWidget);
      expect(find.text('API_URL'), findsNWidgets(2));
      expect(find.text('normal-secret'), findsNothing);
      expect(find.text('preview-secret'), findsNothing);
      final preview = find.byWidgetPredicate(
        (w) => w is CoolifyVariableCard && coolifyIsPreview(w.item),
      );
      final button = find.descendant(
        of: preview,
        matching: find.text('Show value'),
      );
      await Scrollable.ensureVisible(tester.element(button), alignment: .5);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('preview-secret'), findsOneWidget);
      expect(find.text('normal-secret'), findsNothing);
    },
  );
  testWidgets(
    'Value-only editing preserves preview identity and flags and allows an intentional empty value',
    (tester) async {
      final calls = <http.Request>[];
      final session = CoolifySession(
        support.instance,
        createClient: () => CoolifyClient(
          client: MockClient((r) async {
            calls.add(r);
            return http.Response('{}', 200);
          }),
        ),
      );
      addTearDown(session.dispose);
      await tester.pumpWidget(
        support.app(
          CoolifyVariableValuePage(
            session: session,
            operation: catalog.find('PATCH', '/applications/{uuid}/envs')!,
            paths: const {'uuid': 'app-id'},
            item: const {
              'key': 'API_URL',
              'value': 'preview-secret',
              'is_preview': true,
              'is_literal': true,
              'is_multiline': false,
              'id': 77,
            },
            target: 'Application / API_URL',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('coolify-variable-value')),
        '',
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('coolify-save-variable-value')),
      );
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
      await tester.tap(
        find.byKey(const ValueKey('coolify-save-variable-value')),
      );
      await tester.pumpAndSettle();
      await support.read(
        tester,
        () => tester.tap(find.byKey(const ValueKey('coolify-confirm-action'))),
      );
      expect(calls.single.url.path, '/api/v1/applications/app-id/envs');
      expect(calls.single.method, 'PATCH');
      expect(jsonDecode(calls.single.body), {
        'key': 'API_URL',
        'value': '',
        'is_preview': true,
        'is_literal': true,
        'is_multiline': false,
      });
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'Unreadable values cannot be saved untouched and backgrounding clears edits',
    (tester) async {
      final session = CoolifySession(
        support.instance,
        createClient: () => CoolifyClient(
          client: MockClient((_) async => throw StateError('Must not send')),
        ),
      );
      addTearDown(session.dispose);
      await tester.pumpWidget(
        support.app(
          CoolifyVariableValuePage(
            session: session,
            operation: catalog.find('PATCH', '/applications/{uuid}/envs')!,
            paths: const {'uuid': 'app-id'},
            item: const {'key': 'TOKEN', 'is_preview': false},
            target: 'Application / TOKEN',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Value protected by token permissions.'),
        findsOneWidget,
      );
      FilledButton save() => tester.widget<FilledButton>(
        find.byKey(const ValueKey('coolify-save-variable-value')),
      );
      expect(save().onPressed, isNull);
      await tester.enterText(
        find.byKey(const ValueKey('coolify-variable-value')),
        'draft-secret',
      );
      await tester.pumpAndSettle();
      expect(save().onPressed, isNotNull);
      session.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(
              find.byKey(const ValueKey('coolify-variable-value')),
            )
            .controller!
            .text,
        isEmpty,
      );
      session.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(save().onPressed, isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
