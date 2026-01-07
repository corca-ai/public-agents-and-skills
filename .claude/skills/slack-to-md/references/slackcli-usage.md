# SlackCLI

A fast, developer-friendly command-line interface tool for interacting with Slack workspaces. Built with TypeScript and Bun, it enables AI agents, automation tools, and developers to access Slack functionality directly from the terminal.

(Original GitHub repo: https://github.com/shaharia-lab/slackcli)

## Required OAuth Scopes

The following OAuth scopes are required for your Slack app to use SlackCLI:

| Scope | Purpose |
|-------|---------|
| `channels:read` | List public channels |
| `channels:history` | Read public channel messages |
| `channels:join` | Auto-join bot to public channels |
| `users:read` | Read user info (display name, etc.) |
| `chat:write` | Send messages (optional) |
| `im:history` | Read DM messages (optional) |
| `groups:read` | List private channels (optional) |
| `groups:history` | Read private channel messages (optional) |

## Usage

### Authentication Commands

```bash
# List all authenticated workspaces
slackcli auth list

# Set default workspace
slackcli auth set-default T1234567

# Remove a workspace
slackcli auth remove T1234567

# Logout from all workspaces
slackcli auth logout
```

### Conversation Commands

```bash
# List all conversations
slackcli conversations list

# List only public channels
slackcli conversations list --types=public_channel

# List DMs
slackcli conversations list --types=im

# Read recent messages from a channel
slackcli conversations read C1234567890

# Read a specific thread
slackcli conversations read C1234567890 --thread-ts=1234567890.123456

# Read with custom limit
slackcli conversations read C1234567890 --limit=50

# Get JSON output (includes ts and thread_ts for replies)
slackcli conversations read C1234567890 --json
```

### Channel Join (via Slack API)

SlackCLI doesn't have a channel join command, so you need to call the Slack API directly.

```bash
# Join bot to public channel (requires channels:join scope)
curl -X POST https://slack.com/api/conversations.join \
  -H "Authorization: Bearer xoxb-your-bot-token" \
  -H "Content-Type: application/json" \
  -d '{"channel": "C1234567890"}'
```

> **Note**: Bots cannot join private channels on their own. A channel member must invite the bot directly.

### Message Commands

```bash
# Send message to a channel
slackcli messages send --recipient-id=C1234567890 --message="Hello team!"

# Send DM to a user
slackcli messages send --recipient-id=U9876543210 --message="Hey there!"

# Reply to a thread
slackcli messages send --recipient-id=C1234567890 --thread-ts=1234567890.123456 --message="Great idea!"
```

### Update Commands

```bash
# Check for updates
slackcli update check

# Update to latest version
slackcli update
```

### Multi-Workspace Usage

```bash
# Use specific workspace by ID
slackcli conversations list --workspace=T1234567

# Use specific workspace by name
slackcli conversations list --workspace="My Team"
```

## Configuration

Configuration is stored in `~/.config/slackcli/`:

- `workspaces.json` - Workspace credentials
- `config.json` - User preferences (future)