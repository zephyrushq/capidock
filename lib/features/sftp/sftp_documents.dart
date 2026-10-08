import 'package:flutter/services.dart';

import 'sftp_browser.dart';

class SftpDocument {
  const SftpDocument(this.name, this.bytes);
  final String name;
  final Uint8List bytes;
}

abstract interface class SftpDocuments {
  Future<SftpDocument?> open();
  Future<bool> save(String name, Uint8List bytes);
}

class AndroidSftpDocuments implements SftpDocuments {
  const AndroidSftpDocuments();
  static const _channel = MethodChannel(
    'com.zephyrushq.capidock/sftp-documents',
  );
  @override
  Future<SftpDocument?> open() async {
    final data = await _channel.invokeMapMethod<String, Object?>(
      'readDocument',
    );
    if (data == null) return null;
    final bytes = data['bytes'];
    final name = data['name'];
    if (bytes is! Uint8List ||
        name is! String ||
        bytes.length > sftpTransferLimit) {
      throw const FormatException('sftpTooLarge');
    }
    return SftpDocument(sftpName(name), bytes);
  }

  @override
  Future<bool> save(String name, Uint8List bytes) async =>
      await _channel.invokeMethod<bool>('writeDocument', {
        'name': sftpName(name),
        'bytes': bytes,
      }) ??
      false;
}
