#!/bin/bash
# Start a background timer that will send notification after delay
# If user responds before timer expires, cancel-timer.sh will kill this process

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMER_FILE="/tmp/claude-attention-timer.pid"
INPUT_FILE="/tmp/claude-attention-input.json"
DEBUG_LOG="/tmp/claude-attention-debug.log"

# Configurable delay (seconds)
DELAY_SECONDS="${CLAUDE_ATTENTION_DELAY:-30}"

# Debug: log that this script was called
echo "$(date): start-timer.sh called" >> "$DEBUG_LOG"

# Read and save the hook input for later use by attention.sh
INPUT=$(cat)
echo "$INPUT" > "$INPUT_FILE"

# Kill any existing timer
if [ -f "$TIMER_FILE" ]; then
    kill $(cat "$TIMER_FILE") 2>/dev/null
    rm -f "$TIMER_FILE"
fi

# Start background timer - use nohup to detach from process group
# Without nohup, Claude Code kills the subprocess when the hook exits,
# causing sleep to terminate immediately and trigger the notification right away
nohup bash -c "
    sleep $DELAY_SECONDS
    if [ -f '$TIMER_FILE' ]; then
        cat '$INPUT_FILE' | '$SCRIPT_DIR/attention.sh'
        rm -f '$TIMER_FILE' '$INPUT_FILE'
    fi
" > /dev/null 2>&1 &

# Save the background process PID
echo $! > "$TIMER_FILE"

exit 0
