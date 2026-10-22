import 'dart:convert';

import 'docker_command.dart';

Map<String, dynamic> dockerObject(String raw) {
  final value = jsonDecode(raw);
  if (value is! Map<String, dynamic>) {
    throw const FormatException('Invalid Docker response');
  }
  return value;
}

String dockerString(Map<String, dynamic> row, String key) {
  final value = row[key];
  if (value is! String) throw const FormatException('Invalid Docker field');
  return value;
}

class DockerContainer {
  DockerContainer(Map<String, dynamic> row)
    : id = dockerString(row, 'ID'),
      name = dockerString(row, 'Names'),
      image = dockerString(row, 'Image'),
      state = dockerString(row, 'State'),
      status = dockerString(row, 'Status'),
      ports = dockerString(row, 'Ports') {
    validateContainerId(id);
  }
  final String id, name, image, state, status, ports;
  bool get running => state == 'running';
  static List<DockerContainer> parse(String raw) {
    final found = <String, DockerContainer>{};
    for (final line in const LineSplitter().convert(raw)) {
      if (line.trim().isEmpty) continue;
      final container = DockerContainer(dockerObject(line));
      if (found.containsKey(container.id) || found.length >= 1000) {
        throw const FormatException('Invalid container list');
      }
      found[container.id] = container;
    }
    return found.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }
}

class DockerDetails {
  DockerDetails(Map<String, dynamic> row)
    : id = dockerString(row, 'id'),
      name = dockerString(row, 'name').replaceFirst(RegExp(r'^/'), ''),
      image = dockerString(row, 'image'),
      state = dockerString(row, 'state'),
      startedAt = dockerString(row, 'startedAt'),
      restartPolicy = dockerString(row, 'restartPolicy'),
      running = row['running'] as bool,
      exitCode = row['exitCode'] as int,
      restartCount = row['restartCount'] as int,
      ports = Map<String, dynamic>.from(row['ports'] as Map? ?? {}),
      mounts = (row['mounts'] as List)
          .map((m) => Map<String, dynamic>.from(m as Map))
          .toList() {
    validateContainerId(id);
    for (final mount in mounts) {
      for (final key in ['type', 'source', 'destination']) {
        dockerString(mount, key);
      }
      if (mount['rw'] is! bool) throw const FormatException('Invalid mount');
    }
    for (final value in ports.values) {
      if (value == null) continue;
      for (final binding in value as List) {
        dockerString(Map<String, dynamic>.from(binding as Map), 'HostIp');
        dockerString(Map<String, dynamic>.from(binding), 'HostPort');
      }
    }
  }
  final String id, name, image, state, startedAt, restartPolicy;
  final bool running;
  final int exitCode, restartCount;
  final Map<String, dynamic> ports;
  final List<Map<String, dynamic>> mounts;
}

class DockerStats {
  DockerStats(Map<String, dynamic> row, String id)
    : cpu = dockerString(row, 'CPUPerc'),
      memory = dockerString(row, 'MemUsage'),
      memoryPercent = dockerString(row, 'MemPerc') {
    // Docker versions expose either ID or Container for the immutable target.
    if (row['ID'] != id && row['Container'] != id) {
      throw const FormatException('Mismatched stats');
    }
    if (cpu.trim().isEmpty ||
        memory.trim().isEmpty ||
        memoryPercent.trim().isEmpty) {
      throw const FormatException('Missing stats');
    }
  }
  final String cpu, memory, memoryPercent;
}
