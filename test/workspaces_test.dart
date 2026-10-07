import 'package:capidock/features/workspaces/data/workspace_store.dart';
import 'package:capidock/features/workspaces/domain/dock_controller.dart';
import 'package:capidock/features/workspaces/domain/dock_workspace.dart';
import 'package:capidock/features/instances/domain/server_instance.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

void main() {
  test(
    'Workspaces isolate instances and remember each selected channel ',
    () async {
      final store = MemoryWorkspaceStore()..data = fixtureWorkspaces();
      final controller = DockController(store);
      await controller.initialize();
      controller.select('test-staging');
      await controller.createWorkspace('Trabalho');
      final work = controller.activeWorkspace!;
      expect(controller.instances, isEmpty);
      expect(controller.selected, isNull);
      const own = ServerInstance(
        id: 'work',
        name: 'produção',
        type: InstanceType.coolify,
        host: 'https://coolify.example.com',
        port: 443,
      );
      await controller.upsert(own);
      controller.selectWorkspace(defaultWorkspaceId);
      expect(controller.instances, hasLength(3));
      expect(controller.selected!.id, 'test-staging');
      controller.selectWorkspace(work.id);
      expect(controller.instances, [own]);
      expect(controller.selected, own);
      final restored = DockController(store);
      await restored.initialize();
      restored.selectWorkspace(work.id);
      expect(restored.instances.single.id, 'work');
    },
  );

  test('Move is atomic, keeps identity and credentials, and updates both workspaces', () async {
    final store = MemoryWorkspaceStore()..data = fixtureWorkspaces();
    final controller = DockController(store);
    await controller.initialize();
    await controller.createWorkspace('Homelab');
    final target = controller.activeWorkspace!.id;
    controller.selectWorkspace(defaultWorkspaceId);
    store.failSave = true;
    await expectLater(
      controller.moveInstance('test-production', target),
      throwsStateError,
    );
    expect(controller.instances, hasLength(3));
    expect(controller.workspaces.last.instances, isEmpty);
    store.failSave = false;
    await controller.moveInstance('test-production', target);
    expect(controller.activeWorkspace!.id, target);
    expect(controller.selected!.id, 'test-production');
    expect(controller.workspaces.first.instances, hasLength(2));
    final restored = DockController(store);
    await restored.initialize();
    expect(
      restored.workspaces.expand((w) => w.instances).map((i) => i.id).toSet(),
      {'test-production', 'test-staging', 'test-coolify'},
    );
  });

  test('Renaming and deleting a workspace preserve other workspaces', () async {
    final store = MemoryWorkspaceStore()..data = fixtureWorkspaces();
    final controller = DockController(store);
    await controller.initialize();
    await controller.createWorkspace('Cliente');
    final id = controller.activeWorkspace!.id;
    await controller.moveInstance('test-production', id);
    await controller.renameWorkspace(id, 'Cliente A');
    expect(controller.activeWorkspace!.name, 'Cliente A');
    expect(controller.instances.single.id, 'test-production');
    store.failSave = true;
    await expectLater(controller.removeWorkspace(id), throwsStateError);
    expect(controller.workspaces, hasLength(2));
    expect(controller.selected!.id, 'test-production');
    store.failSave = false;
    await controller.removeWorkspace(id);
    expect(controller.activeWorkspace!.id, defaultWorkspaceId);
    expect(controller.instances.map((i) => i.id), [
      'test-staging',
      'test-coolify',
    ]);
    await controller.removeWorkspace(defaultWorkspaceId);
    expect(controller.activeWorkspace, isNull);
    final restored = DockController(store);
    await restored.initialize();
    expect(restored.workspaces, isEmpty);
    await restored.createWorkspace('Recomeçar');
    expect(restored.activeWorkspace!.name, 'Recomeçar');
    expect(restored.instances, isEmpty);
  });

  test('An instance editor saves to its original workspace even if selection changes', () async {
    final controller = DockController(
      MemoryWorkspaceStore()..data = fixtureWorkspaces(),
    );
    await controller.initialize();
    await controller.createWorkspace('Trabalho');
    const instance = ServerInstance(
      id: 'new',
      name: 'novo',
      type: InstanceType.ssh,
      host: 'server.example.com',
      port: 22,
    );
    await controller.upsert(instance, workspaceId: defaultWorkspaceId);
    expect(controller.workspaces.first.instances, hasLength(4));
    expect(controller.workspaces.last.instances, isEmpty);
  });

  test('Storage rejects duplicate instance IDs across workspaces', () async {
    final store = SecureWorkspaceStore(
      preferences: MemoryPreferences(),
      secrets: MemorySecretStore(),
    );
    await expectLater(
      store.save([
        DockWorkspace(id: 'a', name: 'A', instances: [fixtureInstances.first]),
        DockWorkspace(id: 'b', name: 'B', instances: [fixtureInstances.first]),
      ]),
      throwsFormatException,
    );
  });
}
