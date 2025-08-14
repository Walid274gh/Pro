# Khidmeti – Android/iOS Setup (Firebase)

This guide covers only Android and iOS (web not required).

## Prerequisites
- Firebase project created (console)
- Enable Authentication (Phone), Firestore, Storage, Cloud Messaging
- Download platform config files

## Android
1) Place `google-services.json` in:
   - `client_app/android/app/google-services.json`
   - `worker_app/android/app/google-services.json`
2) Add Google Services plugin:
   - In `android/build.gradle` (Project):
     - classpath `com.google.gms:google-services:4.4.1`
   - In `android/app/build.gradle` (Module):
     - `apply plugin: 'com.google.gms.google-services'`
3) Permissions (AndroidManifest.xml under `app/src/main`):
   - `<uses-permission android:name="android.permission.INTERNET"/>`
   - `<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>`
   - `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>`
   - `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>`
   - `<uses-permission android:name="android.permission.CAMERA"/>`
   - For images (API 33+): `<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>`
   - For notifications (API 33+): `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>`
4) FCM Notification Channel (optional): create a default channel in the app if using foreground service.

## iOS
1) Place `GoogleService-Info.plist` in:
   - `client_app/ios/Runner/GoogleService-Info.plist`
   - `worker_app/ios/Runner/GoogleService-Info.plist`
2) Podfile minimum:
   - `platform :ios, '12.0'`
3) Capabilities in Xcode (Targets > Signing & Capabilities):
   - Push Notifications
   - Background Modes > Remote notifications
4) Info.plist keys:
   - `NSCameraUsageDescription`
   - `NSPhotoLibraryUsageDescription`
   - `NSPhotoLibraryAddUsageDescription`
   - `NSLocationWhenInUseUsageDescription`

## Firebase Services
- Firestore Security: see `firebase/firestore.rules`
- Storage Security: see `firebase/storage.rules`
- Cloud Functions: deploy `cloud_functions/functions`

## Build/Run
### Client App
- Android: `cd client_app && flutter pub get && flutter run`
- iOS: `cd client_app && flutter pub get && open ios/Runner.xcworkspace` (then run from Xcode)

### Worker App
- Android: `cd worker_app && flutter pub get && flutter run`
- iOS: `cd worker_app && flutter pub get && open ios/Runner.xcworkspace`

## Notes
- Phone Auth requires a test phone number in Firebase console or proper SHA-1 for Android and APNs on iOS.
- For location on Android 12+, add `android:exported` where needed (Flutter templates handle this).
- Ensure Firestore composite indexes (see `firebase/firestore.indexes.json`).