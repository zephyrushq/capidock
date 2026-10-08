# Coolify integration

Capidock connects directly to the configured HTTPS Coolify installation. It does
not proxy requests through a Capidock server. Only saved instance connection
settings and credentials enter the encrypted local vault; API responses,
environment values, logs, selected upload files and unsaved remote-edit drafts
are not stored by Capidock.

## Configure access

Enable API access in Coolify and create an API token under **Keys & Tokens**.
Use the HTTPS base URL without `/api/v1`. The TLS certificate must be trusted by
Android. Configure any Coolify IP allowlist for the phone's network/VPN.

Read-only tokens can inspect resources. Writes require `write`; deployment and
server operations can additionally require `deploy` or `sensitive`. Permissions
and available fields are enforced by the installed Coolify version. Responses
of 403, 404 or 422 are reported without exposing remote error bodies, which can
contain submitted credentials. Existing read-only tokens are not upgraded.

## Resource workflows

- Read and search resources, applications, databases, services, projects and servers.
- Browse projects as environment cards; opening an environment reads its typed
  applications, databases and services. Deployment environments come from
  `/projects/{uuid}/environments`, not `/envs` (shared variables).
- Servers show their resource cards; services show components whose detail/log
  requests retain the parent service UUID.
- Resource pages keep a readable overview (status, domains, repository and key
  settings) above actions and sections. Responses use labelled fields and cards,
  not raw JSON. Optional complex request fields still accept JSON input in the
  advanced API forms.
- Open a resource to read its environment variables, logs, SQL backup
  schedules, volume/file mounts and application deployment history.
- Create, edit or remove environment variables. Values are masked until explicitly
  revealed. Resource variables are grouped into normal and preview categories.
  The value editor exposes one field and preserves the key, preview identity and
  supported flags. An unreadable value is never submitted unless explicitly edited.
  Environment keys and preview flags identify which variable the API updates.
- Edit configurations using the API's available fields. PATCH sends changed fields
  plus required fields and resource identifiers, preserving untouched remote settings.
- Start, stop, restart and deploy supported resources. The confirmation shows the
  target, endpoint and submitted fields with secrets redacted.
- Create and edit SQL backup schedules, request an immediate backup on an existing
  schedule, inspect executions and delete execution records/files where the API allows.
- Create/edit volumes and file mounts; configure and run storage backups.
- Inspect deployments and their logs; cancellation, rollback, preview deployments,
  scheduled tasks, imports and other operations are accessible in **All operations**.

Delete and database-import actions require typing the target before confirmation.
Queued work is reported as accepted, not completed. Refresh status to inspect its
outcome. Requests are never retried automatically. If a write times out or the
app is backgrounded, it might already have reached Coolify: refresh before sending
it again. Backgrounding clears API displays and forms and cancels pending clients.

## Complete operation catalogue

**All operations** contains all 291 operations from the pinned official OpenAPI
specification: applications, databases, services and their child resources,
projects/environments, teams/shared variables, backups, deployments, volumes,
tags, private keys, S3, Git integrations, notifications, cloud-provider tokens,
cloud servers, proxy and other server settings.

Operations are searchable and grouped. Path/query fields and JSON request bodies
follow their official schemas. Primitive fields use controls; complex arrays and
objects accept JSON. Technical field names and upstream descriptions retain the
API's English terminology; navigation, actions and messages use the selected app
language. Optional untouched fields are omitted so server defaults remain intact.

Backup imports support `upload`, `s3` and `server` sources where documented. The
multipart upload operation uses the Android file picker and streams the selected
file, with a generated upload UUID and the API's 10 GiB limit. Copy the returned
`upload_id` into the import operation. File extensions and engine-specific restore
options are validated by Coolify; an upload alone does not restore a database.

This is a pinned catalogue, not a guarantee that an older installation supports
every endpoint. The app does not download executable UI or specs from the server.
There is no unrestricted URL or header editor, and bearer tokens are never placed
in query strings. Authenticated redirects are refused, bodies are bounded,
responses have timeouts and a 4 MiB limit, and unexpected HTML is rejected.

## Terminal access

The public REST catalogue has log endpoints but no interactive terminal endpoint.
**Open terminal** now opens a native SSH terminal flow for a server or resource.
Select the Coolify server and associate an existing SSH instance from a workspace.
The association is kept in the encrypted vault and bound to both endpoints;
changing the SSH host, port or username invalidates it. SSH credentials and API
credentials remain separate. No dashboard cookies or private WebSocket protocols
are used.

Resource terminals query running containers over SSH using a fixed `docker ps`
command, without inspecting environment variables. Ownership is matched by
`coolify.applicationUuid`, `coolify.serviceUuid` or `coolify.databaseUuid`, with
legacy compose-project/stack-namespace matches where an appropriate Coolify label
exists. Numeric resource IDs alone are never sufficient. Service components use
their parent service UUID. A resource without identifiable running containers
shows an empty state instead of silently listing unrelated containers.

Select a container and `sh` (default) or `bash` (must be installed). Before opening,
the app refreshes the running list and rechecks ownership. Only a validated full
64-character hexadecimal Docker ID and a fixed shell name reach `docker exec -it`.
The session has a PTY, resizing, keyboard, arrows, Tab, Ctrl+C and Ctrl+D. Server
shell access is a separate explicit action. No automatic sudo or software
installation is performed. Docker must already be available to the SSH user.

Host-key verification and the existing SSH algorithm policy apply. SSH/Docker
privileges are independent of a read-only Coolify API token; Docker access may
grant full server control. Backgrounding, removing/changing the associated SSH
instance, or closing the page clears and closes the connection. Associations are
excluded from portable workspace backups and are recreated on the new device.

The ownership convention follows [Coolify docker helpers](https://github.com/coollabsio/coolify/blob/main/bootstrap/helpers/docker.php).

## Catalogue source and regeneration

Source: [Coolify OpenAPI at 81239e6](https://github.com/coollabsio/coolify/blob/81239e61323a1410ae8b9c024c0d6daab45b2029/openapi.json).
The omitted multipart annotation was checked against
`app/Http/Controllers/Api/Concerns/HandlesDatabaseImportsApi.php` at the same commit.
Upstream metadata is Apache-2.0; attribution and the unmodified license live in
`assets/coolify/NOTICE` and `assets/coolify/LICENSE.txt` and are included in app notices.

```bash
python3 tool/generate_coolify_catalog.py /path/to/openapi.json UPSTREAM_COMMIT_SHA
flutter test test/coolify_management_test.dart test/connections_test.dart
```

When updating, review changed endpoints, request fields and permissions, update
provenance and the expected coverage count, and re-test multipart contract changes.
Tests use controlled HTTP responses and do not mutate a real Coolify server.
