import 'dart:convert';

import '../../instances/domain/server_instance.dart';
import '../../workspaces/data/secret_store.dart';

/// Encrypted association, bound to both endpoints. No API/SSH credentials copied.
class TerminalLinkStore {
  TerminalLinkStore({SecretStore? secrets})
    : _secrets = secrets ?? const AndroidSecretStore();
  final SecretStore _secrets;
  String _key(ServerInstance coolify, String serverUuid) =>
      'capidock.terminal-link.${Uri.encodeComponent(coolify.id)}.${Uri.encodeComponent(serverUuid)}';
  Future<String?> read(
    ServerInstance coolify,
    String uuid,
    List<ServerInstance> choices,
  ) async {
    final raw = await _secrets.read(_key(coolify, uuid));
    if (raw == null) return null;
    final data = jsonDecode(raw);
    if (data is! Map ||
        data['coolifyHost'] != coolify.host ||
        data['coolifyPort'] != coolify.port) {
      return null;
    }
    for (final ssh in choices) {
      if (ssh.id == data['sshId'] &&
          ssh.host == data['host'] &&
          ssh.port == data['port'] &&
          ssh.username == data['username'] &&
          ssh.type == InstanceType.ssh) {
        return ssh.id;
      }
    }
    return null;
  }

  Future<void> write(ServerInstance coolify, String uuid, ServerInstance ssh) =>
      _secrets.write(
        _key(coolify, uuid),
        jsonEncode({
          'coolifyHost': coolify.host,
          'coolifyPort': coolify.port,
          'sshId': ssh.id,
          'host': ssh.host,
          'port': ssh.port,
          'username': ssh.username,
        }),
      );
}
