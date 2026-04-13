#!/usr/bin/env bash
# ============================================================================
# warn-filename.sh — WARNING HOOK
# Checks that C# file name matches the primary class/struct name.
# Unity requires MonoBehaviour/ScriptableObject file name == class name,
# otherwise the script cannot be attached to GameObjects.
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

# Get the expected class name from file name (without path and extension)
FILENAME=$(basename "$FILE_PATH" .cs)

# Skip test files, editor scripts, and generated files
case "$FILENAME" in
    *Tests|*Test|*.g|*.generated|AssemblyInfo) exit 0 ;;
esac

# Read the file content (from the new_string for Edit, or content for Write)
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // empty')

if [ -z "$CONTENT" ]; then
    # For Edit, we might need to check the full file — skip if we can't
    exit 0
fi

# Check if the file contains a class/struct matching the filename
# Look for: public/internal/sealed class/struct FileName
if echo "$CONTENT" | grep -qE "(class|struct|interface)\s+$FILENAME\b"; then
    exit 0
fi

# Check if there's any MonoBehaviour or ScriptableObject subclass
if echo "$CONTENT" | grep -qE ':\s*(MonoBehaviour|ScriptableObject|NetworkBehaviour|StateMachineBehaviour)'; then
    # There IS a Unity component but the name doesn't match
    CLASS_NAME=$(echo "$CONTENT" | grep -oE '(class|struct)\s+\w+' | head -1 | awk '{print $2}')
    if [ -n "$CLASS_NAME" ] && [ "$CLASS_NAME" != "$FILENAME" ]; then
        echo "WARNING: File name '$FILENAME.cs' does not match class name '$CLASS_NAME'." >&2
        echo "" >&2
        echo "  File: $FILE_PATH" >&2
        echo "" >&2
        echo "  Unity requires MonoBehaviour/ScriptableObject file name to match" >&2
        echo "  the class name. This script won't be attachable to GameObjects." >&2
        echo "" >&2
        echo "  Fix: Rename the file to '$CLASS_NAME.cs' or rename the class to '$FILENAME'." >&2
    fi
fi

exit 0
