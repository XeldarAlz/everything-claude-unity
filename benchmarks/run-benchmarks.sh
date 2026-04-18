#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# run-benchmarks.sh
# Runs all benchmark scenarios (or a single one) and collects results.
# Optionally compares against a previous result file.
#
# Usage:
#   ./benchmarks/run-benchmarks.sh [OPTIONS]
#
# Options:
#   --workdir <dir>       Working directory to evaluate (default: current dir)
#   --scenario <name>     Run only the named scenario
#   --compare <file>      Compare results against a previous JSON result file
#   -h, --help            Show help
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCENARIOS_DIR="$SCRIPT_DIR/scenarios"
RESULTS_DIR="$SCRIPT_DIR/results"
EVALUATE="$SCRIPT_DIR/evaluate.sh"

# ---------------------------------------------------------------------------
# Color support
# ---------------------------------------------------------------------------
if [[ -t 1 ]] && command -v tput &>/dev/null && [[ $(tput colors 2>/dev/null || echo 0) -ge 8 ]]; then
    RED=$(tput setaf 1); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3)
    CYAN=$(tput setaf 6); BOLD=$(tput bold); RESET=$(tput sgr0)
else
    RED=""; GREEN=""; YELLOW=""; CYAN=""; BOLD=""; RESET=""
fi

# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    cat <<EOF
${BOLD}run-benchmarks.sh${RESET} — Benchmark evaluator for Claude Code Unity agent output.

${BOLD}Usage:${RESET}
  bash benchmarks/run-benchmarks.sh [OPTIONS]

${BOLD}Options:${RESET}
  --workdir <dir>       Working directory to evaluate (default: current directory)
  --scenario <name>     Run only the named scenario (without .json extension)
  --compare <file>      Compare results against a previous JSON result file
  -h, --help            Show this help

${BOLD}Examples:${RESET}
  bash benchmarks/run-benchmarks.sh --workdir /tmp/agent-output
  bash benchmarks/run-benchmarks.sh --scenario simple-component
  bash benchmarks/run-benchmarks.sh --compare benchmarks/results/previous.json
EOF
    exit 0
fi

# ---------------------------------------------------------------------------
# Arguments
# ---------------------------------------------------------------------------
WORK_DIR="$PWD"
SINGLE_SCENARIO=""
COMPARE_FILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --workdir)    WORK_DIR="$2"; shift 2 ;;
        --scenario)   SINGLE_SCENARIO="$2"; shift 2 ;;
        --compare)    COMPARE_FILE="$2"; shift 2 ;;
        *) echo "${RED}Unknown option: $1${RESET}" >&2; exit 1 ;;
    esac
done

# ---------------------------------------------------------------------------
# Dependencies
# ---------------------------------------------------------------------------
if ! command -v jq &>/dev/null; then
    echo "${RED}Error: jq is required but not installed.${RESET}" >&2
    exit 1
fi

if [[ ! -x "$EVALUATE" ]]; then
    echo "${RED}Error: evaluate.sh not found or not executable at $EVALUATE${RESET}" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Collect scenario files
# ---------------------------------------------------------------------------
SCENARIO_FILES=()

if [[ -n "$SINGLE_SCENARIO" ]]; then
    TARGET="$SCENARIOS_DIR/${SINGLE_SCENARIO}.json"
    if [[ ! -f "$TARGET" ]]; then
        echo "${RED}Error: Scenario not found: $TARGET${RESET}" >&2
        exit 1
    fi
    SCENARIO_FILES+=("$TARGET")
