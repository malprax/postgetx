#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/backups"
STAMP="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$DEST"
tar --exclude=.git --exclude=build --exclude=.dart_tool --exclude=backups -czf "$DEST/postgetx-$STAMP.tar.gz" -C "$ROOT" .
echo "$DEST/postgetx-$STAMP.tar.gz"
