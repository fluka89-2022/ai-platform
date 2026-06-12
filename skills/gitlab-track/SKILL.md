---
name: gitlab-track
description: "GitLab issue author. Use when the user asks to open a bug report,
  feature request, technical debt item, or documentation issue on GitLab via glab.
  Apply when the user says 'create an issue', 'report a bug', 'track tech debt',
  'propose a feature', 'apri un task', 'crea un task figlio di una story',
  'crea branch task', or 'task su story branch'. Also use for branch strategy
  on task issues, child task linked to a parent story, or task branch based on
  story branch. Not for merge requests (→ See codeskine/gitlab-workflow@gitlab-review)
  or milestones (→ See codeskine/gitlab-workflow@gitlab-plan)."
user-invocable: true
license: MIT
compatibility: "Designed for Claude Code or similar AI coding agents. Requires glab CLI authenticated."
metadata:
  author: codeskine
  version: "1.4.0"
allowed-tools: Read Edit Write Glob Grep Bash(git:*) Bash(glab:*) Agent AskUserQuestion
---

**Personas:** You are a team member. You create GitLab issues to track work clearly so it can be refined, prioritized, and developed later by the appropriate people

**Modes:**

- **Create** — generate a new issue from context and publish via `glab issue create [--flags]`
- **Transition** — change the lifecycle state of an existing issue via `glab issue update <id> [--flags]`

# GitLab track — issue author

## Supported types

| Type             | Template                                             |
| ---------------- | ---------------------------------------------------- |
| `bug`            | [assets/bug.md](assets/bug.md)                       |
| `feature`        | [assets/feature.md](assets/feature.md)               |
| `technical-debt` | [assets/technical-debt.md](assets/technical-debt.md) |
| `documentation`  | [assets/documentation.md](assets/documentation.md)   |

→ See [shared/references/label-registry.md](../shared/references/label-registry.md) for default labels and colors.

## Create workflow

### 1. Identify the issue type

The user must specify the type in the prompt (e.g. _"create a bug issue for..."_, _"open a technical debt on..."_). If missing, ask once:

> "What type of issue do you want to open? bug / feature / technical-debt / documentation"

### 1.5. Detect story parent (optional)

If the user mentioned a parent story (e.g. "figlio della story #42", "sotto la story #12",
"--parent 42", or similar), resolve it:

```bash
glab issue view <parent-id> --output json
```

Extract parent title and compute:
- `<parent-slug>` = first 4–5 tokens of parent title, kebab-case, only ASCII
- `<story-branch>` = `story/<parent-id>-<parent-slug>`

The task branch base will be `<story-branch>`.
The MR for this task will target `<story-branch>` (not `main`/`develop`).

If no parent is mentioned, set parent = none; base and MR target will be determined in step 3.

### 2. Load the template

Read only `assets/<type>.md` for the chosen type.

### 3. Explore context

**Automatic git extraction** (silent):

```bash
git log --oneline -20        # recent work area
git diff HEAD                # files and symbols involved
```

For `bug` or `technical-debt`, also run:

```bash
git blame <file> -L <start>,<end>   # author and date of affected lines
```

**Detect base branch** (silent):

```bash
git branch -r | grep -E 'origin/(main|develop)' | head -1
```

If a story parent was identified in step 1.5, `<base-branch>` = `<story-branch>`.
Otherwise, use `develop` if found, else `main`.

**Codebase exploration:** Use `Read`, `Grep`, `Glob` to open identified files, resolve symbolic references (function name, struct, package → `file:line`), and find relevant callers when useful for diagrams.

**Snippet policy:** Include fenced code blocks of 5–20 lines per significant point, with exact `path/file.ext` line N citation. Use language-appropriate syntax highlighting.

Context gathering is silent — no intermediate output. Everything converges in the draft.

### 4. Discover labels and milestone

```bash
glab label list              # discover real project labels before suggesting
glab milestone list --state active
```

Select the most relevant active milestone based on branch name, label, or issue type. If a
milestone fits, suggest it. If none fits (e.g. hotfix, out-of-sprint task), leave it empty
without asking — not every issue belongs to a milestone.

Suggest `workflow::ready` as the initial lifecycle label alongside the type label.

### 5. Apply diagram policy

Decide whether to include a diagram and which pattern to use, then generate it.

→ Policy table and reusable patterns: [references/mermaid-diagrams.md](references/mermaid-diagrams.md)

### 6. Quality gate (silent)

Before presenting the draft, verify:

- Title ≥ 5 words and not generic (`Fix bug` alone fails; `Fix nil pointer in user handler` passes)
- At least one fenced code snippet (5–20 lines) for `bug` and `technical-debt` types
- Labels include at least `type::*` + `workflow::ready`
- No placeholder text (`TBD`, `TODO`, `<...>`) in any section

Fix any violations automatically. Do not output the checklist to the user.

→ Full criteria: [../shared/references/quality-standard.md](../shared/references/quality-standard.md)

### 7. Draft gate

**Create `docs/gitlab/` if missing:**

```bash
mkdir -p docs/gitlab
```

