#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter clean
flutter pub get
flutter build web --release --no-wasm-dry-run

test -f build/web/index.html
test -f build/web/main.dart.js
test -f build/web/flutter_bootstrap.js

if rg -i "firebase|firestore|google_sign_in|pocketbase" lib test pubspec.yaml pubspec.lock android web; then
  echo "Blocked: forbidden backend dependency string found." >&2
  exit 1
fi

if rg -i "example\.com|your-domain|your_domain" lib web deployment docs; then
  echo "Blocked: placeholder domain/content found." >&2
  exit 1
fi

rg -q "Retail POS Demo" lib README.md
test -f deployment/nginx/retail-pos-demo.conf
test -f docs/WEB_DEMO_DEPLOYMENT.md

echo "Retail POS Demo web build verified at build/web"
