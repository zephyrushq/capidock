# WorkManager Gradle compatibility

The application uses Android Gradle Plugin 9.1 and built-in Kotlin. Flutter 3.47's
`FlutterPluginUtils.getSubprojectPluginState` scans plugin build script text with
regular expressions. It flags the legacy Kotlin plugin declaration inside the
conditional AGP <9/disabled-built-in-Kotlin branch in workmanager_android 0.10.9,
even when that branch never executes.

`settings.gradle.kts` substitutes only the Android Gradle script with the local
copy in this directory. All Dart/Kotlin sources, resources, Android manifests and
tests still come from the pinned upstream dependency in pubspec.lock. No package
cache or Flutter SDK files are changed, and warnings are not suppressed.

The adapted script removes the legacy plugin fallback and requires AGP 9 with
built-in Kotlin enabled. Other upstream build settings and dependencies are
preserved. The upstream build script SHA-256 is verified before substitution;
an upstream update fails clearly until this compatibility script is reviewed or
removed. Keep `android.newDsl=false` for Flutter's Android DSL compatibility.
The unapplied Kotlin compiler version declaration remains to meet Flutter's
minimum compiler version; it does not apply the legacy Kotlin Android plugin.

Source: https://pub.dev/packages/workmanager_android/versions/0.10.9
Repository: https://github.com/fluttercommunity/flutter_workmanager
Upstream build script SHA-256: `fd27a9e88c4ab79de6f8b397a573bf830290a8a2ce4cefd19cb2eed0dfe22ee9`

The upstream MIT licence is preserved in LICENSE-workmanager. Remove the override
and this directory when Flutter's detector or the upstream package no longer
requires it. Validate both debug and release Android builds after changes.
