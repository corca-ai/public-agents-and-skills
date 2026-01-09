#!/bin/bash
# Slack thread to Markdown converter
# Reads JSON from stdin (from slack-api.mjs)
# Usage: ./slack-to-md.sh <channel_id> <thread_ts> <workspace> <output_file> [title]

set -e

CHANNEL_ID="$1"
THREAD_TS="$2"
WORKSPACE="$3"
OUTPUT_FILE="$4"
TITLE="${5:-Slack Thread}"

if [[ -z "$CHANNEL_ID" || -z "$THREAD_TS" || -z "$WORKSPACE" || -z "$OUTPUT_FILE" ]]; then
    echo "Usage: $0 <channel_id> <thread_ts> <workspace> <output_file> [title]" >&2
    echo "       JSON is read from stdin" >&2
    exit 1
fi

# Read JSON from stdin
echo "Reading messages from stdin..." >&2
JSON=$(cat)

if [[ -z "$JSON" ]]; then
    echo "Error: No JSON data received from stdin" >&2
    exit 1
fi

# Generate thread URL (remove dot from timestamp)
THREAD_URL="https://${WORKSPACE}.slack.com/archives/${CHANNEL_ID}/p${THREAD_TS//./}"

# Create output directory if needed
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Get current timestamp
UPDATED_AT=$(date "+%Y-%m-%d %H:%M")

# Write header
cat > "$OUTPUT_FILE" << EOF
# $TITLE

> Slack thread archive
> Source: $THREAD_URL
> Last updated: $UPDATED_AT

EOF

# Extract user map as TSV (id<tab>name)
USER_MAP=$(echo "$JSON" | jq -r '.users[] | "\(.id)\t\(.real_name)"')

# Function to get username from user_id
get_username() {
    local user_id="$1"
    echo "$USER_MAP" | grep "^$user_id	" | cut -f2 || echo "$user_id"
}

# Function to convert Slack links to markdown
convert_links() {
    local text="$1"
    # Convert <url|text> to [text](url)
    text=$(echo "$text" | perl -pe 's/<(https?:\/\/[^|>]+)\|([^>]+)>/[$2]($1)/g')
    # Convert <url> to plain url
    text=$(echo "$text" | perl -pe 's/<(https?:\/\/[^>]+)>/$1/g')
    # Convert &amp; &lt; &gt;
    text=$(echo "$text" | sed 's/&amp;/\&/g; s/&lt;/</g; s/&gt;/>/g')
    echo "$text"
}

# Process each message sorted by timestamp
echo "$JSON" | jq -r '.messages | sort_by(.ts) | .[] | "\(.ts)\t\(.user)\t\(.text | gsub("\n"; "\\n"))"' | while IFS=$'\t' read -r ts user_id text; do
    # Get username
    user_name=$(get_username "$user_id")

    # Convert timestamp to date (uses system timezone - should be KST)
    unix_ts="${ts%%.*}"
    date_str=$(date -r "$unix_ts" "+%Y-%m-%d %H:%M" 2>/dev/null || date -d "@$unix_ts" "+%Y-%m-%d %H:%M" 2>/dev/null)

    # Convert \n back to newlines and convert links
    text=$(echo -e "$text")
    text=$(convert_links "$text")

    # Replace user mentions with names
    while [[ "$text" =~ \<@(U[A-Z0-9]+)\> ]]; do
        mention_id="${BASH_REMATCH[1]}"
        mention_name=$(get_username "$mention_id")
        text="${text//<@$mention_id>/@$mention_name}"
    done

    # Write message
    cat >> "$OUTPUT_FILE" << EOF
---

**${user_name}** · ${date_str}

$text

EOF
done

echo "Saved to $OUTPUT_FILE" >&2
echo "$OUTPUT_FILE"
