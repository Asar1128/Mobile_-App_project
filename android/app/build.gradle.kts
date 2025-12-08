plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.hospital_management_system"
    
    // Use SDK 34 (stable)
    compileSdk = 34
    buildToolsVersion = "34.0.0"
    ndkVersion = flutter.ndkVersion
    
    defaultConfig {
        applicationId = "com.example.hospital_management_system"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    
    // CHANGED: Use Java 21 to match your installed JDK
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }
    
    // CHANGED: Use JVM target 21
    kotlinOptions {
        jvmTarget = "21"
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