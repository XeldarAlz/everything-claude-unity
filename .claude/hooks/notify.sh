#!/usr/bin/env bash
# ============================================================================
# notify.sh — STOP HOOK (standard profile)
# Multi-channel notification system for session events.
#
# Supports Discord webhooks, Slack webhooks, and OS-native notifications.
# Events: session_end, build_complete, verify_fail, cost_threshold
#
# Environment variables:
#   UNITY_NOTIFY_ENABLED=1           — enable notifications (disabled by default)
#   UNITY_NOTIFY_CHANNELS='[...]'    — JSON array of channel configs (see below)
#   UNITY_NOTIFY_RATE_LIMIT=60       — minimum seconds between notifications per channel
#   UNITY_NOTIFY_MIN_DURATION=300    — minimum session seconds for session_end (default: 5 min)
#
# Channel config format (UNITY_NOTIFY_CHANNELS):
#   [
#     {"url": "https://discord.com/api/webhooks/...", "format": "discord", "events": ["session_end", "build_complete"]},
#     {"url": "https://hooks.slack.com/services/...", "format": "slack", "events": ["verify_fail"]},
#     {"format": "native", "events": ["session_end", "build_complete"]}
#   ]
#
# Backward compatibility:
#   UNITY_NOTIFY_WEBHOOK_URL=<url>   — single webhook URL (legacy)
#   UNITY_NOTIFY_FORMAT=auto         — auto | discord | slack (legacy)
#
# The "auto" format sends both "text" and "content" fields, which makes it
# compatible with both Discord and Slack webhooks out of the box.
# ============================================================================
# Trigger: Stop
# Exit: 0 always (advisory — never blocks)
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_PROFILE_LEVEL="standard"
source "${SCRIPT_DIR}/_lib.sh"

# --- Guard: notifications must be explicitly enabled ---
if [ "${UNITY_NOTIFY_ENABLED:-}" != "1" ]; then
    exit 0
fi

# --- Rate limiting ---
RATE_LIMIT="${UNITY_NOTIFY_RATE_LIMIT:-60}"

# _channel_hash — produce a short hash for rate-limit file naming
_channel_hash() {
    local identifier="$1"
    if command -v md5 &>/dev/null; then
        echo -n "$identifier" | md5
    elif command -v md5sum &>/dev/null; then
        echo -n "$identifier" | md5sum | cut -d' ' -f1
    else
        # Fallback: simple string-based hash
        echo -n "$identifier" | cksum | cut -d' ' -f1
    fi
}

# _is_rate_limited — returns 0 (true) if the channel was notified too recently
_is_rate_limited() {
    local hash="$1"
    local ratelimit_file="${UNITY_HOOK_STATE_DIR}/notify-ratelimit-${hash}.txt"
    if [ -f "$ratelimit_file" ]; then
        local last_time
        last_time=$(cat "$ratelimit_file" 2>/dev/null || echo "0")
        local now
        now=$(date +%s)
        local elapsed=$(( now - last_time ))
        if [ "$elapsed" -lt "$RATE_LIMIT" ]; then
            return 0  # rate limited
        fi
    fi
    return 1  # not rate limited
}

# _record_notification — update the rate-limit timestamp for a channel
_record_notification() {
    local hash="$1"
    local ratelimit_file="${UNITY_HOOK_STATE_DIR}/notify-ratelimit-${hash}.txt"
    date +%s > "$ratelimit_file"
}

# _send_native — send an OS-native notification
_send_native() {
    local title="$1"
    local message="$2"
    if [[ "$OSTYPE" == darwin* ]] && command -v osascript &>/dev/null; then
        osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null || true
    elif command -v notify-send &>/dev/null; then
        notify-send "$title" "$message" 2>/dev/null || true
    fi
    # Silently skip if neither is available
}

# _send_webhook — send a webhook notification
_send_webhook() {
    local url="$1"
    local format="$2"
    local message="$3"
    local payload

    case "$format" in
        discord)
            payload=$(jq -nc --arg msg "$message" '{content: $msg}')
            ;;
        slack)
            payload=$(jq -nc --arg msg "$message" '{text: $msg}')
            ;;
        *)
            # Auto: send both fields for maximum compatibility
            payload=$(jq -nc --arg msg "$message" '{text: $msg, content: $msg}')
            ;;
    esac

    curl -s -o /dev/null -X POST -H "Content-Type: application/json" \
        -d "$payload" "$url" 2>/dev/null || true
}

# _notify_channel — send notification to a single channel (with rate limiting)
_notify_channel() {
    local url="$1"
    local format="$2"
    local message="$3"

    # Determine hash identifier
    local identifier
    if [ "$format" = "native" ]; then
        identifier="native"
    else
        identifier="$url"
    fi
    local hash
    hash=$(_channel_hash "$identifier")

    # Check rate limit
    if _is_rate_limited "$hash"; then
        return 0
    fi

    # Send notification
    if [ "$format" = "native" ]; then
        _send_native "Unity Claude" "$message"
    else
        if [ -n "$url" ]; then
            _send_webhook "$url" "$format" "$message"
        fi
    fi

    # Record timestamp for rate limiting
    _record_notification "$hash"
}

# --- Build session_end message ---
_build_session_end_message() {
    local duration_secs="$1"
    local edit_count=0
    if [ -f "$UNITY_EDITS_FILE" ]; then
        edit_count=$(sort -u "$UNITY_EDITS_FILE" | wc -l | tr -d ' ')
    fi

    local branch
    branch=$(git branch --show-current 2>/dev/null || echo "unknown")
    local minutes=$((duration_secs / 60))
    local seconds_remainder=$((duration_secs % 60))

    echo "Unity Claude session complete | Branch: ${branch} | Duration: ${minutes}m ${seconds_remainder}s | Files modified: ${edit_count}"
}

