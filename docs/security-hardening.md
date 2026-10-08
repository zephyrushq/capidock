# Security hardening plan

Scope: Android, local workspaces, SSH and user-operated Coolify endpoints. No Capidock cloud, telemetry, account service or credential escrow is introduced.

## Threat model

Protect passwords, private keys, passphrases, API tokens, SSH host fingerprints, environment values and terminal output against network interception, accidental disclosure, backup extraction and casual access to an unlocked phone. A malicious server can still return dangerous content; server authentication does not make its content trustworthy.

A compromised/rooted device, malicious keyboard/accessibility service or runtime instrumentation can observe secrets while they are used. Managed Dart strings cannot be reliably zeroised. This patch is not a penetration test, independent certification or a guarantee against reverse engineering.

## Priority 0: transport and local credentials — implemented

- Coolify requires HTTPS, normal certificate-chain/hostname validation and TLS 1.2 or newer. There is no certificate-error bypass. Bearer tokens are sent in headers, never followed through redirects. Paths reject traversal, encoded separators, double encoding and control characters. Response size and time are bounded; remote error bodies are not echoed.
- The Android network configuration disables cleartext and trusts system certificates. Dart HTTP has its own TLS context; the XML alone does not enforce Dart transport policy. Self-signed or privately issued endpoints require a trusted certificate; no “ignore TLS errors” switch is provided.
- SSH requires explicit host-fingerprint confirmation before credentials are used and retains the accepted fingerprint in encrypted storage. Verify the first fingerprint through an independent trusted channel. Changes require confirmation. SHA-1 signatures/key exchange, SHA-1 MACs, CBC and MD5 are excluded. AES-CTR requires SHA-2 encrypt-then-MAC; AEAD ciphers are preferred. There is no automatic legacy fallback.
- Workspace credentials and accepted SSH host keys use flutter_secure_storage with explicit AES-GCM storage and RSA-OAEP/SHA-256 wrapping backed by Android Keystore. Existing encrypted storage is preserved. Legacy plaintext migration deletes old data only after verified encrypted writes. Read/decryption errors do not reset the vault. Android backup and device-transfer exclusions remain enabled.

## Priority 1: access and sensitive-screen lifecycle — implemented

- The production entry point requires the operating system's authentication before loading the vault. PIN/password and biometrics are supported through local_auth. Missing device security, cancellation and platform errors leave the app locked.
- Backgrounding invalidates the authenticated session and drops controller references to decrypted workspaces. Navigator removal/disposal is scheduled before the next visible frame; connections close through their lifecycle observers. Unlocking reads the vault again, without automatically reconnecting. Pending loads and saves cannot repopulate a locked controller. An already-started encrypted save is allowed to finish; a later unlock waits for it before loading.
- Inactive screens are hidden, including from the accessibility tree. Android FLAG_SECURE blocks platform screenshots, screen recording and unsecured display capture; Android 12+ requests overlay-window protection. These are platform controls, not protection against a compromised OS.
- Disconnecting SSH clears both terminal buffers, server information and errors. Closing/backgrounding Coolify cancels the shared HTTP client and invalidates late responses. API responses are not persisted.
- The authentication gate is an app access control. It does **not** turn the existing vault key into an authentication-bound Keystore key. Requiring device authentication for each cryptographic operation needs a separately tested migration/recovery design; it must not silently invalidate existing credentials.

## Priority 2: performance, release resilience and maintainability — implemented

- One bounded HTTP connection pool per foreground Coolify session replaces a new client per request. It closes on background/disposal. Write serialisation survives cancellation generations.
- Responses use BytesBuilder with a 4 MiB cap, avoiding a growable boxed integer list. There is no sensitive response cache.
- Explicit SSH policy and an injectable device authenticator separate security decisions from presentation and allow regression tests.
- Android release builds enable R8/resource shrinking. The release workflow obfuscates Dart and generates split debug symbols. Source remains public: obfuscation only raises the cost of casual binary inspection.
- Raw symbols are not uploaded to public Release assets or Actions artifacts. Optional GitHub secret `CAPIDOCK_SYMBOLS_PASSWORD` enables AES-256 GPG-encrypted symbol retention for 14 days; download and retain the encrypted archive with its matching version if needed. Without the secret, runner-local symbols are discarded after the job and cannot later be recovered for symbolication. Local release builds should use `--obfuscate --split-debug-info=/private/path/to/symbols` and protect that directory.
- CI runs `python3 tool/security_checks.py`: narrow regression guardrails for Android protections, certificate bypasses, SSH wire logging, redirects and tracked signing files. This is not a general secret scanner or dependency audit.

