# Contributing to Capidock

Capidock currently focuses on a local Android app. SSH and Coolify connections
go directly to user-configured servers; workspaces and credentials stay encrypted
on the device. See the
[README](README.md) for setup, supported features, and current limitations.

## Language and naming

Use **English** for identifiers, comments, API documentation, Markdown guides,
test descriptions, developer-facing CLI output, release notes, and commit messages.

- Dart functions, methods, parameters, variables, and fields use
  `lowerCamelCase`: `createWorkspace`, `moveInstance`, `workspaceId`.
- Dart classes, enums, and other types use `UpperCamelCase`:
  `DockController`, `ServerInstance`, `InstanceType`.
- Dart source files use `snake_case`: `dock_controller.dart`.
- Python functions, variables, and modules use `snake_case`:
  `plan_release`, `build_number`, `release_version.py`. Constants use
  `UPPER_SNAKE_CASE`.
- Follow the framework's required names for overrides and lifecycle hooks,
  such as Dart's `initState` and Python unittest's `setUp`.
- Prefer descriptive English names for actions. Keep domain terms consistent:
  a `workspace` contains `instances`; a channel represents an instance in the UI.

The app's user-facing text currently uses Portuguese (`pt_PT`). Keep localized
labels and fixtures separate from developer documentation. Tests may quote the
exact Portuguese labels that they interact with. Do not rename persisted keys,
serialized fields, or user-created data just to change naming conventions.
Keep legal entity names and third-party notices in their original form.

Comments should explain intent or constraints that are not clear from the code.
Use `///` documentation comments for Dart API contracts when useful, such as the
difference between first-launch storage and an intentionally empty workspace.

Use the repository's `.editorconfig` for UTF-8, LF line endings, a final newline,
and space indentation. Dart formatting is still defined by `dart format`.

## Issues and proposals

Use the [issue chooser](https://github.com/zephyrushq/capidock-mobile/issues/new/choose)
for bug reports, feature requests, and documentation improvements. Search existing
issues first, use a concise English title, and keep each report focused on one
problem. Bug reports should include a version or commit, environment, reproduction
steps, and expected behavior. Use sample data and redact logs and screenshots.

Follow [SECURITY.md](SECURITY.md) for suspected vulnerabilities. The public
security-contact template is only for requesting a private channel; it must
never contain vulnerability details.

Discuss substantial features, new dependencies, storage changes, or new remote
services in an issue before investing in a large implementation. Keep discussion
respectful, focus feedback on the work, and do not share someone else's private
information.

## Branches and pull requests

- Branch from `release` and target `release` in your pull request.
- Use descriptive English branch names such as `feat/workspace-search`,
  `fix/storage-migration`, or `docs/android-setup`.
- Keep each PR focused on one change. Use a draft PR while the work is incomplete.
- Follow the [pull request template](.github/PULL_REQUEST_TEMPLATE.md): explain
  the problem, resulting behavior, related issues, and actual validation results.
- Include screenshots for visible UI changes. Document effects on persisted data,
  permissions, dependencies, and backwards compatibility where relevant.
- Preserve existing data and schema compatibility unless an explicit migration
  is part of the change. Do not commit build outputs or signing material.
- Address review feedback and resolve relevant CI failures before merging.

## Validation

Run these commands from the project root for code changes:

```sh
flutter pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
# For changes to SSH transport, also run the loopback test in README.md.
python3 -m unittest discover -s tool/tests -v
```

For documentation or artwork changes, check relative links, image rendering,
alternative text, and that the instructions still match the project.
Add or update tests when behavior changes; keep documentation updates focused.

## Commits and releases

Use Conventional Commits in English, for example:

```text
feat(workspaces): add workspace search
fix(storage): preserve unreadable workspace data
docs: update Android setup instructions
```

Use the same format for PR titles. For squash merges, retain the intended
Conventional Commit type and any breaking-change marker in the final commit.
For other merge strategies, the included commit messages determine versioning.
Mark incompatible changes with `!` or a `BREAKING CHANGE:` footer and explain
their impact and migration requirements.

Every push to `release` triggers the release workflow. See the
[release guide](docs/releases.md) for version rules and signing configuration.
Do not commit signing keys, passwords, tokens, or local secrets.

## GitHub setup for maintainers

Issue forms and the PR template become available after these files reach the
repository's default branch, currently `release`. The templates do not depend on
custom labels, assignees, or organization-level issue types.

To receive vulnerability reports privately, enable **Private vulnerability
reporting** in the repository's security settings and make sure the maintainers
receive security notifications. See GitHub's
[setup instructions](https://docs.github.com/en/code-security/how-tos/report-and-fix-vulnerabilities/configure-vulnerability-reporting/configure-for-a-repository).
The security policy and templates alone do not change this setting.

## Licensing and branding

Preserve applicable notices in [LICENSE](LICENSE), [COPYRIGHT](COPYRIGHT), and
[LICENSE-TRADEMARKS](LICENSE-TRADEMARKS). Third-party components retain their own
licenses. The [branding guide](assets/branding/README.md) records asset provenance
and the policy for using the Capidock name, logo, and icon.
