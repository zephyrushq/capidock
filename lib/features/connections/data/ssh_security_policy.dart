import 'package:dartssh2/dartssh2.dart';

/// No SHA-1 MAC, CBC cipher, legacy RSA/SHA-1 signature or automatic downgrade.
const secureSshAlgorithms = SSHAlgorithms(
  kex: [
    SSHKexType.x25519Rfc,
    SSHKexType.x25519,
    SSHKexType.nistp521,
    SSHKexType.nistp384,
    SSHKexType.nistp256,
    SSHKexType.dhGexSha256,
    SSHKexType.dh14Sha256,
  ],
  hostkey: [
    SSHHostkeyType.ed25519,
    SSHHostkeyType.rsaSha512,
    SSHHostkeyType.rsaSha256,
    SSHHostkeyType.ecdsa521,
    SSHHostkeyType.ecdsa384,
    SSHHostkeyType.ecdsa256,
  ],
  cipher: [
    SSHCipherType.aes256gcm,
    SSHCipherType.aes128gcm,
    SSHCipherType.chacha20poly1305,
    SSHCipherType.aes256ctr,
    SSHCipherType.aes128ctr,
  ],
  mac: [SSHMacType.hmacSha256Etm, SSHMacType.hmacSha512Etm],
);
