pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.1.0" apply false
    // Pin a Flutter-compatible Kotlin compiler without applying legacy KGP.
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
}

include(":app")

// Keep the upstream Dart/native sources and substitute only its Gradle script.
// Flutter 3.47 scans source text and flags the conditional legacy KGP branch.
project(":workmanager_android").apply {
    // The plugin projectDir is already its Android folder.
    val actualBuild = projectDir.resolve("build.gradle")
    val digest = java.security.MessageDigest.getInstance("SHA-256")
        .digest(actualBuild.readBytes()).joinToString("") { "%02x".format(it) }
    require(digest == "fd27a9e88c4ab79de6f8b397a573bf830290a8a2ce4cefd19cb2eed0dfe22ee9") {
        "workmanager_android changed: review or remove android/compat/workmanager_android.gradle"
    }
    buildFileName = projectDir.toPath()
        .relativize(file("compat/workmanager_android.gradle").toPath()).toString()
}
