# Android Setup (Users)

1. Set your applicationId in `android/app/build.gradle`:
```
android {
  defaultConfig {
    applicationId "com.khidmeti.users"
    minSdk 21
    targetSdk 34
  }
}
```

2. Add Firebase:
- Create a Firebase project
- Add Android app with package `com.khidmeti.users`
- Download `google-services.json` and place it in `android/app/`
- Add classpath and plugin `com.google.gms.google-services` in project-level and app-level build.gradle

3. Run build:
```
flutter pub get
flutter build apk --debug
```