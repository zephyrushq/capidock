import 'dart:convert';

import 'package:capidock/core/security/device_lock.dart';
import 'package:capidock/features/workspaces/domain/dock_controller.dart';
import 'package:capidock/l10n/locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

class NoAuthentication implements DeviceAuthenticator {
  int attempts = 0;
  @override
  Future<bool> unlock(String reason) async {
    attempts++;
    return false;
  }
}

void main() {
  for (final language in AppLanguage.values) {
    final tag = language.locale.toLanguageTag();
    testWidgets(
      '$tag legal documents work offline without unlocking the vault',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = DockController(MemoryWorkspaceStore());
        final locales = LocaleController(
          initialLocale: language.locale,
          preferences: MemoryPreferences(),
        );
        final auth = NoAuthentication();
        final json = await tester.runAsync(
          () => rootBundle.loadString('assets/legal/$tag.json'),
        );
        final data = jsonDecode(json!) as Map<String, dynamic>;
        for (final kind in ['terms', 'privacy']) {
          final sections = (data[kind] as Map)['sections'] as List;
          expect(sections, isNotEmpty);
          expect(
            sections.map((s) => s['body']).join('\n'),
            contains('legal@zephyrushq.com'),
          );
          expect(
            sections.every(
              (s) =>
                  (s['title'] as String).isNotEmpty &&
                  (s['body'] as String).isNotEmpty,
            ),
            isTrue,
          );
        }
        await tester.pumpWidget(
          DeviceLock(
            controller: controller,
            locales: locales,
            authenticator: auth,
          ),
        );
        for (final kind in ['terms', 'privacy']) {
          await tester.ensureVisible(find.byKey(ValueKey('legal-$kind')));
          await tester.runAsync(() async {
            await tester.tap(find.byKey(ValueKey('legal-$kind')));
            await tester.pump();
            await rootBundle.loadString('assets/legal/$tag.json');
          });
          await tester.pumpAndSettle();
          expect(
            find.text(data[kind]['sections'][0]['title'] as String),
            findsOneWidget,
          );
          expect(controller.isLoading, isTrue);
          expect(auth.attempts, 0);
          await tester.tap(find.byType(BackButton));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        controller.dispose();
        locales.dispose();
      },
    );
  }
}
