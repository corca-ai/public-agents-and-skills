#!/bin/bash
# Cancel the attention timer when user responds to AskUserQuestion
# Called by PostToolUse hook after AskUserQuestion completes

TIMER_FILE="/tmp/claude-attention-timer.pid"
INPUT_FILE="/tmp/claude-attention-input.json"
DEBUG_LOG="/tmp/claude-attention-debug.log"

# Debug: log that this script was called
echo "$(date): cancel-timer.sh called" >> "$DEBUG_LOG"

# Read and discard stdin (hook input)
cat > /dev/null

if [ -f "$TIMER_FILE" ]; then
    echo "$(date): Found timer file, killing PID $(cat "$TIMER_FILE")" >> "$DEBUG_LOG"
    kill $(cat "$TIMER_FILE") 2>/dev/null
    rm -f "$TIMER_FILE" "$INPUT_FILE"
else
    echo "$(date): No timer file found" >> "$DEBUG_LOG"
fi

exit 0
