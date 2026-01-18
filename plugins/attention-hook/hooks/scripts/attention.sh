#!/bin/bash
# Claude Code notification script
# Sends notification only after 60 seconds of inactivity (idle_prompt)
# Includes task context: user request, Claude response, questions, and todo status
#
# === COMPATIBILITY WARNING ===
# This script relies on parse-transcript.sh to parse Claude Code's internal transcript format.
# The transcript structure is not a public API and may change between versions.
# If notifications stop working after a Claude Code update, the jq queries may need adjustment.
#
# Last tested with: Claude Code v2.1.11 (2025-01-18)

# Usage: Add this file to ~/.claude/hooks, and add the following to your .claude/settings.json
# {
#   "hooks": {
#     "Notification": [
#       {
#         "matcher": "idle_prompt",
#         "hooks": [
#           {
#             "type": "command",
#             "command": "~/.claude/hooks/attention.sh"
#           }
#         ]
#       }
#     ]
#   }
# }

# === HELPER FUNCTIONS ===
# These functions are always defined, allowing this script to be sourced for testing.

# Truncate text to first N lines + ... + last N lines
truncate_text() {
    local text="$1"
    local line_count=$(echo "$text" | wc -l)

    if [ "$line_count" -le 10 ]; then
        echo "$text"
    else
        local first=$(echo "$text" | head -n 5)
        local last=$(echo "$text" | tail -n 5)
        echo "$first"
        echo ""
        echo "...(truncated)..."
        echo ""
        echo "$last"
    fi
}

# Escape special characters for JSON
escape_json() {
    local text="$1"
    text="${text//\\/\\\\}"
    text="${text//\"/\\\"}"
    text="${text//$'\n'/\\n}"
    text="${text//$'\t'/\\t}"
    echo "$text"
}

# === MAIN LOGIC ===
# Only run when executed directly (not when sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # === CONFIGURATION ===
    # Load webhook URLs from ~/.claude/.env if it exists
    ENV_FILE="$HOME/.claude/.env"
    if [ -f "$ENV_FILE" ]; then
        # Source the .env file (supports KEY="value" format)
        set -a
        source "$ENV_FILE"
        set +a
    fi

    # Use environment variables (can be set in ~/.claude/.env or shell environment)
    SLACK_WEBHOOK="${SLACK_WEBHOOK_URL:-}"

    # === READ HOOK INPUT ===
    INPUT=$(cat)
    TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')

    # === BUILD NOTIFICATION ===
    HOSTNAME=$(hostname)
    TITLE="Claude Code @ $HOSTNAME"

    if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
        # Use parse-transcript.sh to get parsed data
        PARSE_SCRIPT="$SCRIPT_DIR/parse-transcript.sh"

        if [ -x "$PARSE_SCRIPT" ]; then
            eval "$("$PARSE_SCRIPT" "$TRANSCRIPT_PATH")"
            LAST_HUMAN_TEXT="$PARSED_HUMAN_TEXT"
            LAST_ASSISTANT_TEXT="$PARSED_ASSISTANT_TEXT"
            ASK_QUESTION="$PARSED_ASK_QUESTION"
            TODO_STATUS="$PARSED_TODO_STATUS"
        else
            # Fallback: minimal parsing if parse-transcript.sh is not available
            LAST_HUMAN_TEXT=""
            LAST_ASSISTANT_TEXT=""
            ASK_QUESTION=""
            TODO_STATUS=""
        fi

        # Build message
        MESSAGE="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"$'\n'

        if [ -n "$LAST_HUMAN_TEXT" ]; then
            TRUNCATED_REQUEST=$(truncate_text "$LAST_HUMAN_TEXT")
            MESSAGE+=$'\n'":memo: Request:"$'\n'"$TRUNCATED_REQUEST"$'\n'
        fi

        if [ -n "$LAST_ASSISTANT_TEXT" ]; then
            TRUNCATED_RESPONSE=$(truncate_text "$LAST_ASSISTANT_TEXT")
            MESSAGE+=$'\n'":robot_face: Response:"$'\n'"$TRUNCATED_RESPONSE"$'\n'
        fi

        if [ -n "$ASK_QUESTION" ]; then
            TRUNCATED_QUESTION=$(truncate_text "$ASK_QUESTION")
            MESSAGE+=$'\n'":question: Waiting for answer:"$'\n'"$TRUNCATED_QUESTION"$'\n'
        fi

        if [ -n "$TODO_STATUS" ]; then
            MESSAGE+=$'\n'"$TODO_STATUS"
        fi
    else
        MESSAGE="Claude is waiting for your input"
    fi

    # === SEND NOTIFICATIONS ===
    ESCAPED_TITLE=$(escape_json "$TITLE")
    ESCAPED_MESSAGE=$(escape_json "$MESSAGE")

    # Send to Slack
    if [ -n "$SLACK_WEBHOOK" ]; then
        curl -s -X POST "$SLACK_WEBHOOK" \
            -H "Content-Type: application/json" \
            -d "{\"text\": \"*$ESCAPED_TITLE*\\n$ESCAPED_MESSAGE\"}" \
            > /dev/null 2>&1
    fi

    exit 0
fi
