---
name: story-handoff
description: >
  Bridges the GitLab planning workflow (story-breakdown → issue-draft → story-workflow)
  with Superpowers agents. Reads a GitLab story and its published task issues, then
  produces a Superpowers-compatible spec document that writing-plans can consume
  directly — preserving all issue content verbatim without regenerating or summarizing
  anything. Embeds GitLab references and glab commands so any agent can fetch fresh
  details at any time during implementation.

  Use this skill whenever the user says: "handoff story #N to Superpowers",
  "prepara la spec Superpowers per la storia #N", "ready story #N for implementation",
  "passa la storia #N agli agenti", "crea il design doc per la storia #N", or any
  request to prepare a planned GitLab story for implementation via Superpowers — even
  if they don't use these exact words.
compatibility: "Requires glab CLI authenticated and git remote configured."
---

You bridge GitLab planning artifacts to Superpowers implementation agents.
Your job is to read what was already planned and approved — story issue, task issues,
acceptance criteria — and repackage it into a spec that writing-plans can consume
without losing a single detail.

**Never regenerate, summarize, or paraphrase issue content.** Verbatim preservation
is the entire value of this skill. The planning team reviewed and approved what's in
those issues; rewriting it throws that work away and introduces drift.

---

## Phase 1 — Load story and tasks from GitLab (silent)

Capture the GitLab project remote first — you'll need it for every glab command in the spec:

```bash
git remote get-url origin
```

Extract `<owner>/<repo>` from the URL (e.g. `git@gitlab.com:acme/pk-watch.git` → `acme/pk-watch`).

Fetch the parent story:

```bash
glab issue view <story-id> --repo <owner>/<repo>
```

Extract: title, description, labels, milestone, web_url, child issue links.

**If child issues are not linked on the parent**, read workflow state from
`<service-path>/docs/workflow-<story-id>.json` to get the task list.

Fetch each task issue:

```bash
glab issue view <task-id> --repo <owner>/<repo>
```

Extract per task: title, description, acceptance criteria, labels, web_url,
estimate (from label or description), design_needed (from label or description).

**If a task issue cannot be fetched**, stop and ask the user for the correct
issue number before continuing. Do not invent or infer missing tasks.

**If neither GitLab links nor workflow state are available**, ask the user for
the task issue numbers before proceeding.

---

## Phase 2 — Load codebase context (silent)

```bash
git log --oneline -20
```

Use Read/Grep/Glob on `<service-path>` to understand:
- project structure and module boundaries
- existing patterns relevant to the story domain
- tech stack, test conventions, key interfaces

Load relevant project standards from the path indicated in CLAUDE.md.

Do not narrate this phase.

---

## Phase 3 — Write the Superpowers spec document

Save to:

```
<service-path>/docs/superpowers/specs/YYYY-MM-DD-story-<story-id>-<slug>.md
```

where `<slug>` is the first 4–5 words of the story title in kebab-case.

Use this exact structure:

````markdown
# <story title>

## GitLab references
<!-- Agents: use these commands to fetch fresh details at any time -->

**Story:** #<story-id> — <story title>
**URL:** <story web_url>
**Milestone:** <milestone>
**Fetch command:**
```bash
glab issue view <story-id> --repo <owner>/<repo>
```

**Tasks:**
| # | Title | GitLab issue | URL | Fetch command |
|---|-------|-------------|-----|---------------|
| 1 | <title> | #<id> | <url> | `glab issue view <id> --repo <owner>/<repo>` |
| 2 | ... | ... | ... | ... |

---

## Context
<2–3 sentences: why this story exists, what problem it solves,
how it fits the system. Derived from the story description — no invention.>

## Scope
<What is included in this story. What is explicitly excluded.>

## Architecture
<2–4 sentences: approach, key design decisions, how this fits existing
patterns found in the codebase. If any task has design_needed, note that
an ADR is required for that task before implementation begins.>

## Tech stack and constraints
<Key technologies, version constraints, and project-wide rules from standards.
One line each. These become Global Constraints in the writing-plans output.>

## Tasks

For each task, in dependency order (tasks with no depends_on first):

### Task <N>: <title>

<!-- GitLab: #<issue-id> | <web_url> -->
<!-- To fetch fresh details: glab issue view <id> --repo <owner>/<repo> -->

**GitLab issue:** #<issue-id>
**Estimate:** <XS/S/M/L>
**Depends on:** <task titles, or "none">
**Impacted modules:** <from issue>

**What to build:**
<Verbatim from the GitLab issue body. Do not paraphrase or summarize.>

**Acceptance criteria:**
- [ ] <Verbatim from GitLab issue>
- [ ] <Verbatim from GitLab issue>

[If design_needed is yes or maybe, add:]
> ⚠️ ADR required before implementation.
> Run `glab issue view <id> --repo <owner>/<repo>` for full context.
````

**Two rules that override everything else:**

1. **Verbatim rule.** "What to build" and "Acceptance criteria" must come from the
   GitLab issue content character-for-character. No synonyms, no compression, no
   restructuring. If the issue is vague, the spec is vague — and that's a signal to
   fix the issue, not to invent clarity here.

2. **Reference rule.** Every task section must include the issue ID and the exact
   glab fetch command. An agent that loses context mid-session can always recover by
   running that one command.

---

## Phase 4 — Self-review (silent)

Before saving, verify every item:

- No TODOs, placeholders, or TBD anywhere in the document
- No contradictions between task descriptions
- No ambiguous requirements (if found, flag them verbatim — do not resolve them)
- Scope focused on this story only — no work from adjacent stories snuck in
- No YAGNI — no features not present in the GitLab issues
- Every task has a GitLab issue reference and fetch command
- Every glab command uses the `--repo` flag captured in Phase 1
- Dependency order is correct (blocked tasks appear after their dependencies)

Fix violations inline. Do not surface this phase to the user.

---

## Phase 5 — Handoff message

After saving, tell the user (in their language):

> "Spec scritta in `<path>` a partire da <N> task GitLab
> (storia #<story-id>, milestone <milestone>).
>
> Per avviare l'implementazione, di' all'agente:
>
> ```
> The design for story #<id> is already approved.
> Spec is at <path>.
> Skip brainstorming. Run writing-plans on it.
> ```"

If any task has `design_needed: yes`, append:

> "⚠️ Prima di avviare, completa l'ADR per: <task titles>.
> Usa `glab issue view <id> --repo <owner>/<repo>` per il contesto completo."

---

## Hard constraints

- Never modify GitLab issues or workflow state files
- Never start implementation
- Never regenerate or paraphrase issue content — preserve it verbatim
- Always include `--repo` in every glab command written into the spec
- If a task issue cannot be fetched, ask the user before proceeding
- Never invent tasks not present in the GitLab issues
