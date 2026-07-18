#!/usr/bin/env bash
set -euo pipefail
if [[ $# -ne 2 ]]; then echo "Usage: $0 <archive.tar.gz> <empty-destination>" >&2; exit 2; fi
mkdir -p "$2"
tar -xzf "$1" -C "$2"
echo "restored: $2"
