# Local monitoring

Open **App settings → Monitoring**. Monitoring is off by default and must be enabled for each instance after explicit consent and fresh device authentication. Choose a 15, 30 or 60 minute interval, allow Android notifications, and choose alert categories. **Check soon** schedules an additional check; Android controls its execution time.

Checks run entirely on the Android device through AndroidX WorkManager. There is no Capidock monitoring backend, Firebase, Google Play Services requirement, third-party app or external push provider. WorkManager is an in-app scheduling library. Notifications are posted through a local Android bridge registered in both foreground and headless Flutter engines.

## Fast monitoring while the app is open

Enabled Coolify instances are checked immediately when the unlocked app resumes, then every 10, 30 or 60 seconds after each round finishes. The fast-monitoring toggle and interval are separate from the 15/30/60 minute background schedule. SSH uses the background schedule only. Leaving the foreground or locking the UI cancels foreground-owned connections and prevents late results from committing or notifying. Resume waits for any previous round to finish; native leases also prevent overlap with background workers.

Fast rounds start no further probes after one minute. Slow requests and multiple instances extend the effective cadence. Connection/offline failures wait at least 30 seconds; authentication, incomplete responses (including rate limits) and identity problems wait at least 60 seconds. These are polling notifications, not instantaneous push: brief deployments or transitions between requests can be missed. No two- or three-minute background schedule is promised.

## Checks and alerts

- SSH checks authenticate over the existing secure transport without opening a shell or executing commands. Connect interactively and verify the host fingerprint first. A missing/changed fingerprint is never accepted by a background check. Authentication rejection is an access problem, not proof that the server is unavailable.
- Coolify uses the existing HTTPS client: platform certificate validation, TLS 1.2 minimum, no authenticated redirects, response size and timeout limits. Checks read `/version`, the latest 20 `/deployments` and `/resources`. Read permissions are sufficient for these endpoints where supported by the server. Permission failures do not become downtime alerts.
- Two consecutive connection failures generate an alert. Further failures are deduplicated until the connection becomes reachable again. Offline/incomplete observations interrupt a failure streak; long gaps also reset it. A failure is seen **from the phone** and may reflect a VPN, firewall, DNS or mobile network problem.
- Existing failed deployments and unhealthy resources are the initial baseline. New deployment starts, completions, cancellations, failures and resource state changes generate alerts. Unknown or legacy collapsed states establish a baseline before emitting change alerts. Intentionally stopped resources are not classified as unhealthy. Polling a bounded deployment window can miss failures that disappear between checks. Up to 500 recently seen identifiers are retained per category to deduplicate paging; very old identifiers may eventually age out.
- Recovery, credentials/permissions, host identity and incomplete checks have separate events. Alerts can be disabled independently from recording observations.

## In-app floating notices

While the unlocked app is in the foreground, enabled monitoring alerts also appear as a compact floating card above any screen. Cards use the current app language, a status icon, a close button and an eight-second timeout. Repeated visible/queued categories are coalesced and the waiting queue is bounded to three notices. A native in-process event bus allows checks from the UI or a headless worker to notify the visible app, independently of Android notification permission. Only known event categories cross this bus; no server identifiers or values are included. Leaving the foreground, locking, clearing notifications or erasing monitoring data discards pending notices. Events received while closed are not replayed on reopening; the encrypted history remains available in Monitoring.

## Observed availability

Availability is the fraction of recorded reachable checks over reachable and failed checks in the retained history. Authentication rejection proves reachability and counts as reachable; offline, identity and incomplete observations are excluded. This measures observed endpoint reachability, not authenticated application health or continuous uptime. No successful samples are filled in between checks. The last check time and a stale state are shown when updates are delayed beyond twice the selected interval.

The latest observation updates on every completed check. Uptime samples are recorded no more frequently than the configured background interval, so opening the app does not oversample availability. History retains at most 30 days, 3,000 samples and 100 events per instance. Only check timestamps, status, elapsed check time, opaque identifiers and event types are retained. Elapsed time includes authentication/API reads, not an ICMP ping. Notifications use generic translated text without instance names, hosts, credentials, environment values or logs. Opening one follows normal device authentication.

## Android limits

Periodic WorkManager jobs have a [15 minute minimum](https://developer.android.com/reference/androidx/work/PeriodicWorkRequest). Doze, battery restrictions, disabled background activity, force stop and missing connectivity can delay or prevent checks. The phone must have network/VPN access to the server. There is no always-on service, exact alarm or continuous terminal session. Before the first device unlock following reboot, encrypted storage may be unavailable; checks fail safely and retry. Android notification permission and the Capidock notification channel must be enabled for alerts to appear.

No background request grants SSH trust, changes a resource or deploys anything. A user-approved background check temporarily decrypts the required saved credentials into memory; device authentication protects the UI, not each scheduled check. Use least-privilege accounts. Disable monitoring when unattended access is unwanted.

## Persistence and revocation

Configuration and history use the same AES-GCM/Android Keystore storage as the workspace vault. Jobs receive no endpoints or secrets as WorkManager input data. A native process-wide transaction gate and an encrypted expiring lease prevent foreground/headless commits from racing and prevent overlapping checks from counting twice. Network activity happens outside the transaction; each commit verifies the active configuration revision, instance existence, endpoint/credential fingerprint and lease again.

Disabling monitoring removes that instance's history. Editing the instance invalidates in-flight results and resets its baseline on the next check. Deleted instances cannot commit or alert; orphan history is pruned by a subsequent valid commit/settings save and is inaccessible in the UI. Erasing all saved server data revokes configuration and clears history/notifications under the same transaction before deleting the vault. Late checks cannot recreate erased data. A network request already in progress may finish after revocation, but its result cannot commit or notify.

Monitoring settings/history are excluded from workspace backup export/import. Maximum enabled instances: 20. The worker processes the least recently checked instances first, limits each probe, stops starting probes after eight minutes, and releases its lease on completion; a killed worker's lease expires after 12 minutes. This keeps delayed/slow instances from monopolising later runs.

## Validation

`flutter test test/monitoring_test.dart` covers failure/recovery transitions, offline gaps, baseline/deduplication, bounded retention, concurrent workers and disable/delete/edit/erase races. UI checks cover all five locales at 320×640 with larger text.

For an isolated Android smoke test, build with:

```sh
CAPIDOCK_MONITOR_SMOKE=1 flutter build apk --debug --target tool/testing/monitoring_device_smoke.dart
```

This debug-only flag uses the separate package `com.zephyrushq.capidock.monitorcheck`. Never use the smoke entry point with the production package. Install that APK, grant its Android notification permission, then launch it. It uses an unreachable loopback port and synthetic credentials, checks headless scheduling, encrypted history, failure alerts and erasure, and displays PASS/FAIL. It does not access the real Capidock vault. Remove the test package afterwards and rebuild the ordinary debug APK without the flag.
