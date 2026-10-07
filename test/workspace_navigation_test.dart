import 'package:capidock/features/workspaces/domain/dock_workspace.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'widget_test.dart' as helpers;

void main() {
  testWidgets(
    'Create workspace, add a scoped instance, switch, move and manage',
    (tester) async {
      final controller = await helpers.launch(tester);
      await tester.tap(find.byTooltip('Abrir instâncias'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('add-workspace')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('save-workspace')));
      await tester.pumpAndSettle();
      expect(find.text('Dê um nome ao workspace.'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('workspace-name')),
        'Trabalho',
      );
      await tester.tap(find.byKey(const ValueKey('save-workspace')));
      await tester.pumpAndSettle();
      final workspaceId = controller.activeWorkspace!.id;
      expect(controller.instances, isEmpty);
      expect(
        find.byKey(const ValueKey('channel-test-production')),
        findsNothing,
      );
      await tester.tap(find.text('Nova instância'));
      await tester.pumpAndSettle();
      expect(find.text('No workspace “Trabalho”.'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('instance-name')),
        'cliente-vps',
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
      expect(controller.instances.single.name, 'cliente-vps');
      await tester.tap(find.byTooltip('Abrir instâncias'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('workspace-$defaultWorkspaceId')),
      );
      await tester.pumpAndSettle();
      expect(find.text('cliente-vps'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('channel-test-production')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Opções da instância'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mover para workspace'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(SimpleDialog),
          matching: find.text('Trabalho'),
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.activeWorkspace!.id, workspaceId);
      expect(controller.instances, hasLength(2));
      expect(controller.selected!.id, 'test-production');
      expect(controller.workspaces.first.instances, hasLength(2));

      await tester.tap(find.byTooltip('Abrir instâncias'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('workspace-switcher')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey('workspace-options-$workspaceId')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Renomear'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('workspace-name')),
        'Cliente A',
      );
      await tester.tap(find.byKey(const ValueKey('save-workspace')));
      await tester.pumpAndSettle();
      expect(controller.activeWorkspace!.name, 'Cliente A');
      await tester.tap(find.byKey(ValueKey('workspace-options-$workspaceId')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remover workspace'));
      await tester.pumpAndSettle();
      expect(find.textContaining('suas 2 instâncias'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(controller.workspaces, hasLength(2));
      await tester.tap(find.byKey(ValueKey('workspace-options-$workspaceId')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remover workspace'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remover'));
      await tester.pumpAndSettle();
      expect(controller.workspaces, hasLength(1));
      expect(controller.activeWorkspace!.id, defaultWorkspaceId);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Search is scoped to the workspace and resets when switching', (
    tester,
  ) async {
    final controller = await helpers.launch(tester);
    await controller.createWorkspace('Trabalho');
    final workId = controller.activeWorkspace!.id;
    controller.selectWorkspace(defaultWorkspaceId);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Abrir instâncias'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'staging');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('channel-test-production')), findsNothing);
    expect(find.byKey(const ValueKey('channel-test-staging')), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('workspace-$workId')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('channel-test-staging')), findsNothing);
    await tester.tap(
      find.byKey(const ValueKey('workspace-$defaultWorkspaceId')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('channel-test-production')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Last workspace removal offers workspace creation', (
    tester,
  ) async {
    final controller = await helpers.launch(tester);
    await controller.removeWorkspace(defaultWorkspaceId);
    await tester.pumpAndSettle();
    expect(find.text('Os seus servidores.\nO seu dock.'), findsOneWidget);
    expect(find.byKey(const ValueKey('onboarding-workspace')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final entry in [
    (const Size(320, 700), 1.0),
    (const Size(390, 844), 1.5),
    (const Size(1024, 800), 1.5),
  ]) {
    testWidgets('Workspace navigation adapts to ${entry.$1} / ${entry.$2}', (
      tester,
    ) async {
      final controller = await helpers.launch(
        tester,
        size: entry.$1,
        scale: entry.$2,
      );
      await controller.createWorkspace(
        'Um workspace com um nome muito comprido',
      );
      await tester.pumpAndSettle();
      if (entry.$1.width < 900) {
        await tester.tap(find.byTooltip('Abrir instâncias'));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('workspace-switcher')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
