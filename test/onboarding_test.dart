import 'package:capidock/app.dart';
import 'package:capidock/features/workspaces/domain/dock_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';
import 'widget_test.dart' as helpers;

Future<void> next(WidgetTester tester) async {
  await tester.ensureVisible(find.byKey(const ValueKey('onboarding-next')));
  await tester.tap(find.byKey(const ValueKey('onboarding-next')));
  await tester.pumpAndSettle();
}

void main() {
  for (final coolify in [false, true]) {
    testWidgets(
      'Onboarding saves ${coolify ? 'Coolify' : 'SSH'} once and reopens the real workspace',
      (tester) async {
        final store = MemoryWorkspaceStore();
        final controller = await helpers.launch(tester, store: store);
        await next(tester);
        expect(find.text('Dê um nome ao workspace.'), findsOneWidget);
        await tester.enterText(
          find.byKey(const ValueKey('onboarding-workspace')),
          'Pessoal',
        );
        await next(tester);
        await tester.enterText(
          find.byKey(const ValueKey('instance-name')),
          'Meu servidor',
        );
        await next(tester);
        expect(store.saves, 0);
        if (coolify) await tester.tap(find.text('Coolify'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('instance-host')),
          coolify ? 'https://coolify.example.com:8443' : 'server.example.com',
        );
        if (coolify) {
          await tester.enterText(
            find.byKey(const ValueKey('instance-token')),
            'test-api-token',
          );
        } else {
          await tester.enterText(
            find.byKey(const ValueKey('instance-user')),
            'deploy',
          );
          await tester.enterText(
            find.byKey(const ValueKey('instance-password')),
            'test-password',
          );
        }
        store.failSave = true;
        await next(tester);
        expect(controller.workspaces, isEmpty);
        expect(
          find.textContaining('Os campos foram preservados'),
          findsOneWidget,
        );
        store.failSave = false;
        await next(tester);
        expect(store.saves, 1);
        expect(
          controller.selected!.host,
          coolify ? 'https://coolify.example.com:8443' : 'server.example.com',
        );
        expect(controller.selected!.port, coolify ? 8443 : 22);
        expect(controller.selected!.hasCredentials, isTrue);
        expect(find.text('Por ligar'), findsOneWidget);
        final reopened = DockController(store);
        await reopened.initialize();
        await tester.pumpWidget(CapidockApp(controller: reopened));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('onboarding-workspace')),
          findsNothing,
        );
        await reopened.removeWorkspace(reopened.activeWorkspace!.id);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('onboarding-workspace')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Storage errors do not offer to overwrite existing data', (
    tester,
  ) async {
    await helpers.launch(
      tester,
      store: MemoryWorkspaceStore()..failLoad = true,
    );
    expect(find.text('Tentar novamente'), findsOneWidget);
    expect(find.byKey(const ValueKey('onboarding-workspace')), findsNothing);
  });

  for (final size in [
    const Size(320, 700),
    const Size(390, 844),
    const Size(1024, 800),
  ]) {
    testWidgets('Welcome and credentials adapt to $size with large text', (
      tester,
    ) async {
      await helpers.launch(
        tester,
        store: MemoryWorkspaceStore(),
        size: size,
        scale: 1.5,
      );
      await tester.enterText(
        find.byKey(const ValueKey('onboarding-workspace')),
        'Pessoal',
      );
      await next(tester);
      await tester.enterText(
        find.byKey(const ValueKey('instance-name')),
        'Servidor',
      );
      await next(tester);
      await tester.ensureVisible(find.byKey(const ValueKey('onboarding-next')));
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Voltar'));
      await tester.pumpAndSettle();
      expect(find.text('Servidor'), findsOneWidget);
    });
  }
}
