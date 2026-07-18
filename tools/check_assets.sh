#!/usr/bin/env bash
set -euo pipefail
test -d assets
rg -q -- "- assets/" pubspec.yaml
echo "assets: ok"
