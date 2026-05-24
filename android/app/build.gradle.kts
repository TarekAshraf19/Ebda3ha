plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")   // مش محتاج "kotlin-android" لو عندك ده
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // مهم للفirebase
}

android {
    namespace = "com.example.ebad3a_ecommerce"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"   // ✅ خليها النسخة اللي Firebase عايزها

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

defaultConfig {
    applicationId = "com.example.ebad3a_ecommerce"
    minSdk = 23   
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

dependencies {
    // Firebase BOM (يحافظ على كل إصدارات Firebase متوافقة مع بعض)
    implementation(platform("com.google.firebase:firebase-bom:34.3.0"))

    // لو عايز Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")

    // لو عايز Firebase Auth
    implementation("com.google.firebase:firebase-auth")

    // لو عايز Cloud Firestore
    implementation("com.google.firebase:firebase-firestore")

    // لو عايز Firebase Storage
    implementation("com.google.firebase:firebase-storage")

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
