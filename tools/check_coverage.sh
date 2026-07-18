#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

COVERAGE_DIR="coverage"
LCOV_FILE="$COVERAGE_DIR/lcov.info"
HTML_DIR="$COVERAGE_DIR/html"

command -v genhtml >/dev/null 2>&1 || {
  echo "ERROR: genhtml is required to generate HTML coverage."
  echo "Install it with: brew install lcov"
  exit 1
}

rm -rf "$COVERAGE_DIR"
mkdir -p "$COVERAGE_DIR"

flutter test --coverage

if [ ! -s "$LCOV_FILE" ]; then
  echo "ERROR: Flutter did not generate $LCOV_FILE"
  exit 1
fi

genhtml \
  "$LCOV_FILE" \
  --output-directory "$HTML_DIR" \
  --title "PostGetX Test Coverage" \
  --legend \
  --quiet

if [ ! -f "$HTML_DIR/index.html" ]; then
  echo "ERROR: HTML coverage report was not generated."
  exit 1
fi

echo
lcov --summary "$LCOV_FILE"
echo
echo "coverage html: $ROOT/$HTML_DIR/index.html"
echo "coverage: ok"
