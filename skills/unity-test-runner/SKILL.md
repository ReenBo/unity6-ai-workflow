---
name: unity-test-runner
description: Background execution of Unity Test Runner in batchmode (EditMode/PlayMode), parsing XML test results, and validating code correctness.
---

# Unity Test Runner Skill

## Purpose:
Background verification of code correctness via native Unity Test Framework without requiring manual Editor GUI interaction.

## Step-by-Step Algorithm:
1. Run background runner script `scripts/run-unity-tests.ps1` or `scripts/run-unity-tests.sh`.
2. Read generated XML results file `logs/unity_test_results.xml`.
3. If failing tests are detected (`<test-case result="Failed">`), handoff stack traces to `Auto-Fixer`.
4. Generate Tier 2 execution report in `.foragents/logs/`.
