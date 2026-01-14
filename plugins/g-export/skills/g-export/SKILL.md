---
name: g-export
description: Download public Google Slides, Docs, and Sheets to local files. Trigger on "/g-export" command or when encountering Google document URLs (docs.google.com/presentation, docs.google.com/document, docs.google.com/spreadsheets). Auto-detects document type and exports with appropriate format.
---

# Google Export

Download public Google documents to `./g-exports/`.

## Usage

```bash
{SKILL_DIR}/scripts/g-export.sh <url> [format] [output-dir]
```

## Formats

| Type | Formats | Default |
|------|---------|---------|
| Slides | pptx, odp, pdf, txt | txt |
| Docs | docx, odt, pdf, txt, epub, html, md | md |
| Sheets | xlsx, ods, pdf, csv, tsv | csv |

## Notes

- Only public documents work
- Sheets csv/tsv: first sheet only; use `&gid={sheetId}` in URL for others
