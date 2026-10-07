# Automated Android releases

The `Android release` workflow runs on pushes to `release`. It can also be started
manually from the Actions tab by selecting that branch. It does not require an app
server, user account system, paid service, or personal GitHub token.

## What gets published

1. Calculates the version from `vMAJOR.MINOR.PATCH` tags and subsequent commits.
2. Checks signing secrets, installs Flutter/JDK, and resolves the lockfile.
3. Runs versioning tests, formatting checks, static analysis, and Flutter tests.
4. Builds and verifies a signed Android release APK (API 24+).
5. Publishes the tag, commit notes, `capidock-VERSION.apk`,
   `capidock-VERSION-source.tar.gz`, `LICENSE`, `LICENSE-TRADEMARKS`, `COPYRIGHT`,
   and `SHA256SUMS` in a GitHub Release. The same files remain available as a
   workflow artifact for 14 days; this retention period does not remove the
   GitHub Release assets.

The APK includes the Android architectures supported by the Flutter build; it is
not published to Google Play. SSH connects directly to your servers; Coolify resources are read from its API. Credentials remain encrypted locally.

The source archive is generated directly from the commit identified in the notes
and tag, including lockfiles, scripts, and build instructions. Package managers
retrieve dependencies during the build. Private signing keys are excluded: use
your own key or debug mode for your builds. Keep each version's source available
for as long as you distribute its APK. Binary redistributors must fulfill the
GPL's source and notice obligations, including those applicable to their changes
and dependencies.

## Versioning rules

The first release uses `version` from `pubspec.yaml`: initially **0.2.1**.
After that, the largest change among commits since the last tag determines the bump:

| Commit | Bump | Example starting at 0.2.1 |
| --- | --- | --- |
| `feat: ...` or `feat(ssh): ...` | minor | 0.3.0 |
| `fix: ...`, `docs: ...`, `ci: ...`, `chore: ...`, and other commits | patch | 0.2.2 |
| `feat!: ...` or a `BREAKING CHANGE:` footer | major | 1.0.0 |

This rule also applies during the 0.x series. A push containing multiple commits
produces one release with all changes. Runs are serialized; if multiple pushes
arrive while a build is running, the next run checks out the latest `release` tip
and includes all pending commits. No changes disappear from the release notes.

The Android `versionCode` is `major × 1000000 + minor × 1000 + patch`: version
0.2.1 produces `0.2.1+2001`. Minor and patch must be below 1000. The script rejects
values outside Android's limit and histories that do not descend from the latest
release tag.

Tags are the source of truth after the first release. The workflow passes the
version to Flutter with `--build-name` and `--build-number`; it does not create
bot commits or edit `pubspec.yaml` on the branch. The About dialog reads the
installed APK version. Local builds without these flags use the development
version from the pubspec.

Rerunning an already published release does not change its assets. A failure
after tag creation can be retried with the same version. Publication starts as a
draft and becomes public only after all assets have been uploaded.

Release notes are generated in English. Commit subjects are included verbatim,
so write Conventional Commit messages in English too.

## Initial signing setup

A persistent key is required to update APKs without changing their signature.
Never generate a new key for each workflow run.

If you do not already have a release key, run this **once** from the project root:

```sh
python3 tool/create_signing_key.py
```

The command requires `keytool` (JDK). It creates the key in `.secrets/` with
restricted permissions and writes `android/key.properties` for local builds.
Both paths are ignored by Git. The script refuses to overwrite existing signing
material. Keep a secure backup of `.secrets/` and its passwords.

On GitHub, open **Settings → Secrets and variables → Actions → New repository secret**.
Create these four secrets by copying the full contents of the corresponding file:

| Secret | Local file |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | `.secrets/ANDROID_KEYSTORE_BASE64.txt` |
| `ANDROID_KEYSTORE_PASSWORD` | `.secrets/ANDROID_KEYSTORE_PASSWORD.txt` |
| `ANDROID_KEY_ALIAS` | `.secrets/ANDROID_KEY_ALIAS.txt` |
| `ANDROID_KEY_PASSWORD` | `.secrets/ANDROID_KEY_PASSWORD.txt` |

If you already have a key, reuse it: configure these secrets with its values and
the base64-encoded keystore. For local builds, set `storeFile`, `storePassword`,
`keyAlias`, and `keyPassword` in `android/key.properties`. A relative `storeFile`
path is resolved from the `android/` directory.

The workflow requests `contents: write` for `GITHUB_TOKEN` to publish tags and
releases. Your organization must allow GitHub Actions and the actions in use.
Rules that block `v*` tag creation must also permit this workflow. The bot does
not need permission to write commits to the branch.

Without all four secrets, publishing fails with a clear error and does not release
APKs signed with a temporary key. After configuration, use **Re-run all jobs**
or push another commit to `release`.

## Local development and validation

```sh
python3 -m unittest discover -s tool/tests -v
flutter analyze
flutter test
flutter build apk --release --build-name 0.2.1 --build-number 2001
```

Release builds require signing configuration. `flutter run` and `--debug` builds
continue using the usual development key.

An existing debug installation has a different signature. Do not uninstall it
without preserving important data first; the app does not yet support exports.
After installing the first release APK, keep using the same key for every update.

To preview the next version after creating commits:

```sh
python3 tool/release_version.py --notes /tmp/capidock-release-notes.md
```

This only reads Git history and generates notes; it does not create tags or
publish anything. To build the source from an existing release tag, check out
that tag and use the version and build number returned by this command as
Flutter's `--build-name` and `--build-number` arguments.
