#!/usr/bin/env bash
# ============================================================================
# stop-validate.sh — STOP HOOK (standard profile)
# Runs validation checks on all C# files modified during the session when
# the agent stops. Catches issues that per-edit hooks might miss because
# they only see the edited fragment, not the full file.
# ============================================================================
# Trigger: Stop
# Exit: 0 always (advisory)
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_PROFILE_LEVEL="standard"
source "${SCRIPT_DIR}/_lib.sh"

# Get list of C# files modified during this session
if [ ! -f "$UNITY_EDITS_FILE" ]; then
    exit 0
fi

CS_FILES=$(sort -u "$UNITY_EDITS_FILE" | grep '\.cs$' || true)

if [ -z "$CS_FILES" ]; then
    exit 0
fi

CS_COUNT=$(echo "$CS_FILES" | wc -l | tr -d ' ')
ISSUES=0

echo "" >&2
echo "--- Stop Validation ($CS_COUNT C# files) ---" >&2

while IFS= read -r FILE; do
    [ -f "$FILE" ] || continue

    FILE_ISSUES=""

    # Check for GetComponent in Update/FixedUpdate/LateUpdate (full file context)
    if grep -qE 'void\s+(Update|FixedUpdate|LateUpdate)' "$FILE" 2>/dev/null; then
        # Extract the method bodies would be complex, so just check for these calls existing in the file
        PERF_HITS=$(grep -nE '(GetComponent|FindObjectOfType|Camera\.main)\b' "$FILE" 2>/dev/null | grep -v '//.*GetComponent' || true)
        if [ -n "$PERF_HITS" ]; then
            FILE_ISSUES="${FILE_ISSUES}    Performance: GetComponent/FindObjectOfType/Camera.main found (cache in Awake)\n"
        fi
    fi

    # Check for missing FormerlySerializedAs (serialized field without it)
    # This is a heuristic — look for [SerializeField] fields that have common "renamed" patterns
    SERIALIZE_FIELDS=$(grep -c '\[SerializeField\]' "$FILE" 2>/dev/null || true)
    FORMERLY_ATTRS=$(grep -c 'FormerlySerializedAs' "$FILE" 2>/dev/null || true)
    # Not a perfect check, but flag files with many serialized fields and zero FormerlySerializedAs
    # (this is informational, not an error)

    # Check for ?. on Unity objects in full file
    NULL_COND=$(grep -nE '\?\.(enabled|transform|gameObject|name|tag|activeSelf|activeInHierarchy)' "$FILE" 2>/dev/null || true)
    if [ -n "$NULL_COND" ]; then
        FILE_ISSUES="${FILE_ISSUES}    Safety: Null-conditional (?.) on Unity object (bypasses destroyed-object detection)\n"
    fi

    # Check for coroutine usage (should be UniTask)
    if grep -qE '(StartCoroutine|IEnumerator|yield\s+return)' "$FILE" 2>/dev/null; then
        case "$FILE" in
            *Test*|*test*|*Editor*) ;; # Skip test/editor files
            *)
                FILE_ISSUES="${FILE_ISSUES}    Convention: Coroutine usage detected — prefer UniTask\n"
                ;;
        esac
    fi

    # Check for singleton pattern
    if grep -qE 'static\s+\w+\s+[Ii]nstance\b' "$FILE" 2>/dev/null; then
        FILE_ISSUES="${FILE_ISSUES}    Architecture: Singleton pattern detected — use VContainer instead\n"
    fi

    # Check for public fields (should be [SerializeField] private)
    PUBLIC_FIELDS=$(grep -nE '^\s*public\s+(int|float|string|bool|Vector[234]|Color|GameObject|Transform|Sprite|AudioClip)\s+\w+\s*[;=]' "$FILE" 2>/dev/null || true)
    if [ -n "$PUBLIC_FIELDS" ]; then
        FILE_ISSUES="${FILE_ISSUES}    Convention: Public fields detected — use [SerializeField] private\n"
    fi

    if [ -n "$FILE_ISSUES" ]; then
        echo "  $FILE:" >&2
        echo -e "$FILE_ISSUES" >&2
        ISSUES=$((ISSUES + 1))
    fi
done <<< "$CS_FILES"

if [ "$ISSUES" -eq 0 ]; then
    echo "  All files passed validation." >&2
else
    echo "  $ISSUES file(s) with potential issues. Consider running /unity-review." >&2
fi

echo "-------------------------------" >&2

exit 0
