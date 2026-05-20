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

    buildTypes {
        debug {
            // نسخة المطورين تعمل الآن بدون تعقيدات التوقيع
        }
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
    
    // تأكد من وجود هذا إذا كنت تستخدم Keystore في الـ Release
    signingConfigs {
        create("release") {
            storeFile = file("nafahat-release.keystore")
            storePassword = System.getenv("KEYSTORE_PASSWORD") ?: "mhndbarbwd777611705mhndbarbwd"
            keyAlias = System.getenv("KEY_ALIAS") ?: "nafahat"
            keyPassword = System.getenv("KEY_PASSWORD") ?: "mhndbarbwd777611705mhndbarbwd"
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
