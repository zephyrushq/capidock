enum InstanceType {
  ssh('SSH', 'Acesso ao servidor por terminal', 22),
  coolify('Coolify', 'Aplicações e deployments', 443);

  const InstanceType(this.label, this.description, this.defaultPort);
  final String label;
  final String description;
  final int defaultPort;
}

/// Persist this object only through the encrypted workspace store.
class ServerInstance {
  const ServerInstance({
    required this.id,
    required this.name,
    required this.type,
    required this.host,
    required this.port,
    this.username = '',
    this.isDemo = false,
    this.password = '',
    this.privateKey = '',
    this.passphrase = '',
    this.apiToken = '',
  });

  final String id;
  final String name;
  final InstanceType type;
  final String host;
  final int port;
  final String username;
  final bool isDemo;
  final String password;
  final String privateKey;
  final String passphrase;
  final String apiToken;

  bool get hasCredentials => type == InstanceType.ssh
      ? username.isNotEmpty && (password.isNotEmpty || privateKey.isNotEmpty)
      : apiToken.isNotEmpty;

  String get address => type == InstanceType.ssh
      ? '${username.isEmpty ? '' : '$username@'}$host:$port'
      : host;

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'host': host,
    'port': port,
    'username': username,
    'isDemo': isDemo,
    'password': password,
    'privateKey': privateKey,
    'passphrase': passphrase,
    'apiToken': apiToken,
  };

  factory ServerInstance.fromJson(Map<String, dynamic> json) {
    final instance = ServerInstance(
      id: json['id'] as String,
      name: json['name'] as String,
      type: InstanceType.values.byName(json['type'] as String),
      host: json['host'] as String,
      port: json['port'] as int,
      username: json['username'] as String? ?? '',
      isDemo: json['isDemo'] as bool? ?? false,
      password: json['password'] as String? ?? '',
      privateKey: json['privateKey'] as String? ?? '',
      passphrase: json['passphrase'] as String? ?? '',
      apiToken: json['apiToken'] as String? ?? '',
    );
    if (instance.id.isEmpty ||
        instance.name.trim().isEmpty ||
        validateHost(instance.host, instance.type) != null ||
        instance.port < 1 ||
        instance.port > 65535) {
      throw const FormatException('Configuração de instância inválida.');
    }
    return instance;
  }

  static String? validateHost(String? value, InstanceType type) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Informe o endereço da instância.';
    if (RegExp(r'\s').hasMatch(input)) {
      return 'O endereço não pode ter espaços.';
    }
    if (type == InstanceType.coolify) {
      final uri = Uri.tryParse(input);
      if (uri == null ||
          uri.scheme != 'https' ||
          uri.host.isEmpty ||
          uri.port < 1 ||
          uri.port > 65535 ||
          uri.userInfo.isNotEmpty ||
          uri.hasQuery ||
          uri.hasFragment ||
          (uri.path.isNotEmpty && uri.path != '/')) {
        return 'Use uma URL HTTPS, como https://coolify.exemplo.pt.';
      }
    } else {
      if (input.contains('://') ||
          input.contains('/') ||
          input.contains('@') ||
          input.contains('?') ||
          input.contains('#') ||
          !RegExp(r'^[a-zA-Z0-9._:\-\[\]]+$').hasMatch(input)) {
        return 'Use apenas o hostname ou IP do servidor.';
      }
    }
    return null;
  }
}
