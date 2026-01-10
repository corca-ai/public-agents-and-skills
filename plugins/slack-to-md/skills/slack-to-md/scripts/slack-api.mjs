#!/usr/bin/env node
/**
 * Slack API wrapper for fetching thread messages
 * Usage: node slack-api.mjs <channel_id> <thread_ts>
 * Outputs JSON to stdout: { messages: [...], users: [...] }
 */

import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const SKILL_DIR = join(__dirname, '..');
const CACHE_DIR = join(SKILL_DIR, '.cache');
const CACHE_FILE = join(CACHE_DIR, 'users.json');

// ============================================
// Environment / Token
// ============================================

function loadToken() {
  // Try .env.local first, then .env
  for (const filename of ['.env.local', '.env']) {
    const filepath = join(SKILL_DIR, filename);
    if (existsSync(filepath)) {
      const content = readFileSync(filepath, 'utf-8');
      const match = content.match(/^BOT_TOKEN=(.+)$/m);
      if (match && match[1].trim()) {
        // Remove surrounding quotes and whitespace
        return match[1].trim().replace(/^["']|["']$/g, '').trim();
      }
    }
  }
  throw new Error(
    'BOT_TOKEN not found. Create .env.local with BOT_TOKEN=xoxb-...'
  );
}

// ============================================
// User Cache
// ============================================

function loadUserCache() {
  if (existsSync(CACHE_FILE)) {
    try {
      return JSON.parse(readFileSync(CACHE_FILE, 'utf-8'));
    } catch {
      return {};
    }
  }
  return {};
}

function saveUserCache(cache) {
  if (!existsSync(CACHE_DIR)) {
    mkdirSync(CACHE_DIR, { recursive: true });
  }
  writeFileSync(CACHE_FILE, JSON.stringify(cache, null, 2));
}

// ============================================
// Slack API
// ============================================

async function slackApi(endpoint, token, options = {}) {
  const baseUrl = 'https://slack.com/api/';
  const method = options.method || 'GET';
  const headers = {
    Authorization: `Bearer ${token}`,
    'Content-Type': 'application/json',
  };

  let url = baseUrl + endpoint;
  const fetchOptions = { method, headers };

  if (method === 'GET' && options.params) {
    const searchParams = new URLSearchParams(options.params);
    url += '?' + searchParams.toString();
  } else if (method === 'POST' && options.body) {
    fetchOptions.body = JSON.stringify(options.body);
  }

  const response = await fetch(url, fetchOptions);
  const data = await response.json();

  if (!data.ok) {
    const error = new Error(data.error || 'Slack API error');
    error.slackError = data.error;
    error.needed = data.needed; // For missing_scope errors
    throw error;
  }

  return data;
}

async function fetchThread(channelId, threadTs, token) {
  try {
    const data = await slackApi('conversations.replies', token, {
      params: {
        channel: channelId,
        ts: threadTs,
        limit: 100,
      },
    });
    return data.messages || [];
  } catch (error) {
    if (error.slackError === 'not_in_channel') {
      // Try to join the channel
      console.error('Bot not in channel, attempting to join...');
      await joinChannel(channelId, token);
      // Retry
      const data = await slackApi('conversations.replies', token, {
        params: {
          channel: channelId,
          ts: threadTs,
          limit: 100,
        },
      });
      return data.messages || [];
    }
    throw error;
  }
}

async function joinChannel(channelId, token) {
  try {
    await slackApi('conversations.join', token, {
      method: 'POST',
      body: { channel: channelId },
    });
    console.error('Successfully joined channel');
  } catch (error) {
    if (error.slackError === 'missing_scope') {
      throw new Error(
        `Error: missing_scope\nRequired scope: ${error.needed || 'channels:join'}\nPlease add this scope to your Slack app at https://api.slack.com/apps`
      );
    }
    throw error;
  }
}

async function fetchUserInfo(userId, token) {
  const data = await slackApi('users.info', token, {
    params: { user: userId },
  });
  return data.user?.real_name || data.user?.name || userId;
}

async function resolveUsers(userIds, token, cache) {
  const users = [];
  let cacheUpdated = false;

  for (const userId of userIds) {
    if (!userId) continue;

    let realName = cache[userId];
    if (!realName) {
      try {
        realName = await fetchUserInfo(userId, token);
        cache[userId] = realName;
        cacheUpdated = true;
      } catch (error) {
        console.error(`Failed to fetch user ${userId}: ${error.message}`);
        realName = userId;
      }
    }
    users.push({ id: userId, real_name: realName });
  }

  if (cacheUpdated) {
    saveUserCache(cache);
  }

  return users;
}

// ============================================
// Main
// ============================================

async function main() {
  const [channelId, threadTs] = process.argv.slice(2);

  if (!channelId || !threadTs) {
    console.error('Usage: node slack-api.mjs <channel_id> <thread_ts>');
    process.exit(1);
  }

  const token = loadToken();
  const cache = loadUserCache();

  const messages = await fetchThread(channelId, threadTs, token);

  // Collect unique user IDs
  const userIds = [...new Set(messages.map((m) => m.user).filter(Boolean))];

  // Resolve user names
  const users = await resolveUsers(userIds, token, cache);

  // Output JSON (compatible with slackcli format)
  console.log(JSON.stringify({ messages, users }));
}

main().catch((error) => {
  if (error.slackError === 'missing_scope') {
    console.error(
      `Error: missing_scope\nRequired scope: ${error.needed || 'unknown'}\nPlease add this scope to your Slack app at https://api.slack.com/apps`
    );
  } else {
    console.error(error.message);
  }
  process.exit(1);
});
