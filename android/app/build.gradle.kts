plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.nafahat.quran"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.nafahat.quran"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 1. تعريف إعدادات التوقيع أولاً
    signingConfigs {
        create("release") {
            storeFile = file("nafahat-release.keystore")
            storePassword = System.getenv("KEYSTORE_PASSWORD") ?: "mhndbarbwd777611705mhndbarbwd"
            keyAlias = System.getenv("KEY_ALIAS") ?: "nafahat"
            keyPassword = System.getenv("KEY_PASSWORD") ?: "mhndbarbwd777611705mhndbarbwd"
        }
    }

    // 2. استخدام إعدادات التوقيع بعد تعريفها
    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("release")
        }
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
