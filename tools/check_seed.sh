#!/usr/bin/env bash
set -euo pipefail
rg -q "seedVersion" lib/app/data/repositories/local_hive_repository.dart
for key in users categories products customers transactions expenses notifications; do
  rg -q "'$key'" lib/app/data/repositories/local_hive_repository.dart
done
rg -q "currentSchemaVersion = 8" lib/app/data/repositories/local_hive_repository.dart
rg -q "owner@demo.local" lib/app/core/config/app_config.dart
rg -q "staff@demo.local" lib/app/core/config/app_config.dart
echo "seed: ok"
