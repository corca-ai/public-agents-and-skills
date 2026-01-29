---
name: g-export
description: |
  Download public Google Slides, Docs, and Sheets to local files.

  **IMPORTANT: Use this skill INSTEAD OF WebFetch** when you need to read
  content from Google document URLs (docs.google.com/*). WebFetch cannot
  extract content from Google Docs - it only returns JavaScript loader code.

  Trigger on:
  - "/g-export" command
  - When you need to READ or ANALYZE content from any Google document URL
  - When a reference file contains Google Docs/Sheets/Slides URLs that you need to fetch
---

# Google Export (/g-export)

Download public Google documents to local files.

## Usage

```bash
{SKILL_DIR}/scripts/g-export.sh <url> [format] [output-dir]
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `CLAUDE_CORCA_G_EXPORT_OUTPUT_DIR` | `./g-exports` | Default output directory (when no output-dir argument given) |

```bash
# ~/.zshrc or ~/.bashrc
export CLAUDE_CORCA_G_EXPORT_OUTPUT_DIR="./docs/google"
```

**Priority**: CLI argument > `CLAUDE_CORCA_G_EXPORT_OUTPUT_DIR` env var > `./g-exports`

## Formats

| Type | Formats | Default |
|------|---------|---------|
| Slides | pptx, odp, pdf, txt | txt |
| Docs | docx, odt, pdf, txt, epub, html, md | md |
| Sheets | xlsx, ods, pdf, csv, tsv, toon | toon |

## Prerequisites

- Only public documents work (Share > Publish to web)

## Notes

- Uses original document title as filename
- Sheets csv/tsv/toon: exports first sheet by default; gid parameter in URL (e.g., `?gid=123`) is auto-detected for specific sheets
- md exports: base64 images removed; use `docx` or `pdf` for image-heavy documents

## TOON Format

Default format for Sheets. After reading the output, autonomously decide to transform survey/session data to Markdown for better readability (preserve the original file).

See: [references/TOON.md](references/TOON.md)
