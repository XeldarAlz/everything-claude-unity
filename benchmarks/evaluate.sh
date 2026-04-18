#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# evaluate.sh
# Evaluates a single benchmark scenario against a working directory.
# Checks expected_files, expected_patterns, and forbidden_patterns from the
# scenario JSON, then outputs a JSON result to stdout.
#
# Usage:
#   ./benchmarks/evaluate.sh <scenario.json> <working-directory>
# =============================================================================

# ---------------------------------------------------------------------------
# Color support
# ---------------------------------------------------------------------------
if [[ -t 2 ]] && command -v tput &>/dev/null && [[ $(tput colors 2>/dev/null || echo 0) -ge 8 ]]; then
    RED=$(tput setaf 1); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3)
    CYAN=$(tput setaf 6); BOLD=$(tput bold); RESET=$(tput sgr0)
else
    RED=""; GREEN=""; YELLOW=""; CYAN=""; BOLD=""; RESET=""
fi

# ---------------------------------------------------------------------------
# Arguments
# ---------------------------------------------------------------------------
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <scenario.json> <working-directory>" >&2
    exit 1
fi

SCENARIO_FILE="$1"
WORK_DIR="$2"

if [[ ! -f "$SCENARIO_FILE" ]]; then
    echo "${RED}Error: Scenario file not found: $SCENARIO_FILE${RESET}" >&2
    exit 1
fi

if [[ ! -d "$WORK_DIR" ]]; then
    echo "${RED}Error: Working directory not found: $WORK_DIR${RESET}" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Dependencies
# ---------------------------------------------------------------------------
if ! command -v jq &>/dev/null; then
    echo "${RED}Error: jq is required but not installed.${RESET}" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Parse scenario
# ---------------------------------------------------------------------------
SCENARIO_NAME=$(jq -r '.name // "unknown"' "$SCENARIO_FILE")

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
PASSED=0
FAILED=0
DETAILS="[]"

add_result() {
    local check="$1" result="$2" message="$3"
    DETAILS=$(echo "$DETAILS" | jq \
        --arg check "$check" \
        --arg result "$result" \
        --arg message "$message" \
        '. + [{"check": $check, "result": $result, "message": $message}]')
    if [[ "$result" == "pass" ]]; then
        PASSED=$((PASSED + 1))
        echo "  ${GREEN}PASS${RESET} $check — $message" >&2
    else
        FAILED=$((FAILED + 1))
        echo "  ${RED}FAIL${RESET} $check — $message" >&2
    fi
}

# Resolve a glob pattern relative to the working directory.
# Returns matching file paths (one per line), or empty if none match.
resolve_glob() {
    local pattern="$1"
    # Use find for ** patterns, simple glob for others
    if [[ "$pattern" == **"**"** ]]; then
        # Convert glob to find-compatible pattern
        local find_pattern
        find_pattern=$(echo "$pattern" | sed 's|^\*\*/||')
        find "$WORK_DIR" -type f -name "$find_pattern" 2>/dev/null || true
    else
        # shellcheck disable=SC2086
        local resolved
        resolved=$(cd "$WORK_DIR" && ls $pattern 2>/dev/null | while read -r f; do echo "$WORK_DIR/$f"; done || true)
        echo "$resolved"
    fi
}

# ---------------------------------------------------------------------------
# Check: expected_files
# ---------------------------------------------------------------------------
EXPECTED_FILES_COUNT=$(jq -r '.expected_files // [] | length' "$SCENARIO_FILE")

for (( fileIndex = 0; fileIndex < EXPECTED_FILES_COUNT; fileIndex++ )); do
    PATTERN=$(jq -r ".expected_files[$fileIndex]" "$SCENARIO_FILE")
    MATCHES=$(resolve_glob "$PATTERN")
    if [[ -n "$MATCHES" ]]; then
        add_result "expected_file" "pass" "Found file matching: $PATTERN"
    else
        add_result "expected_file" "fail" "No file matching: $PATTERN"
    fi
done

# ---------------------------------------------------------------------------
# Check: expected_patterns
# ---------------------------------------------------------------------------
EXPECTED_PATTERNS_COUNT=$(jq -r '.expected_patterns // [] | length' "$SCENARIO_FILE")

for (( patternIndex = 0; patternIndex < EXPECTED_PATTERNS_COUNT; patternIndex++ )); do
    FILE_GLOB=$(jq -r ".expected_patterns[$patternIndex].file" "$SCENARIO_FILE")
    REGEX=$(jq -r ".expected_patterns[$patternIndex].pattern" "$SCENARIO_FILE")

    MATCHES=$(resolve_glob "$FILE_GLOB")
    if [[ -z "$MATCHES" ]]; then
        add_result "expected_pattern" "fail" "No files matching $FILE_GLOB to check for pattern: $REGEX"
        continue
    fi

    FOUND=false
    while IFS= read -r FILE; do
        [[ -z "$FILE" ]] && continue
        if grep -qE "$REGEX" "$FILE" 2>/dev/null; then
            FOUND=true
            break
        fi
    done <<< "$MATCHES"

    if [[ "$FOUND" == true ]]; then
        add_result "expected_pattern" "pass" "Pattern '$REGEX' found in $FILE_GLOB"
    else
        add_result "expected_pattern" "fail" "Pattern '$REGEX' NOT found in any file matching $FILE_GLOB"
    fi
done

# ---------------------------------------------------------------------------
# Check: forbidden_patterns
# ---------------------------------------------------------------------------
FORBIDDEN_PATTERNS_COUNT=$(jq -r '.forbidden_patterns // [] | length' "$SCENARIO_FILE")

for (( forbiddenIndex = 0; forbiddenIndex < FORBIDDEN_PATTERNS_COUNT; forbiddenIndex++ )); do
    FILE_GLOB=$(jq -r ".forbidden_patterns[$forbiddenIndex].file" "$SCENARIO_FILE")
    REGEX=$(jq -r ".forbidden_patterns[$forbiddenIndex].pattern" "$SCENARIO_FILE")

    MATCHES=$(resolve_glob "$FILE_GLOB")
    if [[ -z "$MATCHES" ]]; then
        # No files to check — pattern is trivially not present
        add_result "forbidden_pattern" "pass" "No files matching $FILE_GLOB (pattern '$REGEX' trivially absent)"
        continue
    fi

    VIOLATION_FOUND=false
    VIOLATION_FILE=""
    while IFS= read -r FILE; do
        [[ -z "$FILE" ]] && continue
        if grep -qE "$REGEX" "$FILE" 2>/dev/null; then
            VIOLATION_FOUND=true
            VIOLATION_FILE="$FILE"
            break
        fi
    done <<< "$MATCHES"

    if [[ "$VIOLATION_FOUND" == true ]]; then
        local_path="${VIOLATION_FILE#"$WORK_DIR"/}"
        add_result "forbidden_pattern" "fail" "Forbidden pattern '$REGEX' found in $local_path"
    else
        add_result "forbidden_pattern" "pass" "Forbidden pattern '$REGEX' correctly absent from $FILE_GLOB"
    fi
done

# ---------------------------------------------------------------------------
# Output JSON result to stdout
# ---------------------------------------------------------------------------
TOTAL=$((PASSED + FAILED))

jq -n \
    --arg scenario "$SCENARIO_NAME" \
    --argjson passed "$PASSED" \
    --argjson failed "$FAILED" \
    --argjson total "$TOTAL" \
    --argjson details "$DETAILS" \
    '{
        "scenario": $scenario,
        "passed": $passed,
        "failed": $failed,
        "total": $total,
        "details": $details
    }'
