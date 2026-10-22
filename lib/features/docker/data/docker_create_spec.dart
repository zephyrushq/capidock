import 'dart:convert';
import 'dart:io';

enum DockerCreateField { image, name, ports, environment, mounts }

class DockerCreateValidation implements Exception {
  const DockerCreateValidation(this.field);
  final DockerCreateField field;
}

String dockerShellQuote(String value) =>
    "'${value.replaceAll("'", "'\"'\"'")}'";
String _csv(String value) => value.contains(',') || value.contains('"')
    ? '"${value.replaceAll('"', '""')}"'
    : value;

class DockerPortMapping {
  DockerPortMapping({
    required this.hostAddress,
    required this.hostPort,
    required this.containerPort,
    this.protocol = 'tcp',
  }) {
    if (InternetAddress.tryParse(hostAddress) == null ||
        hostAddress.contains('%') ||
        hostPort < 1 ||
        hostPort > 65535 ||
        containerPort < 1 ||
        containerPort > 65535 ||
        !const {'tcp', 'udp'}.contains(protocol)) {
      throw const DockerCreateValidation(DockerCreateField.ports);
    }
  }
  final String hostAddress, protocol;
  final int hostPort, containerPort;
  String get binding =>
      '${hostAddress.contains(':') ? '[$hostAddress]' : hostAddress}:$hostPort:$containerPort/$protocol';
}

class DockerEnvironment {
  DockerEnvironment(this.name, this.value) {
    if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_]{0,127}$').hasMatch(name) ||
        value.contains(RegExp(r'[\x00\r\n]')) ||
        utf8.encode(value).length > 8192) {
      throw const DockerCreateValidation(DockerCreateField.environment);
    }
  }
  final String name, value;
}

enum DockerMountType { volume, bind }

class DockerMount {
  DockerMount({
    required this.type,
    required this.source,
    required this.target,
    this.readOnly = false,
  }) {
    if (!validPath(target) ||
        target.split('/').every((part) => part.isEmpty) ||
        source.length > 1024 ||
        (type == DockerMountType.bind
            ? !validPath(source)
            : !validName(source))) {
      throw const DockerCreateValidation(DockerCreateField.mounts);
    }
  }
  final DockerMountType type;
  final String source, target;
  final bool readOnly;
  static bool validName(String value) =>
      value.length <= 128 &&
      RegExp(r'^[A-Za-z0-9][A-Za-z0-9_.-]*$').hasMatch(value);
  static bool validPath(String value) =>
      value.startsWith('/') &&
      value.length <= 1024 &&
      !value.contains(RegExp(r'[\x00-\x1f\x7f]')) &&
      !value.split('/').any((part) => part == '.' || part == '..');
  String get normalizedTarget =>
      '/${target.split('/').where((part) => part.isNotEmpty).join('/')}';
  String get argument => [
    'type=${type.name}',
    _csv('source=$source'),
    _csv('target=$normalizedTarget'),
    if (readOnly) 'readonly',
  ].join(',');
}

/// Validated, immutable creation draft. Environment values only travel on stdin.
class DockerCreateSpec {
  DockerCreateSpec({
    required this.image,
    required this.name,
    List<DockerPortMapping> ports = const [],
    List<DockerEnvironment> environment = const [],
    List<DockerMount> mounts = const [],
  }) : ports = List.unmodifiable(ports),
       environment = List.unmodifiable(environment),
       mounts = List.unmodifiable(mounts) {
    if (!validImage(image)) {
      throw const DockerCreateValidation(DockerCreateField.image);
    }
    if (!DockerMount.validName(name)) {
      throw const DockerCreateValidation(DockerCreateField.name);
    }
    if (ports.length > 32 ||
        ports
                .map((p) => '${p.hostAddress}:${p.hostPort}/${p.protocol}')
                .toSet()
                .length !=
            ports.length) {
      throw const DockerCreateValidation(DockerCreateField.ports);
    }
    if (environment.length > 128 ||
        environment.map((e) => e.name).toSet().length != environment.length ||
        utf8.encode(stdin).length > 65536) {
      throw const DockerCreateValidation(DockerCreateField.environment);
    }
    if (mounts.length > 32 ||
        mounts.map((m) => m.normalizedTarget).toSet().length != mounts.length) {
      throw const DockerCreateValidation(DockerCreateField.mounts);
    }
  }
  final String image, name;
  final List<DockerPortMapping> ports;
  final List<DockerEnvironment> environment;
  final List<DockerMount> mounts;
  static bool validImage(String value) =>
      value.length <= 512 &&
      RegExp(
        r'^(?:[a-z0-9]+(?:[._-][a-z0-9]+)*(?::[0-9]{1,5})?/)?[a-z0-9]+(?:(?:[._]|__|-+)[a-z0-9]+)*(?:/[a-z0-9]+(?:(?:[._]|__|-+)[a-z0-9]+)*)*(?::[A-Za-z0-9_][A-Za-z0-9_.-]{0,127})?(?:@sha256:[a-f0-9]{64})?$',
      ).hasMatch(value);
  String get stdin =>
      '${environment.map((e) => '${e.name}=${e.value}').join('\n')}${environment.isEmpty ? '' : '\n'}';
  List<String> get arguments => [
    'docker',
    'create',
    '--name',
    name,
    '--env-file',
    '/dev/stdin',
    for (final port in ports) ...['--publish', port.binding],
    for (final mount in mounts) ...['--mount', mount.argument],
    image,
  ];
  String get command =>
      'LC_ALL=C docker create ${arguments.skip(2).map(dockerShellQuote).join(' ')}';
}
