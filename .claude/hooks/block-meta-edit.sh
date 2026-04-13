#!/usr/bin/env bash
# ============================================================================
# block-meta-edit.sh — BLOCKING HOOK
# Prevents Claude from editing .meta files.
# Meta files contain GUIDs that Unity uses to reference assets. Editing them
# breaks every reference to that asset across all scenes, prefabs, and scripts.
# ============================================================================
# Trigger: PreToolUse on Edit|Write
# Exit: 2 = block, 0 = allow
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_PROFILE_LEVEL="minimal"
source "${SCRIPT_DIR}/_lib.sh"

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

case "$FILE_PATH" in
    *.meta)
        MSG="Editing .meta files breaks asset references across the entire project."
        echo "" >&2
        echo "  File: $FILE_PATH" >&2
        echo "" >&2
        echo "  .meta files contain GUIDs that Unity uses to track assets." >&2
        echo "  Modifying them will break every reference to this asset in" >&2
        echo "  all scenes, prefabs, and ScriptableObjects." >&2
        echo "" >&2
        echo "  Unity manages these files automatically — never edit them manually." >&2
        unity_hook_block "$MSG"
        ;;
    *)
        exit 0
        ;;
esac
