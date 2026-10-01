#!/usr/bin/env bash
# Universal CI/CD Check Runner for Unity 6 (Bash/Linux/macOS/Git Bash)

PROJECT_PATH="${1:-.}"

if command -v python3 &>/dev/null; then
    python3 "$PROJECT_PATH/ci/runner.py" "$PROJECT_PATH"
elif command -v python &>/dev/null; then
    python "$PROJECT_PATH/ci/runner.py" "$PROJECT_PATH"
else
    echo "========================================="
    echo "🚀 Starting Unity 6 AI Workflow CI Checks"
    echo "========================================="

    # Fallback to shell scripts if python is not available
    if [ -f "$PROJECT_PATH/skills/vcontainer-auditor/scripts/audit-vcontainer.sh" ]; then
        bash "$PROJECT_PATH/skills/vcontainer-auditor/scripts/audit-vcontainer.sh" "$PROJECT_PATH"
    fi

    if [ -f "$PROJECT_PATH/skills/security-pii-scanner/scripts/scan-pii-leaks.sh" ]; then
        bash "$PROJECT_PATH/skills/security-pii-scanner/scripts/scan-pii-leaks.sh" "$PROJECT_PATH"
    fi

    if [ -f "$PROJECT_PATH/skills/memory-gc-profiler/scripts/check-allocations.sh" ]; then
        bash "$PROJECT_PATH/skills/memory-gc-profiler/scripts/check-allocations.sh" "$PROJECT_PATH"
    fi
fi
