#!/usr/bin/env bash
# ============================================================================
# build-analyze.sh — WARNING HOOK (strict profile)
# Detects Unity build commands and analyzes output for common issues:
#   - Build size warnings
#   - Shader variant counts
#   - Script compilation errors
#   - Stripping issues
# Runs after Bash commands that look like Unity builds.
# ============================================================================
# Trigger: PostToolUse on Bash
# Exit: 0 always (warning only, via stderr)
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_PROFILE_LEVEL="strict"
source "${SCRIPT_DIR}/_lib.sh"

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
OUTPUT=$(echo "$INPUT" | jq -r '.tool_output.stdout // empty')
STDERR=$(echo "$INPUT" | jq -r '.tool_output.stderr // empty')

# Only analyze build-related commands
IS_BUILD=false
case "$COMMAND" in
    *Unity*-buildTarget*|*-executeMethod*Build*|*BuildPipeline*|*unity-build*|*mcp__unityMCP__manage_build*)
        IS_BUILD=true
        ;;
esac

if ! $IS_BUILD; then
    # Also check if output mentions build completion
    if echo "$OUTPUT$STDERR" | grep -qiE '(Build completed|Build succeeded|Build failed|BuildPlayer)'; then
        IS_BUILD=true
    fi
fi

if ! $IS_BUILD; then
    exit 0
fi

COMBINED="$OUTPUT$STDERR"
WARNINGS=""

# --- Check for build failure ---
if echo "$COMBINED" | grep -qiE '(Build failed|error CS|Fatal error)'; then
    ERRORS=$(echo "$COMBINED" | grep -ciE '(error CS|Fatal error)' || true)
    WARNINGS="${WARNINGS}  BUILD FAILED — $ERRORS compilation error(s) detected.\n"
fi

# --- Check shader variant count ---
SHADER_VARIANTS=$(echo "$COMBINED" | grep -oE 'Compiled [0-9]+ shader variants' | grep -oE '[0-9]+' || true)
if [ -n "$SHADER_VARIANTS" ]; then
    for COUNT in $SHADER_VARIANTS; do
        if [ "$COUNT" -gt 500 ]; then
            WARNINGS="${WARNINGS}  High shader variant count: $COUNT variants. Consider shader stripping or variant collections.\n"
        fi
    done
fi

# --- Check build size ---
BUILD_SIZE=$(echo "$COMBINED" | grep -oE 'Total size: [0-9.]+ [KMG]B' || true)
if [ -n "$BUILD_SIZE" ]; then
    WARNINGS="${WARNINGS}  Build size: $BUILD_SIZE\n"
fi

# --- Check for stripping warnings ---
STRIP_WARNINGS=$(echo "$COMBINED" | grep -ci 'stripping' || true)
if [ "$STRIP_WARNINGS" -gt 5 ]; then
    WARNINGS="${WARNINGS}  $STRIP_WARNINGS stripping warnings — check link.xml for preserved types.\n"
fi

# --- Check for managed code stripping issues ---
if echo "$COMBINED" | grep -qiE '(MissingMethodException|TypeLoadException|link\.xml)'; then
    WARNINGS="${WARNINGS}  Potential code stripping issue — types may be stripped that are needed at runtime.\n"
    WARNINGS="${WARNINGS}  Add [Preserve] attribute or entries in link.xml for reflection-accessed types.\n"
fi

# --- Check for deprecated API usage ---
DEPRECATED=$(echo "$COMBINED" | grep -ci 'obsolete' || true)
if [ "$DEPRECATED" -gt 0 ]; then
    WARNINGS="${WARNINGS}  $DEPRECATED deprecated API warning(s). Run /unity-migrate to update.\n"
fi

if [ -n "$WARNINGS" ]; then
    echo "" >&2
    echo "--- Build Analysis ---" >&2
    echo -e "$WARNINGS" >&2
    echo "----------------------" >&2
fi

# Write build_complete event for notification system
BUILD_STATUS=""
if echo "$COMBINED" | grep -qiE '(Build failed|error CS|Fatal error)'; then
    BUILD_STATUS="FAILED — ${ERRORS:-unknown} error(s)"
elif echo "$COMBINED" | grep -qiE '(Build completed|Build succeeded)'; then
    BUILD_STATUS="SUCCESS"
    if [ -n "${BUILD_SIZE:-}" ]; then
        BUILD_STATUS="SUCCESS (${BUILD_SIZE})"
    fi
fi

if [ -n "$BUILD_STATUS" ]; then
    jq -nc --arg event "build_complete" --arg details "$BUILD_STATUS" \
        '{event: $event, details: $details}' > "$UNITY_HOOK_STATE_DIR/notify-event.json" 2>/dev/null || true
fi

exit 0
