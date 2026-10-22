# Docker over SSH

Open an SSH instance and select **Docker**. The tab reuses the instance's trusted
SSH connection and credentials. If disconnected, connect explicitly from the
Docker tab or the server page. The remote host must have a working Docker Engine
and a Docker CLI available in the non-interactive SSH user's command path. That
user must already have permission to access Docker, including rootless Docker
when its environment is configured for non-interactive SSH commands. Capidock
does not install Docker, change permissions, invoke sudo, or require Portainer,
an agent, a backend or an exposed Docker API port.

## Containers and details

The list includes running and stopped containers, with name, image and Docker's
reported status. Search matches names, images and states. Refresh the list
manually or by pulling down. Open a container to see its full immutable ID,
image, state, start time, exit code, restart policy/count, published ports and
mounts. Server-provided names, timestamps, statuses and output are not translated.

Details refresh every ten seconds while that page is visible, the application is
resumed and no other operation is in progress. CPU and RAM are point-in-time
Docker CLI measurements; RAM shows usage/limit and percentage. Missing, stopped
or failed measurements display a dash, never simulated zeros. There is no metric
history. The list and container inspection deliberately exclude environment
values, labels, command arguments and health-check output.

## Create a container

Select **Create container** in the connected Docker tab. Enter an image reference
and a container name, then optionally add:

- Published ports: a host IPv4/IPv6 address, host/container ports from 1 to 65535,
  and TCP/UDP. The default address is `127.0.0.1`; entering `0.0.0.0` or `::`
  publishes on all corresponding server interfaces when the container starts.
- Environment variables: unique names, including explicit empty values. Values
  are hidden while editing and masked in the review. Single-line UTF-8 values,
  including spaces, quotes, dollar signs and equals signs, are sent literally.
- Mounts: named Docker volumes or existing absolute paths on the server, absolute
  container destinations and an optional read-only flag. Missing named volumes
  are created by Docker. Bind sources belong to the server, not the phone;
  writable mounts allow the container to modify their contents. A missing bind
  source fails rather than silently creating a host directory.

Review the image, name, complete port bindings, variable names and mounts before
confirming. The app submits one `docker create` operation and creates the
container **stopped**. It refreshes the list and opens its details, where **Start**
is a separate explicit action. No command, entrypoint or restart-policy override
is supplied; the image's default command is retained. Images are pulled if missing
using the server user's existing registry access. Image/registry login management
is not included.

Creation has a 180-second execution limit and a 1 MiB response limit to allow
image downloads. Names/image references, addresses, ports, environment entries and
mount paths are validated before review and at the command boundary. Duplicate
variable names, host bindings and normalized mount destinations are rejected.
Limits are 32 ports, 32 mounts, 128 variables, 8 KiB per value and 64 KiB total
UTF-8 environment input. Volume names and container names are limited to 128
characters and paths to 1,024 characters. Multiline environment values, path
segments `.`/`..` and mounting over the container root are unsupported.

Each argument is POSIX-quoted and mount fields are CSV-escaped. Environment values
are sent through SSH stdin to `--env-file /dev/stdin`, never interpolated into the
command or written to temporary files. Drafts are not persisted or included in
backups. Leaving the foreground or losing SSH clears the draft, dismisses its
review and revokes pending work. Closing the form cancels local waiting without
guaranteeing that Docker cancelled a submitted operation. An unknown result
blocks resubmission and directs you back to the list; check the actual server
state before creating again. Name conflicts and image-access failures have
separate messages and permit an explicit corrected attempt. Remote error bodies
are not displayed because they may include sensitive values.

## Logs

The **Logs** section reads the latest 200 lines with timestamps on demand. Manual
refresh fetches a new snapshot. Standard output and standard error are combined
by the remote logs command. No follow stream runs in the background. A logging
driver that cannot provide `docker logs` may reject the request. Logs can contain
application secrets; they stay in memory and are cleared when the details close,
the app leaves the foreground or SSH disconnects. They are not included in the
vault, backups, notifications or diagnostic logs.

