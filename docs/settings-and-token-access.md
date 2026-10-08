# App settings and token access

App settings are available from the rightmost button on onboarding and the
sidebar footer. The mobile drawer closes before opening the settings page. Language
and terminal font size are non-sensitive local preferences. Security controls
include locking immediately, inspecting/forgetting trusted SSH fingerprints,
and erasing all saved server data after a fresh Android authentication.

Erasure unmounts the authenticated navigator and sessions, waits for outstanding
workspace saves, removes legacy migration sources and deletes the encrypted vault
and SSH trust records. Readback verifies deletion. Storage failures remain visible
on the locked screen. Language and terminal preferences are preserved. No remote
resources are deleted, no credentials are revoked, and no server request is sent.

Connection testing in instance forms uses an authenticated GET of Coolify resources
or SSH authentication only. SSH test mode never requests a shell or executes
commands, and newly confirmed trust is temporary. Credentials remain in the draft
until saved. Backgrounding or editing connection fields cancels test results.

## Permission evidence

The public Coolify API does not expose token abilities or root status. The app
therefore shows **Unknown**, **Observed** and **Denied** rather than claiming to
identify a readonly, sensitive or root token conclusively. Observations live only
in the current session and are cleared when backgrounded or the instance changes.
No write/deploy probes are sent to discover permissions.

`coolify_route_permissions.dart` indexes public v4.x API middleware metadata
reviewed on 2026-10-08. A successful operation records observed access for its
single known ability, which might have been authorised by root. Unknown routes
and alternative abilities do not invent a capability. Version differences remain
server-authoritative.

Only the exact JSON `Missing required permissions: ...` middleware message,
bounded to 4 KiB and a short timeout, records scope denial. HTML, generic 403s,
proxy/IP failures, role errors, malformed/oversized responses and 401s do not
invent scope classifications. Raw error bodies are never displayed or persisted.
Explicitly denied actions are disabled and blocked again in the request layer.
Edit/re-save the instance or start a new session to discard old observations.

Public API metadata is cached in memory as immutable data. Server responses,
environment values, credentials and permission observations are not cached on disk.
Initial requests show static accessible placeholders; refreshes retain existing
cards, show progress and allow retry with a sanitised error if the refresh fails.
Explanations are behind accessible Help buttons. Identity-change and destructive
operation confirmations retain their explicit warnings.

Sources:

- https://coolify.io/docs/api/permissions
- https://github.com/coollabsio/coolify/blob/v4.x/routes/api.php
- https://github.com/coollabsio/coolify/blob/v4.x/app/Http/Middleware/ApiAbility.php

Validation still needed before publishing: real-device PIN/biometric cancellation,
background/resume and secure-storage deletion on Android/GrapheneOS; a compatible
Coolify deployment with readonly and privileged tokens. Mocked tests do not certify
native authentication or independently audit cryptography.
