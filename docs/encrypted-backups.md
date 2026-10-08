# Encrypted backups and activity views

App settings → Encrypted backup exports workspaces and connection credentials
to a user-selected `.capidock` document. Import decrypts and validates the file,
shows a metadata-only summary and requires confirmation before saving new copies.
Existing workspaces are preserved. New random IDs deliberately require fresh SSH
host verification. Trusted fingerprints, preferences, server resources and log
history are excluded. Exported copies are not erased by clearing the app vault.

## File format and security boundaries

- Version 1 JSON envelope: `format`, `version`, `cipher`, `kdf`, `iterations`,
  `salt`, `nonce`, `mac`, `ciphertext`. No workspace names or credentials in the header.
- AES-256-GCM with a random 12-byte nonce and a 16-byte authentication tag.
- PBKDF2-HMAC-SHA256, 600,000 iterations, random 32-byte salt, 256-bit key.
  KDF parameters are fixed and checked before derivation. Encryption binds the
  protocol version and algorithm identifiers as authenticated additional data.
- New export passwords require at least 12 Unicode characters. Passwords are
  neither stored nor recoverable. A strong unique passphrase remains necessary.
- File limit 8 MiB; plaintext limit 4 MiB; at most 100 workspaces and 1,000
  instances. Reject unsupported versions, duplicate identities, invalid endpoints,
  demo entries, malformed credentials, downgrade attempts and altered ciphertext.
- Encryption/decryption run in a separate Dart isolate using `cryptography`.
  Plaintext is not written to a temporary file; mutable plaintext buffers and
  derived keys are cleared where supported. Dart strings and object copies cannot
  be guaranteed to be wiped from memory. This is not an independent security audit.

Android uses `ACTION_CREATE_DOCUMENT` / `ACTION_OPEN_DOCUMENT`, with bounded
stream reads on a worker thread and no broad storage permission. Providers chosen
by the user may independently sync the encrypted document. While the OS picker is
active the app navigator stays behind a privacy curtain; sessions still close on
backgrounding. The guarded operation times out after five minutes and locks the
vault on failure. Device authentication is required before returning to the backup
page. Failed reauthentication locks the vault. Ordinary backgrounding retains its
normal lock behavior. Import reauthenticates before the confirmed secure write.

## Coolify activity

Runtime and deployment logs use a bounded terminal-style reader, not a JSON
envelope. Search and heuristic error/warning filters operate on visible lines.
Runtime log requests can retrieve 200, 500 or 1,000 recent lines; on-device pages
contain 200 lines. These are recent-log windows, not a full archive. Live reads
poll every three seconds without overlapping, stop on errors or backgrounding and
skip covered routes. Users can pause, follow the tail or browse previous lines.

Application deployments use API `skip`/`take`: 20 visible records plus one
lookahead record to determine whether another page exists. Search/status filters
apply to the current server page, as the help dialog explains. Backup schedules
and execution history use local pages of ten records. History accepts the API's
`executions` envelope. Cards show status and selected metadata; further details
are behind a button. Logs and configuration snapshots are omitted from metadata.
Cancellation is shown only for active deployments. Mutating actions retain
confirmation and server-authoritative permission checks.

Tests include an independent Python AES-GCM/PBKDF2 fixture, tamper and wrong-password
rejection, restore/save failure behavior, picker privacy/reauthentication, small
screens in five locales, real API query shapes and wrapped execution responses.
Native document-provider, cancellation and authentication flows still require
real-device validation; the Android build verifies compilation, not those flows.
