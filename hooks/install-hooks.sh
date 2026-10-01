#!/usr/bin/env bash
# Bash Script: Install Git Hooks for Unity Project (macOS/Linux/Git Bash)

TARGET_GIT_FOLDER="${1:-../.git}"

echo "=== Installing AI Workflow Git Hooks (Bash) ==="

if [ ! -d "$TARGET_GIT_FOLDER/hooks" ]; then
    echo "Git directory not found at $TARGET_GIT_FOLDER."
    exit 1
fi

cat << 'EOF' > "$TARGET_GIT_FOLDER/hooks/pre-commit"
#!/usr/bin/env bash
if [ -f "./.agents/hooks/pre-commit-audit.sh" ]; then
    bash ./.agents/hooks/pre-commit-audit.sh
else
    powershell -ExecutionPolicy Bypass -File ./.agents/hooks/pre-commit-audit.ps1
fi
EOF

chmod +x "$TARGET_GIT_FOLDER/hooks/pre-commit"
echo "Local pre-commit hook installed successfully in $TARGET_GIT_FOLDER/hooks/pre-commit"
