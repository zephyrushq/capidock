import 'dart:async';
import 'dart:convert';

import 'package:capidock/core/app_theme.dart';

import 'package:capidock/features/connections/data/coolify_client.dart';
import 'package:capidock/features/coolify/presentation/coolify_workspace_page.dart';
import 'package:capidock/features/settings/settings_page.dart';
import 'package:capidock/features/workspaces/data/workspace_store.dart';
import 'package:capidock/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'connections_test.dart' show coolify;
import 'test_support.dart';

Widget localized(Widget child) => MaterialApp(
  theme: buildTheme(),
  locale: const Locale('en', 'GB'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: Scaffold(body: child),
);
void main() {
  testWidgets('Refresh preserves cards while waiting for an updated response', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final refresh = Completer<http.Response>();
    var requests = 0;
    await tester.pumpWidget(
      localized(
        CoolifyWorkspacePage(
          instance: coolify,
          onEdit: () {},
          onTerminal: () {},
          createClient: () => CoolifyClient(
            client: MockClient((_) async {
              requests++;
              if (requests > 1) return refresh.future;
              return http.Response(
                '[{"uuid":"app","name":"Existing resource","type":"application"}]',
                200,
              );
            }),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const ValueKey('connect-instance')));
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    await tester.pumpAndSettle();
    expect(requests, greaterThan(0));
    expect(
      find.text('Existing resource'),
      findsOneWidget,
      reason: 'Loaded cards should remain visible',
    );
    await tester.tap(find.byKey(const ValueKey('connect-instance')));
    await tester.pump();
    expect(find.text('Existing resource'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    refresh.complete(
      http.Response(
        '[{"uuid":"app","name":"Updated resource","type":"application"}]',
        200,
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
    });
    await tester.pumpAndSettle();
    expect(find.text('Updated resource'), findsOneWidget);
    expect(find.text('Existing resource'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Forgetting SSH trust preserves the credential vault', (
    tester,
  ) async {
    final secrets = MemorySecretStore()
      ..values[SecureWorkspaceStore.storageKey] = 'private-credentials';
    const key = 'capidock.host-key.one';
    secrets.values[key] = jsonEncode({
      'host': 'server.example.com',
      'port': 22,
      'type': 'ssh-ed25519',
      'fingerprint': 'SHA256:example',
    });
    await tester.pumpWidget(localized(TrustedKeysPage(secrets: secrets)));
    await tester.pumpAndSettle();
    expect(find.text('SHA256:example'), findsOneWidget);
    expect(find.text('private-credentials'), findsNothing);
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
    await tester.pumpAndSettle();
    expect(secrets.values.containsKey(key), isFalse);
    expect(
      secrets.values[SecureWorkspaceStore.storageKey],
      'private-credentials',
    );
    expect(find.text('No trusted identities'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
