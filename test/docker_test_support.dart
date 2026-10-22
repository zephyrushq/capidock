import 'dart:async';
import 'dart:convert';

import 'package:capidock/features/connections/data/host_key_store.dart';
import 'package:capidock/features/connections/data/ssh_connection.dart';
import 'package:capidock/features/connections/data/ssh_terminal_channel.dart';
import 'package:capidock/features/docker/data/docker_command.dart';
import 'package:flutter/foundation.dart';
import 'package:xterm/xterm.dart';

import 'test_support.dart';

final dockerId = List.filled(64, 'a').join();
final dockerStoppedId = List.filled(64, 'b').join();
Map<String, dynamic> dockerRow(String id, String name, String state) => {
  'ID': id,
  'Names': name,
  'Image': 'nginx:alpine',
  'State': state,
  'Status': state == 'running' ? 'Up 2 hours' : 'Exited (0)',
  'Ports': '127.0.0.1:8080->80/tcp',
};
Map<String, dynamic> dockerDetail(String id, {bool running = true}) => {
  'id': id,
  'name': '/web',
  'image': 'nginx:alpine',
  'state': running ? 'running' : 'exited',
  'running': running,
  'exitCode': 0,
  'startedAt': '2026-10-22T10:00:00Z',
  'restartCount': 2,
  'restartPolicy': 'unless-stopped',
  'ports': {
    '80/tcp': [
      {'HostIp': '127.0.0.1', 'HostPort': '8080'},
    ],
  },
  'mounts': [
    {
      'type': 'volume',
      'source': '/var/lib/docker/volumes/site/_data',
      'destination': '/usr/share/nginx/html',
      'rw': false,
    },
  ],
};
Map<String, dynamic> dockerStatsRow(String id) => {
  'ID': id,
  'Container': id,
  'CPUPerc': '1.25%',
  'MemUsage': '25MiB / 1GiB',
  'MemPerc': '2.44%',
};

class FakeDockerTerminal extends ChangeNotifier implements SshTerminalChannel {
  @override
  final terminal = Terminal(maxLines: 3000);
  @override
  bool active = true;
  @override
  int? get exitCode => active ? null : 0;
  final sent = <String>[];
  FakeDockerTerminal() {
    terminal.write('container shell\r\n');
    terminal.onOutput = sent.add;
  }
  @override
  void close() {
    active = false;
    terminal.onOutput = null;
    terminal.buffer.clear();
    terminal.buffer.setCursor(0, 0);
    notifyListeners();
  }
}

class FakeDockerConnection extends SshConnection {
  FakeDockerConnection({bool connected = true})
    : super(
        fixtureInstances.first,
        hostKeys: HostKeyStore(secrets: MemorySecretStore()),
      ) {
    status = connected
        ? ConnectionStatus.connected
        : ConnectionStatus.disconnected;
    terminal.write('host shell remains intact');
  }
  final requests = <DockerCommand>[];
  bool running = true;
  String? output;
  DockerException? failure;
  DockerOperation? failingOperation;
  DockerCommandResult? result;
  Completer<DockerCommandResult>? pending;
  DockerCancellation? lastToken;
  FakeDockerTerminal? opened;
  String? openedId, openedShell;
  @override
  Future<void> connect(ConfirmHostKey confirm, {bool openShell = true}) async {
    status = ConnectionStatus.connected;
    notifyListeners();
  }

  @override
  Future<DockerCommandResult> executeDocker(
    DockerCommand command,
    DockerCancellation cancellation,
  ) async {
    requests.add(command);
    lastToken = cancellation;
    if (pending != null) return pending!.future;
    if (failure != null &&
        (failingOperation == null || failingOperation == command.operation)) {
      throw failure!;
    }
    if (result != null) return result!;
    final raw = switch (command.operation) {
      DockerOperation.list => [
        jsonEncode(dockerRow(dockerId, 'web', running ? 'running' : 'exited')),
        jsonEncode(dockerRow(dockerStoppedId, 'worker', 'exited')),
      ].join('\n'),
      DockerOperation.inspect => jsonEncode(
        dockerDetail(command.id!, running: running && command.id == dockerId),
      ),
      DockerOperation.stats => jsonEncode(dockerStatsRow(command.id!)),
      DockerOperation.logs => '2026-10-22T10:00:00Z hello from stdout\n2026-10-22T10:00:01Z stderr entry\n',
      _ => command.id!,
    };
    if (command.operation == DockerOperation.stop) running = false;
    if (command.operation == DockerOperation.start) running = true;
    return DockerCommandResult(output ?? raw, '', 0);
  }

  @override
  Future<SshTerminalChannel> openDockerTerminal(
    String id,
    String shell,
    DockerCancellation cancellation,
  ) async {
    openedId = id;
    openedShell = shell;
    opened = FakeDockerTerminal();
    cancellation.add(opened!.close);
    return opened!;
  }
}