else
    for SFILE in "$SCENARIOS_DIR"/*.json; do
        [[ -f "$SFILE" ]] || continue
        SCENARIO_FILES+=("$SFILE")
    done
fi

if [[ ${#SCENARIO_FILES[@]} -eq 0 ]]; then
    echo "${YELLOW}No scenarios found in $SCENARIOS_DIR${RESET}"
    exit 0
fi

# ---------------------------------------------------------------------------
# Run evaluations
# ---------------------------------------------------------------------------
echo ""
echo "${BOLD}${CYAN}Benchmark Evaluation${RESET}"
echo "${BOLD}${CYAN}====================${RESET}"
echo "Working directory: ${BOLD}$WORK_DIR${RESET}"
echo "Scenarios:         ${BOLD}${#SCENARIO_FILES[@]}${RESET}"
echo ""

TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_CHECKS=0
SCENARIO_RESULTS="[]"

for SFILE in "${SCENARIO_FILES[@]}"; do
    SNAME=$(jq -r '.name // "unknown"' "$SFILE")
    SDESC=$(jq -r '.description // ""' "$SFILE")

    echo "${BOLD}${CYAN}--- $SNAME ---${RESET}"
    [[ -n "$SDESC" ]] && echo "    $SDESC"
    echo ""

    # Run evaluator, capture JSON from stdout (diagnostic output goes to stderr)
    RESULT=$("$EVALUATE" "$SFILE" "$WORK_DIR" 2>&2) || {
        echo "  ${RED}Error running evaluator for $SNAME${RESET}" >&2
        RESULT=$(jq -n --arg scenario "$SNAME" '{
            "scenario": $scenario,
            "passed": 0,
            "failed": 1,
            "total": 1,
            "details": [{"check": "evaluator", "result": "fail", "message": "Evaluator script failed"}]
        }')
    }

    # Extract counts
    SC_PASSED=$(echo "$RESULT" | jq '.passed')
    SC_FAILED=$(echo "$RESULT" | jq '.failed')
    SC_TOTAL=$(echo "$RESULT" | jq '.total')

    TOTAL_PASSED=$((TOTAL_PASSED + SC_PASSED))
    TOTAL_FAILED=$((TOTAL_FAILED + SC_FAILED))
    TOTAL_CHECKS=$((TOTAL_CHECKS + SC_TOTAL))

    # Accumulate
    SCENARIO_RESULTS=$(echo "$SCENARIO_RESULTS" | jq --argjson result "$RESULT" '. + [$result]')

    # Scenario summary
    if [[ "$SC_FAILED" -eq 0 ]]; then
        echo "  ${GREEN}${BOLD}PASSED${RESET} ($SC_PASSED/$SC_TOTAL checks)"
    else
        echo "  ${RED}${BOLD}FAILED${RESET} ($SC_PASSED/$SC_TOTAL checks passed, $SC_FAILED failed)"
    fi
    echo ""
done

# ---------------------------------------------------------------------------
# Save results
# ---------------------------------------------------------------------------
TIMESTAMP=$(date +"%Y-%m-%d-%H%M%S")
RESULT_FILE="$RESULTS_DIR/$TIMESTAMP.json"

mkdir -p "$RESULTS_DIR"

FULL_RESULT=$(jq -n \
    --arg timestamp "$TIMESTAMP" \
    --arg workdir "$WORK_DIR" \
    --argjson total_passed "$TOTAL_PASSED" \
    --argjson total_failed "$TOTAL_FAILED" \
    --argjson total_checks "$TOTAL_CHECKS" \
    --argjson scenarios "$SCENARIO_RESULTS" \
    '{
        "timestamp": $timestamp,
        "workdir": $workdir,
        "total_passed": $total_passed,
        "total_failed": $total_failed,
        "total_checks": $total_checks,
        "scenarios": $scenarios
    }')

echo "$FULL_RESULT" > "$RESULT_FILE"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo "================================================================"
if [[ $TOTAL_FAILED -eq 0 ]]; then
    echo "${GREEN}${BOLD}ALL PASSED${RESET} — $TOTAL_PASSED/$TOTAL_CHECKS checks across ${#SCENARIO_FILES[@]} scenario(s)"
else
    echo "${RED}${BOLD}FAILURES${RESET} — $TOTAL_PASSED/$TOTAL_CHECKS passed, ${RED}$TOTAL_FAILED failed${RESET} across ${#SCENARIO_FILES[@]} scenario(s)"
fi
echo "Results saved to: ${BOLD}$RESULT_FILE${RESET}"
echo "================================================================"

# ---------------------------------------------------------------------------
# Comparison (optional)
# ---------------------------------------------------------------------------
if [[ -n "$COMPARE_FILE" ]]; then
    if [[ ! -f "$COMPARE_FILE" ]]; then
        echo ""
        echo "${RED}Comparison file not found: $COMPARE_FILE${RESET}" >&2
        exit 1
    fi

    echo ""
    echo "${BOLD}${CYAN}Comparison with: $COMPARE_FILE${RESET}"
    echo ""

    PREV_PASSED=$(jq '.total_passed' "$COMPARE_FILE")
    PREV_FAILED=$(jq '.total_failed' "$COMPARE_FILE")
    PREV_TOTAL=$(jq '.total_checks' "$COMPARE_FILE")

    DELTA_PASSED=$((TOTAL_PASSED - PREV_PASSED))
    DELTA_FAILED=$((TOTAL_FAILED - PREV_FAILED))

    echo "  Previous: $PREV_PASSED/$PREV_TOTAL passed, $PREV_FAILED failed"
    echo "  Current:  $TOTAL_PASSED/$TOTAL_CHECKS passed, $TOTAL_FAILED failed"
    echo ""

    if [[ $DELTA_PASSED -gt 0 ]]; then
        echo "  ${GREEN}+$DELTA_PASSED more checks passing${RESET}"
    elif [[ $DELTA_PASSED -lt 0 ]]; then
        echo "  ${RED}$DELTA_PASSED fewer checks passing${RESET}"
    else
        echo "  ${YELLOW}No change in passing checks${RESET}"
    fi

    if [[ $DELTA_FAILED -gt 0 ]]; then
        echo "  ${RED}+$DELTA_FAILED more checks failing (regression)${RESET}"
    elif [[ $DELTA_FAILED -lt 0 ]]; then
        ABS_DELTA=${DELTA_FAILED#-}
        echo "  ${GREEN}$ABS_DELTA fewer checks failing (improvement)${RESET}"
    fi

    # Per-scenario comparison
    echo ""
    echo "  ${BOLD}Per-scenario:${RESET}"

    PREV_SCENARIO_COUNT=$(jq '.scenarios | length' "$COMPARE_FILE")
    for (( compIndex = 0; compIndex < PREV_SCENARIO_COUNT; compIndex++ )); do
        PREV_NAME=$(jq -r ".scenarios[$compIndex].scenario" "$COMPARE_FILE")
        PREV_SC_PASSED=$(jq ".scenarios[$compIndex].passed" "$COMPARE_FILE")
        PREV_SC_TOTAL=$(jq ".scenarios[$compIndex].total" "$COMPARE_FILE")

        # Find matching scenario in current results
        CUR_MATCH=$(echo "$SCENARIO_RESULTS" | jq --arg name "$PREV_NAME" '[.[] | select(.scenario == $name)] | first // empty')
        if [[ -n "$CUR_MATCH" ]]; then
            CUR_SC_PASSED=$(echo "$CUR_MATCH" | jq '.passed')
            CUR_SC_TOTAL=$(echo "$CUR_MATCH" | jq '.total')
            if [[ $CUR_SC_PASSED -gt $PREV_SC_PASSED ]]; then
                echo "    ${GREEN}$PREV_NAME: $PREV_SC_PASSED/$PREV_SC_TOTAL -> $CUR_SC_PASSED/$CUR_SC_TOTAL${RESET}"
            elif [[ $CUR_SC_PASSED -lt $PREV_SC_PASSED ]]; then
                echo "    ${RED}$PREV_NAME: $PREV_SC_PASSED/$PREV_SC_TOTAL -> $CUR_SC_PASSED/$CUR_SC_TOTAL${RESET}"
            else
                echo "    $PREV_NAME: $PREV_SC_PASSED/$PREV_SC_TOTAL (unchanged)"
            fi
        else
            echo "    ${YELLOW}$PREV_NAME: present in previous, missing in current${RESET}"
        fi
    done
    echo ""
fi

# Exit with failure if any checks failed
if [[ $TOTAL_FAILED -gt 0 ]]; then
    exit 1
fi
