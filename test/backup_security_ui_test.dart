import 'dart:async';
import 'dart:typed_data';

import 'package:capidock/core/security/device_lock.dart';
import 'package:capidock/core/security/security_controls.dart';
import 'package:capidock/features/backups/presentation/backup_page.dart';
import 'package:capidock/features/settings/settings_page.dart';
import 'package:capidock/features/workspaces/domain/dock_controller.dart';
import 'package:capidock/l10n/locale_controller.dart';
import 'package:capidock/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'settings_access_test.dart' show ToggleAuthenticator;
import 'test_support.dart';

void main() {
  for (final outcome in ['accepted', 'denied', 'timeout']) {
    final accepted = outcome == 'accepted';
    testWidgets('Document chooser stays private and reauthenticates: $outcome', (
      tester,
    ) async {
      final store = MemoryWorkspaceStore()..data = fixtureWorkspaces();
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
        ),
      );
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Open instances'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('sidebar-app-settings')));
      await tester.pumpAndSettle();
      final controls = SecurityControls.maybeOf(
        tester.element(find.byType(SettingsPage)),
      )!;
      final document = Completer<Uint8List?>();
      final operation = controls
          .documentAction!('Backup test', () => document.future)
          .then<Object?>((value) => value, onError: (Object error) => error);
      await tester.pump();
      expect(find.byType(SettingsPage), findsNothing);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(find.byType(SettingsPage), findsNothing);
      auth.accepted = accepted;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      if (outcome == 'timeout') {
        await tester.pump(const Duration(minutes: 5));
      } else {
        document.complete(Uint8List.fromList([1, 2, 3]));
      }
      await tester.pumpAndSettle();
      final result = await operation;
      expect(auth.attempts, outcome == 'timeout' ? 1 : 2);
      if (accepted) {
        expect(result, [1, 2, 3]);
        expect(find.byType(SettingsPage), findsOneWidget);
        expect(controller.workspaces, isNotEmpty);
        // Returning from the chooser never leaves a general background bypass.
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pumpAndSettle();
      } else if (outcome == 'timeout') {
        expect(result, isA<TimeoutException>());
      } else {
        expect(result, isNull);
      }
      expect(find.text('Capidock locked'), findsOneWidget);
      expect(controller.workspaces, isEmpty);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      locales.dispose();
    });
  }

  for (final language in AppLanguage.values) {
    testWidgets(
      '${language.locale}: backup and password form fit a small screen',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final controller = DockController(
          MemoryWorkspaceStore()..data = fixtureWorkspaces(),
        );
        await controller.initialize();
        await tester.pumpWidget(
          SecurityControls(
            lock: () {},
            clearData: (_) async {},
            reauthenticate: (_) async => false,
            documentAction: <T>(String reason, Future<T?> Function() action) =>
                action(),
            child: MaterialApp(
              locale: language.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: BackupPage(controller: controller),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('backup-export')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('backup-password')),
          'short',
        );
        final submit = find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(FilledButton),
        );
        await tester.ensureVisible(submit);
        await tester.tap(submit);
        await tester.pumpAndSettle();
        expect(
          find.text(
            tester.element(find.byType(AlertDialog)).l10n.backupPasswordWeak,
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        controller.dispose();
      },
    );
  }
}
