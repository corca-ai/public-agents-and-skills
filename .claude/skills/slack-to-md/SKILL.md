---
name: slack-to-md
description: Convert Slack thread URLs to markdown documents. Trigger on "SLACK_TO_MD" command or when user provides a Slack URL (https://*.slack.com/archives/*/p*). Also handles updating existing markdown files from their source Slack threads.
---

# Slack to Markdown Converter

Convert Slack thread URLs to well-formatted markdown documents using slackcli.

## Prerequisites

Before using this skill, the following setup is required:

1. **Install slackcli**: Install [slackcli](https://github.com/shaharia-lab/slackcli)
2. **Set up Slack Bot**: Add a bot to your Slack workspace and grant the necessary permissions
3. **Auth token**: If your organization is already using this skill, request the auth token from an existing user

## Workflow

### 1. Parse Input

**Slack URL format:** `https://{workspace}.slack.com/archives/{channel_id}/p{timestamp}`

Extract:
- `workspace`: subdomain
- `channel_id`: after `/archives/`
- `thread_ts`: convert `p{digits}` → `{first10}.{rest}` (e.g., `p1234567890123456` → `1234567890.123456`)

**Existing .md file**: Read and extract Slack URL from `> Source:` line.

### 2. Execute Conversion

Run from the skill's base directory:

```bash
{SKILL_DIR}/scripts/slack-to-md.sh <channel_id> <thread_ts> <workspace> {PROJECT_ROOT}/slack-outputs/<output_file>.md [title]
```

- `{SKILL_DIR}`: Base directory provided when skill is invoked
- `{PROJECT_ROOT}`: Git root / current working directory where Claude Code runs

### 3. Rename to Meaningful Filename

After fetching, read the generated markdown file and extract the first message content. Then rename the file to a meaningful name:

1. Read the markdown file to find the first message (after the header)
2. Extract a short, descriptive title from the first message (first 30-50 characters, or a key phrase)
3. Sanitize the title for use as filename:
   - Convert to lowercase
   - Replace spaces with hyphens
   - Remove special characters (keep only alphanumeric, hyphens, Korean characters)
   - Truncate to reasonable length (max 50 chars)
4. Rename the file: `mv {old_file}.md {PROJECT_ROOT}/slack-outputs/{sanitized_title}.md`
5. Report the new filename to the user

### 4. Handle Errors

If `not_in_channel` error occurs, join the channel first. See [slackcli-usage.md](references/slackcli-usage.md) for API details.

## Resources

- **scripts/slack-to-md.sh**: Main conversion script (requires slackcli, jq, perl)
- **references/slackcli-usage.md**: slackcli commands and Slack API reference
