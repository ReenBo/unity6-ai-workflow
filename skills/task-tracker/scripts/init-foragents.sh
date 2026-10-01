#!/usr/bin/env bash
# Bash Script: Task Tracker Initialization & Verification
set -e

PROJECT_ROOT="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_INIT="$SCRIPT_DIR/../../../scripts/init-foragents.sh"

if [ -f "$ROOT_INIT" ]; then
    bash "$ROOT_INIT" "$PROJECT_ROOT"
else
    # Fallback
    TARGET="${PROJECT_ROOT:-$(pwd)}"
    mkdir -p "$TARGET/.foragents/logs"
fi
