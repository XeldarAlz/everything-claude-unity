#!/usr/bin/env bash
# ============================================================================
# track-edits.sh — TRACKING HOOK (standard profile)
# Records files that have been edited during this session. Used by:
#   - stop-validate.sh (runs validation on modified files)
#   - session-save.sh (persists session state)
#   - cost-tracker.sh (session metrics)
# ============================================================================
# Trigger: PostToolUse on Edit|Write
# Exit: 0 always (tracking only)
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_PROFILE_LEVEL="standard"
source "${SCRIPT_DIR}/_lib.sh"

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -n "$FILE_PATH" ]; then
    unity_track_edit "$FILE_PATH"
fi

exit 0
