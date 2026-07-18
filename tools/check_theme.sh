#!/usr/bin/env bash
set -euo pipefail
for token in app_colors app_typography app_spacing app_radius app_shadows app_animations app_icons app_theme; do
  test -f "lib/app/theme/${token}.dart"
done
rg -q "ThemeController" lib/app/app.dart
echo "theme: ok"
