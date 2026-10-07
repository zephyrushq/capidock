import 'package:dartssh2/dartssh2.dart';

/// Runs in a worker isolate: decrypting OpenSSH keys can be expensive.
List<SSHKeyPair> decodeSshIdentity((String, String) input) =>
    SSHKeyPair.fromPem(input.$1.trim(), input.$2.isEmpty ? null : input.$2);
