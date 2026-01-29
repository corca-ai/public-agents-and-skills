---
name: retro
description: |
  Perform a comprehensive session retrospective. Use when user says
  "retro", "retrospective", "회고", or at the end of a working session.
allowed-tools:
  - Read
  - Write
  - Edit
  - WebSearch
  - Skill
  - AskUserQuestion
---

# Session Retrospective

Comprehensive end-of-session review. Produces `retro.md` alongside
`plan.md` and `lessons.md` in the session's prompt-logs directory.

## Invocation

```
/retro [path]
```

- `path`: optional override for output directory

## Workflow

### 1. Locate Output Directory

Resolution order:
1. If `[path]` argument provided, use it
2. Scan session for `prompt-logs/` paths already used (plan.md, lessons.md writes)
3. List `prompt-logs/` dirs matching today's date (`{YYMMDD}-*`)
4. If ambiguous, AskUserQuestion with candidates
5. If none exist, create `prompt-logs/{YYMMDD}-{title}/` (derive title from session topic)

### 2. Read Existing Artifacts

- `plan.md` and `lessons.md` in the target directory (if they exist) — understand session goals, avoid duplicating captured learnings
- `CLAUDE.md` from project root — needed for Section 2
- Project context document (if one exists, e.g. `docs/project-context.md`) — avoid repeating already-persisted context in Section 1

### 3. Draft Retro

Analyze the full conversation to produce five sections. Draft everything internally before writing to file.

#### Section 1: Context Worth Remembering

User, organization, and project facts that future sessions would benefit from:
- Domain knowledge, tech stack, conventions discovered
- Organizational context, team structure, decision-making patterns
- Only include what is genuinely useful for future work

#### Section 2: Collaboration Preferences

- Work style observations (iteration speed, review depth, autonomy level)
- Communication preferences (verbosity, language, formality)
- Compare against current CLAUDE.md rules
- If warranted, draft specific additions under `### Suggested CLAUDE.md Updates` as a bullet list of changes
- If no changes warranted, omit the subsection

#### Section 3: Prompting Habits

- Patterns that led to misunderstandings or extra rounds
- Specific examples from the session with improved alternatives
- Frame constructively: "X worked; Y could work even better"

#### Section 4: Learning Resources

- Use WebSearch to find 2–5 relevant resources
- Calibrate to user's apparent knowledge level
- Focus on topics where the session revealed knowledge gaps or curiosity
- Each resource: title, URL, and one-line reason for relevance
- Prefer fewer high-quality links over many mediocre ones

#### Section 5: Relevant Skills

- Assess whether the session reveals a workflow gap or repetitive pattern
- If yes: invoke `find-skills` via Skill tool, report relevant results
- If a needed skill does not exist: briefly describe what it would do and suggest using `skill-creator`
- If no clear gap: state "No skill gaps identified in this session"

### 4. Write retro.md

Write to `{output-dir}/retro.md` using the format below.

### 5. Persist Findings

retro.md is session-specific. Findings worth keeping across sessions should be persisted to project-level documents.

**Context (Section 1)**: If new context was identified, offer to append it to the project context document. If no such document exists, offer to create one.

**Collaboration & CLAUDE.md (Section 2)**: If collaboration style observations or explicit CLAUDE.md suggestions were produced:
1. AskUserQuestion: "Apply the suggested CLAUDE.md changes?" — Yes / No
2. If yes: Edit CLAUDE.md with the changes
3. If no: suggestions remain documented in retro.md for future reference

## Output Format

```markdown
# Retro: {session-title}

> Session date: {YYYY-MM-DD}

## 1. Context Worth Remembering

{content}

## 2. Collaboration Preferences

{content}

### Suggested CLAUDE.md Updates

{bullet list of changes, or omit subsection if none}

## 3. Prompting Habits

{content}

## 4. Learning Resources

{content}

## 5. Relevant Skills

{content}
```

## Language

Write retro.md in the user's language. Detect from conversation, not from this skill file.

## Rules

1. Never duplicate content already in lessons.md
2. Be specific — cite session moments, not generic advice
3. Keep each section focused — if nothing to say, state that briefly
4. CLAUDE.md changes require explicit user approval
5. If early session context is unavailable due to conversation length, focus on what is visible and note the limitation
