#!/usr/bin/env bash
# ============================================================================
# validate-commit.sh — WARNING HOOK
# Runs meta integrity and code quality checks before git commit.
# Warns about missing .meta files, orphaned metas, and code quality issues.
# ============================================================================
# Trigger: PostToolUse on Bash (when command contains "git commit")
# Exit: 0 always (warning only, via stderr)
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_PROFILE_LEVEL="standard"
source "${SCRIPT_DIR}/_lib.sh"

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only run on git commit
if ! echo "$COMMAND" | grep -qE 'git\s+commit'; then
    exit 0
fi

WARNINGS=0

# --- Meta File Integrity ---
# Check for staged .cs files without corresponding .meta
STAGED_CS=$(git diff --cached --name-only --diff-filter=A 2>/dev/null | grep '\.cs$' || true)
for CS_FILE in $STAGED_CS; do
    META_FILE="${CS_FILE}.meta"
    if ! git diff --cached --name-only 2>/dev/null | grep -qF "$META_FILE"; then
        if [ ! -f "$META_FILE" ]; then
            echo "WARNING: New script '$CS_FILE' has no .meta file staged." >&2
            echo "  Unity needs the .meta file to track this asset." >&2
            echo "  Open Unity Editor to generate it, then stage it." >&2
            echo "" >&2
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
done

# Check for orphaned .meta files (meta staged but asset isn't)
STAGED_META=$(git diff --cached --name-only --diff-filter=A 2>/dev/null | grep '\.meta$' || true)
for META_FILE in $STAGED_META; do
    ASSET_FILE="${META_FILE%.meta}"
    if ! git diff --cached --name-only 2>/dev/null | grep -qF "$ASSET_FILE"; then
        if [ ! -f "$ASSET_FILE" ] && [ ! -d "$ASSET_FILE" ]; then
            echo "WARNING: Orphaned .meta file '$META_FILE' — no corresponding asset found." >&2
            echo "" >&2
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
done

# --- Code Quality Quick Check ---
STAGED_CS_ALL=$(git diff --cached --name-only 2>/dev/null | grep '\.cs$' || true)
for CS_FILE in $STAGED_CS_ALL; do
    if [ -f "$CS_FILE" ]; then
        # Check for GetComponent in Update
        if grep -nE '(void\s+Update|void\s+FixedUpdate|void\s+LateUpdate)' "$CS_FILE" > /dev/null 2>&1; then
            UPDATE_LINES=$(grep -n 'GetComponent\|FindObjectOfType\|Camera\.main\b' "$CS_FILE" 2>/dev/null || true)
            if [ -n "$UPDATE_LINES" ]; then
                echo "WARNING: Potential performance issue in $CS_FILE" >&2
                echo "  Found GetComponent/FindObjectOfType/Camera.main — cache these in Awake()." >&2
                echo "" >&2
                WARNINGS=$((WARNINGS + 1))
            fi
        fi
    fi
done

if [ "$WARNINGS" -gt 0 ]; then
    echo "Found $WARNINGS warning(s). Review before committing." >&2
fi

exit 0
