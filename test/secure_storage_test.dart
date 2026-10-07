import 'dart:convert';

import 'package:capidock/features/instances/domain/server_instance.dart';
import 'package:capidock/features/workspaces/data/workspace_store.dart';
import 'package:capidock/features/workspaces/domain/dock_controller.dart';
import 'package:capidock/features/workspaces/domain/dock_workspace.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

const legacyDemo = ServerInstance(
  id: 'demo-production',
  name: 'produção',
  type: InstanceType.ssh,
  host: '192.0.2.10',
  port: 22,
  isDemo: true,
);

void main() {
  test('First launch and persisted empty dock never seed examples', () async {
    final memory = MemoryWorkspaceStore();
    final dock = DockController(memory);
    await dock.initialize();
    expect(dock.workspaces, isEmpty);
    expect(memory.saves, 0);
    await dock.createFirstWorkspace('Pessoal', fixtureInstances.first);
    await dock.removeWorkspace(dock.activeWorkspace!.id);
    final reopened = DockController(memory);
    await reopened.initialize();
    expect(reopened.workspaces, isEmpty);
  });

  test(
    'Atomic onboarding preserves the draft boundary when saving fails',
    () async {
      final memory = MemoryWorkspaceStore()..failSave = true;
      final dock = DockController(memory);
      await dock.initialize();
      await expectLater(
        dock.createFirstWorkspace('Personal', fixtureInstances.first),
        throwsStateError,
      );
      expect(dock.workspaces, isEmpty);
      memory.failSave = false;
      await dock.createFirstWorkspace('Personal', fixtureInstances.first);
      expect(memory.saves, 1);
      expect(dock.selected, fixtureInstances.first);
    },
  );

  test(
    'Credentials and metadata cross only the secure storage boundary',
    () async {
      final prefs = MemoryPreferences();
      final secrets = MemorySecretStore();
      final store = SecureWorkspaceStore(preferences: prefs, secrets: secrets);
      const instance = ServerInstance(
        id: 'own',
        name: 'Private',
        type: InstanceType.ssh,
        host: 'private.example.com',
        port: 22,
        username: 'deploy',
        privateKey: 'test-key',
        passphrase: 'test-passphrase',
      );
      await store.save([
        DockWorkspace(id: 'own', name: 'Private', instances: [instance]),
      ]);
      expect(prefs.values, isEmpty);
      expect(
        (await store.load())!.single.instances.single.toJson(),
        instance.toJson(),
      );
    },
  );

  for (final version in [1, 2]) {
    test(
      'v$version removes untouched demos and persists an empty encrypted dock',
      () async {
        final prefs = MemoryPreferences();
        final secrets = MemorySecretStore();
        prefs.values[version == 1
            ? SecureWorkspaceStore.legacyStorageKey
            : SecureWorkspaceStore.previousStorageKey] = jsonEncode(
          version == 1
              ? {
                  'version': 1,
                  'instances': [legacyDemo.toJson()],
                }
              : {
                  'version': 2,
                  'workspaces': [
                    DockWorkspace(
                      id: defaultWorkspaceId,
                      name: 'Meu workspace',
                      instances: [legacyDemo],
                    ).toJson(),
                  ],
                },
        );
        final store = SecureWorkspaceStore(
          preferences: prefs,
          secrets: secrets,
        );
        expect(await store.load(), isEmpty);
        expect(prefs.values, isEmpty);
        expect(
          secrets.values.containsKey(SecureWorkspaceStore.storageKey),
          isTrue,
        );
        expect(await store.load(), isEmpty);
      },
    );
  }

  test(
    'Migration preserves edited examples, mixed and renamed workspaces',
    () async {
      final prefs = MemoryPreferences();
      final secrets = MemorySecretStore();
      final edited = ServerInstance.fromJson({
        ...legacyDemo.toJson(),
        'isDemo': false,
        'host': 'my-host.example.com',
      });
      prefs.values[SecureWorkspaceStore.previousStorageKey] = jsonEncode({
        'version': 2,
        'workspaces': [
          DockWorkspace(
            id: defaultWorkspaceId,
            name: 'Meu workspace',
            instances: [edited, fixtureInstances.first],
          ).toJson(),
          DockWorkspace(
            id: 'custom',
            name: 'Custom',
            instances: [
              ServerInstance.fromJson({
                ...legacyDemo.toJson(),
                'id': 'another-demo',
              }),
            ],
          ).toJson(),
          DockWorkspace(id: 'empty', name: 'Empty').toJson(),
        ],
      });
      final store = SecureWorkspaceStore(preferences: prefs, secrets: secrets);
      final result = (await store.load())!;
      expect(result, hasLength(3));
      expect(result.first.instances.first.host, 'my-host.example.com');
      expect(result.first.instances, hasLength(2));
      expect(result[1].instances, isEmpty);
      expect(result.last.name, 'Empty');
    },
  );

  test('Failed or unverified migration retains plaintext until secure retry succeeds', () async {
    for (final drop in [false, true]) {
      final prefs = MemoryPreferences();
      final secrets = MemorySecretStore()
        ..failWrite = !drop
        ..dropWrites = drop;
      const legacy = '{"version":1,"instances":[]}';
      prefs.values[SecureWorkspaceStore.legacyStorageKey] = legacy;
      final dock = DockController(
        SecureWorkspaceStore(preferences: prefs, secrets: secrets),
      );
      await dock.initialize();
      expect(dock.loadError, isNotNull);
      expect(prefs.values[SecureWorkspaceStore.legacyStorageKey], legacy);
      secrets
        ..failWrite = false
        ..dropWrites = false;
      await dock.initialize();
      expect(dock.loadError, isNull);
      expect(prefs.values, isEmpty);
    }
  });

  test(
    'Interrupted plaintext cleanup resumes from the secure record',
    () async {
      final prefs = MemoryPreferences()..failSave = true;
      final secrets = MemorySecretStore();
      prefs.values[SecureWorkspaceStore.legacyStorageKey] =
          '{"version":1,"instances":[]}';
      final store = SecureWorkspaceStore(preferences: prefs, secrets: secrets);
      await expectLater(store.load(), throwsStateError);
      expect(secrets.values, isNotEmpty);
      prefs.failSave = false;
      expect(await store.load(), isEmpty);
      expect(prefs.values, isEmpty);
    },
  );

  test(
    'Corrupt v1, v2 or encrypted data is never reset or replaced by fallback',
    () async {
      for (final key in [
        SecureWorkspaceStore.legacyStorageKey,
        SecureWorkspaceStore.previousStorageKey,
        SecureWorkspaceStore.storageKey,
      ]) {
        final prefs = MemoryPreferences();
        final secrets = MemorySecretStore();
        (key == SecureWorkspaceStore.storageKey
                ? secrets.values
                : prefs.values)[key] =
            '{broken';
        final dock = DockController(
          SecureWorkspaceStore(preferences: prefs, secrets: secrets),
        );
        await dock.initialize();
        expect(dock.loadError, isNotNull);
        expect(
          (key == SecureWorkspaceStore.storageKey
              ? secrets.values
              : prefs.values)[key],
          '{broken',
        );
      }
    },
  );
}
