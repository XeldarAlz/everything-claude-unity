#!/usr/bin/env bash
# ============================================================================
# session-restore.sh — SESSION START HOOK
# Restores prior session state on conversation start. Loads branch context,
# previously modified files, and workflow phase so the agent can resume
# where it left off — especially useful after context compaction or
# across conversation boundaries.
# ============================================================================
# Trigger: SessionStart
# Exit: 0 always (advisory)
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_PROFILE_LEVEL="standard"
source "${SCRIPT_DIR}/_lib.sh"

# Initialize session start time
echo "$(date +%s)" > "${UNITY_HOOK_STATE_DIR}/session-start-time"

# Clear stale gateguard state from previous sessions
rm -f "$UNITY_READS_FILE" "$UNITY_EDITS_FILE" "$UNITY_COST_FILE" "$UNITY_LEARNING_FILE"

# Check if we have a saved session state
if [ ! -f "$UNITY_SESSION_FILE" ]; then
    exit 0
fi

# Check if the session file is stale (older than 4 hours)
FILE_AGE=$(( $(date +%s) - $(stat -f %m "$UNITY_SESSION_FILE" 2>/dev/null || stat -c %Y "$UNITY_SESSION_FILE" 2>/dev/null || echo 0) ))
if [ "$FILE_AGE" -gt 14400 ]; then
    rm -f "$UNITY_SESSION_FILE"
    exit 0
fi

# Restore session context
BRANCH=$(jq -r '.branch // empty' "$UNITY_SESSION_FILE" 2>/dev/null)
WORKFLOW_PHASE=$(jq -r '.workflow_phase // empty' "$UNITY_SESSION_FILE" 2>/dev/null)
MODIFIED_FILES=$(jq -r '.modified_files // [] | join(", ")' "$UNITY_SESSION_FILE" 2>/dev/null)
LAST_COMMAND=$(jq -r '.last_command // empty' "$UNITY_SESSION_FILE" 2>/dev/null)

CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")

echo "" >&2
echo "--- Session Restored ---" >&2

if [ -n "$BRANCH" ] && [ "$BRANCH" != "$CURRENT_BRANCH" ]; then
    echo "  Previous branch: $BRANCH (current: $CURRENT_BRANCH)" >&2
elif [ -n "$BRANCH" ]; then
    echo "  Branch: $BRANCH" >&2
fi

if [ -n "$WORKFLOW_PHASE" ]; then
    echo "  Workflow phase: $WORKFLOW_PHASE" >&2
fi

if [ -n "$MODIFIED_FILES" ]; then
    echo "  Previously modified: $MODIFIED_FILES" >&2
fi

if [ -n "$LAST_COMMAND" ]; then
    echo "  Last command: $LAST_COMMAND" >&2
fi

echo "------------------------" >&2

exit 0
