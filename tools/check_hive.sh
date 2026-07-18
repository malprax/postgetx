#!/usr/bin/env bash
set -euo pipefail
rg -q "Hive.initFlutter" lib/app/data/repositories/local_hive_repository.dart
rg -q "LocalHiveRepository" lib/app/bindings/initial_binding.dart
if rg -i "firebase|firestore" lib pubspec.yaml --glob '*.dart' --glob '*.yaml'; then
  echo "cloud reference detected" >&2
  exit 1
fi
echo "hive: ok"
