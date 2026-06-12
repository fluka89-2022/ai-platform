---
name: issue-draft
description: Creates GitLab issue draft .md files from task descriptions. Use when the user wants to draft GitLab issues from a task list produced by story-breakdown, or wants to create a single issue draft standalone. Triggers on: "crea le bozze dei task", "draft the issues", "scrivi i task", "draft issue for", "crea la bozza", any request to turn tasks or a story breakdown into GitLab issue files — even if the user does not say "draft" explicitly.
---

# Issue Draft

You create GitLab issue draft files (`.md`) from task descriptions — either a full list from
`story-breakdown`, or a single task provided interactively.

## Mode detection

**Batch mode**: the conversation contains a task table produced by `story-breakdown`
(columns: #, Title, Type, Estimate, Design needed, Depends on, Impacted files/modules).
Process all tasks from the table sequentially.

**Standalone mode**: no prior task table in context. The user describes a single task.
Gather missing info interactively (one question at a time), then create the draft.

---

## Draft creation — steps for each task

Apply these steps to every task, whether in batch or standalone mode.

### 1. Load the template

Read the template for the task's type from `../gitlab-track/assets/<type>.md`.

Supported types: `feature`, `bug`, `technical-debt`, `documentation`.

### 2. Gather context (silent)

```bash
git log --oneline -10  # recent activity and conventions
glab label list        # available labels
```

In standalone mode, if `estimate` and `design_needed` are not provided by the user,
ask for them one at a time before proceeding.

**Project standards (when filesystem is available):**
- Read CLAUDE.md to find where project standards are documented
- Explore that directory using Glob to list available standard files
- Read only the files relevant to the domain of the current task
  (use file names and directory structure to assess relevance;
  if uncertain, read the first 20 lines of a file before loading it fully)
- Use findings exclusively to:
  - write precise, standard-compliant acceptance criteria
    (e.g. if a logging standard defines required fields, acceptance criteria
    must reference those fields explicitly)
  - add the correct ADR/impl-spec notes when design_needed is yes or maybe
- Do not narrate this step or surface the standard file names to the user
- Do not use standards to add file paths, code snippets, or implementation
  details to the issue body — those belong in impl-spec only

### 3. Compose the issue body

Fill the template with the gathered context.

Do NOT include code snippets, file paths, or line references anywhere in the issue body,
regardless of type. These belong in the Technical Spec, not in the issue.

Always add this note at the end of the issue body, for every task.
Write it in the **same language as the issue body** (Italian if the body is in Italian, English if English, etc.):

> ℹ️ Implementation details (exact files, functions, commands) will be defined in the
> Technical Spec when this task is picked up. Do not start implementation without it.

Italian version (use when the issue body is in Italian):

> ℹ️ I dettagli implementativi (file, funzioni, comandi) saranno definiti nella
> Technical Spec quando il task viene preso in carico. Non iniziare l'implementazione senza di essa.

If `design_needed` is `yes` or `maybe`, also add the following note (same language rule applies):

English:
> ⚠️ An ADR is required before implementation. Run `tech-adr` on this task before
> generating the Technical Spec.

Italian:
> ⚠️ È richiesto un ADR prima dell'implementazione. Esegui `tech-adr` su questo task prima
> di generare la Technical Spec.

→ Diagram patterns: `../gitlab-track/references/mermaid-diagrams.md`
→ Quality criteria: `../shared/references/quality-standard.md`

### 4. Quality gate (silent)

Before writing, verify:
- Title is ≥ 5 words and specific (not generic like "Fix bug")
- Labels include at least `type::*` + `workflow::ready`
- No placeholder text (`TBD`, `TODO`, `<...>`) anywhere in the body
- No file paths anywhere in the body (pattern: `path/file.ext` or `path/to/file`)
- No code snippets with line references
- No fenced code blocks in the body
- impl-spec note must be present at the end of every draft
- If design_needed is yes or maybe, ADR note must also be present

Fix violations automatically without surfacing them to the user.

### 5. Write the draft file

Determine the target directory:
- If called from `story-workflow`: use the directory passed in context (e.g., `pk-watch/core/api-server/docs/gitlab/`)
- Otherwise: default to `docs/gitlab/`

Create the directory if missing:

```bash
mkdir -p <target-dir>
```

Write to `<target-dir>/task_<storyNum>_<slug>.md` where:
- `<storyNum>` is the parent story issue number (e.g. `task_42_add-api-key-endpoint.md`)
- `<slug>` is the first 5–7 words of the title in kebab-case
- If no parent story is known, use `task_<slug>.md` (omit the number prefix)

```markdown
---
kind: issue
type: <type>
title: "<title>"
labels: "<labels>"
parent_story: <parent-story-id or empty>
design_needed: <yes/no/maybe>
estimate: <XS/S/M/L>
status: draft
created_at: <YYYY-MM-DD>
---

<body>
```

Always include the `parent_story` field. Set it to the story issue ID if known, otherwise leave empty.

---

## Running the publish script

**The script must always be run from `<service-path>`** (the root of the service git repo,
e.g. `pk-watch/scrapers/ea-scraper`). This is required so that `glab` can resolve the
correct GitLab project from the git remote. Running it from the workspace root will cause
`glab issue create` to fail.

Use the absolute path for the script and relative paths (from `<service-path>`) in
`pending-publish.json`:

```bash
cd /abs/path/to/<service-path> && python /abs/path/to/workspace/ai-platform/skills/gitlab-track/scripts/publish_issues.py docs/gitlab/pending-publish.json
```

**`pending-publish.json` paths must be relative to `<service-path>`**, not to the workspace root.

Correct:
```json
{ "issues": ["docs/gitlab/task_9_creare-package-observability.md"] }
```

Wrong:
```json
{ "issues": ["pk-watch/scrapers/ea-scraper/docs/gitlab/task_9_creare-package-observability.md"] }
```

---

## Batch mode — after all drafts

Generate `<target-dir>/pending-publish.json` with paths relative to `<service-path>`:

```json
{
  "issues": [
    "docs/gitlab/task_<storyNum>_<slug-1>.md",
    "docs/gitlab/task_<storyNum>_<slug-2>.md"
  ]
}
```

Then tell the user:

> "Ho creato N bozze in `<target-dir>`. Leggile e modificale liberamente, poi dimmi quali task
> vuoi pubblicare su GitLab (per numero o titolo).
> Quando sei pronto, eseguirò:
> `cd <abs-service-path> && python <abs-workspace>/ai-platform/skills/gitlab-track/scripts/publish_issues.py docs/gitlab/pending-publish.json`"

**Stop here. Do not publish until the user explicitly names the tasks to create.**

When the user names which tasks to publish, update `<target-dir>/pending-publish.json` to include
only the approved files, then run the command above from `<service-path>`.

Report results as returned by the script.

---

## Standalone mode — after the draft

Tell the user:

> "Bozza creata: `<target-dir>/task_<storyNum>_<slug>.md`
> Per pubblicarla:
> `cd <abs-service-path> && python <abs-workspace>/ai-platform/skills/gitlab-track/scripts/publish_issues.py docs/gitlab/pending-publish.json`"

If `<target-dir>/pending-publish.json` does not exist yet, create it with just this file
(paths relative to `<service-path>`).
If it already exists, append the new file to the `issues` array.
