import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.rmac.multitimer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Load keystore properties
    val keystoreProperties = Properties()
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { rootProject.file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    defaultConfig {
        applicationId = "com.rmac.multitimer"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Enable code shrinking and obfuscation for smaller app size
            isMinifyEnabled = true
            isShrinkResources = true
            
            // Use ProGuard rules - this will generate mapping files
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            
            signingConfig = signingConfigs.getByName("release")
            
            // Add debugging for release builds to catch crashes
            isDebuggable = false
            isJniDebuggable = false
            isRenderscriptDebuggable = false
            
            // Ensure proper packaging
            packagingOptions {
                pickFirst("**/libc++_shared.so")
                pickFirst("**/libjsc.so")
            }
        }
        
        debug {
            // Keep debug builds unobfuscated
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = true
        }
    }
}

flutter {
    source = "../.."
}
