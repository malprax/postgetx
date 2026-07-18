#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
bash tools/check_routes.sh
bash tools/check_theme.sh
bash tools/check_hive.sh
bash tools/check_assets.sh
bash tools/check_seed.sh
bash tools/check_data_integrity.sh
bash tools/check_offline_media.sh
bash tools/check_bdd.sh
dart format --set-exit-if-changed lib test
flutter analyze
bash tools/check_coverage.sh
git diff --check
echo "all checks: ok"