Write the draft to `docs/gitlab/YYYY-MM-DD-<slug>.md` (slug = first 5–7 tokens of the title, kebab-case). Use today's date for `YYYY-MM-DD`:

```markdown
---
kind: issue
type: <type>
title: "<title>"
labels: "<labels>"
milestone: "<milestone or empty>"
parent_story: <parent-story-id or empty>
status: draft
created_at: <YYYY-MM-DD>
---

<body>
```

Always include the `parent_story` field. Set it to the parent issue ID if one was identified in step 1.5, otherwise leave it empty.

Present the confirmation in chat referencing the file path:

```
Bozza pronta.

  File      : docs/gitlab/<YYYY-MM-DD-slug>.md
  Titolo    : `<title>`
  Label     : <labels>
  Milestone : <milestone|nessuna>
  Branch    : `task/<issue-id>-<slug>` (base: `<base-branch>`) — ID assegnato alla pubblicazione
  MR target : `<story-branch>`          ← solo se task figlio di una story

Procedo? (sì / modifiche / annulla)
```

Omit the "MR target" line if the task has no parent story.

If the user requests changes, update the file in `docs/gitlab/` and re-present. Repeat until approved.

### 8. Publish via glab

After explicit approval:

1. Strip the YAML frontmatter and publish:

```bash
awk 'BEGIN{n=0} /^---$/{n++; next} n==2{print}' \
  docs/gitlab/YYYY-MM-DD-<slug>.md > /tmp/issue-body-<slug>.md

glab issue create \
  --title "<title>" \
  --label "<type-label>,workflow::ready" \
  --milestone "<milestone>" \
  --description "$(cat /tmp/issue-body-<slug>.md)"
```

2. Extract the issue ID from the returned URL (last numeric path segment). Compute:
   - `<branch-slug>` = first 4–5 tokens of the title, kebab-case, only ASCII
   - `<branch-name>` = `task/<id>-<branch-slug>`

3. Create the task branch:

```bash
git checkout -b task/<id>-<branch-slug> <base-branch>
git push -u origin task/<id>-<branch-slug>
```

4. If the task has a parent story, link it via the REST API:

```bash
glab api --method POST "projects/:id/issues/<new-issue-iid>/links" \
  -f target_project_id="$(glab api projects/:id --jq .id)" \
  -f target_issue_iid=<parent-iid> -f link_type=relates_to
```

5. Update `docs/gitlab/YYYY-MM-DD-<slug>.md` frontmatter in-place — replace `status: draft` with:

```yaml
status: published
gitlab_url: <returned-url>
branch: task/<id>-<branch-slug>
parent_story: <parent-id|empty>
published_at: <YYYY-MM-DD>
```

6. Return the created issue URL and the branch name:

> "Issue creata: <url> — Branch: `task/<id>-<branch-slug>` (base: `<base-branch>`)"
> [solo se figlio] "MR target: `<story-branch>`"

Optional flags (use when the user specifies):

```bash
  --assignee "<username>"      # discover members first: glab member list
  --confidential               # for sensitive issues
  --repo "<group/project>"     # cross-project creation
```

→ Full flag reference: [references/glab-issue-commands.md](references/glab-issue-commands.md)

## Transition workflow

Use when the user says "start working on #N", "resolve #N", or similar lifecycle phrases.

1. Read current issue state:
   ```bash
   glab issue view <N> --output json
   ```
2. Determine the current `workflow::` label.
3. Look up the valid transition in [references/issue-lifecycle.md](references/issue-lifecycle.md).
4. Warn if the requested transition is invalid (e.g. issue is already `workflow::in dev`).
5. Present the planned transition for confirmation before executing:

   > "Shall I move issue #N from `<current-state>` to `<new-state>`? (yes / cancel)"

6. Apply the transition on confirmation:
   ```bash
   glab issue update <N> --label "<new-state>" --unlabel "<current-state>"
   ```
   Report the applied change in chat.
7. **Branch setup (only when transitioning to `workflow::in dev`):** Offer two options:

   > "Ready to start development. How do you want to proceed?
   > A) Create branch `task/<N>-<short-title>` (base: `<base-branch>`)
   > B) Stay on current branch `<current-branch>`"

   Detect `<base-branch>` as in step 3 of the Create workflow: check for an existing
   `story/<parent-id>-*` branch if the issue is linked to a parent story, otherwise use
   `develop` or `main`.

   If option A: run `git checkout -b task/<N>-<short-title> <base-branch>` and
   `git push -u origin task/<N>-<short-title>`, then confirm the new branch in chat.
   If option B: continue without branch change.

   `<short-title>` = first 3–4 significant words of the issue title in kebab-case.

Full state machine: [references/issue-lifecycle.md](references/issue-lifecycle.md)

## References

- Mermaid patterns: [references/mermaid-diagrams.md](references/mermaid-diagrams.md)
- Issue lifecycle: [references/issue-lifecycle.md](references/issue-lifecycle.md)
- Full glab flag reference: [references/glab-issue-commands.md](references/glab-issue-commands.md)
- Templates: [assets/bug.md](assets/bug.md), [assets/feature.md](assets/feature.md), [assets/technical-debt.md](assets/technical-debt.md), [assets/documentation.md](assets/documentation.md)
