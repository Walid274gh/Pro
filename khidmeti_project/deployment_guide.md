# Khidmeti Project - Guide de Déploiement

## 🚀 Vue d'ensemble

Ce guide détaille le processus de déploiement complet du projet Khidmeti, incluant la configuration Firebase, la génération des builds, et le déploiement sur les stores.

## 📋 Prérequis

### Outils Requis
- **Flutter SDK** 3.3.0 ou supérieur
- **Android Studio** ou **VS Code**
- **Xcode** (pour iOS)
- **Git**
- **Firebase CLI**

### Comptes Nécessaires
- **Firebase Console** (gratuit)
- **Google Play Console** (25$ une fois)
- **Apple Developer Program** (99$/an)
- **OpenRouteService** (gratuit jusqu'à 2000 requêtes/mois)

## 🔧 Configuration Firebase

### 1. Créer un Projet Firebase

```bash
# Installer Firebase CLI
npm install -g firebase-tools

# Se connecter à Firebase
firebase login

# Créer un nouveau projet
firebase projects:create khidmeti-project
```

### 2. Configurer les Services Firebase

#### Authentication
1. Aller dans Firebase Console > Authentication
2. Activer "Email/Password"
3. Configurer les règles de sécurité

#### Firestore Database
1. Créer une base de données Firestore
2. Configurer les règles de sécurité :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Workers collection
    match /workers/{workerId} {
      allow read, write: if request.auth != null && request.auth.uid == workerId;
    }
    
    // Requests collection
    match /requests/{requestId} {
      allow read, write: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         resource.data.workerId == request.auth.uid);
    }
    
    // Chats collection
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
    }
  }
}
```

#### Storage
1. Créer un bucket Storage
2. Configurer les règles :

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /workers/{workerId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == workerId;
    }
  }
}
```

#### Cloud Messaging
1. Activer Cloud Messaging
2. Générer les clés API

### 3. Ajouter les Configurations

#### Android
1. Télécharger `google-services.json`
2. Placer dans `khidmeti_users/android/app/` et `khidmeti_workers/android/app/`

#### iOS
1. Télécharger `GoogleService-Info.plist`
2. Placer dans `khidmeti_users/ios/Runner/` et `khidmeti_workers/ios/Runner/`

## 🔑 Configuration des Clés API

