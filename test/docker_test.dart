import 'dart:async';
import 'dart:convert';

import 'package:capidock/features/docker/data/docker_client.dart';
import 'package:capidock/features/docker/data/docker_command.dart';
import 'package:capidock/features/docker/data/docker_models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'docker_test_support.dart';

Matcher failure(DockerFailure value) =>
    isA<DockerException>().having((e) => e.failure, 'failure', value);

void main() {
  test(
    'Only full immutable IDs and fixed operations reach Docker commands',
    () {
      for (final operation in DockerOperation.values.where(
        (v) => v != DockerOperation.list,
      )) {
        for (final id in [
          'web',
          '--help',
          '$dockerId;id',
          '$dockerId\n',
          'a' * 63,
          'A' * 64,
        ]) {
          expect(() => DockerCommand(operation, id: id), throwsFormatException);
        }
        final command = DockerCommand(operation, id: dockerId);
        expect(command.command, contains(dockerId));
        expect(command.timeout, lessThanOrEqualTo(const Duration(seconds: 60)));
      }
      expect(
        DockerCommand(DockerOperation.list).command,
        contains('ps -a --no-trunc'),
      );
      expect(dockerListTemplate, isNot(contains('.Command')));
      expect(dockerListTemplate, isNot(contains('.Labels')));
      expect(dockerInspectTemplate, isNot(contains('.Env')));
      expect(dockerInspectTemplate, isNot(contains('{{json .}}')));
      expect(
        DockerCommand(DockerOperation.logs, id: dockerId).command,
        contains('--tail 200 --timestamps'),
      );
    },
  );
  test(
    'Container models reject malformed, duplicate and mismatched identities',
    () async {
      final row = jsonEncode(dockerRow(dockerId, 'web', 'running'));
      expect(DockerContainer.parse(row).single.running, isTrue);
      expect(() => DockerContainer.parse('$row\n$row'), throwsFormatException);
      expect(
        () => DockerContainer.parse('{"ID":"name"}'),
        throwsFormatException,
      );
      final ssh = FakeDockerConnection()
        ..output = jsonEncode(dockerDetail(dockerStoppedId));
      addTearDown(ssh.dispose);
      final client = DockerClient(ssh);
      addTearDown(client.dispose);
      await expectLater(
        client.details(dockerId),
        throwsA(failure(DockerFailure.invalidResponse)),
      );
      ssh.output = jsonEncode(dockerStatsRow(dockerStoppedId));
      await expectLater(
        client.stats(dockerId),
        throwsA(failure(DockerFailure.invalidResponse)),
      );
      ssh.output = 'unsupported';
      await expectLater(
        client.containers(),
        throwsA(failure(DockerFailure.invalidResponse)),
      );
    },
  );
  test(
    'Exit failures are categorized without exposing remote error bodies',
    () async {
      final ssh = FakeDockerConnection();
      addTearDown(ssh.dispose);
      final client = DockerClient(ssh);
      addTearDown(client.dispose);
      for (final sample in [
        (127, 'docker: not found', DockerFailure.notInstalled),
        (
          1,
          'permission denied while accessing the socket',
          DockerFailure.permission,
        ),
        (1, 'Cannot connect to the Docker daemon', DockerFailure.unavailable),
        (1, 'No such container: gone', DockerFailure.notFound),
        (1, 'PRIVATE_REMOTE_CONTENT', DockerFailure.failed),
      ]) {
        ssh.result = DockerCommandResult('', sample.$2, sample.$1);
        await expectLater(client.containers(), throwsA(failure(sample.$3)));
      }
    },
  );
  test(
    'Actions are sent once and never retried on uncertain outcomes',
    () async {
      final ssh = FakeDockerConnection()
        ..failure = const DockerException(DockerFailure.timeout);
      addTearDown(ssh.dispose);
      final client = DockerClient(ssh);
      addTearDown(client.dispose);
      await expectLater(
        client.act(DockerOperation.restart, dockerId),
        throwsA(failure(DockerFailure.timeout)),
      );
      expect(ssh.requests.where((r) => r.mutates), hasLength(1));
      await expectLater(
        client.act(DockerOperation.list, dockerId),
        throwsArgumentError,
      );
    },
  );
  test(
    'Cancellation discards late results and blocks opening a terminal',
    () async {
      final ssh = FakeDockerConnection()..pending = Completer();
      addTearDown(ssh.dispose);
      final client = DockerClient(ssh);
      addTearDown(client.dispose);
      final terminal = client.terminal(dockerId, 'sh');
      await Future<void>.delayed(Duration.zero);
      final assertion = expectLater(
        terminal,
        throwsA(failure(DockerFailure.cancelled)),
      );
      client.cancelPending();
      expect(ssh.lastToken!.cancelled, isTrue);
      ssh.pending!.complete(
        DockerCommandResult(jsonEncode(dockerDetail(dockerId)), '', 0),
      );
      await assertion;
      expect(ssh.openedId, isNull);
    },
  );
  test(
    'Stopped containers have no fake metrics and cannot open a shell',
    () async {
      final ssh = FakeDockerConnection()..running = false;
      addTearDown(ssh.dispose);
      final client = DockerClient(ssh);
      addTearDown(client.dispose);
      await expectLater(
        client.terminal(dockerId, 'sh'),
        throwsA(failure(DockerFailure.notFound)),
      );
      ssh.output = '';
      expect(await client.stats(dockerId), isNull);
    },
  );
}
