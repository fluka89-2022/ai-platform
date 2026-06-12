---
name: story-breakdown
description: >-
  Breaks down a user story into atomic, implementable GitLab tasks with effort estimates
  and codebase impact analysis. Use this skill whenever the user wants to decompose a
  story or feature into tasks — even if they don't say "break down" explicitly.
  Triggers on: "break down story", "propose tasks for", "decompose this story",
  "split story into tasks", "what tasks do I need to implement", "create subtasks",
  "help me plan this feature", any request to turn a story or GitLab issue into a list
  of implementable work items.
---

# Story Breakdown

You decompose user stories into atomic, implementable GitLab tasks.

**The process is always two-phase: propose first, create only after explicit approval.**
Never skip this order, even if the user seems confident.

## Phase 1 — Silent context gathering

Before proposing anything, gather context silently using available tools. Do not narrate this step or announce what you are doing.

**If given a GitLab issue number:**
```bash
glab issue view <N>
```
Extract: title, description, acceptance criteria, labels, milestone. If glab fails or the issue is not found, ask for the story text directly.

**If given free text:** use it as-is.

**Codebase context (when filesystem is available):**
- `git log --oneline -20` — understand recent activity and conventions
- Use Read, Grep, Glob to explore the codebase related to the story's domain
- Goal: identify the correct module and layer names from the actual project structure,
  not generic names
- Do not collect file paths — they are volatile and do not belong in planning artifacts
- Surface findings only via the "Impacted modules/layers" column in the proposal table

**Project standards (when filesystem is available):**
- Read CLAUDE.md to find where project standards are documented
- Explore that directory using Glob to list available standard files
- Read only the files relevant to the domain of the current story
  (use file names and directory structure to assess relevance;
  if uncertain, read the first 20 lines of a file before loading it fully)
- Use findings exclusively to:
  - identify mandatory tasks that standards require and that would otherwise be missing
    from the proposal (e.g. a logging standard may require a dedicated task for
    structured log integration; an error-handling standard may require a task for
    error wrapping conventions)
  - do NOT use standards to write acceptance criteria — that is issue-draft's
    responsibility, not story-breakdown's
- Do not narrate this step or surface the standard file names to the user

## Phase 2 — Propose tasks

Output a Markdown table using this exact structure:

| # | Title | Type | Estimate | Design needed | Depends on | Impacted modules/layers |
|---|-------|------|----------|---------------|------------|------------------------|
| 1 | Add API key generation endpoint | feature | M | yes | — | auth module, API layer |
| 2 | Store hashed API keys in database | feature | S | no | 1 | database migrations, auth module |
| 3 | Write unit tests for key generation | feature | S | no | 1 | auth module |

**Types:** `feature` | `bug` | `tech-debt` | `docs`

**Estimates:**
- `XS` — under 2 hours
- `S` — roughly half a day
- `M` — roughly one day
- `L` — up to two days (maximum allowed per task)

**Language:** Write task titles and descriptions in the same language the user is using in the current conversation.

**Task titles:** Use conventional commit noun-phrase style — action verb + specific noun.
- ✓ `"Add rate limiting middleware to webhook endpoint"` (English user)
- ✓ `"Aggiungere rate limiting middleware all'endpoint webhook"` (Italian user)
- ✗ `"webhook rate limiting"`, `"fix the thing"`

**Impacted modules/layers:**
- Always cite modules or architectural layers, never specific file paths
  (e.g. `auth module`, `API layer`, `database migrations`, `worker queue`)
- Specific file paths change before the task is picked up — they belong in impl-spec,
  not in planning artifacts
- When codebase is available: use Read/Grep/Glob to identify the correct module or
  layer name from the actual project structure, not generic names
- When not: use the story description to infer the affected area

**Dependencies:** Use `—` when none; reference task numbers otherwise (e.g. `1, 3`).

**Design needed:** Assign based on estimate and task nature:
- `XS` → `no`
- `S` → `no`
- `M` → `yes` if the task introduces a new interface, external dependency, or has multiple viable approaches; otherwise `no`
- `L` → always `yes`

Use `maybe` when genuinely uncertain — e.g., an M-sized task touching an area with no existing patterns.

After the table, add:
1. One sentence explaining the decomposition rationale (e.g. "Tasks follow the vertical slice pattern — data layer first, then business logic, then API surface, then tests.")
2. If any tasks are marked `yes` or `maybe` in the Design needed column, output this block:
   > "These tasks need a Technical Design Document before implementation:
   > - Task N — [one-line reason]
   >
   > Do you want me to run `tech-adr` on them after creating the issues?"
3. Explicitly ask: *"Do you want to adjust any task before I create them?"*

**Stop here. Do not proceed to Phase 3 until the user explicitly confirms.**

## Constraints

**Atomicity:** Every task must be closeable in 1–2 days. A task that would clearly take longer must be split further before proposing.

**Story size cap — 8 tasks maximum.** If the story requires more than 8 tasks, do not decompose it. Instead, refuse and suggest a split:

> "This story is too broad to decompose into ≤ 8 atomic tasks. I'd suggest splitting it:
> - **Story A:** [focused scope]
> - **Story B:** [remaining scope]
>
> Which part should I break down first?"

**Vague or ambiguous stories:** If the story lacks enough detail to define concrete tasks (missing acceptance criteria, undefined scope, unclear technical approach), ask **one focused clarifying question** before proposing anything:

> "Before I propose tasks, I need to clarify one thing: [single question]. Once you answer, I'll proceed."

Ask about the most critical ambiguity only. Do not list multiple questions.

## Phase 3 — Hand off to issue-draft

After the user confirms the task table (e.g., "yes", "go ahead", "looks good", "create them"),
output the final task list in this format so it is ready for the `issue-draft` skill:

```
Task list — ready for issue-draft:

| # | Title | Type | Estimate | Design needed | Depends on | Labels | Parent story |
|---|-------|------|----------|---------------|------------|--------|--------------|
| 1 | <title> | <type> | <estimate> | <yes/no/maybe> | <task numbers or —> | <labels> | #<story-id or —> |
```

Then tell the user:

> "Proposta completata. Invoca `issue-draft` per generare le bozze GitLab dei task."

**Stop here. `story-breakdown` is done.**

## What NOT to do

- Never create GitLab issues before the user explicitly approves the proposal
- Never propose more than 8 tasks without first recommending a story split
- Never use vague task titles ("fix stuff", "implement feature")
- Never ask multiple clarifying questions at once — one at a time
- Never narrate the context-gathering phase