# --- Detect events to fire ---
EVENTS_TO_FIRE=()
declare -A EVENT_MESSAGES

# Check for notify-event.json (written by other hooks: verify_fail, build_complete, cost_threshold)
NOTIFY_EVENT_FILE="${UNITY_HOOK_STATE_DIR}/notify-event.json"
if [ -f "$NOTIFY_EVENT_FILE" ]; then
    EVENT_TYPE=$(jq -r '.event // empty' "$NOTIFY_EVENT_FILE" 2>/dev/null || true)
    EVENT_DETAILS=$(jq -r '.details // empty' "$NOTIFY_EVENT_FILE" 2>/dev/null || true)

    if [ -n "$EVENT_TYPE" ]; then
        EVENTS_TO_FIRE+=("$EVENT_TYPE")
        case "$EVENT_TYPE" in
            verify_fail)
                EVENT_MESSAGES["verify_fail"]="Unity Claude — Verification failed: ${EVENT_DETAILS}"
                ;;
            build_complete)
                EVENT_MESSAGES["build_complete"]="Unity Claude — Build complete: ${EVENT_DETAILS}"
                ;;
            cost_threshold)
                EVENT_MESSAGES["cost_threshold"]="Unity Claude — Cost threshold reached: ${EVENT_DETAILS}"
                ;;
            *)
                EVENT_MESSAGES["$EVENT_TYPE"]="Unity Claude — ${EVENT_TYPE}: ${EVENT_DETAILS}"
                ;;
        esac
    fi

    # Clean up so events don't fire twice
    rm -f "$NOTIFY_EVENT_FILE" 2>/dev/null || true
fi

# Check for session_end event (duration-based, like original behavior)
MIN_DURATION="${UNITY_NOTIFY_MIN_DURATION:-300}"
DURATION_SECS=0
if [ -f "${UNITY_HOOK_STATE_DIR}/session-start-time" ]; then
    START_TIME=$(cat "${UNITY_HOOK_STATE_DIR}/session-start-time")
    DURATION_SECS=$(( $(date +%s) - START_TIME ))
fi

if [ "$DURATION_SECS" -ge "$MIN_DURATION" ]; then
    EVENTS_TO_FIRE+=("session_end")
    EVENT_MESSAGES["session_end"]=$(_build_session_end_message "$DURATION_SECS")
fi

# --- No events to fire? Exit early ---
if [ ${#EVENTS_TO_FIRE[@]} -eq 0 ]; then
    exit 0
fi

# --- Build channel list ---
CHANNELS_JSON="${UNITY_NOTIFY_CHANNELS:-}"

if [ -z "$CHANNELS_JSON" ]; then
    # Backward compatibility: construct single-channel config from legacy env vars
    WEBHOOK_URL="${UNITY_NOTIFY_WEBHOOK_URL:-}"
    if [ -z "$WEBHOOK_URL" ]; then
        # No channels configured and no legacy webhook — check if native is wanted
        if [ "${UNITY_NOTIFY_NATIVE:-}" = "1" ]; then
            CHANNELS_JSON='[{"format":"native","events":["session_end","build_complete","verify_fail","cost_threshold"]}]'
        else
            exit 0
        fi
    else
        FORMAT="${UNITY_NOTIFY_FORMAT:-auto}"
        CHANNELS_JSON=$(jq -nc --arg url "$WEBHOOK_URL" --arg fmt "$FORMAT" \
            '[{url: $url, format: $fmt, events: ["session_end", "build_complete", "verify_fail", "cost_threshold"]}]')
    fi
fi

# --- Dispatch notifications ---
SENT_COUNT=0
CHANNEL_COUNT=$(echo "$CHANNELS_JSON" | jq 'length' 2>/dev/null || echo "0")

for channelIndex in $(seq 0 $(( CHANNEL_COUNT - 1 ))); do
    CHANNEL_URL=$(echo "$CHANNELS_JSON" | jq -r ".[$channelIndex].url // empty" 2>/dev/null || true)
    CHANNEL_FORMAT=$(echo "$CHANNELS_JSON" | jq -r ".[$channelIndex].format // \"auto\"" 2>/dev/null || true)
    CHANNEL_EVENTS=$(echo "$CHANNELS_JSON" | jq -r ".[$channelIndex].events // [] | .[]" 2>/dev/null || true)

    # If no events specified, subscribe to all
    if [ -z "$CHANNEL_EVENTS" ]; then
        CHANNEL_EVENTS="session_end build_complete verify_fail cost_threshold"
    fi

    for event in "${EVENTS_TO_FIRE[@]}"; do
        # Check if this channel subscribes to this event
        if echo "$CHANNEL_EVENTS" | grep -qxF "$event"; then
            MESSAGE="${EVENT_MESSAGES[$event]:-}"
            if [ -n "$MESSAGE" ]; then
                _notify_channel "$CHANNEL_URL" "$CHANNEL_FORMAT" "$MESSAGE"
                SENT_COUNT=$((SENT_COUNT + 1))
            fi
        fi
    done
done

if [ "$SENT_COUNT" -gt 0 ]; then
    echo "" >&2
    echo "  Notification sent ($SENT_COUNT dispatch(es) across ${#EVENTS_TO_FIRE[@]} event(s))." >&2
fi

exit 0
