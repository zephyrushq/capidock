import 'dart:typed_data' show BytesBuilder;
import 'dart:async';

import 'package:flutter/services.dart' show PlatformException;

import 'dart:convert';
import 'dart:math';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';

const sftpTransferLimit = 16 * 1024 * 1024;
const sftpEditorLimit = 256 * 1024;
String sftpName(String name) {
  if (name.isEmpty ||
      name == '.' ||
      name == '..' ||
      name.length > 255 ||
      RegExp(r'[/\x00-\x1f\x7f]').hasMatch(name)) {
    throw const FormatException('sftpInvalidName');
  }
  return name;
}

String sftpJoin(String directory, String name) =>
    '${directory == '/' ? '' : directory}/${sftpName(name)}';
String sftpParent(String path) => path == '/'
    ? '/'
    : path.substring(0, path.lastIndexOf('/')).isEmpty
    ? '/'
    : path.substring(0, path.lastIndexOf('/'));
String sftpError(Object error) => error is PlatformException
    ? (error.code == 'sftpTooLarge' ? 'sftpTooLarge' : 'sftpLocalFailed')
    : error is SftpStatusError && error.code == 3
    ? 'sftpPermissionDenied'
    : error is FormatException
    ? error.message
    : 'sftpFailed';

/// One bounded SFTP subsystem on the already verified SSH transport. No shell
/// commands, local cache or elevated privileges. Closing aborts pending requests.
class SftpBrowser {
  SftpBrowser(this.client);
  final SftpClient client;
  bool _closed = false;
  bool get isClosed => _closed;
  Future<T> _run<T>(Future<T> Function() action) async {
    if (_closed) throw StateError('SFTP closed');
    try {
      return await action().timeout(const Duration(seconds: 60));
    } on TimeoutException {
      close();
      rethrow;
    }
  }

  void close() {
    if (_closed) return;
    _closed = true;
    unawaited(client.close().catchError((Object _) {}));
  }

  Future<String> home() => _run(() => client.absolute('.'));
  Future<List<SftpName>> list(String path) => _run(() async {
    final result = <SftpName>[];
    await for (final batch in client.readdir(path)) {
      for (final entry in batch) {
        if (entry.filename == '.' || entry.filename == '..') continue;
        sftpName(entry.filename);
        result.add(entry);
        if (result.length > 5000) {
          close();
          throw const FormatException('sftpDirectoryLimit');
        }
      }
    }
    result.sort(
      (a, b) => a.attr.isDirectory != b.attr.isDirectory
          ? (a.attr.isDirectory ? -1 : 1)
          : a.filename.compareTo(b.filename),
    );
    return result;
  });
  Future<SftpFileAttrs?> stat(String path) => _run(() async {
    try {
      return await client.stat(path, followLink: false);
    } on SftpStatusError catch (e) {
      if (e.code == 2) return null;
      rethrow;
    }
  });
  Future<Uint8List> read(
    String path, {
    int limit = sftpTransferLimit,
    void Function(int)? progress,
  }) => _run(() async {
    final attrs = await client.stat(path, followLink: false);
    if (!attrs.isFile) throw const FormatException('sftpRegularOnly');
    if ((attrs.size ?? 0) > limit) throw const FormatException('sftpTooLarge');
    final file = await client.open(path);
    try {
      final builder = BytesBuilder(copy: false);
      await for (final chunk in file.read(
        length: limit + 1,
        onProgress: progress,
      )) {
        builder.add(chunk);
      }
      final bytes = builder.takeBytes();
      if (bytes.length > limit) {
        bytes.fillRange(0, bytes.length, 0);
        throw const FormatException('sftpTooLarge');
      }
      progress?.call(bytes.length);
      return bytes;
    } finally {
      await file.close();
    }
  });
  Future<void> createFolder(String path) => _run(() => client.mkdir(path));
  Future<void> delete(String path) => _run(() async {
    final attrs = await client.stat(path, followLink: false);
    // Empty directories only; symlinks are removed without following them.
    if (attrs.isDirectory) {
      await client.rmdir(path);
    } else {
      await client.remove(path);
    }
  });
  Future<void> rename(String path, String destination) => _run(() async {
    if (await stat(destination) != null) {
      throw const FormatException('sftpExists');
    }
    await client.rename(path, destination);
  });
  Future<void> upload(
    String path,
    Uint8List bytes, {
    bool overwrite = false,
    Uint8List? original,
    void Function(int)? progress,
  }) => _run(() async {
    if (bytes.length > sftpTransferLimit) {
      throw const FormatException('sftpTooLarge');
    }
    final attrs = await stat(path);
    if (attrs != null && (!overwrite || !attrs.isFile)) {
      throw const FormatException('sftpExists');
    }
    if (original != null) {
      final current = await read(path, limit: sftpEditorLimit);
      final same = listEquals(current, original);
      current.fillRange(0, current.length, 0);
      if (!same) throw const FormatException('sftpChanged');
    }
    // Replacements are staged. Never truncate the existing destination before
    // a completed write. Servers lacking overwrite-rename leave it untouched.
    final staged = attrs != null;
    final destination = staged
        ? '$path.capidock-${Random.secure().nextInt(1 << 32).toRadixString(16)}.part'
        : path;
    SftpFile? file;
    var created = false;
    try {
      file = await client.open(
        destination,
        mode:
            SftpFileOpenMode.write |
            SftpFileOpenMode.create |
            SftpFileOpenMode.exclusive,
      );
      created = true;
      await client.setStat(
        destination,
        SftpFileAttrs(mode: SftpFileMode.value(0x180)),
      );
      // Small sequential writes give bounded memory and observable progress.
      for (var offset = 0; offset < bytes.length; offset += 32768) {
        if (_closed) throw StateError('SFTP closed');
        final end = min(offset + 32768, bytes.length);
        await file.writeBytes(
          Uint8List.sublistView(bytes, offset, end),
          offset: offset,
        );
        progress?.call(end);
      }
      await file.close();
      file = null;
      if (staged) {
        await client.setStat(
          destination,
          SftpFileAttrs(
            mode: attrs.mode == null
                ? SftpFileMode.value(0x180)
                : SftpFileMode.value(attrs.mode!.value & 0x1ff),
            userID: attrs.userID,
            groupID: attrs.groupID,
          ),
        );
        final latest = await stat(path);
        if (latest == null ||
            !latest.isFile ||
            latest.size != attrs.size ||
            latest.modifyTime != attrs.modifyTime) {
          throw const FormatException('sftpChanged');
        }
        await client.rename(destination, path);
      }
      created = false;
    } finally {
      try {
        await file?.close();
      } catch (_) {}
      if (created && !_closed) {
        try {
          await client.remove(destination);
        } catch (_) {}
      }
    }
  });
}

String sftpDecodeText(Uint8List bytes) {
  if (bytes.length > sftpEditorLimit || bytes.contains(0)) {
    throw const FormatException('sftpTextOnly');
  }
  try {
    return utf8.decode(bytes);
  } catch (_) {
    throw const FormatException('sftpTextOnly');
  }
}
