#!/bin/bash
# Claude Code notification script (improved version)
# Sends notification only after 60 seconds of inactivity (idle_prompt)
# Includes task context: user request, Claude response, and todo status

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

# === CONFIGURATION ===
# Option 1: Slack webhook
SLACK_WEBHOOK=""

# Option 2: Discord webhook
DISCORD_WEBHOOK=""

# === READ HOOK INPUT ===
INPUT=$(cat)
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')

# === HELPER FUNCTIONS ===
# Truncate text to first 3 lines + ... + last 3 lines
truncate_text() {
    local text="$1"
    local line_count=$(echo "$text" | wc -l)

    if [ "$line_count" -le 6 ]; then
        echo "$text"
    else
        local first=$(echo "$text" | head -n 3)
        local last=$(echo "$text" | tail -n 3)
        echo "$first"
        echo "..."
        echo "$last"
    fi
}

# Extract text content from message (handles both string and array content)
extract_content() {
    local json="$1"
    # If content is a string, return it directly
    # If content is an array, extract text from text blocks
    echo "$json" | jq -r '
        if .message.content | type == "string" then
            .message.content
        elif .message.content | type == "array" then
            [.message.content[] | select(.type == "text") | .text] | join("\n")
        else
            ""
        end
    '
}

# Parse todo status from transcript
parse_todos() {
    local transcript="$1"

    # Find the last TodoWrite tool result
    local todo_json=$(jq -s '
        [.[] | select(.type == "assistant") |
         .message.content[]? |
         select(.type == "tool_use" and .name == "TodoWrite") |
         .input.todos] |
        last // []
    ' "$transcript" 2>/dev/null)

    if [ -z "$todo_json" ] || [ "$todo_json" = "null" ] || [ "$todo_json" = "[]" ]; then
        echo ""
        return
    fi

    local completed=$(echo "$todo_json" | jq '[.[] | select(.status == "completed")] | length')
    local in_progress=$(echo "$todo_json" | jq '[.[] | select(.status == "in_progress")] | length')
    local pending=$(echo "$todo_json" | jq '[.[] | select(.status == "pending")] | length')
    local total=$((completed + in_progress + pending))

    if [ "$total" -gt 0 ]; then
        echo "✅ Todo: $completed/$total 완료"
        if [ "$in_progress" -gt 0 ]; then
            echo "  (진행중: $in_progress, 대기: $pending)"
        fi
    fi
}

# === BUILD NOTIFICATION ===
HOSTNAME=$(hostname)
TITLE="Claude Code @ $HOSTNAME"

if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    # Get last human message
    LAST_HUMAN=$(jq -s '[.[] | select(.type == "human")] | last' "$TRANSCRIPT_PATH" 2>/dev/null)
    LAST_HUMAN_TEXT=$(extract_content "$LAST_HUMAN")

    # Get last assistant message
    LAST_ASSISTANT=$(jq -s '[.[] | select(.type == "assistant")] | last' "$TRANSCRIPT_PATH" 2>/dev/null)
    LAST_ASSISTANT_TEXT=$(extract_content "$LAST_ASSISTANT")

    # Get todo status
    TODO_STATUS=$(parse_todos "$TRANSCRIPT_PATH")

    # Build message
    MESSAGE="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"$'\n'

    if [ -n "$LAST_HUMAN_TEXT" ]; then
        TRUNCATED_REQUEST=$(truncate_text "$LAST_HUMAN_TEXT")
        MESSAGE+=$'\n'"📝 요청:"$'\n'"$TRUNCATED_REQUEST"$'\n'
    fi

    if [ -n "$LAST_ASSISTANT_TEXT" ]; then
        TRUNCATED_RESPONSE=$(truncate_text "$LAST_ASSISTANT_TEXT")
        MESSAGE+=$'\n'"🤖 응답:"$'\n'"$TRUNCATED_RESPONSE"$'\n'
    fi

    if [ -n "$TODO_STATUS" ]; then
        MESSAGE+=$'\n'"$TODO_STATUS"
    fi
else
    MESSAGE="Claude is waiting for your input"
fi

# === SEND NOTIFICATIONS ===
# Escape special characters for JSON
escape_json() {
    local text="$1"
    text="${text//\\/\\\\}"
    text="${text//\"/\\\"}"
    text="${text//$'\n'/\\n}"
    text="${text//$'\t'/\\t}"
    echo "$text"
}

ESCAPED_TITLE=$(escape_json "$TITLE")
ESCAPED_MESSAGE=$(escape_json "$MESSAGE")

# Send to Slack
if [ -n "$SLACK_WEBHOOK" ]; then
    curl -s -X POST "$SLACK_WEBHOOK" \
        -H "Content-Type: application/json" \
        -d "{\"text\": \"*$ESCAPED_TITLE*\\n$ESCAPED_MESSAGE\"}" \
        > /dev/null 2>&1
fi

# Send to Discord
if [ -n "$DISCORD_WEBHOOK" ]; then
    curl -s -X POST "$DISCORD_WEBHOOK" \
        -H "Content-Type: application/json" \
        -d "{\"content\": \"**$ESCAPED_TITLE**\\n$ESCAPED_MESSAGE\"}" \
        > /dev/null 2>&1
fi

exit 0