## Actions and container terminal

Start, stop and restart each require confirmation and target the full container
ID, never a shell-interpolated name. The stop/start buttons reflect the latest
inspected state. Docker applies its configured stop behavior and timeout.
Mutations are submitted once and are never automatically retried. Closing an SSH
channel does not guarantee cancellation of a command already received by Docker.
If the outcome is unknown, the app asks you to refresh before trying again and
pauses automatic detail refresh until a manual refresh.

Choose `sh` or `bash` and open **Container terminal** for a running container.
Capidock rechecks its identity/state, then opens an independent interactive PTY
on the same SSH transport. The selected shell must exist in the image; minimal
images without a shell cannot provide this terminal. Exiting/closing that PTY
leaves the host terminal and SSH transport intact. The terminal has arrow, Tab,
Esc, Ctrl+C and Ctrl+D controls and a 3,000-line in-memory scrollback. Backgrounding,
locking, changing the instance or disconnecting SSH closes it and clears output.
Returning requires explicit reconnection/reopening.

## Bounds and compatibility

Commands have fixed operations, validated 64-character hexadecimal container IDs
and fixed shell choices. SSH still enforces the existing host-key trust policy.
Requests drain stdout and stderr together, enforce response/time limits and close
late channels after cancellation. Responses are limited to 1 MiB for the list,
256 KiB for details, 512 KiB for logs, and 64 KiB for statistics/actions; lists
support at most 1,000 containers. Oversized, malformed or mismatched responses
fail explicitly. Docker absence, socket permissions, daemon availability and
removed containers have separate messages. No persistent schema, credentials,
monitoring consent or background monitoring behavior changes.

The app does not remove containers or separately manage images, volumes,
networks or Compose projects. It targets Docker on Linux/POSIX SSH hosts and
requires the CLI's JSON/Go-template formatting support. Docker-compatible tools
are not assumed compatible without testing.

## Validation and previews

`flutter test test/docker_test.dart test/docker_ui_test.dart test/docker_create_test.dart test/docker_create_ui_test.dart` covers parsing,
command validation, confirmation, failed/uncertain actions, lifecycle cancellation,
terminal isolation, logs and layouts in all five languages with enlarged text.
The regular SSH loopback suite additionally checks bounded Docker output and
command-channel cancellation without closing the transport:

```sh
CAPIDOCK_TEST_PYTHON=/tmp/capidock-ssh-tests/bin/python bash tool/testing/run_ssh_smoke.sh
```

A separate test uses one disposable real Docker container and a loopback-only SSH
server. It verifies list/inspect JSON, real CPU/RAM responses, stdout/stderr logs,
start/stop/restart, creation with a loopback port, environment values and an owned
volume, and an interactive PTY while preserving the host shell. Install
the SSH test requirements as described in the README, then run:

```sh
CAPIDOCK_TEST_PYTHON=/tmp/capidock-ssh-tests/bin/python bash tool/testing/run_docker_smoke.sh
```

The running fixture uses Alpine 3.21 with no network, published ports or host
mounts, a read-only filesystem and dropped capabilities. A second Alpine container
is created but never started; its loopback port is configured without opening a
listener, and its named volume is owned by the test. The SSH adapter confines
Docker operations to these fixtures, including filtering the list. The script
removes both containers, the owned volume and temporary SSH credentials on completion. CI runs both transport
suites. These checks do not replace verification on a real Android device or on
your own server's Docker/SSH configuration.

Generate test-only UI previews with `FLUTTER_ROOT` set. Optionally set
`CAPIDOCK_MONO_FONT` to a local monospace TTF for faithful log rendering; otherwise
the preview uses the SDK font in place of the device font:

```sh
flutter test tool/testing/docker_preview_test.dart
```

Preview-only data: [containers](previews/docker-containers.png),
[details](previews/docker-details.png), [logs](previews/docker-logs.png),
[creation](previews/docker-create.png) and [creation review](previews/docker-create-review.png).
