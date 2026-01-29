# API Reference

Detailed curl patterns, output formats, and error handling for the web-search skill.

---

## Environment Variables

| Variable | Required for | Get key at |
|----------|-------------|------------|
| `TAVILY_API_KEY` | `/web-search`, `/web-search extract` | https://app.tavily.com/home |
| `EXA_API_KEY` | `/web-search code` | https://dashboard.exa.ai/api-keys |

Only check the key required for the invoked subcommand. Do not require both keys at once.

---

## JSON Builder Helper

Always use safe JSON construction. Never interpolate variables directly into JSON strings.

```bash
# With jq (preferred)
PAYLOAD=$(jq -n --arg q "$QUERY" '{query: $q, search_depth: "basic", max_results: 5, include_answer: true}')

# Without jq (python3 fallback)
PAYLOAD=$(python3 -c "import json,sys; print(json.dumps({'query': sys.argv[1], 'search_depth': 'basic', 'max_results': 5, 'include_answer': True}))" "$QUERY")
```

---

## curl Pattern

All API calls follow this pattern:

```bash
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT INT TERM

HTTP_CODE=$(curl -s --max-time 30 --connect-timeout 10 \
  -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "$AUTH_HEADER" \
  -d "$PAYLOAD" \
  -o "$TMPFILE" -w "%{http_code}")
CURL_EXIT=$?

# Check curl exit code first
if [ "$CURL_EXIT" -ne 0 ] || [ "$HTTP_CODE" = "000" ]; then
  echo "Error: Connection failed. Check your network."
  exit 1
fi

# Check HTTP status
if [ "$HTTP_CODE" = "200" ]; then
  # Parse and format results
elif [ "$HTTP_CODE" = "401" ]; then
  echo "Error: API key is invalid. Check your $KEY_VAR_NAME."
elif [ "$HTTP_CODE" = "429" ]; then
  echo "Error: Rate limit exceeded. Please wait and retry."
else
  echo "Error: Request failed (HTTP $HTTP_CODE). Try built-in WebSearch as fallback."
fi
```

---

## 1. Tavily Search (`/web-search <query>`)

**Endpoint**: `POST https://api.tavily.com/search`
**Auth**: `Authorization: Bearer $TAVILY_API_KEY`

### Request

```bash
PAYLOAD=$(jq -n --arg q "$QUERY" '{
  query: $q,
  search_depth: "basic",
  max_results: 5,
  include_answer: true
}')
```

### Response Fields

```json
{
  "answer": "string or null",
  "results": [
    {
      "title": "string",
      "url": "string",
      "content": "string"
    }
  ]
}
```

### Output Format

```markdown
## Search Results: <query>

<answer if present>

### 1. <title>
<content snippet>
- URL: <url>

### 2. <title>
...

---
Sources:
- [Title1](url1)
- [Title2](url2)
```

### jq Parse

```bash
# Extract answer
ANSWER=$(jq -r '.answer // empty' "$TMPFILE")

# Extract numbered results
jq -r '[.results[] | {t: (.title // "Untitled"), c: (.content // ""), u: (.url // "")}] | to_entries[] | "### \(.key + 1). \(.value.t)\n\(.value.c)\n- URL: \(.value.u)\n"' "$TMPFILE"

# Extract sources
jq -r '.results[] | "- [\(.title // "Untitled")](\(.url // ""))"' "$TMPFILE"
```

### python3 Parse (fallback)

```bash
python3 -c "
import json, sys
try:
    data = json.load(open(sys.argv[1]))
except (json.JSONDecodeError, FileNotFoundError) as e:
    print(f'Error parsing response: {e}', file=sys.stderr)
    sys.exit(1)
answer = data.get('answer')
if answer:
    print(answer + '\n')
for i, r in enumerate(data.get('results', []), 1):
    print(f\"### {i}. {r.get('title', 'Untitled')}\")
    print(r.get('content', ''))
    print(f\"- URL: {r.get('url', '')}\n\")
print('---')
print('Sources:')
for r in data.get('results', []):
    print(f\"- [{r.get('title', 'Untitled')}]({r.get('url', '')})\")
" "$TMPFILE"
```

---

## 2. Exa Code Context (`/web-search code <query>`)

**Endpoint**: `POST https://api.exa.ai/context`
**Auth**: `x-api-key: $EXA_API_KEY`

### Request

```bash
PAYLOAD=$(jq -n --arg q "$QUERY" '{
  query: $q,
  tokensNum: 5000
}')
```

`tokensNum`: Max response tokens (range: 1000-50000). Default 5000.

### Response Fields

```json
{
  "response": "string (formatted code context)",
  "resultsCount": 15,
  "costDollars": "0.0025"
}
```

### Output Format

```markdown
## Code Context: <query>

*Source: Exa Code Context API (GitHub, Stack Overflow, docs)*

<response content>
```

### jq Parse

```bash
jq -r '.response // "No results"' "$TMPFILE"
```

### python3 Parse (fallback)

```bash
python3 -c "
import json, sys
try:
    data = json.load(open(sys.argv[1]))
except (json.JSONDecodeError, FileNotFoundError) as e:
    print(f'Error parsing response: {e}', file=sys.stderr)
    sys.exit(1)
print(data.get('response', 'No results'))
" "$TMPFILE"
```

---

## 3. Tavily Extract (`/web-search extract <url>`)

**Endpoint**: `POST https://api.tavily.com/extract`
**Auth**: `Authorization: Bearer $TAVILY_API_KEY`

### URL Validation

Before calling the API, validate that the URL starts with `http://` or `https://`.
If invalid, suggest: `Did you mean: /web-search <query>?`

### Request

```bash
PAYLOAD=$(jq -n --arg u "$URL" '{
  urls: [$u],
  extract_depth: "basic",
  format: "markdown"
}')
```

### Response Fields

```json
{
  "results": [
    {
      "url": "string",
      "raw_content": "string"
    }
  ],
  "failed_results": []
}
```

### Output Format

```markdown
## Extracted: <url>

<raw_content>
```

### jq Parse

```bash
jq -r '.results[0].raw_content // "Extraction failed"' "$TMPFILE"
```

### python3 Parse (fallback)

```bash
python3 -c "
import json, sys
try:
    data = json.load(open(sys.argv[1]))
except (json.JSONDecodeError, FileNotFoundError) as e:
    print(f'Error parsing response: {e}', file=sys.stderr)
    sys.exit(1)
results = data.get('results', [])
if results:
    print(results[0].get('raw_content', 'No content'))
else:
    failed = data.get('failed_results', [])
    print('Extraction failed' + (f': {failed}' if failed else ''))
" "$TMPFILE"
```

---

## Error Handling

| HTTP Code | Message |
|-----------|---------|
| curl non-zero exit | `Connection failed. Check your network.` |
| 200 | (parse and display results) |
| 401 | `API key is invalid. Check your {KEY_VAR}.` |
| 429 | `Rate limit exceeded. Please wait and retry.` |
| Other | `Request failed (HTTP {code}). Try built-in WebSearch as fallback.` |

## Missing API Key Message

Show only the relevant provider for the invoked subcommand:

```
Error: {KEY_VAR} is not set.

Get your API key: {provider_url}

Then add to your shell profile:
  export {KEY_VAR}="your-key-here"
```

## Usage Message (no args or "help")

```
Web Search Skill

Usage:
  /web-search <query>           General web search (Tavily)
  /web-search code <query>      Code/technical search (Exa)
  /web-search extract <url>     Extract URL content (Tavily)

Environment variables:
  TAVILY_API_KEY    Required for search and extract
  EXA_API_KEY       Required for code search
```
