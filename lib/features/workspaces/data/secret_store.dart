import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

/// Android uses authenticated AES-GCM encryption with a Keystore-protected key.
/// Decryption failures must never silently reset the user's vault.
class AndroidSecretStore implements SecretStore {
  const AndroidSecretStore();
  static const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: false, migrateWithBackup: true),
  );

  @override
  Future<String?> read(String key) => storage.read(key: key);
  @override
  Future<void> write(String key, String value) =>
      storage.write(key: key, value: value);
}
