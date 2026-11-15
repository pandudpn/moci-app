import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// The release key lives in android/key.properties (gitignored). Without that
// file the build falls back to the debug key so `make install` still works.
val kunciRilis = Properties()
val berkasKunciRilis = rootProject.file("key.properties")
if (berkasKunciRilis.exists()) {
    berkasKunciRilis.inputStream().use { kunciRilis.load(it) }
}

android {
    namespace = "id.pandudpn.moci"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "id.pandudpn.moci"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 36
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (berkasKunciRilis.exists()) {
            create("release") {
                keyAlias = kunciRilis.getProperty("keyAlias")
                keyPassword = kunciRilis.getProperty("keyPassword")
                storeFile = file(kunciRilis.getProperty("storeFile"))
                storePassword = kunciRilis.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig =
                if (berkasKunciRilis.exists()) {
                    signingConfigs.getByName("release")
                } else {
                    signingConfigs.getByName("debug")
                }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
