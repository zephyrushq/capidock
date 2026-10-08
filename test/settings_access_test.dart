import 'dart:async';
import 'dart:convert';

import 'package:capidock/app.dart';
import 'package:capidock/core/help_button.dart';
import 'package:capidock/core/security/device_lock.dart';
import 'package:capidock/features/connections/data/coolify_client.dart';
import 'package:capidock/features/connections/data/host_key_store.dart';
import 'package:capidock/features/coolify/data/coolify_access.dart';
import 'package:capidock/features/coolify/data/coolify_catalog.dart';
import 'package:capidock/features/coolify/data/coolify_session.dart';
import 'package:capidock/features/coolify/presentation/coolify_access_button.dart';
import 'package:capidock/features/coolify/presentation/coolify_operation_page.dart';
import 'package:capidock/features/settings/app_preferences.dart';
import 'package:capidock/features/settings/settings_page.dart';
import 'package:capidock/features/workspaces/data/workspace_store.dart';
import 'package:capidock/features/workspaces/domain/dock_controller.dart';
import 'package:capidock/features/workspaces/domain/dock_workspace.dart';
import 'package:capidock/l10n/locale_controller.dart';
import 'package:capidock/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'connections_test.dart' show coolify;
import 'test_support.dart';
import 'monitor_support.dart';

import 'package:capidock/features/monitoring/monitor_service.dart';

class GatedSecureStore extends SecureWorkspaceStore {
  GatedSecureStore(MemorySecretStore secrets, MemoryPreferences preferences)
    : super(secrets: secrets, preferences: preferences);
  final gate = Completer<void>();
  @override
  Future<void> save(List<DockWorkspace> workspaces) async {
    await gate.future;
    await super.save(workspaces);
  }
}

class ToggleAuthenticator implements DeviceAuthenticator {
  bool accepted = true;
  int attempts = 0;
  @override
  Future<bool> unlock(String reason) async {
    attempts++;
    return accepted;
  }
}

