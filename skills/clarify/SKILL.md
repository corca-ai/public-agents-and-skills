---
name: clarify
description: Transform vague or ambiguous specifications into precise, actionable requirements through iterative questioning. Use when user asks to "clarify requirements", "refine requirements", "specify requirements", "what do I mean", "make this clearer", or when requests are ambiguous and need structured clarification. Also trigger when user says "clarify", "/clarify", or mentions unclear/vague requirements.
---

# Clarify

Transform vague or ambiguous requirements into precise, actionable specifications through structured and iterative questioning.

## Purpose

When requirements are unclear, incomplete, or open to multiple interpretations, use structured questioning to extract the user's true intent before any implementation begins.

## Definitions

### Ambiguity

Information required for implementation or decision-making that is missing or unclear in the spec.

**Two types:**

1. **Implicit Ambiguity**: Unclear aspects the author hasn't recognized
   - Example: "Add login feature" without specifying failure handling

2. **Decision Prerequisite Ambiguity**: Missing information needed to make a decision on an open question
   - Example: "Not sure which tracking tool to use" → Missing: expected traffic, budget, analytics depth needed

### Open Question

A point where the author hasn't decided yet or recognizes that discussion is needed. Can be expressed as:

**Explicit markers:**
- `[고민]`, `[TODO]`, `[미정]`, `[TBD]`, `?`
- "TODO:", "FIXME:", "DECISION NEEDED:"

**Implicit expressions:**
- "~할지 모르겠다" / "not sure about ~"
- "~중에 뭐가 나을까" / "which one is better"
- "아직 정하지 않은" / "haven't decided yet"
- "고려 중" / "considering"
- Rhetorical questions in the spec

Recognize these various expressions and treat them as open questions requiring analysis and recommendations.

## Process

Each iteration follows these steps:

### Step 1: Assess Clarity Level (1-5)

| Level | Description |
|-------|-------------|
| 1 | Almost everything unclear |
| 2 | Core intent understood but mostly ambiguous |
| 3 | Core understood but important details missing |
| 4 | Mostly clear but some edge cases undefined |
| 5 | Ready for implementation |

### Step 2: Identify Ambiguities (max 3)

For each ambiguity, determine:
- **Description**: What is unclear
- **Type**: `implicit` or `decision_prerequisite`
- **Impact**: How this affects implementation/decisions
- **Related decision** (if type is `decision_prerequisite`): Which open question this relates to

Prioritize by implementation impact.

### Step 3: Generate Questions (max 3)

For each question:
- **Question**: Clear, specific question
- **Reason**: Why this question matters
- **Options**: 2-4 concrete choices (when applicable)

Use AskUserQuestion tool to present questions to the user.

**Question Design Principles:**
- **Specific over general**: Ask about concrete details, not abstract preferences
- **Options over open-ended**: Provide 2-4 choices (recognition > recall)
- **One concern at a time**: Avoid bundling multiple questions
- **Neutral framing**: Present options without bias
- **Impact-aware**: Explain why the question matters

Order questions by importance (most critical first).

### Step 4: Provide Suggestions for Open Questions (if applicable)

When you have gathered enough information to address an open question:
- Analyze trade-offs between options
- Provide a recommendation with reasoning
- Note any remaining uncertainties

**Important:** Don't immediately answer open questions. First check if you have enough information. If not, identify what's missing (this becomes a `decision_prerequisite` ambiguity) and ask for it.

### Step 5: Wait for User Response

After presenting your analysis and questions, wait for user answers before proceeding.

### Step 6: Update Understanding and Re-assess

After receiving answers:
- Incorporate answers into your understanding
- Re-assess clarity level
- If < 5, return to Step 1

## Protocol Phases

### Phase 1: Capture Original Requirement

Record the original requirement exactly as stated:

```markdown
## Original Requirement
"{user's original request verbatim}"
```

Identify ambiguities:
- What is unclear or underspecified?
- What assumptions would need to be made?
- What decisions are left to interpretation?

### Phase 2: Iterative Clarification

Use AskUserQuestion tool to resolve each ambiguity. Continue until ALL aspects are clear.

**Loop Structure:**
```
while ambiguities_remain:
    identify_most_critical_ambiguity()
    ask_clarifying_question()  # Use AskUserQuestion tool
    update_requirement_understanding()
    check_for_new_ambiguities()
```

**AskUserQuestion Format:**
```
question: "What authentication method should be used?"
header: "Auth method"
options:
  - label: "Username/Password"
    description: "Traditional email/password login"
  - label: "OAuth"
    description: "Google, GitHub, etc. social login"
  - label: "Magic Link"
    description: "Passwordless email link"
multiSelect: false
```

