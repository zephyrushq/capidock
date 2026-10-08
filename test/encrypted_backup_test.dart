import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:capidock/features/backups/data/encrypted_backup.dart';
import 'package:capidock/features/workspaces/domain/dock_controller.dart';
import 'package:capidock/features/workspaces/domain/dock_workspace.dart';
import 'package:flutter_test/flutter_test.dart';

import 'connections_test.dart' show coolify;
import 'test_support.dart';

void main() {
  const password = 'correct horse capybara battery';
  final workspace = DockWorkspace(
    id: 'w',
    name: 'Production',
    instances: [coolify],
  );
  late Uint8List encrypted;
  setUpAll(() async {
    encrypted = await EncryptedBackup.export([workspace], password);
  });

  test(
    'Round trip retains credentials and exposes no workspace metadata',
    () async {
      final encoded = utf8.decode(encrypted);
      expect(encoded, isNot(contains('Production')));
      expect(encoded, isNot(contains('test-token')));
      expect(encoded, isNot(contains(coolify.host)));
      final restored = await EncryptedBackup.import(encrypted, password);
      expect(restored.single.toJson(), workspace.toJson());
      final second = jsonDecode(
        utf8.decode(await EncryptedBackup.export([workspace], password)),
      ) as Map;
      final first = jsonDecode(encoded) as Map;
      expect(second['salt'], isNot(first['salt']));
      expect(second['nonce'], isNot(first['nonce']));
      expect(second['ciphertext'], isNot(first['ciphertext']));
    },
  );

  test('Interoperates with an independent Python AES-GCM/PBKDF2 fixture', () async {
    // Created with Python cryptography AESGCM and hashlib.pbkdf2_hmac,
    // fixed test-only salt/nonce. These are never used for production exports.
    final bytes = await File('test/fixtures/encrypted-backup-v1.json')
        .readAsBytes();
    final restored = await EncryptedBackup.import(
      bytes,
      'fixture-password-2026',
    );
    expect(restored.single.instances.single.password, 'test-only-password');
    expect(restored.single.name, 'Fixture');
  });

  test('Wrong password and altered ciphertext fail authentication', () async {
    await expectLater(
      EncryptedBackup.import(encrypted, 'wrong-password'),
      throwsA(
        isA<BackupException>().having(
          (e) => e.code,
          'code',
          'backupUnlockFailed',
        ),
      ),
    );
    final map = jsonDecode(utf8.decode(encrypted)) as Map<String, dynamic>;
    final cipher = base64Decode(map['ciphertext'] as String);
    cipher[0] ^= 1;
    map['ciphertext'] = base64Encode(cipher);
    await expectLater(
      EncryptedBackup.import(
        Uint8List.fromList(utf8.encode(jsonEncode(map))),
        password,
      ),
      throwsA(
        isA<BackupException>().having(
          (e) => e.code,
          'code',
          'backupUnlockFailed',
        ),
      ),
    );
  });

  test(
    'Rejects malformed files, KDF downgrade, unbounded KDF, size and nonce',
    () async {
      for (final change in [
        {'iterations': 1},
        {'iterations': 999999999},
        {'version': 2},
        {
          'nonce': base64Encode([1, 2]),
        },
        {'salt': 'not-base64'},
        {'cipher': 'AES-CBC'},
      ]) {
        final map = jsonDecode(utf8.decode(encrypted)) as Map<String, dynamic>;
        map.addAll(change);
        await expectLater(
          EncryptedBackup.import(
            Uint8List.fromList(utf8.encode(jsonEncode(map))),
            password,
          ),
          throwsA(isA<BackupException>()),
        );
      }
      await expectLater(
        EncryptedBackup.import(
          Uint8List.fromList(utf8.encode('{broken')),
          password,
        ),
        throwsA(isA<BackupException>()),
      );
      expect(
        () => EncryptedBackup.import(
          Uint8List(EncryptedBackup.maxFileBytes + 1),
          password,
        ),
        throwsA(isA<BackupException>()),
      );
      expect(
        () => EncryptedBackup.export([workspace], 'short'),
        throwsA(isA<BackupException>()),
      );
    },
  );

  test(
    'Validates identities, duplicates, endpoints and oversized collections',
    () {
      for (final rows in [
        [workspace.toJson(), workspace.toJson()],
        [
          {
            ...workspace.toJson(),
            'instances': [coolify.toJson(), coolify.toJson()],
          },
        ],
        [
          {
            ...workspace.toJson(),
            'instances': [
              {...coolify.toJson(), 'host': 'http://insecure.test'},
            ],
          },
        ],
        [
          {
            ...workspace.toJson(),
            'instances': [
              {...coolify.toJson(), 'isDemo': true},
            ],
          },
        ],
        List.generate(
          101,
          (i) => {...workspace.toJson(), 'id': '$i', 'instances': []},
        ),
      ]) {
        expect(
          () => EncryptedBackup.validatePayload({
            'version': 1,
            'workspaces': rows,
          }),
          throwsA(isA<BackupException>()),
        );
      }
    },
  );

  test('Restore adds copies with new IDs, preserving existing data and trust namespace', () async {
    final store = MemoryWorkspaceStore()..data = [workspace];
    final controller = DockController(store);
    await controller.initialize();
    await controller.importWorkspaces([workspace]);
    expect(controller.workspaces.length, 2);
    expect(controller.workspaces.first.toJson(), workspace.toJson());
    final copy = controller.workspaces.last;
    expect(copy.id, isNot(workspace.id));
    expect(copy.instances.single.id, isNot(coolify.id));
    expect(copy.instances.single.apiToken, coolify.apiToken);
    controller.dispose();
  });

  test(
    'Failed secure save leaves current workspaces and selection unchanged',
    () async {
      final store = MemoryWorkspaceStore()..data = [workspace];
      final controller = DockController(store);
      await controller.initialize();
      store.failSave = true;
      await expectLater(
        controller.importWorkspaces([workspace]),
        throwsStateError,
      );
      expect(controller.workspaces.single.toJson(), workspace.toJson());
      expect(controller.activeWorkspace?.id, workspace.id);
      expect(store.data?.single.toJson(), workspace.toJson());
      controller.dispose();
    },
  );
}
