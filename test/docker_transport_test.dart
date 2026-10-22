import 'dart:convert';
import 'dart:io';

import 'package:capidock/features/connections/data/host_key_store.dart';
import 'package:capidock/features/connections/data/ssh_connection.dart';
import 'package:capidock/features/docker/data/docker_client.dart';
import 'package:capidock/features/docker/data/docker_command.dart';
import 'package:capidock/features/docker/data/docker_create_spec.dart';
import 'package:capidock/features/instances/domain/server_instance.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ssh_transport_test.dart' show until;
import 'test_support.dart';

const configPath = String.fromEnvironment('DOCKER_SSH_TEST_CONFIG');

void main() {
  test(
    'Real Docker over SSH manages and creates isolated containers',
    () async {
      final config = jsonDecode(
        File(configPath).readAsStringSync(),
      ) as Map<String, dynamic>;
      final id = config['dockerId'] as String;
      final ssh = SshConnection(
        ServerInstance(
          id: 'docker-smoke',
          name: 'Docker loopback',
          type: InstanceType.ssh,
          host: '127.0.0.1',
          port: config['port'] as int,
          username: config['username'] as String,
          password: config['password'] as String,
        ),
        hostKeys: HostKeyStore(secrets: MemorySecretStore()),
      );
      addTearDown(ssh.dispose);
      await ssh.connect((_, _, _) async => true);
      expect(ssh.status, ConnectionStatus.connected, reason: ssh.error);
      final client = DockerClient(ssh);
      addTearDown(client.dispose);
      expect((await client.containers()).single.id, id);
      expect((await client.details(id)).running, isTrue);
      final stats = await client.stats(id);
      expect(stats, isNotNull);
      expect(stats!.memory, contains('/'));
      final logs = await client.logs(id);
      expect(logs, contains('capidock-docker-stdout'));
      expect(logs, contains('capidock-docker-stderr'));
      final channel = await client.terminal(id, 'sh');
      addTearDown(channel.dispose);
      // Docker's local PTY adapter switches terminal modes during startup.
      // Wait for the actual container shell before sending the challenge.
      try {
        await until(() => channel.terminal.buffer.getText().contains('/ #'));
      } catch (_) {
        fail(
          'Docker fixture PTY did not become ready: active=${channel.active}, exit=${channel.exitCode}, output=${channel.terminal.buffer.getText()}',
        );
      }
      // BusyBox ash queries the cursor position after drawing its first prompt.
      // Let the terminal's automatic reply complete before sending user input.
      await Future<void>.delayed(const Duration(milliseconds: 250));
      channel.terminal.onOutput!("printf 'capidock-docker-%s\\n' 'pty-ok'\n");
      try {
        await until(
          () => channel.terminal.buffer.getText().contains(
            'capidock-docker-pty-ok',
          ),
        );
      } catch (_) {
        fail(
          'Docker fixture command output missing: ${channel.terminal.buffer.getText()}',
        );
      }
      channel.terminal.onOutput!('exit\n');
      await until(() => !channel.active);
      expect(ssh.status, ConnectionStatus.connected);
      expect(ssh.hasShell, isTrue);
      ssh.terminal.onOutput!('printf capidock-transport-ok\n');
      await until(
        () => ssh.terminal.buffer.getText().contains('capidock-transport-ok'),
      );
      await client.act(DockerOperation.stop, id);
      expect((await client.details(id)).running, isFalse);
      await client.act(DockerOperation.start, id);
      expect((await client.details(id)).running, isTrue);
      await client.act(DockerOperation.restart, id);
      expect((await client.details(id)).running, isTrue);
      final createdName = config['dockerCreateName'] as String;
      const environmentValue =
          r"literal ' quote $(printf SHOULD_NOT_RUN) `id` = trailing ";
      final spec = DockerCreateSpec(
        image: 'alpine:3.21',
        name: createdName,
        ports: [
          DockerPortMapping(
            hostAddress: '127.0.0.1',
            hostPort: 18080,
            containerPort: 80,
          ),
        ],
        environment: [
          DockerEnvironment('CAPIDOCK_TEST_VALUE', environmentValue),
          DockerEnvironment('CAPIDOCK_EMPTY', ''),
        ],
        mounts: [
          DockerMount(
            type: DockerMountType.volume,
            source: '$createdName-data',
            target: '/data',
          ),
        ],
      );
      final createdId = await client.create(spec);
      final created = await client.details(createdId);
      expect(created.state, 'created');
      expect(created.running, isFalse);
      expect(created.ports.keys, contains('80/tcp'));
      expect(created.mounts.single['destination'], '/data');
      final inspected = await Process.run('docker', ['inspect', createdId]);
      expect(inspected.exitCode, 0);
      final data =
          (jsonDecode(inspected.stdout as String) as List).single as Map;
      expect(
        (data['Config'] as Map)['Env'],
        contains('CAPIDOCK_TEST_VALUE=$environmentValue'),
      );
      expect((data['Config'] as Map)['Env'], contains('CAPIDOCK_EMPTY='));
      expect(
        (data['HostConfig'] as Map)['PortBindings']['80/tcp'][0]['HostIp'],
        '127.0.0.1',
      );
      expect(
        (data['HostConfig'] as Map)['PortBindings']['80/tcp'][0]['HostPort'],
        '18080',
      );
      expect((await client.containers()).map((c) => c.id), contains(createdId));
      final second = await client.terminal(id, 'sh');
      addTearDown(second.dispose);
      ssh.disconnect();
      expect(second.active, isFalse);
      expect(second.terminal.onOutput, isNull);
      expect(second.terminal.buffer.getText().trim(), isEmpty);
    },
    skip: configPath.isEmpty
        ? 'Set DOCKER_SSH_TEST_CONFIG for isolated real Docker checks'
        : false,
  );
}
