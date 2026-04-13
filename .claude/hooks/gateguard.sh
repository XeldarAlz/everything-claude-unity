#!/usr/bin/env bash
# ============================================================================
# gateguard.sh — BLOCKING HOOK (strict profile)
# Fact-forcing gate: blocks the first Edit/Write on a C# file until the agent
# has Read it first. Prevents hallucinated changes to files the agent hasn't
# investigated.
#
# Unity-specific: for MVS pattern files (Model/View/System), also checks that
# related counterparts have been read (e.g., editing a View requires reading
# its Model first).
# ============================================================================
# Trigger: PreToolUse on Edit|Write
# Exit: 2 = block (file not yet read), 0 = allow
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_PROFILE_LEVEL="strict"
source "${SCRIPT_DIR}/_lib.sh"

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only gate C# files
case "$FILE_PATH" in
    *.cs) ;;
    *) exit 0 ;;
esac

# Check if this file has been read
if ! unity_was_read "$FILE_PATH"; then
    MSG="GateGuard: You must Read this file before editing it."
    echo "" >&2
    echo "  File: $FILE_PATH" >&2
    echo "" >&2
    echo "  Read the file first to understand its current state, imports," >&2
    echo "  and dependencies before making changes." >&2
    echo "" >&2
    echo "  This prevents hallucinated edits to code you haven't seen." >&2
    unity_hook_block "$MSG"
fi

# --- MVS counterpart check ---
# If editing a View, check that its Model was read
# If editing a System, check that its Model was read
BASENAME=$(basename "$FILE_PATH" .cs)
DIR=$(dirname "$FILE_PATH")

check_counterpart() {
    local suffix="$1"
    local role="$2"
    # Strip known suffixes and try the counterpart
    local base="${BASENAME%View}"
    base="${base%System}"
    base="${base%Model}"
    local counterpart_name="${base}${suffix}"

    # Search in same directory and parent directories
    for search_dir in "$DIR" "$(dirname "$DIR")"; do
        local candidate
        candidate=$(find "$search_dir" -name "${counterpart_name}.cs" -maxdepth 3 2>/dev/null | head -1)
        if [ -n "$candidate" ] && [ -f "$candidate" ]; then
            if ! unity_was_read "$candidate"; then
                echo "SUGGESTION: Consider reading the ${role} first: ${candidate}" >&2
                echo "  The MVS pattern works best when you understand the full picture." >&2
                echo "" >&2
            fi
            return
        fi
    done
}

case "$BASENAME" in
    *View)
        check_counterpart "Model" "Model"
        check_counterpart "System" "System"
        ;;
    *System)
        check_counterpart "Model" "Model"
        ;;
esac

exit 0
