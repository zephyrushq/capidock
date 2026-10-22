import 'dart:async';

import '../../connections/data/ssh_connection.dart';
import '../../connections/data/ssh_terminal_channel.dart';
import 'docker_command.dart';
import 'docker_models.dart';
import 'docker_create_spec.dart';

class DockerClient {
  DockerClient(this.connection);
  final SshConnection connection;
  DockerCancellation _cancellation = DockerCancellation();
  bool _disposed = false;
  void cancelPending() {
    _cancellation.cancel();
    _cancellation = DockerCancellation();
  }

  void dispose() {
    _disposed = true;
    _cancellation.cancel();
  }

  Future<String> _run(DockerOperation operation, [String? id]) async {
    return _execute(DockerCommand(operation, id: id));
  }

  Future<String> _execute(DockerCommand command) async {
    if (_disposed) throw const DockerException(DockerFailure.cancelled);
    final token = _cancellation;
    try {
      final result = await connection.executeDocker(command, token);
      if (_disposed || token.cancelled) {
        throw const DockerException(DockerFailure.cancelled);
      }
      if (result.exitCode != 0) {
        final message = '${result.stderr}\n${result.stdout}'.toLowerCase();
        throw DockerException(
          command.operation == DockerOperation.create &&
                  message.contains('already in use')
              ? DockerFailure.nameConflict
              : command.operation == DockerOperation.create &&
                    (message.contains('pull access denied') ||
                        message.contains('manifest unknown') ||
                        message.contains('repository does not exist'))
              ? DockerFailure.imageUnavailable
              : result.exitCode == 127
              ? DockerFailure.notInstalled
              : message.contains('permission denied')
              ? DockerFailure.permission
              : message.contains('no such container') ||
                    message.contains('no such object')
              ? DockerFailure.notFound
              : message.contains('cannot connect') ||
                    message.contains('is the docker daemon running')
              ? DockerFailure.unavailable
              : DockerFailure.failed,
        );
      }
      return result.stdout;
    } on TimeoutException {
      throw const DockerException(DockerFailure.timeout);
    }
  }

  Future<T> _parse<T>(Future<String> read, T Function(String) parse) async {
    final raw = await read;
    try {
      return parse(raw);
    } catch (_) {
      throw const DockerException(DockerFailure.invalidResponse);
    }
  }

  Future<List<DockerContainer>> containers() =>
      _parse(_run(DockerOperation.list), DockerContainer.parse);
  Future<DockerDetails> details(String id) => _parse(
    _run(DockerOperation.inspect, id),
    (raw) {
      final details = DockerDetails(dockerObject(raw));
      if (details.id != id) throw const FormatException('Mismatched container');
      return details;
    },
  );
  Future<DockerStats?> stats(String id) => _parse(
    _run(DockerOperation.stats, id),
    (raw) => raw.trim().isEmpty ? null : DockerStats(dockerObject(raw), id),
  );
  Future<String> logs(String id) => _run(DockerOperation.logs, id);
  Future<void> act(DockerOperation operation, String id) async {
    if (!const {
      DockerOperation.start,
      DockerOperation.stop,
      DockerOperation.restart,
    }.contains(operation)) {
      throw ArgumentError('Not a Docker action');
    }
    await _run(operation, id);
  }

  Future<String> create(DockerCreateSpec spec) =>
      _parse(_execute(DockerCommand.create(spec)), (raw) {
        final id = raw.trim();
        validateContainerId(id);
        return id;
      });

  Future<SshTerminalChannel> terminal(String id, String shell) async {
    final token = _cancellation;
    final current = await details(id);
    if (!current.running) throw const DockerException(DockerFailure.notFound);
    if (_disposed || token.cancelled) {
      throw const DockerException(DockerFailure.cancelled);
    }
    return connection.openDockerTerminal(id, shell, token);
  }
}
