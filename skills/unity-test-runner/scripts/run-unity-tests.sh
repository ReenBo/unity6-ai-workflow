#!/usr/bin/env bash
# Bash Script: Cross-Platform Unity Test Runner with OS Detection (macOS/Linux)

PROJECT_PATH="${1:-.}"
TEST_MODE="${2:-EditMode}"
UNITY_VERSION="${3:-6000.0.0f1}"

echo "=== Cross-Platform Unity Test Runner ($TEST_MODE) ==="

# OS Auto-Detection
if [[ "$OSTYPE" == "darwin"* ]]; then
    UNITY_EXEC="/Applications/Unity/Hub/Editor/$UNITY_VERSION/Unity.app/Contents/MacOS/Unity"
else
    UNITY_EXEC="$HOME/Unity/Hub/Editor/$UNITY_VERSION/Editor/Unity"
fi

RESULTS_FILE="$PROJECT_PATH/logs/unity_test_results.xml"

if [ -f "$UNITY_EXEC" ]; then
    echo "Found Unity at: $UNITY_EXEC"
    "$UNITY_EXEC" -batchmode -runTests -projectPath "$PROJECT_PATH" -testResults "$RESULTS_FILE" -testPlatform "$TEST_MODE"
    echo "Unity Tests Execution Finished. Results: $RESULTS_FILE"
else
    echo "Unity Executable not found at $UNITY_EXEC. Simulation mode active."
fi
