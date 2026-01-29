---
name: slack-to-md
description: |
  Convert Slack thread URLs to markdown documents.
  Trigger on "slack-to-md" command or when user provides Slack URLs
  (https://*.slack.com/archives/*/p*). Also handles updating existing
  markdown files from their source Slack threads.
---

# Slack to Markdown Converter (/slack-to-md)

Convert Slack thread URLs to well-formatted markdown documents.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `CLAUDE_CORCA_SLACK_TO_MD_OUTPUT_DIR` | `./slack-outputs` | Default output directory for generated markdown files and attachments |

```bash
# ~/.zshrc or ~/.bashrc
export CLAUDE_CORCA_SLACK_TO_MD_OUTPUT_DIR="./docs/slack"
```

**Priority**: CLI output path > `CLAUDE_CORCA_SLACK_TO_MD_OUTPUT_DIR` env var > `./slack-outputs`

## Prerequisites

Before using this skill, the following setup is required:

1. **Node.js 18+**: Required for the Slack API script
2. **Set up Slack Bot**: Create a bot at https://api.slack.com/apps with these OAuth scopes:
   - `channels:history` - Read messages from public channels
   - `channels:join` - Auto-join channels when needed
   - `users:read` - Resolve user IDs to names
   - `files:read` - Download file attachments
3. **Configure token**: Add your bot token to `~/.claude/.env`:
   ```
   SLACK_BOT_TOKEN=xoxb-your-token-here
   ```

## Workflow

### 1. Determine Output Directory

Resolve `OUTPUT_DIR` using the priority chain:
1. If the user specifies an output path → use that directory
2. Otherwise check `CLAUDE_CORCA_SLACK_TO_MD_OUTPUT_DIR` env var
3. Fall back to `{PROJECT_ROOT}/slack-outputs/`

Use the resolved `OUTPUT_DIR` in all commands below.

### 2. Parse Input

**Slack URL format:** `https://{workspace}.slack.com/archives/{channel_id}/p{timestamp}`

Extract:
- `workspace`: subdomain
- `channel_id`: after `/archives/`
- `thread_ts`: convert `p{digits}` → `{first10}.{rest}` (e.g., `p1234567890123456` → `1234567890.123456`)

**Existing .md file**: Read and extract Slack URL from `> Source:` line.

### 3. Execute Conversion

Run the two scripts in a pipe:

```bash
node {SKILL_DIR}/scripts/slack-api.mjs <channel_id> <thread_ts> --attachments-dir OUTPUT_DIR/attachments | \
  {SKILL_DIR}/scripts/slack-to-md.sh <channel_id> <thread_ts> <workspace> OUTPUT_DIR/<output_file>.md [title]
```

- `{SKILL_DIR}`: Shown at the top when skill is invoked as "Base directory for this skill: ..."
- `{PROJECT_ROOT}`: Git root or current working directory (use absolute paths for reliability)
- `slack-api.mjs`: Fetches thread data from Slack API, outputs JSON. With `--attachments-dir`, also downloads file attachments to the specified directory.
- `slack-to-md.sh`: Reads JSON from stdin, generates markdown file. If files have `local_path`, renders them as links (images inline, others as download links).

### 4. Rename to Meaningful Filename

After fetching, read the generated markdown file and extract the first message content. Then rename the file to a meaningful name:

1. Read the markdown file to find the first message (after the header)
2. Extract a short, descriptive title from the first message (first 30-50 characters, or a key phrase)
3. Sanitize the title for use as filename:
   - Convert to lowercase
   - Replace spaces with hyphens
   - Remove special characters (keep only alphanumeric, hyphens, Korean characters)
   - Truncate to reasonable length (max 50 chars)
4. Rename the file: `mv {old_file}.md OUTPUT_DIR/{sanitized_title}.md`
5. Report the new filename to the user

### 5. Handle Errors

The `slack-api.mjs` script automatically handles common errors:
- `not_in_channel`: Automatically joins the channel and retries
- `missing_scope`: Prints required OAuth scope to stderr

If errors persist, check:
1. Bot token is valid in `~/.claude/.env`
2. Bot has required OAuth scopes
3. Bot is added to the workspace

## Resources

- **scripts/slack-api.mjs**: Slack API wrapper (Node.js 18+, no external deps)
- **scripts/slack-to-md.sh**: JSON to markdown converter (requires jq, perl)
