---
name: story-workflow
description: Orchestrates the full story-to-issues workflow (breakdown → draft → review → publish) with persistent state. Use whenever the user wants to run or resume the full pipeline for a story, even if they don't say "workflow" explicitly. Triggers on: "gestisci la story", "workflow per la story", "riprendi il workflow", "avvia il workflow", "crea i task per la story", any request to take a story all the way to GitLab issues.
---

# Story Workflow

You orchestrate the full pipeline for turning a GitLab story into published issues:

```
story-breakdown → issue-draft → [review] → publish_issues.py
```

State persists in `<microservice>/docs/workflow-<story-id>.json` — never committed to git.
Any session (or any team member) can resume from the last completed step by invoking this skill again.

---

## Step 1 — Identify the story

If the user provided a GitLab issue number, fetch it:
```bash
glab issue view <N>
```
Extract title, description, labels, milestone.

If the user provided free text, use it as-is. Set `story_id` to `null`.

## Step 2 — Identify the microservice

Ask the user:
> "A quale microservizio appartiene questa storia?"

List the available services from the workspace (see CLAUDE.md). Set `<service-path>` to the
selected path (e.g., `pk-watch/core/api-server`).

## Step 3 — Load or create state

Set `<state-file>` = `<service-path>/docs/workflow-<story-id>.json`.

**If `<state-file>` exists:**
- Read it
- Tell the user: "Workflow esistente trovato — riprendendo dallo step `<current-step>`."
- Jump to the current step (see Steps below)

**If not:**
- Ensure the directory and gitignore are ready:
  ```bash
  mkdir -p <service-path>/docs
  grep -q 'workflow-\*\.json' <service-path>/.gitignore 2>/dev/null || \
    echo 'docs/workflow-*.json' >> <service-path>/.gitignore
  ```
- Write the initial state file:
  ```json
  {
    "story_id": <id or null>,
    "story_title": "<title>",
    "microservice": "<service-path>",
    "step": "breakdown",
    "tasks": [],
    "drafts": [],
    "published": []
  }
  ```
- Proceed to step `breakdown`

---

## Steps

### `breakdown`

Follow the `story-breakdown` skill instructions to propose the task table.

When the user confirms, extract the full task list and update the state file:

```json
{
  "step": "draft",
  "story_title": "<confirmed title>",
  "tasks": [
    {
      "id": 1,
      "title": "...",
      "type": "feature",
      "labels": "...",
      "estimate": "S",
      "depends_on": null,
      "impacted": "..."
    }
  ]
}
```

Proceed to step `draft`.

### `draft`

Follow the `issue-draft` skill instructions using:
- Task list from `state.tasks`
- Target directory: `<service-path>/docs/gitlab/`
- Parent story: `state.story_id` (if not null)

After all drafts are created, update the state file:

```json
{
  "step": "review",
  "drafts": [
    "<service-path>/docs/gitlab/YYYY-MM-DD-<slug>.md"
  ]
}
```

Tell the user:
> "Bozze create in `<service-path>/docs/gitlab/`. Leggile e modificale, poi dimmi quali task vuoi pubblicare."

**Stop here. Wait for the user to name the tasks to approve.**

### `review`

When the user names which tasks to publish, build the approved list from `state.drafts`,
write the publish queue, update state, and run the script:

```json
{ "step": "publishing" }
```

```bash
# Write pending-publish.json with only the approved files
# IMPORTANT: run from <service-path> so glab resolves the correct GitLab project.
# Paths in pending-publish.json must be relative to <service-path> (e.g. docs/gitlab/task_9_foo.md).
cd /abs/path/to/<service-path> && \
  python /abs/path/to/workspace/ai-platform/skills/gitlab-track/scripts/publish_issues.py \
  docs/gitlab/pending-publish.json
```

After the script completes successfully, update state:

```json
{
  "step": "published",
  "published": [
    { "issue_url": "...", "branch": "..." }
  ]
}
```

Report the published issues to the user.

### `published`

The workflow is complete. Tell the user the summary and the state file location.
If the user wants to restart for a new iteration, delete the state file and begin again.

---

## State file schema

```json
{
  "story_id": 42,
  "story_title": "Add API key management",
  "microservice": "pk-watch/core/api-server",
  "step": "breakdown | draft | review | publishing | published",
  "tasks": [],
  "drafts": [],
  "published": []
}
```

The state file is written after each step completes. If Claude is interrupted mid-step,
the next session resumes from the last successfully written step.

## Gitignore rule

`docs/workflow-*.json` must be present in `<microservice>/.gitignore`.
Check and add it at initialization (step 3) — never skip this.
