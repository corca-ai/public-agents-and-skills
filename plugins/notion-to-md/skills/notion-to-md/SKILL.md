---
name: notion-to-md
description: |
  Convert public Notion pages to local Markdown files.
  No auth or external dependencies required (Python 3.7+ stdlib only).
  Trigger on "/notion-to-md" command or when user provides Notion URLs
  (https://*.notion.site/*, https://www.notion.so/*).
allowed-tools:
  - Bash
---

# Notion to Markdown (/notion-to-md)

Convert a public Notion page to a local Markdown file via Notion's undocumented v3 API.
Python 3.7+ stdlib only — no pip packages or API keys needed.

**Language**: Adapt all outputs to match the user's prompt language.

## Commands

```
/notion-to-md                        → Usage guide
/notion-to-md help                   → Usage guide
/notion-to-md <url>                  → Convert and save as {title}.md
/notion-to-md <url> <output_path>    → Convert and save to specified path
```

## Usage

```bash
python3 {SKILL_DIR}/scripts/notion-to-md.py "$URL" "$OUTPUT_PATH"
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `CLAUDE_CORCA_NOTION_TO_MD_OUTPUT_DIR` | `./notion-outputs` | Default output directory (when no output_path argument given) |

```bash
# ~/.zshrc or ~/.bashrc
export CLAUDE_CORCA_NOTION_TO_MD_OUTPUT_DIR="./docs/notion"
```

**Priority**: CLI argument > `CLAUDE_CORCA_NOTION_TO_MD_OUTPUT_DIR` env var > `./notion-outputs`

## Supported URL Formats

- `https://workspace.notion.site/Title-{32hex}`
- `https://www.notion.so/Title-{32hex}`
- `https://www.notion.so/{32hex}`
- 32-character hex string (bare page ID)

## Prerequisites

- Page must be **published to the web** (Share → Publish in Notion)
- Python 3.7+

## Known Limitations

- Sub-pages: rendered as `<!-- missing block -->`
- Images: URL references only (Notion S3 URLs expire)
- Database views (`collection_view`): not supported
- Relies on undocumented Notion v3 API

## References

- [supported-blocks.md](references/supported-blocks.md) - Block types, rich text formatting, conversion details
