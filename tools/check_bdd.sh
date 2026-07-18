#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BDD_DIR="test/behavior"

if [ ! -d "$BDD_DIR" ]; then
  echo "BDD directory is missing: $BDD_DIR"
  exit 1
fi

mapfile_compatible_files="$(
  find "$BDD_DIR" -type f -name "*_test.dart" | sort
)"

if [ -z "$mapfile_compatible_files" ]; then
  echo "No BDD tests found in $BDD_DIR"
  exit 1
fi

while IFS= read -r file; do
  [ -n "$file" ] || continue

  if ! rg -q "Given" "$file"; then
    echo "$file: missing Given behavior"
    exit 1
  fi

  if ! rg -q "When" "$file"; then
    echo "$file: missing When behavior"
    exit 1
  fi

  if ! rg -q "Then" "$file"; then
    echo "$file: missing Then behavior"
    exit 1
  fi
done <<< "$mapfile_compatible_files"

flutter test "$BDD_DIR"
echo "bdd: ok"
