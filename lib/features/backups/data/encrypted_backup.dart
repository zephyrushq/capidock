import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../../workspaces/domain/dock_workspace.dart';

class BackupException implements Exception {
  const BackupException(this.code);
  final String code;
}

/// Versioned, authenticated, password-based backups. Only ciphertext reaches
/// the file picker. Fixed KDF parameters reject downgrade and resource attacks.
class EncryptedBackup {
  static const maxFileBytes = 8 * 1024 * 1024;
  static const maxPlaintextBytes = 4 * 1024 * 1024;
  static const iterations = 600000;
  static const aad =
      'Capidock backup v1 | AES-256-GCM | PBKDF2-HMAC-SHA256:600000';

  static Future<Uint8List> export(
    List<DockWorkspace> workspaces,
    String password,
  ) {
    if (password.runes.length < 12 || password.length > 1024) {
      throw const BackupException('backupPasswordWeak');
    }
    final data = {
      'version': 1,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'workspaces': workspaces.map((workspace) => workspace.toJson()).toList(),
    };
    validatePayload(data);
    return Isolate.run(() => _encrypt(data, password));
  }

  static Future<List<DockWorkspace>> import(Uint8List bytes, String password) {
    if (bytes.length > maxFileBytes ||
        password.length > 1024 ||
        password.isEmpty) {
      throw const BackupException('backupInvalid');
    }
    return Isolate.run(() => _decrypt(bytes, password));
  }

  static Future<SecretKey> _key(String password, List<int> salt) async {
    final passwordKey = SecretKey(utf8.encode(password));
    try {
      return await Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: iterations,
        bits: 256,
      ).deriveKey(secretKey: passwordKey, nonce: salt);
    } finally {
      passwordKey.destroy();
    }
  }

  static Future<Uint8List> _encrypt(
    Map<String, Object> data,
    String password,
  ) async {
    final plaintext = Uint8List.fromList(utf8.encode(jsonEncode(data)));
    if (plaintext.length > maxPlaintextBytes) {
      throw const BackupException('backupTooLarge');
    }
    // Both are obtained from the cryptographic package's secure RNG.
    final cipher = AesGcm.with256bits();
    final salt = (await cipher.newSecretKey()).extractBytes();
    final saltBytes = await salt;
    final nonce = cipher.newNonce();
    final key = await _key(password, saltBytes);
    try {
      final box = await cipher.encrypt(
        plaintext,
        secretKey: key,
        nonce: nonce,
        aad: utf8.encode(aad),
      );
      return Uint8List.fromList(
        utf8.encode(
          jsonEncode({
            'format': 'capidock-backup',
            'version': 1,
            'cipher': 'AES-256-GCM',
            'kdf': 'PBKDF2-HMAC-SHA256',
            'iterations': iterations,
            'salt': base64Encode(saltBytes),
            'nonce': base64Encode(box.nonce),
            'mac': base64Encode(box.mac.bytes),
            'ciphertext': base64Encode(box.cipherText),
          }),
        ),
      );
    } finally {
      key.destroy();
      plaintext.fillRange(0, plaintext.length, 0);
    }
  }

  static Future<List<DockWorkspace>> _decrypt(
    Uint8List bytes,
    String password,
  ) async {
    try {
      final data = jsonDecode(utf8.decode(bytes));
      if (data is! Map<String, dynamic> ||
          data.length != 9 ||
          data['format'] != 'capidock-backup' ||
          data['version'] != 1 ||
          data['cipher'] != 'AES-256-GCM' ||
          data['kdf'] != 'PBKDF2-HMAC-SHA256' ||
          data['iterations'] != iterations) {
        throw const BackupException('backupInvalid');
      }
      final salt = base64Decode(data['salt'] as String);
      final nonce = base64Decode(data['nonce'] as String);
      final mac = base64Decode(data['mac'] as String);
      final ciphertext = base64Decode(data['ciphertext'] as String);
      if (salt.length != 32 ||
          nonce.length != 12 ||
          mac.length != 16 ||
          ciphertext.length > maxPlaintextBytes ||
          ciphertext.isEmpty) {
        throw const BackupException('backupInvalid');
      }
      final key = await _key(password, salt);
      late final List<int> plain;
      try {
        plain = await AesGcm.with256bits().decrypt(
          SecretBox(ciphertext, nonce: nonce, mac: Mac(mac)),
          secretKey: key,
          aad: utf8.encode(aad),
        );
      } finally {
        key.destroy();
      }
      try {
        return validatePayload(jsonDecode(utf8.decode(plain)));
      } finally {
        if (plain is Uint8List) plain.fillRange(0, plain.length, 0);
      }
    } on BackupException {
      rethrow;
    } on SecretBoxAuthenticationError {
      throw const BackupException('backupUnlockFailed');
    } catch (_) {
      throw const BackupException('backupInvalid');
    }
  }

  static List<DockWorkspace> validatePayload(Object? payload) {
    try {
      if (payload is! Map ||
          payload['version'] != 1 ||
          payload['workspaces'] is! List) {
        throw const FormatException();
      }
      final rows = payload['workspaces'] as List;
      if (rows.length > 100) throw const FormatException();
      final ids = <String>{}, instanceIds = <String>{};
      var count = 0;
      final result = <DockWorkspace>[];
      for (final row in rows) {
        if (row is! Map<String, dynamic> ||
            row['instances'] is! List ||
            (row['instances'] as List).length + count > 1000) {
          throw const FormatException();
        }
        final workspace = DockWorkspace.fromJson(row);
        if (!ids.add(workspace.id) ||
            workspace.id.length > 200 ||
            workspace.name.trim().length > 40) {
          throw const FormatException();
        }
        for (final instance in workspace.instances) {
          if (++count > 1000 ||
              !instanceIds.add(instance.id) ||
              instance.isDemo ||
              instance.id.length > 200 ||
              instance.name.length > 80 ||
              instance.host.length > 2048 ||
              instance.username.length > 256 ||
              instance.privateKey.length > 65536 ||
              instance.password.length > 4096 ||
              instance.passphrase.length > 4096 ||
              instance.apiToken.length > 4096 ||
              (instance.apiToken.isNotEmpty &&
                  RegExp(r'[\x00-\x20\x7f]').hasMatch(instance.apiToken))) {
            throw const FormatException();
          }
        }
        result.add(workspace);
      }
      return result;
    } catch (_) {
      throw const BackupException('backupInvalid');
    }
  }
}
