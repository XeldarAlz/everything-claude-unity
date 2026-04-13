#!/usr/bin/env bash
# ============================================================================
# warn-platform-defines.sh — WARNING HOOK
# Checks for #if UNITY_ANDROID / UNITY_IOS etc. without #else fallback.
# Code inside platform defines is silently excluded on other platforms,
# which can cause missing functionality or compilation errors.
# ============================================================================
# Trigger: PostToolUse on Edit|Write
# Exit: 0 always (warning only, via stderr)
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_PROFILE_LEVEL="standard"
source "${SCRIPT_DIR}/_lib.sh"

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check C# files
case "$FILE_PATH" in
    *.cs) ;;
    *) exit 0 ;;
esac

CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // empty')

if [ -z "$CONTENT" ]; then
    exit 0
fi

# Platform-specific defines to check
PLATFORM_DEFINES="UNITY_ANDROID|UNITY_IOS|UNITY_WEBGL|UNITY_STANDALONE_WIN|UNITY_STANDALONE_OSX|UNITY_STANDALONE_LINUX|UNITY_PS4|UNITY_PS5|UNITY_XBOXONE|UNITY_GAMECORE|UNITY_SWITCH"

# Check for platform defines without else
if echo "$CONTENT" | grep -qE "#if\s+($PLATFORM_DEFINES)"; then
    # Count #if UNITY_PLATFORM and #else occurrences
    IF_COUNT=$(echo "$CONTENT" | grep -cE "#if\s+($PLATFORM_DEFINES)" || true)
    ELSE_COUNT=$(echo "$CONTENT" | grep -cE "#else|#elif" || true)

    if [ "$IF_COUNT" -gt "$ELSE_COUNT" ]; then
        DEFINES_USED=$(echo "$CONTENT" | grep -oE "#if\s+($PLATFORM_DEFINES)" | sed 's/#if\s*//' | sort -u | tr '\n' ', ' | sed 's/,$//')
        echo "WARNING: Platform-specific code without #else fallback." >&2
        echo "" >&2
        echo "  File: $FILE_PATH" >&2
        echo "  Defines: $DEFINES_USED" >&2
        echo "" >&2
        echo "  Code inside platform defines is silently excluded on other platforms." >&2
        echo "  Consider adding #else with a fallback or #error for unsupported platforms:" >&2
        echo "" >&2
        echo "    #if UNITY_ANDROID" >&2
        echo "        // Android implementation" >&2
        echo "    #elif UNITY_IOS" >&2
        echo "        // iOS implementation" >&2
        echo "    #else" >&2
        echo "        // Default / other platforms" >&2
        echo "    #endif" >&2
    fi
fi

exit 0
