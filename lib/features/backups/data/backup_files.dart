import 'package:flutter/services.dart';

import 'encrypted_backup.dart';

abstract interface class BackupFiles {
  Future<Uint8List?> open();
  Future<bool> save(Uint8List bytes);
}

/// Android Storage Access Framework: no broad storage permissions or plaintext
/// temporary files. The user explicitly chooses the source/destination.
class AndroidBackupFiles implements BackupFiles {
  const AndroidBackupFiles();
  static const _channel = MethodChannel('com.zephyrushq.capidock/backups');
  @override
  Future<Uint8List?> open() async {
    final bytes = await _channel.invokeMethod<Uint8List>('readBackup');
    if (bytes != null && bytes.length > EncryptedBackup.maxFileBytes) {
      throw const BackupException('backupTooLarge');
    }
    return bytes;
  }

  @override
  Future<bool> save(Uint8List bytes) async =>
      await _channel.invokeMethod<bool>('writeBackup', {
        'bytes': bytes,
        'name':
            'capidock-${DateTime.now().toUtc().toIso8601String().substring(0, 10)}.capidock',
      }) ??
      false;
}
