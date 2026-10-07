# Security policy

Capidock is maintained by **ZEPHYRUS PROSPERITY - UNIPESSOAL LDA**.
This policy covers the Android app, local storage, dependencies as used by
Capidock, and the build and release tooling in
[zephyrushq/capidock-mobile](https://github.com/zephyrushq/capidock-mobile).

## Supported versions

Security fixes target the latest published release and the current `release`
branch. Before the first published release, report against the current branch.
Older versions, forks, and modified third-party builds do not receive guaranteed
backports. Reports affecting them are still useful when the issue also affects
the current upstream code.

This is an early-stage project. This policy does not establish a fixed support
period, guaranteed response time, or paid bug bounty program.

## Reporting a vulnerability

**Do not publish vulnerability details in public issues, pull requests, or comments.**

1. Open the repository's [Security page](https://github.com/zephyrushq/capidock-mobile/security).
2. If **Report a vulnerability** is available, use it to send a private report
   through GitHub. You will need to sign in.
3. If the button is unavailable, open a
   [private-contact request](https://github.com/zephyrushq/capidock-mobile/issues/new?template=04-security-contact.yml).
   This request is public: ask only for a private reporting channel, without
   describing the vulnerability, affected component, or impact. Wait for the
   maintainer to provide a private channel before sharing technical details.

Adding this file does not enable GitHub private vulnerability reporting. The
contact-request path is a fallback while that feature is unavailable.

In the **private report**, include:

- The affected release/build number or commit and relevant Android/build environment.
- A concise description, affected component, and potential impact.
- Reproduction steps and a minimal proof of concept using test data.
- Relevant redacted logs, prerequisites, and any suggested mitigation.
- Whether you would like public credit and the name or handle to use.

Do not send real passwords, private keys, tokens, signing keys, or other people's
data. Test only on devices, repositories, and servers you own or are authorized
to assess. If real credentials have been exposed, revoke or rotate them through
their provider instead of including them in a report.

## Current security boundaries

- Workspace metadata and credentials are encrypted locally using AES-GCM with
  an Android Keystore-protected key through `flutter_secure_storage`. Plaintext
  legacy preferences are removed only after a verified secure migration.
- There is no biometric app lock. Credentials are accessible to the running app;
  encryption at rest cannot protect an unlocked or compromised device.
- SSH verifies host-key fingerprints and requires explicit trust for a new or
  changed key. Authentication is attempted only after host-key verification.
  Terminal input executes on the configured server with that user's privileges.
- Coolify uses HTTPS with platform certificate verification and bearer tokens;
  redirects are not followed. Current Coolify operations are read-only.
- SSH sessions close when changing instances or backgrounding the app. Terminal
  output is not persisted. There are no accounts, cloud sync, or backend services.
- Android backup and device transfer of app data are disabled. No credential
  recovery or export is available. Host-key fingerprints also use secure storage.
- Android signing material belongs outside Git and must not appear in logs or
  release assets. The release workflow uses GitHub Actions secrets.

Report missing features and ordinary functional bugs through the normal
issue templates. Suspected unauthorized data access, unintended command
execution, dependency vulnerabilities with a demonstrated impact, or release
artifact tampering belong in a private report.
If you are unsure whether an issue is security-sensitive, use the private
reporting process.

## Coordinated disclosure

Maintainers review reports, request clarification where needed, and work with
reporters on validation, a fix or mitigation, and an appropriate disclosure date.
Please coordinate publication of technical details while a fix is being prepared.
If you have a planned disclosure date, include it in the private report.

Where appropriate, confirmed fixes will be documented in release notes or a
GitHub Security Advisory. Reporter credit is included only with consent.
Response and resolution times depend on severity, reproducibility, and maintainer
availability; this policy does not promise a service-level agreement.
