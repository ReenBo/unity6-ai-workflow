---
name: unity-test-runner
description: Ultra-fast execution of Unity Test Runner via Unity CLI in warm editor or headless fallback, parsing test results, and validating code correctness.
---

# Unity Test Runner Skill

## Purpose:
Verification of code correctness via native Unity Test Framework using official Unity CLI (`unity test`) without cold-start overhead or lockfile collisions.

## Step-by-Step Algorithm:
1. Run runner script `scripts/run-unity-tests.ps1` or `scripts/run-unity-tests.sh`.
2. The script prioritizes `unity test --mode <TestMode>` against the active warm Unity Editor (completing in 1-2 seconds).
3. If Unity Editor is closed, `unity test` automatically provisions headless execution for the project's exact editor version.
4. If failing tests are detected, handoff stack traces to `Auto-Fixer`.
5. Generate Tier 2 execution report in `.foragents/logs/`.
