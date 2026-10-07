import 'package:capidock/app.dart';
import 'package:capidock/features/workspaces/domain/dock_controller.dart';
import 'package:capidock/l10n/locale_controller.dart';
import 'package:capidock/l10n/language_selector.dart';
import 'package:capidock/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

void main() {
  test(
    'Language preference survives restart and invalid preferences fall back',
    () async {
      final preferences = MemoryPreferences();
      final controller = LocaleController(preferences: preferences);
      await controller.initialize([const Locale('pt', 'BR')]);
      expect(controller.locale, const Locale('pt', 'BR'));
      await controller.select(const Locale('en', 'US'));
      final restarted = LocaleController(preferences: preferences);
      await restarted.initialize([const Locale('es', 'ES')]);
      expect(restarted.locale, const Locale('en', 'US'));
      preferences.values[LocaleController.preferenceKey] = 'invalid';
      await restarted.initialize([
        const Locale('de', 'DE'),
        const Locale('es', 'MX'),
      ]);
      expect(restarted.locale, const Locale('es', 'ES'));
      await restarted.initialize([const Locale('de', 'DE')]);
      expect(restarted.locale, const Locale('en', 'GB'));
      preferences.failSave = true;
      await expectLater(
        restarted.select(const Locale('pt', 'PT')),
        throwsStateError,
      );
      expect(restarted.locale, const Locale('en', 'GB'));
    },
  );

  testWidgets(
    'Welcome language selector preserves the onboarding draft and step',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final preferences = MemoryPreferences();
      final locales = LocaleController(preferences: preferences);
      final controller = DockController(MemoryWorkspaceStore());
      await controller.initialize();
      await tester.pumpWidget(
        CapidockApp(controller: controller, localeController: locales),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('onboarding-workspace')),
        'My homelab',
      );
      final titles = {
        'en-GB': 'Your servers.\nYour dock.',
        'en-US': 'Your servers.\nYour dock.',
        'pt-BR': 'Os seus servidores.\nO seu dock.',
        'es-ES': 'Tus servidores.\nTu dock.',
        'pt-PT': 'Os seus servidores.\nO seu dock.',
      };
      for (final entry in titles.entries) {
        await tester.tap(find.byKey(const ValueKey('language-selector')));
        await tester.pumpAndSettle();
        expect(find.byType(CountryFlag), findsNWidgets(6));
        await tester.tap(find.byKey(ValueKey('language-${entry.key}')));
        await tester.pumpAndSettle();
        expect(find.text(entry.value), findsOneWidget);
        expect(find.text('My homelab'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      await tester.ensureVisible(find.byKey(const ValueKey('onboarding-next')));
      await tester.tap(find.byKey(const ValueKey('onboarding-next')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('instance-name')),
        'real-server',
      );
      await locales.select(const Locale('es', 'ES'));
      await tester.pumpAndSettle();
      expect(find.text('real-server'), findsOneWidget);
      expect(find.textContaining('My homelab'), findsOneWidget);
      expect(controller.workspaces, isEmpty);
      expect(preferences.values[LocaleController.preferenceKey], 'es-ES');
    },
  );

  for (final language in AppLanguage.values) {
    testWidgets(
      '${language.locale.toLanguageTag()} translates forms and transport errors on a small screen',
      (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final locales = LocaleController(
          initialLocale: language.locale,
          preferences: MemoryPreferences(),
        );
        final controller = DockController(MemoryWorkspaceStore());
        await controller.initialize();
        await tester.pumpWidget(
          CapidockApp(controller: controller, localeController: locales),
        );
        await tester.pumpAndSettle();
        final context = tester.element(
          find.byKey(const ValueKey('onboarding-workspace')),
        );
        final strings = context.l10n;
        expect(strings.instanceCount(0), startsWith('0 '));
        expect(strings.instanceCount(1), startsWith('1 '));
        expect(strings.instanceCount(2), startsWith('2 '));
        expect(
          localizedMessage(
            context,
            'Autenticação recusada. Verifique o utilizador e a credencial SSH.',
          ),
          strings.sshAuthError,
        );
        expect(
          localizedMessage(
            context,
            'O Coolify respondeu com erro HTTP 500. Tente novamente.',
          ),
          strings.httpError(500),
        );
        await tester.ensureVisible(
          find.byKey(const ValueKey('onboarding-next')),
        );
        await tester.tap(find.byKey(const ValueKey('onboarding-next')));
        await tester.pumpAndSettle();
        expect(find.text(strings.workspaceNameRequired), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byKey(const ValueKey('language-selector')));
        await tester.pumpAndSettle();
        expect(find.text('English (United Kingdom)'), findsOneWidget);
        expect(find.text('Português (Brasil)'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(
          find.byKey(ValueKey('language-${language.locale.toLanguageTag()}')),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.byKey(const ValueKey('onboarding-workspace')),
        );
        await tester.enterText(
          find.byKey(const ValueKey('onboarding-workspace')),
          'Homelab',
        );
        Future<void> next() async {
          await tester.ensureVisible(
            find.byKey(const ValueKey('onboarding-next')),
          );
          await tester.tap(find.byKey(const ValueKey('onboarding-next')));
          await tester.pumpAndSettle();
        }

        await next();
        await next();
        expect(find.text(strings.instanceNameRequired), findsOneWidget);
        await tester.ensureVisible(find.byKey(const ValueKey('instance-name')));
        await tester.enterText(
          find.byKey(const ValueKey('instance-name')),
          'server',
        );
        await next();
        await next();
        expect(find.text(strings.hostRequired), findsOneWidget);
        expect(find.text(strings.credentialRequired), findsOneWidget);
        expect(controller.workspaces, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
