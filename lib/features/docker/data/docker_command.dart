/// Only fixed operations and immutable Docker IDs can reach the remote shell.
enum DockerOperation { list, inspect, stats, logs, start, stop, restart }

class DockerCommand {
  DockerCommand(this.operation, {this.id}) {
    if (operation != DockerOperation.list) validateContainerId(id ?? '');
  }
  final DockerOperation operation;
  final String? id;
  bool get mutates => const {
    DockerOperation.start,
    DockerOperation.stop,
    DockerOperation.restart,
  }.contains(operation);
  Duration get timeout => Duration(seconds: mutates ? 60 : 25);
  int get limit => switch (operation) {
    DockerOperation.list => 1048576,
    DockerOperation.inspect => 262144,
    DockerOperation.logs => 524288,
    _ => 65536,
  };

  String get command => switch (operation) {
    DockerOperation.list =>
      "LC_ALL=C docker ps -a --no-trunc --format '$dockerListTemplate'",
    DockerOperation.inspect =>
      "LC_ALL=C docker inspect --type container --format '$dockerInspectTemplate' $id",
    DockerOperation.stats =>
      "LC_ALL=C docker stats --no-stream --no-trunc --format '{{json .}}' $id",
    DockerOperation.logs =>
      'LC_ALL=C docker logs --tail 200 --timestamps $id 2>&1',
    DockerOperation.start => 'LC_ALL=C docker start $id',
    DockerOperation.stop => 'LC_ALL=C docker stop $id',
    DockerOperation.restart => 'LC_ALL=C docker restart $id',
  };
}

void validateContainerId(String id) {
  if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(id)) {
    throw const FormatException('Invalid container ID');
  }
}

// Deliberately exclude environment values, labels and command arguments.
const dockerListTemplate =
    '{"ID":{{json .ID}},"Names":{{json .Names}},"Image":{{json .Image}},"State":{{json .State}},"Status":{{json .Status}},"Ports":{{json .Ports}}}';
const dockerInspectTemplate =
    r'{"id":{{json .Id}},"name":{{json .Name}},"image":{{json .Config.Image}},"state":{{json .State.Status}},"running":{{json .State.Running}},"exitCode":{{json .State.ExitCode}},"startedAt":{{json .State.StartedAt}},"restartCount":{{json .RestartCount}},"restartPolicy":{{json .HostConfig.RestartPolicy.Name}},"ports":{{json .NetworkSettings.Ports}},"mounts":[{{range $i, $m := .Mounts}}{{if $i}},{{end}}{"type":{{json $m.Type}},"source":{{json $m.Source}},"destination":{{json $m.Destination}},"rw":{{json $m.RW}}}{{end}}]}';

class DockerCommandResult {
  const DockerCommandResult(this.stdout, this.stderr, this.exitCode);
  final String stdout, stderr;
  final int? exitCode;
}

enum DockerFailure {
  notInstalled,
  permission,
  unavailable,
  notFound,
  invalidResponse,
  tooLarge,
  timeout,
  disconnected,
  cancelled,
  failed,
}

class DockerException implements Exception {
  const DockerException(this.failure);
  final DockerFailure failure;
}

/// Closing a view revokes pending requests without closing its shared SSH client.
class DockerCancellation {
  bool cancelled = false;
  final _callbacks = <void Function()>{};
  void add(void Function() callback) {
    if (cancelled) {
      callback();
    } else {
      _callbacks.add(callback);
    }
  }

  void remove(void Function() callback) => _callbacks.remove(callback);
  void cancel() {
    if (cancelled) return;
    cancelled = true;
    for (final callback in _callbacks.toList()) {
      callback();
    }
    _callbacks.clear();
  }
}
