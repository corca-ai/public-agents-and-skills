---
name: web-search
description: |
  Web search, code search, and URL content extraction skill.
  Calls Tavily and Exa APIs directly via curl.
  Triggers: "/web-search", or when user requests web search.
allowed-tools:
  - Bash
---

# Web Search (/web-search)

Call Tavily/Exa REST APIs directly for web search, code search, and URL content extraction.

**Language**: Adapt all outputs to match the user's prompt language.

## Commands

```
/web-search                         → Usage guide
/web-search help                    → Usage guide
/web-search <query>                 → General web search (Tavily)
/web-search --news <query>          → News search (Tavily, topic: news)
/web-search --deep <query>          → Advanced depth search (Tavily)
/web-search code <query>            → Code/technical search (Exa)
/web-search extract <url> [query]   → Extract URL content, optionally reranked by query (Tavily)
```

**Modifiers** (`--news`, `--deep`) can appear anywhere before the query. They are optional — query intelligence auto-detects topic and depth when possible.

## Execution Flow

```
1. Parse args → subcommand (search | code | extract), query/url, modifiers (--news, --deep)
2. No args or "help" → print usage and stop
3. Query analysis (search subcommand only):
   a. Detect modifier flags:
      --news → set topic: "news"
      --deep → set search_depth: "advanced", include_raw_content: "markdown"
   b. Detect temporal intent in query → set time_range:
      "today", "latest today" → "day"
      "this week", "latest", "recent" → "week"
      "this month" → "month"
      "this year", "2025", "2026" → "year"
   c. Detect topic from query (if not set by flag):
      news keywords (breaking, headline, announced, report) → topic: "news"
      finance keywords (stock, price, market, earnings, revenue) → topic: "finance"
   d. If no signals detected → use defaults (no extra params)
4. If extract: validate URL starts with http(s)://, check for optional query after URL
5. If code: assess query complexity → set tokensNum (see api-reference.md Token Allocation)
6. Check required API key env var for the subcommand
   - search/extract → TAVILY_API_KEY
   - code → EXA_API_KEY
7. Check jq availability → fallback to python3 if missing
8. Build JSON payload safely with jq -n --arg (or python3)
   - Start with base payload, then add conditional params only if set
9. curl with --max-time 30 --connect-timeout 10, capture HTTP status
10. Check curl exit code first → connection error if non-zero
11. Branch on HTTP status: 200 ok / 401,429,other → error message
12. Parse response and output markdown with Sources section
```

## Data Privacy

Queries are sent to external search services. Do not include confidential code or sensitive information in search queries.

## References

- [api-reference.md](references/api-reference.md) - API endpoints, curl patterns, env vars, output formats, error handling
