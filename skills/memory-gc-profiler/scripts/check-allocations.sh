#!/usr/bin/env bash
# Bash Script: Allocation & Memory Check (macOS/Linux/Git Bash)

PROJECT_PATH="${1:-.}"
echo "=== GC & Allocation Checker (Bash) ==="

allocations=$(grep -rn --include="*.cs" --exclude-dir={"Library","Temp","Packages"} "new " "$PROJECT_PATH")

if [ -n "$allocations" ]; then
    echo "Scan complete. Inspect potential allocations above."
else
    echo "No allocations found."
fi
