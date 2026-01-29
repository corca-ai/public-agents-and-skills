---
name: url-export
description: |
  Unified URL export — auto-detects URL type and delegates to the
  appropriate converter skill (g-export, slack-to-md, notion-to-md).
  Falls back to WebFetch for unknown URLs.

  Trigger on:
  - "/url-export" command
  - When the user provides an external content URL that matches a supported service
---

# URL Export (/url-export)

Auto-detect URL type and delegate to the installed converter skill.

## URL Detection

Match URLs in this order (most specific first):

| URL Pattern | Delegate To | Notes |
|-------------|-------------|-------|
| `docs.google.com/{document,presentation,spreadsheets}/d/*` | **g-export** skill | Pass `--format` if user specifies |
| `*.slack.com/archives/*/p*` | **slack-to-md** skill | |
| `*.notion.site/*`, `www.notion.so/*` | **notion-to-md** skill | |
| Any other URL | **WebFetch** fallback | Download, convert to markdown, save |

## Workflow

1. **Detect**: Match the URL against the pattern table above.
2. **Delegate**: Invoke the matching skill by name (e.g., "use the g-export skill to download this URL").
   - If the required skill is not installed, tell the user which skill to install:
     `claude plugin install <skill-name>@corca-plugins`
3. **Fallback**: For unrecognized URLs, use WebFetch to fetch the page content and save as markdown to the output directory.
4. **Output directory**: When the user provides `--output` or `--output-dir`, pass it through to the delegate skill.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `CLAUDE_CORCA_URL_EXPORT_OUTPUT_DIR` | `./exports` | Unified default output directory |
| `CLAUDE_CORCA_G_EXPORT_OUTPUT_DIR` | (falls back to URL_EXPORT_OUTPUT_DIR) | Google-specific override |
| `CLAUDE_CORCA_SLACK_TO_MD_OUTPUT_DIR` | (falls back to URL_EXPORT_OUTPUT_DIR) | Slack-specific override |
| `CLAUDE_CORCA_NOTION_TO_MD_OUTPUT_DIR` | (falls back to URL_EXPORT_OUTPUT_DIR) | Notion-specific override |

**Priority**: CLI argument > service-specific env var > `CLAUDE_CORCA_URL_EXPORT_OUTPUT_DIR` > hardcoded default

When delegating, if `CLAUDE_CORCA_URL_EXPORT_OUTPUT_DIR` is set and the service-specific env var is not, pass the unified output dir to the delegate skill.

## WebFetch Fallback

For URLs that don't match any known service:

1. Use WebFetch to download the page content.
2. Save the result as markdown to `{OUTPUT_DIR}/{sanitized-title}.md`.
3. Sanitize the title: lowercase, spaces to hyphens, remove special characters, max 50 chars.
