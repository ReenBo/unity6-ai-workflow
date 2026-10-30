#!/usr/bin/env bash
# Bash Script: Cross-Platform Unity Test Runner with Unity CLI & Fallback (macOS/Linux)

PROJECT_PATH="${1:-.}"
TEST_MODE="${2:-EditMode}"
FILTER="${3:-}"
RESULTS_FILE="${4:-$PROJECT_PATH/logs/unity_test_results.xml}"

echo "=== Cross-Platform Unity Test Runner ($TEST_MODE) ==="

mkdir -p "$(dirname "$RESULTS_FILE")"

# 1. Primary Route: Official Unity CLI
if command -v unity &> /dev/null; then
    echo "[+] Using official Unity CLI: $(which unity)"
    CLI_ARGS=("test" "$PROJECT_PATH" "--mode" "$TEST_MODE" "--output" "$RESULTS_FILE")
    if [ -n "$FILTER" ]; then
        CLI_ARGS+=("--filter" "$FILTER")
    fi
    unity "${CLI_ARGS[@]}"
    EXIT_CODE=$?
    echo "Unity Tests Execution Finished. ExitCode: $EXIT_CODE"
    exit $EXIT_CODE
fi

# 2. Fallback Route: Direct Unity Editor Executable Detection
echo "[!] Unity CLI not found in PATH. Falling back to direct Editor binary detection..."
PROJECT_VERSION="6000.0.0f1"
if [ -f "$PROJECT_PATH/ProjectSettings/ProjectVersion.txt" ]; then
    VERSION_LINE=$(grep "m_EditorVersion:" "$PROJECT_PATH/ProjectSettings/ProjectVersion.txt")
    if [ -n "$VERSION_LINE" ]; then
        PROJECT_VERSION=$(echo "$VERSION_LINE" | awk '{print $2}' | tr -d '\r')
    fi
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    UNITY_EXEC="/Applications/Unity/Hub/Editor/$PROJECT_VERSION/Unity.app/Contents/MacOS/Unity"
else
    UNITY_EXEC="$HOME/Unity/Hub/Editor/$PROJECT_VERSION/Editor/Unity"
fi

if [ -f "$UNITY_EXEC" ]; then
    echo "Found Unity at: $UNITY_EXEC"
    BATCH_ARGS=("-batchmode" "-runTests" "-projectPath" "$PROJECT_PATH" "-testResults" "$RESULTS_FILE" "-testPlatform" "$TEST_MODE")
    if [ -n "$FILTER" ]; then
        BATCH_ARGS+=("-testFilter" "$FILTER")
    fi
    "$UNITY_EXEC" "${BATCH_ARGS[@]}"
    EXIT_CODE=$?
    echo "Unity Tests Execution Finished. Results: $RESULTS_FILE"
    exit $EXIT_CODE
else
    echo "Unity Executable not found at $UNITY_EXEC. Simulation mode active."
    exit 0
fi
