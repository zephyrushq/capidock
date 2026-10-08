import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<Map<String, String>> readAll();
  Future<void> delete(String key);
  Future<void> deleteAll();
}

/// Android uses authenticated AES-GCM encryption with a Keystore-protected key.
/// Decryption failures must never silently reset the user's vault.
class AndroidSecretStore implements SecretStore {
  const AndroidSecretStore();
  static Future<void> _pending = Future.value();
  static Future<void> _mutate(Future<void> Function() action) {
    final next = _pending.then((_) => action());
    _pending = next.catchError((Object _) {});
    return next;
  }

  static const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      resetOnError: false,
      migrateWithBackup: true,
      keyCipherAlgorithm:
          KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
  );

  @override
  Future<String?> read(String key) => storage.read(key: key);
  @override
  Future<void> write(String key, String value) =>
      _mutate(() => storage.write(key: key, value: value));
  @override
  Future<Map<String, String>> readAll() => storage.readAll();
  @override
  Future<void> delete(String key) => _mutate(() => storage.delete(key: key));
  @override
  Future<void> deleteAll() => _mutate(() => storage.deleteAll());
}
