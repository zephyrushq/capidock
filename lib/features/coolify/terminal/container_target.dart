import 'dart:convert';

/// Only immutable full container IDs reach an exec command. Names and API data
/// are never interpolated into commands.
String containerShellCommand(String id, String shell) {
  if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(id) ||
      !const ['sh', 'bash'].contains(shell)) {
    throw const FormatException('Invalid container terminal target');
  }
  return 'docker exec -it $id $shell';
}

const discoverContainersCommand = "docker ps --no-trunc --format '{{json .}}'";

class CoolifyTerminalTarget {
  const CoolifyTerminalTarget({
    required this.kind,
    required this.uuid,
    required this.name,
    this.details = const {},
    this.parentServiceUuid,
  });
  final String kind, uuid, name;
  final String? parentServiceUuid;
  final Map<String, dynamic> details;
  String get ownerUuid => parentServiceUuid ?? uuid;
  String get ownerType => parentServiceUuid != null
      ? 'service'
      : switch (kind) {
          'applications' => 'application',
          'databases' => 'database',
          'services' => 'service',
          _ => '',
        };
}

typedef OpenResourceTerminal = void Function(CoolifyTerminalTarget target);

class RunningContainer {
  const RunningContainer(this.id, this.name, this.image);
  final String id, name, image;
}

/// UUID ownership follows Coolify's docker helpers, including legacy compose
/// deployments. Numeric IDs alone cannot distinguish different Coolify hosts.
List<RunningContainer> resourceContainers(
  String output,
  CoolifyTerminalTarget? target,
) {
  if (output.length > 262144) throw const FormatException('Response too large');
  final found = <String, RunningContainer>{};
  for (final line in const LineSplitter().convert(output)) {
    if (line.trim().isEmpty) continue;
    final row = jsonDecode(line);
    if (row is! Map<String, dynamic>) {
      throw const FormatException('Invalid Docker output');
    }
    final id = row['ID'], name = row['Names'];
    if (id is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(id) ||
        name is! String) {
      throw const FormatException('Invalid container');
    }
    final labels = <String, String>{};
    for (final label in '${row['Labels'] ?? ''}'.split(',')) {
      final at = label.indexOf('=');
      if (at > 0) labels[label.substring(0, at)] = label.substring(at + 1);
    }
    if (target != null && target.kind != 'servers') {
      final type = target.ownerType, uuid = target.ownerUuid;
      if (type.isEmpty || uuid.isEmpty) continue;
      final explicit = labels['coolify.${type}Uuid'];
      final legacy =
          labels.containsKey('coolify.${type}Id') &&
          (labels['com.docker.compose.project'] == uuid ||
              labels['com.docker.stack.namespace'] == uuid ||
              (type == 'application' && name.startsWith('$uuid-')));
      if (explicit != uuid && !(explicit == null && legacy)) continue;
    }
    found[id] = RunningContainer(id, name, '${row['Image'] ?? ''}');
    if (found.length > 1000) throw const FormatException('Too many containers');
  }
  return found.values.toList()..sort((a, b) => a.name.compareTo(b.name));
}
