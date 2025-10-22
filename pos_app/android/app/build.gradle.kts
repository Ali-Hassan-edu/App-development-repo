plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.pos_app"

    // Keep Flutter-managed compile/ndk versions
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.pos_app"

        // ✅ Explicit minSdk 21 to satisfy plugins
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Modern toolchains
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    buildTypes {
        debug {
            // Keep both off in debug
            isMinifyEnabled = false
            isShrinkResources = false
        }
        release {
            // Simple release setup while developing
            isMinifyEnabled = false
            isShrinkResources = false
            // Use debug signing for now so `flutter run --release` works
            signingConfig = signingConfigs.getByName("debug")

            // If you later enable minify, also enable shrinkResources and add proguard files:
            // isMinifyEnabled = true
            // isShrinkResources = true
            // proguardFiles(
            //     getDefaultProguardFile("proguard-android-optimize.txt"),
            //     "proguard-rules.pro"
            // )
        }
    }

    // Avoid some META-INF duplicates
    packaging {
        resources {
            excludes += setOf(
                "META-INF/AL2.0",
                "META-INF/LGPL2.1",
                "META-INF/licenses/**"
            )
        }
    }
}

flutter {
    source = "../.."
}