### Phase 3: Before/After Comparison

After clarification is complete, present the transformation:

```markdown
## Requirement Clarification Summary

### Before (Original)
"{original request verbatim}"

### After (Clarified)
**Goal**: [precise description of what user wants]
**Scope**: [what's included and excluded]
**Constraints**: [limitations, requirements, preferences]
**Success Criteria**: [how to know when done]

**Decisions Made**:
| Question | Decision |
|----------|----------|
| [ambiguity 1] | [chosen option] |
| [ambiguity 2] | [chosen option] |
```

### Phase 4: Save Option

Ask if the user wants to save the clarified requirement:

```
AskUserQuestion:
question: "Save this requirement specification to a file?"
header: "Save spec"
options:
  - label: "Yes, save to file"
    description: "Save to requirements/ directory"
  - label: "No, proceed"
    description: "Continue without saving"
multiSelect: false
```

If saving:
- Default location: `requirements/` or project-appropriate directory
- Filename: descriptive, based on requirement topic (e.g., `auth-feature-requirements.md`)
- Format: Markdown with Before/After structure

## Ambiguity Categories

Common types to probe:

| Category | Example Questions |
|----------|------------------|
| **Scope** | What's included? What's explicitly out? |
| **Behavior** | Edge cases? Error scenarios? |
| **Interface** | Who/what interacts? How? |
| **Data** | Inputs? Outputs? Format? |
| **Constraints** | Performance? Compatibility? |
| **Priority** | Must-have vs nice-to-have? |

## GitHub Context Usage

When the user provides a GitHub repository URL or when working in a git repository:

1. **Explore the repository** to understand:
   - Project structure (directories, key files)
   - Existing implementation state
   - Technology stack (package.json, requirements.txt, etc.)
   - README and documentation

2. **Use this context** to:
   - Ask more informed questions
   - Avoid asking about things already decided in code
   - Identify inconsistencies between spec and implementation
   - Understand constraints from existing architecture

3. **Reference findings** in your response:
   - "I see from your repo that you're using Next.js..."
   - "Your current auth implementation uses X, should the new feature follow the same pattern?"

## Examples

### Example 1: Vague Feature Request

**Original**: "Add a login feature"

**Clarifying questions (via AskUserQuestion)**:
1. Authentication method? → Username/Password
2. Registration included? → Yes, self-signup
3. Session duration? → 24 hours
4. Password requirements? → Min 8 chars, mixed case

**Clarified**:
- Goal: Add username/password login with self-registration
- Scope: Login, logout, registration, password reset
- Constraints: 24h session, bcrypt, rate limit 5 attempts
- Success: User can register, login, logout, reset password

### Example 2: Bug Report

**Original**: "The export is broken"

**Clarifying questions**:
1. Which export? → CSV
2. What happens? → Empty file
3. When did it start? → After v2.1 update
4. Steps to reproduce? → Export any report

**Clarified**:
- Goal: Fix CSV export producing empty files
- Scope: CSV only, other formats work
- Constraint: Regression from v2.1
- Success: CSV contains correct data matching UI

### Example 3: Open Question with Prerequisites

**Original**: "Not sure which tracking tool to use - GA4, Plausible, or PostHog?"

**Decision prerequisite questions**:
1. Expected monthly active users? → 100-1000
2. Budget constraints? → Prefer free/low-cost
3. Privacy requirements? → GDPR compliance needed
4. Analytics depth needed? → Basic metrics sufficient

**Suggestion after gathering info**:
- **Options analysis:**
  - GA4: Free, powerful, but privacy concerns
  - Plausible: €9/month, privacy-first, GDPR compliant, simple
  - PostHog: Free tier available, most features, complex setup
- **Recommendation**: Plausible
- **Reasoning**: At 100-1000 MAU with GDPR needs and basic metrics requirement, Plausible offers the best balance of simplicity, compliance, and cost

## Output Style

Write natural, conversational responses. Do **not** output structured JSON blocks - focus on clear communication.

Your response should:
- State the current clarity level with brief justification
- Explain the ambiguities you found and why they matter
- Present your questions clearly (using AskUserQuestion tool)
- Provide suggestions for any open questions you can now address
- Be helpful and constructive in tone

**Language**: Respond in the same language as the user's request (Korean or English).

## Rules

1. **No assumptions**: Ask, don't assume
2. **Preserve intent**: Refine the spec, don't redirect it
3. **Minimal questions**: Only ask what's needed (max 3 per iteration)
4. **Respect answers**: Accept user decisions without pushing back
5. **Track progress**: Always show current clarity level
6. **Be helpful**: Your goal is to help, not to criticize
7. **Handle open questions properly**: Don't answer without prerequisites, gather context first
