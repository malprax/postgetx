#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/PROJECT_TREE.txt}"
find "$ROOT" -path "$ROOT/.git" -prune -o -path "$ROOT/build" -prune -o -path "$ROOT/.dart_tool" -prune -o -path "$ROOT/backups" -prune -o -type f -print | sed "s|$ROOT/||" | sort > "$OUT"
echo "$OUT"
