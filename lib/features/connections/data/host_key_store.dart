import 'dart:convert';

import '../../instances/domain/server_instance.dart';
import '../../workspaces/data/secret_store.dart';

typedef ConfirmHostKey = Future<bool> Function(
  String type,
  String fingerprint,
  String? previous,
);

class HostKeyStore {
  HostKeyStore({
    this._secrets = const AndroidSecretStore(),
    this.persist = true,
  });
  final bool persist;
  final SecretStore _secrets;

  Future<bool> verify(
    ServerInstance instance,
    String type,
    String fingerprint,
    ConfirmHostKey confirm, {
    required bool Function() isActive,
  }) async {
    final key = 'capidock.host-key.${instance.id}';
    final raw = await _secrets.read(key);
    final saved = raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
    final sameEndpoint =
        saved?['host'] == instance.host && saved?['port'] == instance.port;
    if (!isActive()) return false;
    if (sameEndpoint &&
        saved?['type'] == type &&
        saved?['fingerprint'] == fingerprint) {
      return true;
    }
    final previous = sameEndpoint ? (saved?['fingerprint'] as String?) : null;
    if (!await confirm(type, fingerprint, previous) || !isActive()) {
      return false;
    }
    if (!persist) return isActive();
    final value = jsonEncode({
      'host': instance.host,
      'port': instance.port,
      'type': type,
      'fingerprint': fingerprint,
    });
    await _secrets.write(key, value);
    if (await _secrets.read(key) != value) {
      throw StateError('Host key was not saved');
    }
    return isActive();
  }
}
