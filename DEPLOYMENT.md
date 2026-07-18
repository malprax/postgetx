# Deployment

## Android

Run `flutter build apk --release`. The artifact is written below `build/app/outputs/flutter-apk/`. The application operates offline after installation; PDF receipt preview uses the platform print sheet.

## Web

Run `flutter build web --release`. Serve `build/web` as static files with SPA fallback to `index.html`. The included deployment configuration is suitable for a static host. Hive's web adapter persists locally in the browser. Clearing browser storage resets runtime data.

Validate both targets with `bash tools/check_all.sh` before release. No Firebase, PocketBase, or remote API configuration is required.