Widget localized(Widget child, [Locale locale = const Locale('en', 'GB')]) =>
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    );
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Permission observations preserve mixed access and never infer root',
    () {
      final access = CoolifyAccess();
      access.succeeded('GET', '/projects');
      expect(access.evidence('read'), AccessEvidence.available);
      expect(access.evidence('root'), AccessEvidence.unknown);
      expect(access.evidence('write'), AccessEvidence.unknown);
      access.refusedOperation('PATCH', '/applications/app', {'write'});
      expect(access.allows('PATCH', '/applications/another'), isFalse);
      expect(access.allows('POST', '/applications/app/restart'), isTrue);
      access.succeeded('POST', '/applications/app/restart');
      expect(access.evidence('deploy'), AccessEvidence.available);
      access.clear();
      expect(access.allows('PATCH', '/applications/app'), isTrue);
      expect(access.evidence('read'), AccessEvidence.unknown);
      expect(CoolifyAccess.requirements('GET', '/enable'), ['write']);
      expect(CoolifyAccess.requirements('GET', '/applications/app/logs'), [
        'read:sensitive',
      ]);
      expect(CoolifyAccess.requirements('PATCH', '/settings/email'), [
        'write:sensitive',
      ]);
      expect(
        CoolifyAccess.requirements('POST', '/future-unknown-operation'),
        isEmpty,
      );
      access.dispose();
    },
  );
  test(
    'Only exact JSON middleware errors update access and block repeat requests',
    () async {
      var sent = 0, lifecycleNotifications = 0;
      final session = CoolifySession(
        coolify,
        createClient: () => CoolifyClient(
          client: MockClient((request) async {
            sent++;
            if (request.method == 'GET') return http.Response('[]', 200);
            return http.Response(
              jsonEncode({
                'message': 'Missing required permissions: write',
                'secret': 'never-show-me',
              }),
              403,
              headers: {'content-type': 'application/json'},
            );
          }),
        ),
      );
      session.addListener(() => lifecycleNotifications++);
      await session.request('GET', '/projects');
      try {
        await session.request('PATCH', '/projects/one', body: {'name': 'test'});
        fail('Must reject');
      } on CoolifyException catch (error) {
        expect(error.missingPermissions, {'write'});
        expect(error.message, isNot(contains('never-show-me')));
      }
      await expectLater(
        session.request('PATCH', '/projects/two'),
        throwsA(isA<CoolifyException>()),
      );
      expect(sent, 2);
      expect(lifecycleNotifications, 0);
      session.dispose();
    },
  );
  for (final body in [
    '<html>Cloudflare block</html>',
    '{"message":"Forbidden"}',
    '{"message":"Missing required permissions: root"}',
    '{"message":"Missing required permissions: write","padding":"${'x' * 5000}"}',
    '{"message":"Missing required permissions: write\\nprivate detail"}',
  ]) {
    test(
      'Generic/invalid 403 does not invent readonly status: ${body.length}',
      () async {
        final session = CoolifySession(
          coolify,
          createClient: () => CoolifyClient(
            client: MockClient(
              (_) async => http.Response(
                body,
                403,
                headers: {'content-type': 'application/json'},
              ),
            ),
          ),
        );
        await expectLater(
          session.request('GET', '/projects'),
          throwsA(isA<CoolifyException>()),
        );
        expect(session.access.evidence('read'), AccessEvidence.unknown);
        expect(session.access.evidence('write'), AccessEvidence.unknown);
        expect(session.access.allows('PATCH', '/projects/one'), isTrue);
        session.dispose();
      },
    );
  }
  test('Preference save failures preserve the working terminal size', () async {
    final preferences = MemoryPreferences();
    final first = AppPreferences(preferences: preferences);
    await first.setTerminalFontSize(18);
    final restarted = AppPreferences(preferences: preferences);
    await restarted.initialize();
    expect(restarted.terminalFontSize, 18);
    preferences.failSave = true;
    await expectLater(restarted.setTerminalFontSize(12), throwsStateError);
    expect(restarted.terminalFontSize, 18);
    expect(restarted.saving, isFalse);
    first.dispose();
    restarted.dispose();
  });
  test('Temporary SSH test trust is never saved', () async {
    final secrets = MemorySecretStore();
    final keys = HostKeyStore(secrets: secrets, persist: false);
    expect(
      await keys.verify(
        fixtureInstances.first,
        'ssh-ed25519',
        'SHA256:test',
        (_, _, _) async => true,
        isActive: () => true,
      ),
      isTrue,
    );
    expect(secrets.values, isEmpty);
  });
  test(
    'Clearing data waits for an outstanding save and prevents resurrection',
    () async {
      final secrets = MemorySecretStore()
        ..values['capidock.host-key.old'] = 'old';
      final preferences = MemoryPreferences()
        ..values[SecureWorkspaceStore.legacyStorageKey] = 'legacy';
      // Do not attempt to load intentionally invalid legacy data before the test save.
      preferences.values.clear();
      final store = GatedSecureStore(secrets, preferences);
      final controller = DockController(store);
      await controller.initialize();
      final saving = controller.createWorkspace('Pending');
      final clearing = controller.clearLocalData();
      await expectLater(
        controller.createWorkspace('Too late'),
        throwsStateError,
      );
      store.gate.complete();
      await saving;
      await clearing;
      expect(secrets.values, isEmpty);
      expect(controller.workspaces, isEmpty);
      await controller.initialize();
      expect(controller.workspaces, isEmpty);
      controller.dispose();
    },
  );
  test('Erasure removes legacy migration sources, and storage failures are visible', () async {
    final prefs = MemoryPreferences()
      ..values[SecureWorkspaceStore.previousStorageKey] = 'old';
    final secrets = MemorySecretStore()
      ..values['capidock.host-key.old'] = 'key';
    final store = SecureWorkspaceStore(secrets: secrets, preferences: prefs);
    secrets.failWrite = true;
    await expectLater(store.clearLocalData(), throwsStateError);
    expect(secrets.values, isNotEmpty);
    secrets.failWrite = false;
    await store.clearLocalData();
    expect(prefs.values, isEmpty);
    expect(secrets.values, isEmpty);
    expect(await store.load(), isNull);
  });
  testWidgets('Denied operations disable execution without network probes', (
    tester,
  ) async {
    var sent = 0;
    final session = CoolifySession(
      coolify,
      createClient: () => CoolifyClient(
        client: MockClient((_) async {
          sent++;
          return http.Response('{}', 200);
        }),
      ),
    );
    session.access.refused({'write'});
    final catalog = await tester.runAsync(CoolifyCatalog.load);
    await tester.pumpWidget(
      localized(
        CoolifyOperationPage(
          session: session,
          operation: catalog!.find('PATCH', '/projects/{uuid}')!,
          pathValues: const {'uuid': 'one'},
        ),
      ),
    );
    await tester.pumpAndSettle();
    final button = tester.widget<FilledButton>(
      find.byKey(const ValueKey('coolify-execute')),
    );
    expect(button.onPressed, isNull);
    expect(sent, 0);
    await tester.pumpWidget(const SizedBox());
    session.dispose();
  });
  testWidgets('Erase requires fresh device authentication and locks the app', (
    tester,
  ) async {
    final secrets = MemorySecretStore();
    final store = SecureWorkspaceStore(
      secrets: secrets,
      preferences: MemoryPreferences(),
    );
    await store.save(fixtureWorkspaces());
    secrets.values['capidock.host-key.test'] = 'test';
    final controller = DockController(store);
    final auth = ToggleAuthenticator();
    final locales = LocaleController(
      initialLocale: const Locale('en', 'GB'),
      preferences: MemoryPreferences(),
    );
    await tester.pumpWidget(
      DeviceLock(
        controller: controller,
        locales: locales,
        authenticator: auth,
        monitoring: MonitorService(
          secrets: secrets,
          bridge: FakeMonitorBridge(),
          cancelJobs: () async {},
        ),
      ),
    );
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open instances'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('sidebar-app-settings')));
    await tester.pumpAndSettle();
    auth.accepted = false;
    Future<void> erase() async {
      await tester.ensureVisible(find.text('Erase saved server data'));
      await tester.tap(find.text('Erase saved server data'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
      await tester.pumpAndSettle();
    }

    await erase();
    expect(secrets.values, isNotEmpty);
    expect(find.byType(SettingsPage), findsOneWidget);
    auth.accepted = true;
    await erase();
    expect(auth.attempts, 3);
    expect(secrets.values, isEmpty);
    expect(find.text('Capidock locked'), findsOneWidget);
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();
    expect(controller.workspaces, isEmpty);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    locales.dispose();
  });
  for (final language in AppLanguage.values) {
    testWidgets(
      '${language.locale} settings and help fit small screens with large text',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final controller = DockController(MemoryWorkspaceStore());
        await controller.initialize();
        final locales = LocaleController(
          initialLocale: language.locale,
          preferences: MemoryPreferences(),
        );
        final prefs = AppPreferences(preferences: MemoryPreferences());
        await tester.pumpWidget(
          CapidockApp(
            controller: controller,
            localeController: locales,
            preferences: prefs,
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();
        final strings = tester.element(find.byType(SettingsPage)).l10n;
        expect(find.text(strings.terminalFontSize), findsOneWidget);
        await tester.ensureVisible(find.byType(HelpButton).first);
        await tester.tap(find.byType(HelpButton).first);
        await tester.pumpAndSettle();
        expect(find.text(strings.trustedSshHelp), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(
          localized(
            Scaffold(body: CoolifyAccessButton(access: CoolifyAccess())),
            language.locale,
          ),
        );
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();
        expect(find.text('root'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        controller.dispose();
        locales.dispose();
        prefs.dispose();
      },
    );
  }
}
