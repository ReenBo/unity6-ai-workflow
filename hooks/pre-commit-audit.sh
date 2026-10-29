#!/usr/bin/env bash
# Bash Script: Pre-Commit AI Workflow Checks

echo "Running Pre-Commit AI Workflow Checks (Bash)..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Run VContainer Check
if [ -f "$WORKFLOW_ROOT/skills/vcontainer-auditor/scripts/audit-vcontainer.sh" ]; then
    bash "$WORKFLOW_ROOT/skills/vcontainer-auditor/scripts/audit-vcontainer.sh" "$(pwd)"
fi

# Run Allocation Check
if [ -f "$WORKFLOW_ROOT/skills/memory-gc-profiler/scripts/check-allocations.sh" ]; then
    bash "$WORKFLOW_ROOT/skills/memory-gc-profiler/scripts/check-allocations.sh" "$(pwd)"
fi

echo "Pre-Commit Checks Finished Successfully."
