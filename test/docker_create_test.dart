import 'dart:async';
import 'dart:io';

import 'package:capidock/features/docker/data/docker_client.dart';
import 'package:capidock/features/docker/data/docker_command.dart';
import 'package:capidock/features/docker/data/docker_create_spec.dart';
import 'package:flutter_test/flutter_test.dart';

import 'docker_test_support.dart';
import 'docker_test.dart' show failure;

void main() {
  test(
    'Creation validates common public, private, tagged and digest references',
    () {
      for (final image in [
        'nginx',
        'nginx:alpine',
        'ghcr.io/team/app:v1',
        'localhost:5000/team/app:V1',
        'registry.example.com/a/b:latest',
        'alpine@sha256:${'a' * 64}',
      ]) {
        expect(DockerCreateSpec(image: image, name: 'my-app').image, image);
      }
      for (final image in [
        '',
        '--privileged',
        'nginx;id',
        'nginx\n',
        'https://registry/app',
        'name with spaces',
        'alpine@sha256:bad',
      ]) {
        expect(
          () => DockerCreateSpec(image: image, name: 'ok'),
          throwsA(isA<DockerCreateValidation>()),
        );
      }
      for (final name in ['', '-v', 'name;id', 'my name', 'x' * 129]) {
        expect(
          () => DockerCreateSpec(image: 'alpine', name: name),
          throwsA(isA<DockerCreateValidation>()),
        );
      }
    },
  );
  test('Ports support IPv4, bracketed IPv6, TCP/UDP and reject invalid or duplicate bindings', () {
    expect(
      DockerPortMapping(
        hostAddress: '::1',
        hostPort: 8080,
        containerPort: 80,
        protocol: 'udp',
      ).binding,
      '[::1]:8080:80/udp',
    );
    for (final row in [
      ('', 8080, 80, 'tcp'),
      ('localhost', 8080, 80, 'tcp'),
      ('127.0.0.1', 0, 80, 'tcp'),
      ('127.0.0.1', 8080, 65536, 'tcp'),
      ('127.0.0.1', 8080, 80, 'sctp'),
    ]) {
      expect(
        () => DockerPortMapping(
          hostAddress: row.$1,
          hostPort: row.$2,
          containerPort: row.$3,
          protocol: row.$4,
        ),
        throwsA(isA<DockerCreateValidation>()),
      );
    }
    final p = DockerPortMapping(
      hostAddress: '127.0.0.1',
      hostPort: 8080,
      containerPort: 80,
    );
    expect(
      () => DockerCreateSpec(image: 'alpine', name: 'app', ports: [p, p]),
      throwsA(isA<DockerCreateValidation>()),
    );
  });
  test('Environment uses stdin only, preserves literal values and rejects ambiguous env-file rows', () {
    const secret =
        r'''apostrophe ' double " dollar $(touch /tmp/should-not-exist) `id` = trailing space ''';
    final spec = DockerCreateSpec(
      image: 'alpine',
      name: 'app',
      environment: [
        DockerEnvironment('TOKEN', secret),
        DockerEnvironment('EMPTY', ''),
      ],
    );
    final command = DockerCommand.create(spec);
    expect(command.command, isNot(contains(secret)));
    expect(command.command, contains("'--env-file' '/dev/stdin'"));
    expect(command.input, 'TOKEN=$secret\nEMPTY=\n');
    expect(command.mutates, isTrue);
    for (final pair in [
      ('BAD-NAME', 'value'),
      ('A', 'one\ntwo'),
      ('A', '\x00'),
      ('A', '\r'),
      ('A', 'x' * 8193),
    ]) {
      expect(
        () => DockerEnvironment(pair.$1, pair.$2),
        throwsA(isA<DockerCreateValidation>()),
      );
    }
    expect(
      () => DockerCreateSpec(
        image: 'alpine',
        name: 'app',
        environment: [DockerEnvironment('A', '1'), DockerEnvironment('A', '2')],
      ),
      throwsA(isA<DockerCreateValidation>()),
    );
  });
  test('Mount CSV and POSIX quoting preserve literal host paths without shell expansion', () async {
    const path = r'''/srv/it's, "quoted" $(id) `id`''';
    final mount = DockerMount(
      type: DockerMountType.bind,
      source: path,
      target: '/data//files/',
      readOnly: true,
    );
    expect(mount.normalizedTarget, '/data/files');
    final spec = DockerCreateSpec(
      image: 'alpine',
      name: 'app',
      mounts: [mount],
    );
    final args = spec.arguments.map(dockerShellQuote).join(' ');
    final result = await Process.run('/bin/sh', [
      '-c',
      'set -- $args; printf \'%s\\n\' "\$@"',
    ]);
    expect(result.exitCode, 0);
    expect((result.stdout as String).split('\n')..removeLast(), spec.arguments);
    expect(mount.argument, contains('readonly'));
    for (final target in ['/', 'relative', '/data/../root', '/data\nother']) {
      expect(
        () => DockerMount(
          type: DockerMountType.volume,
          source: 'data',
          target: target,
        ),
        throwsA(isA<DockerCreateValidation>()),
      );
    }
    expect(
      () => DockerCreateSpec(
        image: 'alpine',
        name: 'app',
        mounts: [
          mount,
          DockerMount(
            type: DockerMountType.volume,
            source: 'other',
            target: '/data/files',
          ),
        ],
      ),
      throwsA(isA<DockerCreateValidation>()),
    );
  });
  test('Create sends one mutation, validates its ID and classifies name/image failures', () async {
    final ssh = FakeDockerConnection();
    addTearDown(ssh.dispose);
    final client = DockerClient(ssh);
    addTearDown(client.dispose);
    final spec = DockerCreateSpec(image: 'alpine', name: 'new-app');
    ssh.result = DockerCommandResult('$dockerId\n', '', 0);
    expect(await client.create(spec), dockerId);
    expect(ssh.requests.single.operation, DockerOperation.create);
    for (final sample in [
      ('Conflict. already in use', DockerFailure.nameConflict),
      ('pull access denied', DockerFailure.imageUnavailable),
    ]) {
      ssh.result = DockerCommandResult('', sample.$1, 1);
      await expectLater(client.create(spec), throwsA(failure(sample.$2)));
    }
    ssh.result = const DockerCommandResult('not-an-id', '', 0);
    await expectLater(
      client.create(spec),
      throwsA(failure(DockerFailure.invalidResponse)),
    );
    ssh.result = null;
    ssh.failure = const DockerException(DockerFailure.timeout);
    final before = ssh.requests.length;
    await expectLater(
      client.create(spec),
      throwsA(failure(DockerFailure.timeout)),
    );
    expect(ssh.requests.length, before + 1);
  });
  test(
    'Cancelled creation cannot return late success or automatically repeat',
    () async {
      final ssh = FakeDockerConnection()..pending = Completer();
      addTearDown(ssh.dispose);
      final client = DockerClient(ssh);
      addTearDown(client.dispose);
      final pending = client.create(
        DockerCreateSpec(image: 'alpine', name: 'app'),
      );
      final assertion = expectLater(
        pending,
        throwsA(failure(DockerFailure.cancelled)),
      );
      client.cancelPending();
      ssh.pending!.complete(DockerCommandResult(dockerId, '', 0));
      await assertion;
      expect(ssh.requests, hasLength(1));
    },
  );
}
