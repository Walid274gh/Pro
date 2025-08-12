# KHIDMETI Users & Workers

Deux applications Flutter réelles, reliées à un projet Firebase (Auth, Firestore, Storage, FCM) avec synchronisation temps réel, KYC pour Workers, abonnement, géolocalisation et notifications push.

## 1) Prérequis
- Flutter 3.32+ (Dart 3.8+)
- Firebase CLI (`npm i -g firebase-tools`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli` ou `flutter pub global activate flutterfire_cli`)
- Compte Firebase avec projet configuré (un seul projet pour les deux apps)

## 2) Configuration Firebase
1. Se placer à la racine `Khidmeti/` et lancer:
   ```bash
   flutterfire configure
   ```
   - Sélectionner le projet Firebase.
   - Générer les configs pour `khidmeti_users` et `khidmeti_workers`.
2. Android
   - Placer `google-services.json` dans `users/android/app/` et `worker/android/app/`.
   - Dans `android/build.gradle` (racine), ajouter la classe Google Services si absent:
     ```gradle
     dependencies {
       classpath 'com.google.gms:google-services:4.4.2'
     }
     ```
   - Dans `android/app/build.gradle` de chaque app, appliquer le plugin:
     ```gradle
     apply plugin: 'com.google.gms.google-services'
     ```
3. iOS
   - Placer `GoogleService-Info.plist` dans chaque `ios/Runner/`.
   - Activer Capabilities: Push Notifications, Background Modes (Remote notifications, Location updates si besoin).
   - Configurer APNs key dans Firebase > Cloud Messaging.

## 3) Permissions Android
- Déjà ajoutées dans `users/android/app/src/main/AndroidManifest.xml` et `worker/android/app/src/main/AndroidManifest.xml`:
  - INTERNET, POST_NOTIFICATIONS, ACCESS_FINE/COARSE/BACKGROUND_LOCATION, FOREGROUND_SERVICE(_LOCATION), CAMERA, READ_MEDIA_IMAGES.

## 4) Cloud Functions (notifications)
- Dossier: `functions/`
- Installation et déploiement:
  ```bash
  cd functions
  npm install
  npm run build
  npm run deploy
  ```
- Callables fournis:
  - `notifyNewRequest`: envoie aux topics `geo_<cellId>`
  - `notifyRequestAssigned`: envoie aux tokens de l’utilisateur
  - `notifyRequestCompleted`: envoie aux tokens de l’utilisateur

## 5) Lancer les apps
- Users:
  ```bash
  cd users
  flutter pub get
  flutter run
  ```
- Workers:
  ```bash
  cd worker
  flutter pub get
  flutter run
  ```

## 6) Tests E2E
- Ouvrir Workers, se connecter, KYC si besoin, passer "En ligne" (WorkersHomeOnline)
- Ouvrir Users, se connecter, publier une demande (Demande):
  - Les Workers en ligne à proximité reçoivent une notification (topic géocellule)
- Dans Workers, accepter une demande (Recherche):
  - Users reçoit "acceptée" via `notifyRequestAssigned`
- Dans Workers, terminer une demande (Assignées):
  - Users reçoit "terminée" via `notifyRequestCompleted`
- Dans Users, évaluer le travailleur (UsersSubmitRating):
  - Le profil worker est mis à jour (rating)

## 7) Notes
- Géocellules: taille par défaut ~0.02° lat (~2.2km). Ajustable.
- OSM via `flutter_map`. Pensez à respecter les Conditions d’utilisation des tuiles.
- i18n: locales fr/en/ar activées (exemples), à compléter par des traductions.

## 8) Sécurité et règles Firestore (à adapter en prod)
- Ajouter des règles pour protéger: profils, KYC, demandes, paiements, ratings.
- Exemple (à compléter):
```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /profiles/{uid} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == uid;
    }
    match /requests/{id} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
    }
    // etc.
  }
}
```