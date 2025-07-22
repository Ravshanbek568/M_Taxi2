plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.m_taxi2"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // 🛠 bu yerga aniq versiya yozildi!

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.m_taxi2"
        // minSdk = flutter.minSdkVersion
        minSdk = 23 // <-- bu qatorda flutter.minSdkVersion o‘rniga to‘g‘ridan-to‘g‘ri 23 yozildi
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
