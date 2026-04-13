#!/usr/bin/env bash
# ============================================================================
# cost-tracker.sh — TRACKING HOOK (strict profile)
# Logs every tool call with timestamp and tool name for session metrics.
# The session-save.sh Stop hook uses this data to report totals.
# ============================================================================
# Trigger: PostToolUse (all tools)
# Exit: 0 always (tracking only)
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_PROFILE_LEVEL="strict"
source "${SCRIPT_DIR}/_lib.sh"

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')

# Log tool call as JSONL
jq -nc \
    --arg tool "$TOOL_NAME" \
    --arg ts "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
    '{tool: $tool, timestamp: $ts}' >> "$UNITY_COST_FILE"

exit 0
