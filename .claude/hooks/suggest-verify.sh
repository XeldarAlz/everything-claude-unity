#!/usr/bin/env bash
# ============================================================================
# suggest-verify.sh — ADVISORY HOOK
# Tracks distinct C# files modified and suggests running /unity-review
# after 5+ files have been changed. One-time suggestion per batch.
# ============================================================================
# Trigger: PostToolUse on Edit|Write
# Exit: 0 always (advisory only, via stderr)
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_PROFILE_LEVEL="standard"
source "${SCRIPT_DIR}/_lib.sh"

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only track C# files
case "$FILE_PATH" in
    *.cs) ;;
    *) exit 0 ;;
esac

# Tracker file — reset if older than 1 hour to avoid cross-session accumulation
TRACKER="/tmp/unity-claude-edit-tracker"
if [ -f "$TRACKER" ]; then
    FILE_AGE=$(( $(date +%s) - $(stat -f %m "$TRACKER" 2>/dev/null || stat -c %Y "$TRACKER" 2>/dev/null || echo 0) ))
    if [ "$FILE_AGE" -gt 3600 ]; then
        rm -f "$TRACKER"
    fi
fi

# Add file path if not already tracked
if [ -f "$TRACKER" ]; then
    if ! grep -qxF "$FILE_PATH" "$TRACKER" 2>/dev/null; then
        echo "$FILE_PATH" >> "$TRACKER"
    fi
else
    echo "$FILE_PATH" > "$TRACKER"
fi

# Count distinct files
COUNT=$(wc -l < "$TRACKER" | tr -d ' ')

# Suggest verification after threshold
if [ "$COUNT" -ge 5 ]; then
    echo "" >&2
    echo "SUGGESTION: You've modified $COUNT C# files. Consider running /unity-review to catch issues early." >&2
    echo "" >&2
    # Reset tracker so we don't spam on every subsequent edit
    rm -f "$TRACKER"
fi

exit 0
