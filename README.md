# Secure Notes App

A Flutter secure-notes application for Week 10/11 covering biometric unlock, encrypted local storage, performance-minded note rendering, and deployment preparation.

## Features

- Biometric unlock with PIN fallback
- PIN setup with SHA-256 hash storage
- AES-encrypted note storage backed by `flutter_secure_storage`
- Search notes by title or content
- Pin important notes to keep them at the top
- Export notes as an encrypted backup file
- Persistent dark mode toggle
- Optimized note list using `ListView.builder`

## Project Structure

```text
lib/
|-- main.dart
|-- models/
|   `-- note.dart
|-- screens/
|   |-- add_edit_note_screen.dart
|   |-- auth_screen.dart
|   `-- notes_list_screen.dart
|-- services/
|   |-- biometric_service.dart
|   |-- notes_service.dart
|   |-- secure_storage_service.dart
|   `-- theme_service.dart
|-- utils/
|   `-- encryption_helper.dart
`-- widgets/
    `-- note_card.dart
```

## Dependencies

- `local_auth`
- `flutter_secure_storage`
- `crypto`
- `encrypt`
- `path_provider`
- `flutter_native_splash`
- `flutter_launcher_icons`

## Run Locally

1. Install Flutter and connect a device or emulator.
2. Run `flutter pub get`.
3. Run `flutter run`.

## Platform Setup

### Android

- `android/app/src/main/AndroidManifest.xml` includes `USE_BIOMETRIC`.

### iOS

- `ios/Runner/Info.plist` includes `NSFaceIDUsageDescription`.
- Building an IPA still requires Xcode on macOS.

## Release Commands

- Android APK: `flutter build apk --release`
- iOS build: `flutter build ios --release`

## Notes

- The app currently implements four extra features from the weekly activity list: search, pin-to-top, encrypted export, and dark mode.
- Splash screen and launcher icon packages are installed, but custom image assets still need to be added before running their generation commands.
