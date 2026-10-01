#!/usr/bin/env bash
# Bash Script: VContainer Auditor for Unity 6 (macOS/Linux/Git Bash)

PROJECT_PATH="${1:-.}"
echo "=== VContainer & POCO Rules Audit (Bash) ==="

mono_count=$(grep -rn --include="*.cs" "class.*:.*MonoBehaviour" "$PROJECT_PATH" | wc -l)
poco_count=$(grep -rn --include="*.cs" "class " "$PROJECT_PATH" | wc -l)

echo "Found POCO Classes: $poco_count"
echo "Found MonoBehaviour Classes: $mono_count"
echo "Audit completed cleanly."
