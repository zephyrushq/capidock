import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:capidock/features/connections/data/host_key_store.dart';
import 'package:capidock/features/connections/data/ssh_connection.dart';
import 'package:capidock/features/instances/domain/server_instance.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

const configPath = String.fromEnvironment('SSH_TEST_CONFIG');

Future<void> until(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('SSH condition not met');
    }
    await Future<void>.delayed(const Duration(milliseconds: 25));
  }
}

void main() {
  for (final keyAuth in [false, true]) {
    test(
      'Real SSH ${keyAuth ? 'encrypted private key' : 'password'} auth, PTY, output and probe',
      () async {
        final config = jsonDecode(
          File(configPath).readAsStringSync(),
        ) as Map<String, dynamic>;
        final instance = ServerInstance(
          id: 'transport',
          name: 'Local test',
          type: InstanceType.ssh,
          host: '127.0.0.1',
          port: config['port'] as int,
          username: config['username'] as String,
          password: keyAuth ? '' : config['password'] as String,
          privateKey: keyAuth ? config['privateKey'] as String : '',
          passphrase: keyAuth ? config['passphrase'] as String : '',
        );
        final connection = SshConnection(
          instance,
          hostKeys: HostKeyStore(secrets: MemorySecretStore()),
        );
        addTearDown(connection.dispose);
        var confirmations = 0;
        await connection.connect((type, fingerprint, old) async {
          confirmations++;
          expect(fingerprint, startsWith('SHA256:'));
          return true;
        });
        expect(
          connection.status,
          ConnectionStatus.connected,
          reason: connection.error,
        );
        connection.terminal.onOutput!('printf capidock-transport-ok\n');
        await until(
          () => connection.terminal.buffer.getText().contains(
            'capidock-transport-ok',
          ),
        );
        await until(() => !connection.refreshing);
        expect(connection.information, contains('Linux'));
        expect(connection.information, contains('DISK /'));
        connection.terminal.onOutput!('exit\n');
        await until(() => connection.status == ConnectionStatus.disconnected);
        await connection.connect((_, _, _) async {
          confirmations++;
          return false;
        });
        expect(connection.status, ConnectionStatus.connected);
        expect(confirmations, 1);
        connection.disconnect();
        expect(connection.terminal.onOutput, isNull);
      },
      skip: configPath.isEmpty,
    );
  }

  test(
    'Connection testing authenticates without any shell or command channel',
    () async {
      final config = jsonDecode(
        File(configPath).readAsStringSync(),
      ) as Map<String, dynamic>;
      final activity = File('$configPath.activity');
      final before = activity.readAsStringSync();
      final secrets = MemorySecretStore();
      final connection = SshConnection(
        ServerInstance(
          id: 'auth-only',
          name: 'Local authentication',
          type: InstanceType.ssh,
          host: '127.0.0.1',
          port: config['port'] as int,
          username: 'capidock-test-auth-only',
          password: config['password'] as String,
        ),
        hostKeys: HostKeyStore(secrets: secrets, persist: false),
      );
      addTearDown(connection.dispose);
      await connection.connect((_, _, _) async => true, openShell: false);
      expect(
        connection.status,
        ConnectionStatus.connected,
        reason: connection.error,
      );
      expect(connection.terminal.onOutput, isNull);
      expect(connection.information, isNull);
      expect(secrets.values, isEmpty);
      connection.disconnect();
      expect(
        activity.readAsStringSync(),
        before,
        reason: 'The server must not receive any shell or exec request',
      );
    },
    skip: configPath.isEmpty,
  );

  test('Real SSH rejects a declined host key and wrong password', () async {
    final config =
        jsonDecode(File(configPath).readAsStringSync()) as Map<String, dynamic>;
    final instance = ServerInstance(
      id: 'rejected',
      name: 'Rejected',
      type: InstanceType.ssh,
      host: '127.0.0.1',
      port: config['port'] as int,
      username: config['username'] as String,
      password: 'wrong-password',
    );
    final secrets = MemorySecretStore();
    final connection = SshConnection(
      instance,
      hostKeys: HostKeyStore(secrets: secrets),
    );
    addTearDown(connection.dispose);
    await connection.connect((_, _, _) async => false);
    expect(connection.status, ConnectionStatus.failed);
    expect(secrets.values, isEmpty);
    await connection.connect((_, _, _) async => true);
    expect(connection.status, ConnectionStatus.failed);
    expect(connection.error, contains('Autenticação recusada'));
    expect(connection.terminal.onOutput, isNull);
  }, skip: configPath.isEmpty);
}
