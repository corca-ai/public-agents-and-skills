#!/bin/bash
# Usage: g-export.sh <google-doc-url> [format] [output-dir]
# Downloads public Google Slides/Docs/Sheets to local files.

set -e

URL="$1"
FORMAT="$2"
OUTPUT_DIR="${3:-./g-exports}"

# Extract document type and ID from URL
if [[ "$URL" =~ docs\.google\.com/(presentation|document|spreadsheets)/d/([^/]+) ]]; then
    TYPE="${BASH_REMATCH[1]}"
    ID="${BASH_REMATCH[2]}"
else
    echo "Error: Invalid Google document URL" >&2
    echo "Expected: docs.google.com/{presentation|document|spreadsheets}/d/{id}/..." >&2
    exit 1
fi

# Set default format based on document type
if [[ -z "$FORMAT" ]]; then
    case "$TYPE" in
        presentation) FORMAT="txt" ;;
        document)     FORMAT="md" ;;
        spreadsheets) FORMAT="csv" ;;
    esac
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Build export URL
EXPORT_URL="https://docs.google.com/${TYPE}/d/${ID}/export?format=${FORMAT}"

# Generate filename
FILENAME="${ID}.${FORMAT}"
OUTPUT_PATH="${OUTPUT_DIR}/${FILENAME}"

# Download
echo "Downloading ${TYPE} as ${FORMAT}..."
curl -sL -o "$OUTPUT_PATH" "$EXPORT_URL"

# Check if download succeeded (non-empty file)
if [[ ! -s "$OUTPUT_PATH" ]]; then
    echo "Error: Download failed or document is not publicly accessible" >&2
    rm -f "$OUTPUT_PATH"
    exit 1
fi

echo "Saved to: $OUTPUT_PATH"
