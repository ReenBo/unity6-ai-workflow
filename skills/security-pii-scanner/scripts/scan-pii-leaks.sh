#!/usr/bin/env bash
# Bash Script: Security & PII Leak Scanner (macOS/Linux/Git Bash)

PROJECT_PATH="${1:-.}"
echo "=== Security & PII Leak Scanner (Bash) ==="

leak_count=0

# Check for user paths
user_paths=$(grep -rn --exclude-dir={"Library","Temp","Packages",".git"} "[C-Z]:\\\\Users\\\\" "$PROJECT_PATH")
if [ -n "$user_paths" ]; then
    echo "SECURITY WARNING: Hardcoded User Path Found!"
    leak_count=$((leak_count + 1))
fi

# Check for API Keys
api_keys=$(grep -rn --exclude-dir={"Library","Temp","Packages",".git"} "sk-[a-zA-Z0-9]\{20,\}" "$PROJECT_PATH")
if [ -n "$api_keys" ]; then
    echo "CRITICAL RISK: Potential API Key Found!"
    leak_count=$((leak_count + 1))
fi

if [ $leak_count -eq 0 ]; then
    echo "No PII or Secret Leaks Detected."
else
    echo "Found $leak_count Security Risks! Developer approval required."
fi
