# Supported Block Types

Block types and their Markdown conversion.

## Block Type → Markdown

| Block Type | Markdown Output |
|-----------|----------------|
| `page` | `# Title` (root) / `**Title**` (sub-page) |
| `header` | `# Title` |
| `sub_header` | `## Title` |
| `sub_sub_header` | `### Title` |
| `text` | Plain text |
| `bulleted_list` | `- Item` (nested with 2-space indent) |
| `numbered_list` | `1. Item` (nested with 2-space indent) |
| `quote` | `> Text` (children also prefixed with `>`) |
| `divider` | `---` |
| `code` | Fenced block with language tag (plain text, no inline formatting) |
| `to_do` | `- [x]` / `- [ ]` |
| `toggle` | `**Title**` (children rendered below) |
| `callout` | `> {icon} Text` |
| `image` | `![caption](url)` (http/https only) |
| `bookmark` | `[title](url)` (http/https only) |
| `table` | GFM pipe table (`|` escaped, newlines → `<br>`) |
| `column_list`/`column` | Layout only — children rendered directly |

Unsupported types emit `<!-- unsupported: {type} -->`.

## Rich Text Formatting

| Format | Markdown | Notes |
|--------|----------|-------|
| Bold | `**text**` | |
| Italic | `*text*` | |
| Bold+Italic | `***text***` | |
| Code | `` `text` `` | Wins over other formatting |
| Strikethrough | `~~text~~` | |
| Link | `[text](url)` | http/https only |
| Highlight | (ignored) | |
| Underline | (ignored) | |

## API Details

- Endpoint: `POST https://www.notion.so/api/v3/loadPageChunk`
- Pagination: cursor-based, max 50 chunks × 100 blocks
- Retry: 3 attempts with exponential backoff (2^n seconds) on 429/5xx
- Timeout: 30 seconds per request
