#!/usr/bin/env bash
# Universal CI/CD Check Runner for Unity 6 (Bash/Linux/macOS/Git Bash)

PROJECT_PATH="${1:-.}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_ROOT="$(dirname "$SCRIPT_DIR")"
RUNNER_SCRIPT="$SCRIPT_DIR/runner.py"
[ ! -f "$RUNNER_SCRIPT" ] && RUNNER_SCRIPT="$PROJECT_PATH/ci/runner.py"

if [ -f "$RUNNER_SCRIPT" ] && command -v python3 &>/dev/null; then
    python3 "$RUNNER_SCRIPT" "$PROJECT_PATH"
elif [ -f "$RUNNER_SCRIPT" ] && command -v python &>/dev/null; then
    python "$RUNNER_SCRIPT" "$PROJECT_PATH"
else
    echo "========================================="
    echo "🚀 Starting Unity 6 AI Workflow CI Checks"
    echo "========================================="

    SKILLS_DIR="$WORKFLOW_ROOT/skills"
    [ ! -d "$SKILLS_DIR" ] && SKILLS_DIR="$PROJECT_PATH/skills"

    # Fallback to shell scripts if python is not available
    if [ -f "$SKILLS_DIR/vcontainer-auditor/scripts/audit-vcontainer.sh" ]; then
        bash "$SKILLS_DIR/vcontainer-auditor/scripts/audit-vcontainer.sh" "$PROJECT_PATH"
    fi

    if [ -f "$SKILLS_DIR/security-pii-scanner/scripts/scan-pii-leaks.sh" ]; then
        bash "$SKILLS_DIR/security-pii-scanner/scripts/scan-pii-leaks.sh" "$PROJECT_PATH"
    fi

    if [ -f "$SKILLS_DIR/memory-gc-profiler/scripts/check-allocations.sh" ]; then
        bash "$SKILLS_DIR/memory-gc-profiler/scripts/check-allocations.sh" "$PROJECT_PATH"
    fi
fi
