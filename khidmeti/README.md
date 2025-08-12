# Khidmeti Monorepo

Two Flutter apps with a unified Paytone One design and SOLID architecture.

## Structure
```
khidmeti/
├── users/
│   ├── lib/main.dart
│   ├── assets/{animations,avatars/users,icons,images,fonts}
│   ├── android/
│   └── pubspec.yaml
├── worker/
│   ├── lib/main.dart
│   ├── assets/{animations,avatars/workers,icons,images,fonts}
│   ├── android/
│   └── pubspec.yaml
└── shared_assets/{animations,fonts,icons}
```

## Notes
- Each app keeps a single `main.dart` containing UI + services (scoped to the app), still respecting SOLID via abstractions.
- Uses OpenStreetMap via `flutter_map`.
- Requires Firebase setup for each app (Android package names, `google-services.json`).