import 'package:capidock/app.dart';
import 'package:capidock/features/workspaces/domain/dock_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'test_support.dart';

Future<DockController> launch(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double scale = 1,
  MemoryWorkspaceStore? store,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final controller = DockController(
    store ?? (MemoryWorkspaceStore()..data = fixtureWorkspaces()),
  );
  await controller.initialize();
  await tester.pumpWidget(CapidockApp(controller: controller));
  await tester.pumpAndSettle();
  return controller;
}

void main() {
  testWidgets(
    'About shows installed version and legal notices on small screens',
    (tester) async {
      PackageInfo.setMockInitialValues(
        appName: 'Capidock',
        packageName: 'com.zephyrushq.capidock',
        version: '0.3.0',
        buildNumber: '3000',
        buildSignature: '',
      );
      await launch(tester, size: const Size(1024, 800));
      await tester.tap(find.byTooltip('Sobre o Capidock'));
      await tester.pumpAndSettle();
      expect(find.text('0.3.0+3000'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(
        find.text('© 2026 ZEPHYRUS PROSPERITY - UNIPESSOAL LDA'),
        findsOneWidget,
      );
      expect(find.textContaining('GPL-3.0-only'), findsOneWidget);

      for (final entry in [
        (const Size(320, 700), 1.0),
        (const Size(390, 844), 1.5),
      ]) {
        tester.view.physicalSize = entry.$1;
        tester.platformDispatcher.textScaleFactorTestValue = entry.$2;
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await tester.ensureVisible(find.text('Ver licenças'));
      await tester.tap(find.text('Ver licenças'));
      await tester.pumpAndSettle();
      expect(find.byType(LicensePage), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Real instances start disconnected without simulated output', (
    tester,
  ) async {
    final controller = await launch(tester);
    expect(find.text('Por ligar'), findsOneWidget);
    expect(find.text('Configurar acesso'), findsOneWidget);
    expect(find.text('DEMONSTRAÇÃO'), findsNothing);
    await tester.tap(find.text('Terminal'));
    await tester.pumpAndSettle();
    expect(find.text('Terminal desligado'), findsOneWidget);
    await tester.tap(find.byTooltip('Abrir instâncias'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('channel-test-coolify')));
    await tester.pumpAndSettle();
    expect(controller.selected!.type.name, 'coolify');
    expect(find.text('Os seus recursos'), findsOneWidget);
    expect(find.text('capidock-web'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Form validates, creates, edits and removes an instance', (
    tester,
  ) async {
    final controller = await launch(tester);
    await tester.tap(find.byTooltip('Adicionar instância'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('save-instance')));
    await tester.tap(find.byKey(const ValueKey('save-instance')));
    await tester.pumpAndSettle();
    expect(find.text('Dê um nome à instância.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('instance-name')),
      'meu-vps',
    );
    await tester.enterText(
      find.byKey(const ValueKey('instance-host')),
      'server.example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('instance-user')),
      'deploy',
    );
    await tester.enterText(
      find.byKey(const ValueKey('instance-password')),
      'test-password',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('save-instance')));
    await tester.tap(find.byKey(const ValueKey('save-instance')));
    await tester.pumpAndSettle();
    expect(controller.instances, hasLength(4));
    expect(find.text('Por ligar'), findsOneWidget);
    expect(find.text('DEMONSTRAÇÃO'), findsNothing);
    await tester.tap(find.text('Editar acesso'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('instance-name')),
      'meu-vps-2',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('save-instance')));
    await tester.tap(find.byKey(const ValueKey('save-instance')));
    await tester.pumpAndSettle();
    expect(controller.selected!.name, 'meu-vps-2');
    await tester.tap(find.byTooltip('Opções da instância'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remover instância'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remover'));
    await tester.pumpAndSettle();
    expect(controller.instances, hasLength(3));
    expect(tester.takeException(), isNull);
  });

  for (final entry in [
    (const Size(320, 700), 1.0),
    (const Size(390, 844), 1.5),
    (const Size(1024, 800), 1.0),
  ]) {
    testWidgets(
      'Layout has no overflow at ${entry.$1}, text scale ${entry.$2}',
      (tester) async {
        await launch(tester, size: entry.$1, scale: entry.$2);
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(ListView).last, const Offset(0, -550));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
