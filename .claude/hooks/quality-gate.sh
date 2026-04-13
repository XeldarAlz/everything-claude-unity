#!/usr/bin/env bash
# ============================================================================
# quality-gate.sh — WARNING HOOK (standard profile)
# Lightweight post-edit quality check for common Unity C# pitfalls.
# Runs after every Edit/Write on C# files and warns about:
#   - GetComponent/FindObjectOfType in Update/FixedUpdate/LateUpdate
#   - Uncached Camera.main
#   - LINQ in gameplay code (outside Editor/)
#   - tag == "string" instead of CompareTag
#   - Null-conditional (?.) on UnityEngine.Object types
#   - Debug.Log without conditional compilation
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

# Skip Editor code — different performance requirements
case "$FILE_PATH" in
    */Editor/*|*/editor/*) exit 0 ;;
esac

# Get the content being written/edited
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // empty')

if [ -z "$CONTENT" ]; then
    exit 0
fi

WARNINGS=""

# --- Check for GetComponent/FindObjectOfType in Update methods ---
# Look for Update-family method signatures in the content
if echo "$CONTENT" | grep -qE 'void\s+(Update|FixedUpdate|LateUpdate)\s*\('; then
    if echo "$CONTENT" | grep -qE '(GetComponent|TryGetComponent|FindObjectOfType|FindObjectsOfType|Camera\.main)\b'; then
        WARNINGS="${WARNINGS}  - GetComponent/FindObjectOfType/Camera.main detected near Update method. Cache in Awake().\n"
    fi
fi

# --- Check for LINQ usage in gameplay code ---
if echo "$CONTENT" | grep -qE '\.(Where|Select|Any|All|First|Last|Count|OrderBy|GroupBy|Aggregate|ToList|ToArray|ToDictionary)\s*\('; then
    # Exclude test files
    case "$FILE_PATH" in
        *Tests*|*Test*|*test*) ;;
        *)
            WARNINGS="${WARNINGS}  - LINQ detected in gameplay code. Use manual loops to avoid GC allocations.\n"
            ;;
    esac
fi

# --- Check for tag == "string" instead of CompareTag ---
if echo "$CONTENT" | grep -qE '\.tag\s*==\s*"'; then
    WARNINGS="${WARNINGS}  - Use CompareTag(\"tag\") instead of .tag == \"tag\" to avoid string allocation.\n"
fi

# --- Check for null-conditional on potential Unity objects ---
if echo "$CONTENT" | grep -qE '\?\.(enabled|transform|gameObject|name|tag|GetComponent)'; then
    WARNINGS="${WARNINGS}  - Null-conditional (?.) on Unity object bypasses destroyed-object detection. Use explicit null check.\n"
fi

# --- Check for Debug.Log without conditional ---
if echo "$CONTENT" | grep -qE 'Debug\.(Log|LogWarning|LogError)\s*\('; then
    if ! echo "$CONTENT" | grep -qE '#if\s+(UNITY_EDITOR|DEBUG|DEVELOPMENT_BUILD)'; then
        if ! echo "$CONTENT" | grep -qE '\[Conditional\s*\('; then
            WARNINGS="${WARNINGS}  - Debug.Log in production code. Wrap with #if UNITY_EDITOR or use [Conditional(\"UNITY_EDITOR\")] wrapper.\n"
        fi
    fi
fi

# --- Check for new WaitForSeconds in methods (likely in Update or repeated calls) ---
if echo "$CONTENT" | grep -qE 'new\s+WaitForSeconds\s*\('; then
    WARNINGS="${WARNINGS}  - new WaitForSeconds() allocates each call. Cache as a field or use UniTask.Delay.\n"
fi

# --- Check for SendMessage/BroadcastMessage ---
if echo "$CONTENT" | grep -qE '(SendMessage|BroadcastMessage)\s*\('; then
    WARNINGS="${WARNINGS}  - SendMessage/BroadcastMessage uses reflection. Use direct references or MessagePipe.\n"
fi

if [ -n "$WARNINGS" ]; then
    echo "" >&2
    echo "QUALITY: Potential issues in $FILE_PATH:" >&2
    echo -e "$WARNINGS" >&2
fi

exit 0
