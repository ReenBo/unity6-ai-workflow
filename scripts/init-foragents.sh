#!/usr/bin/env bash
# Bash Script: Autonomous .foragents Initialization for AI Workflow
set -e

PROJECT_ROOT="${1:-}"

if [ -z "$PROJECT_ROOT" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    CURRENT="$SCRIPT_DIR"
    while [ "$CURRENT" != "/" ] && [ "$(basename "$CURRENT")" != ".agents" ]; do
        CURRENT="$(dirname "$CURRENT")"
    done
    if [ "$(basename "$CURRENT")" = ".agents" ]; then
        PROJECT_ROOT="$(dirname "$CURRENT")"
    else
        PROJECT_ROOT="$(pwd)"
    fi
fi

AGENTS_DIR="$PROJECT_ROOT/.agents"
FORAGENTS_DIR="$PROJECT_ROOT/.foragents"
LOGS_DIR="$FORAGENTS_DIR/logs"
MEMORY_FILE="$FORAGENTS_DIR/PROJECT_MEMORY.md"
README_FILE="$FORAGENTS_DIR/README.md"
TEMPLATE_FILE="$AGENTS_DIR/PROJECT_MEMORY_TEMPLATE.md"

echo "=== AI Workflow: Verifying .foragents Directory ==="
echo "Target Host Project: $PROJECT_ROOT"

# 1. Ensure directories
mkdir -p "$FORAGENTS_DIR"
mkdir -p "$LOGS_DIR"

# 2. Ensure PROJECT_MEMORY.md
if [ ! -f "$MEMORY_FILE" ]; then
    if [ -f "$TEMPLATE_FILE" ]; then
        echo "[+] Initializing $MEMORY_FILE from template..."
        cp "$TEMPLATE_FILE" "$MEMORY_FILE"
    else
        echo "[!] Template not found at $TEMPLATE_FILE. Generating default PROJECT_MEMORY.md..."
        cat << 'EOF' > "$MEMORY_FILE"
# 🧠 Project Memory & Active Status

## 📌 1. Active Status & Task Tracker
- [ ] Initial project task.

## 📐 2. Architectural Decisions Record (ADR)
* VContainer POCO architecture.
* Zero-allocation in Tick().

## ⚠️ 3. Known Gotchas & Technical Debt
* None recorded.

## 📜 4. Last Session Log
* Initialized .foragents directory.
EOF
    fi
else
    echo "[✓] $MEMORY_FILE exists."
fi

# 3. Ensure README.md
if [ ! -f "$README_FILE" ]; then
    echo "[+] Creating $README_FILE..."
    cat << 'EOF' > "$README_FILE"
# 📁 .foragents: Project Memory & Task Execution Logs

> **Purpose:** This folder stores project-specific AI workflow data, architectural decisions, and human-readable task logs.
> All files in this folder are tracked in the host project's Git repository.

## Structure
- `PROJECT_MEMORY.md` (Tier 1): High-level architectural status and task registry.
- `logs/` (Tier 2): Markdown reports for code review and Pull Requests.
EOF
else
    echo "[✓] $README_FILE exists."
fi

echo "=== .foragents verification complete! ==="
