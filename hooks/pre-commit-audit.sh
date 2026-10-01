#!/usr/bin/env bash
# Bash Script: Pre-Commit AI Workflow Checks

echo "Running Pre-Commit AI Workflow Checks (Bash)..."

# Run VContainer Check
if [ -f "skills/vcontainer-auditor/scripts/audit-vcontainer.sh" ]; then
    bash "skills/vcontainer-auditor/scripts/audit-vcontainer.sh" .
fi

# Run Allocation Check
if [ -f "skills/memory-gc-profiler/scripts/check-allocations.sh" ]; then
    bash "skills/memory-gc-profiler/scripts/check-allocations.sh" .
fi

echo "Pre-Commit Checks Finished Successfully."
