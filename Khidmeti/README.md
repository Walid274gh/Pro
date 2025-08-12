# Khidmeti Apps (Users & Workers)

Two Flutter apps with unified Paytone One design, SOLID architecture, OpenStreetMap, and Firebase sync.

Structure:
- `users/`: consumer app
- `worker/`: professional app
- `shared_assets/`: common assets (icons, fonts placeholder, animations)

Design:
- Palette: #FCDC73, #E76268, #193948, #4FADCD
- Rounded cards (20px), bubble buttons, deep shadows, creme background
- No AppBar. Custom `ModernHeader`

Android:
- Unique applicationId: `com.khidmeti.users`, `com.khidmeti.worker`
- OpenStreetMap only (no Google Maps dependency)

Firebase:
- Collections: `users`, `workers`
- Worker dashboard toggles subscription & visibility; Users app reads visible workers

Run:
1) Install Flutter & Dart, configure Android SDK
2) Add `local.properties` with `flutter.sdk`
3) Place proper `google-services.json` into each `android/app` folder
4) From each app dir: `flutter pub get` then `flutter run`