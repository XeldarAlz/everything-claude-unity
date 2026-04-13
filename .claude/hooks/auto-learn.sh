#!/usr/bin/env bash
# ============================================================================
# auto-learn.sh — STOP HOOK (strict profile)
# Extracts session patterns when the agent stops. Records:
#   - Which hooks fired and how often (what pitfalls the agent hit)
#   - What types of files were edited (gameplay, UI, systems, etc.)
#   - Which commands/skills were invoked
#
# Writes session learnings to a persistent log that can be reviewed
# periodically to evolve skills and identify recurring patterns.
# ============================================================================
# Trigger: Stop
# Exit: 0 always (advisory)
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_PROFILE_LEVEL="strict"
source "${SCRIPT_DIR}/_lib.sh"

PERSISTENT_LOG="${SCRIPT_DIR}/../learnings.jsonl"

# Gather session data

# Files edited
EDITED_FILES="[]"
if [ -f "$UNITY_EDITS_FILE" ]; then
    EDITED_FILES=$(sort -u "$UNITY_EDITS_FILE" | jq -Rs 'split("\n") | map(select(length > 0))')
fi

EDIT_COUNT=$(echo "$EDITED_FILES" | jq 'length')
if [ "$EDIT_COUNT" -eq 0 ]; then
    # No edits this session — nothing to learn from
    exit 0
fi

# Categorize edited files
CS_FILES=$(echo "$EDITED_FILES" | jq '[.[] | select(endswith(".cs"))]')
SHADER_FILES=$(echo "$EDITED_FILES" | jq '[.[] | select(endswith(".shader") or endswith(".hlsl") or endswith(".cginc"))]')

# Detect file categories from paths
MODEL_COUNT=$(echo "$CS_FILES" | jq '[.[] | select(contains("Model"))] | length')
VIEW_COUNT=$(echo "$CS_FILES" | jq '[.[] | select(contains("View"))] | length')
SYSTEM_COUNT=$(echo "$CS_FILES" | jq '[.[] | select(contains("System"))] | length')
TEST_COUNT=$(echo "$CS_FILES" | jq '[.[] | select(contains("Test"))] | length')
EDITOR_COUNT=$(echo "$CS_FILES" | jq '[.[] | select(contains("Editor"))] | length')

# Tool call breakdown
TOOL_BREAKDOWN="{}"
if [ -f "$UNITY_COST_FILE" ]; then
    TOOL_BREAKDOWN=$(jq -s 'group_by(.tool) | map({key: .[0].tool, value: length}) | from_entries' "$UNITY_COST_FILE" 2>/dev/null || echo '{}')
fi

# Session duration
DURATION_SECS=0
if [ -f "${UNITY_HOOK_STATE_DIR}/session-start-time" ]; then
    START_TIME=$(cat "${UNITY_HOOK_STATE_DIR}/session-start-time")
    DURATION_SECS=$(( $(date +%s) - START_TIME ))
fi

# Write learning entry
jq -nc \
    --arg date "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
    --arg branch "$(git branch --show-current 2>/dev/null || echo 'unknown')" \
    --argjson edit_count "$EDIT_COUNT" \
    --argjson mvs "{\"models\": $MODEL_COUNT, \"views\": $VIEW_COUNT, \"systems\": $SYSTEM_COUNT}" \
    --argjson test_count "$TEST_COUNT" \
    --argjson editor_count "$EDITOR_COUNT" \
    --argjson shader_count "$(echo "$SHADER_FILES" | jq 'length')" \
    --argjson tools "$TOOL_BREAKDOWN" \
    --argjson duration "$DURATION_SECS" \
    '{
        date: $date,
        branch: $branch,
        files_edited: $edit_count,
        mvs_breakdown: $mvs,
        tests_written: $test_count,
        editor_scripts: $editor_count,
        shaders: $shader_count,
        tool_usage: $tools,
        duration_seconds: $duration
    }' >> "$PERSISTENT_LOG"

echo "" >&2
echo "--- Session Learning Captured ---" >&2
echo "  Files: $EDIT_COUNT edited (M:$MODEL_COUNT V:$VIEW_COUNT S:$SYSTEM_COUNT T:$TEST_COUNT)" >&2
if [ "$DURATION_SECS" -gt 0 ]; then
    echo "  Duration: $((DURATION_SECS / 60))m $((DURATION_SECS % 60))s" >&2
fi
echo "  Log: $PERSISTENT_LOG" >&2
echo "---------------------------------" >&2

exit 0