### OpenRouteService
1. Créer un compte sur [OpenRouteService](https://openrouteservice.org/)
2. Obtenir une clé API gratuite
3. Ajouter dans les variables d'environnement

### Créer le fichier de configuration

```dart
// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-android-api-key',
    appId: 'your-android-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-storage-bucket',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-storage-bucket',
    iosClientId: 'your-ios-client-id',
    iosBundleId: 'your-bundle-id',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your-web-api-key',
    appId: 'your-web-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-storage-bucket',
    authDomain: 'your-auth-domain',
  );
}
```

## 📱 Configuration Android

### 1. Mettre à jour android/app/build.gradle

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.khidmeti.users" // ou "com.khidmeti.workers"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 2. Configurer la Signature

```bash
# Générer une keystore
keytool -genkey -v -keystore khidmeti-users.keystore -alias khidmeti-users -keyalg RSA -keysize 2048 -validity 10000

# Créer key.properties
echo "storePassword=your-store-password
keyPassword=your-key-password
keyAlias=khidmeti-users
storeFile=../khidmeti-users.keystore" > android/key.properties
```

### 3. Configurer ProGuard

```proguard
# android/app/proguard-rules.pro
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
```

## 🍎 Configuration iOS

### 1. Mettre à jour ios/Runner/Info.plist

```xml
<key>CFBundleDisplayName</key>
<string>Khidmeti</string>
<key>CFBundleIdentifier</key>
<string>com.khidmeti.users</string>
<key>CFBundleVersion</key>
<string>1.0.0</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>

<!-- Permissions -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Cette app nécessite l'accès à la localisation pour trouver des services près de vous.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Cette app nécessite l'accès à la localisation pour trouver des services près de vous.</string>
<key>NSCameraUsageDescription</key>
<string>Cette app nécessite l'accès à la caméra pour prendre des photos.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Cette app nécessite l'accès à la galerie pour sélectionner des photos.</string>
```

### 2. Configurer les Capacités

Dans Xcode :
1. Runner > Signing & Capabilities
2. Ajouter "Push Notifications"
3. Ajouter "Background Modes" > "Location updates"

## 🏗️ Build et Test

### 1. Vérifier les Dépendances

```bash
# Dans chaque app
flutter pub get
flutter doctor
```

### 2. Tests Locaux

```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter drive --target=test_driver/app.dart
```

### 3. Build de Test

```bash
# Android APK de test
flutter build apk --debug

# iOS Simulator
flutter build ios --debug
```

## 📦 Build de Production

### 1. Build Android

```bash
cd khidmeti_users
flutter build apk --release
flutter build appbundle --release

cd ../khidmeti_workers
flutter build apk --release
flutter build appbundle --release
```

### 2. Build iOS

```bash
cd khidmeti_users
flutter build ios --release

cd ../khidmeti_workers
flutter build ios --release
```

## 🚀 Déploiement

### Google Play Store

#### 1. Préparer les Assets
- Icônes (512x512, 192x192, 144x144)
- Screenshots (minimum 2 par appareil)
- Description de l'app
- Politique de confidentialité

#### 2. Créer une Release
1. Aller dans Google Play Console
2. Créer une nouvelle app
3. Uploader l'APK/AAB
4. Remplir les informations
5. Soumettre pour review

### Apple App Store

#### 1. Préparer les Assets
- Icônes (1024x1024)
- Screenshots pour différentes tailles d'écran
- Description de l'app
- Politique de confidentialité

#### 2. Créer une Release
1. Aller dans App Store Connect
2. Créer une nouvelle app
3. Uploader l'IPA via Xcode
4. Remplir les informations
5. Soumettre pour review

## 🔄 CI/CD avec GitHub Actions

### Workflow pour Android

```yaml
# .github/workflows/android.yml
name: Android CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.3.0'
    
    - name: Install dependencies
      run: |
        cd khidmeti_users
        flutter pub get
        cd ../khidmeti_workers
        flutter pub get
    
    - name: Run tests
      run: |
        cd khidmeti_users
        flutter test
        cd ../khidmeti_workers
        flutter test
    
    - name: Build APK
      run: |
        cd khidmeti_users
        flutter build apk --release
        cd ../khidmeti_workers
        flutter build apk --release
    
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: khidmeti-apks
        path: |
          khidmeti_users/build/app/outputs/flutter-apk/app-release.apk
          khidmeti_workers/build/app/outputs/flutter-apk/app-release.apk
```

### Workflow pour iOS

```yaml
# .github/workflows/ios.yml
name: iOS CI/CD

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.3.0'
    
    - name: Install dependencies
      run: |
        cd khidmeti_users
        flutter pub get
        cd ../khidmeti_workers
        flutter pub get
    
    - name: Build iOS
      run: |
        cd khidmeti_users
        flutter build ios --release --no-codesign
        cd ../khidmeti_workers
        flutter build ios --release --no-codesign
```

## 📊 Monitoring et Analytics

### 1. Firebase Analytics
- Configurer Firebase Analytics
- Ajouter des événements personnalisés
- Surveiller les métriques utilisateur

### 2. Crashlytics
- Intégrer Firebase Crashlytics
- Surveiller les crashes
- Configurer les alertes

### 3. Performance Monitoring
- Configurer Firebase Performance
- Surveiller les temps de chargement
- Optimiser les performances

## 🔒 Sécurité

### 1. Règles Firestore
- Vérifier les règles de sécurité
- Tester les permissions
- Auditer régulièrement

### 2. Clés API
- Stocker les clés de manière sécurisée
- Utiliser des variables d'environnement
- Rotation régulière des clés

### 3. Validation des Données
- Valider côté client et serveur
- Sanitiser les entrées utilisateur
- Prévenir les injections

## 📈 Maintenance

### 1. Mises à Jour
- Surveiller les dépendances
- Mettre à jour Flutter régulièrement
- Tester les nouvelles versions

### 2. Sauvegardes
- Sauvegarder la base de données
- Sauvegarder les configurations
- Documenter les changements

### 3. Support
- Configurer le support client
- Documenter les FAQ
- Préparer les guides utilisateur

## 🎯 Checklist de Déploiement

### Pré-déploiement
- [ ] Tests unitaires passent
- [ ] Tests d'intégration passent
- [ ] Build de production réussi
- [ ] Assets préparés
- [ ] Documentation mise à jour
- [ ] Politique de confidentialité
- [ ] Conditions d'utilisation

### Déploiement
- [ ] Upload sur les stores
- [ ] Informations remplies
- [ ] Screenshots ajoutées
- [ ] Description complète
- [ ] Mots-clés optimisés
- [ ] Soumission pour review

### Post-déploiement
- [ ] Monitoring configuré
- [ ] Analytics actifs
- [ ] Support configuré
- [ ] Documentation utilisateur
- [ ] Plan de maintenance

---

**Khidmeti** - Prêt pour la production ! 🚀✨