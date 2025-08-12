plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.khidmeti"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.khidmeti"
        minSdk = 23
        targetSdk = 36
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
        multiDexEnabled = true
        
        manifestPlaceholders.putAll(mapOf(
            "appName" to "Khidmeti",
            "backgroundLocation" to "Cette application utilise la localisation en arrière-plan pour vous connecter avec des travailleurs proches."
        ))
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

dependencies {

coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.22")
    
    // Firebase
    implementation(platform("com.google.firebase:firebase-bom:33.1.2"))
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.firebase:firebase-auth-ktx")
    implementation("com.google.firebase:firebase-firestore-ktx")
    implementation("com.google.firebase:firebase-storage-ktx")
    implementation("com.google.firebase:firebase-messaging-ktx")
    implementation("com.google.firebase:firebase-crashlytics-ktx")
    
    // Google Play Services
    implementation("com.google.android.gms:play-services-maps:18.2.0")
    implementation("com.google.android.gms:play-services-location:21.0.1")
    implementation("com.google.android.gms:play-services-auth:20.7.0")
    
    // Background services
    implementation("androidx.work:work-runtime-ktx:2.9.0")
    implementation("androidx.concurrent:concurrent-futures:1.1.0")
    
    // Notifications
    implementation("androidx.core:core:1.12.0")
    implementation("androidx.lifecycle:lifecycle-service:2.7.0")
    
    // Camera et ML Kit
    implementation("com.google.mlkit:face-detection:16.1.5")
    implementation("androidx.camera:camera-camera2:1.3.1")
    implementation("androidx.camera:camera-lifecycle:1.3.1")
    implementation("androidx.camera:camera-view:1.3.1")
    
    // Multidex
    implementation("androidx.multidex:multidex:2.0.1")
    
    // Permissions
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    
    // Boot receiver
    implementation("androidx.startup:startup-runtime:1.1.1")
}
