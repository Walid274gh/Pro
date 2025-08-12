# Khidmeti Monorepo

This repository contains two Flutter applications and a shared assets package:

- `users/` — Customer-facing app.
- `worker/` — Professional/worker app.
- `shared_assets/` — Reusable assets (fonts, animations, icons, images, avatars).

## Requirements
- Flutter 3.19+
- Dart 3.2+

## Setup
1. From repo root, fetch packages for shared assets:
   ```bash
   cd shared_assets && flutter pub get
   ```
2. Install dependencies for each app:
   ```bash
   cd ../users && flutter pub get
   cd ../worker && flutter pub get
   ```

## Run
```bash
cd users   && flutter run
cd worker  && flutter run
```

## Design
- Palette Paytone One
- No AppBar (use `ModernHeader`)
- Bubble buttons with 3D effects
- Lottie animations + SVG avatars
- OpenStreetMap via `flutter_map`

## Notes
- Assets are provided by `shared_assets` package and referenced via `package:shared_assets/...`.