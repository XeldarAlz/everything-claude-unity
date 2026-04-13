#!/usr/bin/env bash
# ============================================================================
# block-projectsettings.sh — BLOCKING HOOK
# Prevents staging ProjectSettings/ and Packages/ files via git add.
# These are Unity-managed YAML configs. Manual edits cause merge conflicts
# and subtle build issues. Use unity-mcp tools instead.
# ============================================================================
# Trigger: PreToolUse on Bash
# Exit: 2 = block, 0 = allow
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_PROFILE_LEVEL="minimal"
source "${SCRIPT_DIR}/_lib.sh"

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
    exit 0
fi

# Check if the command is staging ProjectSettings or Packages files
if echo "$COMMAND" | grep -qE 'git\s+add.*ProjectSettings/'; then
    MSG="Do not stage ProjectSettings/ files directly."
    echo "" >&2
    echo "  Command: $COMMAND" >&2
    echo "" >&2
    echo "  ProjectSettings/ contains Unity-managed YAML configs." >&2
    echo "  Manual edits cause merge conflicts and subtle build issues." >&2
    echo "" >&2
    echo "  Instead, use unity-mcp tools:" >&2
    echo "    - manage_build     → change build/player settings" >&2
    echo "    - manage_physics   → change physics settings" >&2
    echo "    - manage_graphics  → change graphics/quality settings" >&2
    unity_hook_block "$MSG"
fi

if echo "$COMMAND" | grep -qE 'git\s+add.*Packages/(manifest|packages-lock)\.json'; then
    MSG="Do not stage Packages/ manifest files directly."
    echo "" >&2
    echo "  Command: $COMMAND" >&2
    echo "" >&2
    echo "  Use unity-mcp manage_packages to install/remove packages." >&2
    unity_hook_block "$MSG"
fi

exit 0
