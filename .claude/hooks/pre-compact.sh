#!/usr/bin/env bash
# ============================================================================
# pre-compact.sh — ADVISORY HOOK
# Saves session state before context window compression so critical
# information survives compaction. Writes to a temp file that can be
# referenced after compaction occurs.
# ============================================================================
# Trigger: PreCompact
# Exit: 0 always (advisory — saves state, never blocks compaction)
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_PROFILE_LEVEL="minimal"
source "${SCRIPT_DIR}/_lib.sh"

INPUT=$(cat)

STATE_FILE="/tmp/unity-claude-precompact-state.md"

# Gather git state
MODIFIED_FILES=$(git diff --name-only HEAD 2>/dev/null || echo "(not a git repo)")
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || echo "(none)")
RECENT_COMMITS=$(git log --oneline -5 2>/dev/null || echo "(no commits)")
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "(unknown)")

# Count modified C# files specifically
CS_MODIFIED=$(echo "$MODIFIED_FILES" | grep '\.cs$' | wc -l | tr -d ' ')

# Write state file
cat > "$STATE_FILE" <<EOF
# Pre-Compaction Session State
**Saved:** $(date '+%Y-%m-%d %H:%M:%S')
**Branch:** $CURRENT_BRANCH

## Modified Files ($CS_MODIFIED C# files)
\`\`\`
$MODIFIED_FILES
\`\`\`

## Staged Files
\`\`\`
$STAGED_FILES
\`\`\`

## Recent Commits
\`\`\`
$RECENT_COMMITS
\`\`\`
EOF

echo "" >&2
echo "Session state saved to $STATE_FILE before context compaction." >&2
echo "  Branch: $CURRENT_BRANCH | Modified C# files: $CS_MODIFIED" >&2

exit 0