## Why there are no honeypot credentials

Fake local credentials, anti-debug traps and embedded “secret” strings are removable by a reverse engineer. They do not protect the real vault, and reporting their use would introduce a backend/telemetry/privacy obligation. No decoy credentials, hidden monitoring or blanket root ban is added. Enforceable transport, storage and access controls come first. OWASP describes resilience controls as defence in depth, not substitutes for those controls.

## Validation and release acceptance

Automated checks cover vault migration/corruption, host-key trust/change rejection, ambiguous API paths, authenticated redirect rejection, bounded responses, delayed vault loads, locked-screen authentication, stale Coolify replies and terminal cleanup. A real loopback SSH smoke server exercises password/encrypted-key authentication, PTY and probes. A temporary self-signed TLS server verifies that the default Coolify transport rejects it before receiving any HTTP request/token.

Local validation on 2026-10-08: Flutter analysis passed; 93 app tests passed
(the three real SSH tests are skipped in the general suite and passed separately);
six release-tool tests and the security guardrails passed. Debug and obfuscated
release APKs compiled successfully. The three packaged libapp.so variants
were inspected with readelf and contained no DWARF .debug_info sections.
These results do not establish Android authentication or Keystore correctness
on a physical device.

Before publishing, run the following **on a physical Android device**:

1. Upgrade over the previous APK with an existing encrypted workspace and verify that credentials remain available after device authentication.
2. Test PIN/password, biometric success/cancellation, no screen lock, screen-lock changes and biometric enrollment changes. Never reset an unreadable vault as a workaround.
3. Open SSH, reveal environment values, edit a credential, open a modal and background/lock the phone. Resume: only the locked screen should appear; sessions should be closed and old forms should be gone.
4. Try screenshots, recent-app preview, screen recording and overlay apps on Android 12+; repeat authentication/lifecycle tests on the minimum supported Android 7 device/emulator.
5. Verify a trusted HTTPS Coolify server, expired/wrong-host/untrusted certificates, redirecting URLs, first SSH fingerprint, changed host key and a legacy-only SSH server. Reject the latter rather than weakening policy.
6. Inspect app-private preferences and backup output to verify that no credential plaintext is persisted. Keystore hardware backing depends on the actual device; this patch does not claim StrongBox availability.
7. Inspect a signed, obfuscated release APK and exercise authentication after R8 shrinking. Retain the encrypted symbols if configured.

Live Coolify verification is still blocked by the supplied endpoint's Cloudflare rule. Do not describe fixture or loopback tests as verification of that deployment. Android device authentication/Keystore behaviour requires the device checks above.

## Next iterations

- P0: a device-tested authentication-bound Keystore migration with explicit invalidation/recovery behaviour; optional per-instance certificate pinning only with secure enrollment and rotation UX.
- P1: independent review of SSH library/host-key handling, dependency advisories, storage and Android lifecycle flows; permission-denied/readonly testing against a reachable Coolify staging deployment.
- P2: profile large API JSON and terminal floods on a low-memory device before introducing isolate parsing, output quotas or UI throttling. Never cache decrypted secrets to improve performance.

## References

- [Android Keystore](https://developer.android.com/privacy-and-security/keystore)
- [Android sensitive activities and overlays](https://developer.android.com/security/fraud-prevention/activities)
- [Android network security configuration](https://developer.android.com/privacy-and-security/security-config)
- [Flutter device authentication](https://pub.dev/packages/local_auth)
- [Flutter obfuscation](https://docs.flutter.dev/deployment/obfuscate)
- [OWASP MASVS resilience](https://mas.owasp.org/MASVS/11-MASVS-RESILIENCE/)
