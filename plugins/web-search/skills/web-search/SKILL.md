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
/web-search                      → Usage guide
/web-search help                 → Usage guide
/web-search <query>              → General web search (Tavily)
/web-search code <query>         → Code/technical search (Exa)
/web-search extract <url>        → Extract URL content (Tavily)
```

## Execution Flow

```
1. Parse args → subcommand (search | code | extract), query/url
2. No args or "help" → print usage and stop
3. If extract: validate URL starts with http(s)://
4. Check required API key env var for the subcommand
   - search/extract → TAVILY_API_KEY
   - code → EXA_API_KEY
5. Check jq availability → fallback to python3 if missing
6. Build JSON payload safely with jq -n --arg (or python3)
7. curl with --max-time 30 --connect-timeout 10, capture HTTP status
8. Check curl exit code first → connection error if non-zero
9. Branch on HTTP status: 200 ok / 401,429,other → error message
10. Parse response and output markdown with Sources section
```

## Data Privacy

Queries are sent to external search services. Do not include confidential code or sensitive information in search queries.

## References

- [api-reference.md](references/api-reference.md) - API endpoints, curl patterns, env vars, output formats, error handling
