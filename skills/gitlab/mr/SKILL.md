---
name: gitlab-mr
description: Creates structured GitLab merge request descriptions in Italian and publishes them via glab. Use when opening an MR or after implementing an issue, or when dispatched from the gitlab skill.
---

# Skill: GitLab merge request

Creates structured GitLab merge request descriptions in Italian,
ready to publish via `glab mr create`.

Do not apply the `doc-standard` skill. GitLab artifacts follow the template in `../assets/mr.md`.

---

## Workflow

### 1. Gather context

```bash
git branch --show-current
git log <base-branch>...HEAD --oneline
git diff <base-branch>...HEAD --stat
git diff <base-branch>...HEAD
```

Parse the branch name to extract the issue reference:

- `fix/123-description` → `Closes #123`
- `feature/456-name` → `Related to #456`

Infer the target branch:

```bash
git remote show origin | grep 'HEAD branch'
```

After inferring source and target branches, **always** ask for explicit confirmation before continuing:

> "Branch sorgente: `<current-branch>` → Branch destinazione: `<base-branch>`. Confermo e procedo? (si/modifica/annulla)"

Wait for approval before running any `git log` or `git diff` command.

For diffs with more than 20 files changed: limit snippets to the 3 most significant change areas.
Add a note in the draft: "diff ampio: evidenziati solo i punti critici".

Suggest milestone:

```bash
glab milestone list --state active
```

### 2. Fill the template

Read [assets/mr.md](../assets/mr.md). Fill all sections using the extracted context.

Include 5–20 line snippets for each significant change, with `path/file.ext` line N citation.

### 3. Draft gate

Show the complete draft in chat. Do NOT publish yet. Ask for explicit confirmation:

> "Bozza pronta. Procedo a creare la MR su GitLab con titolo '`<title>`', label `<label>`,
> milestone `<milestone|nessuna>`? (si/modifiche/annulla)"

Apply requested changes and show the draft again. Repeat until approved.

### 4. Publish

After explicit approval:

1. Write the approved draft to `/tmp/mr-<slug>.md`
   (slug = first 5–7 tokens of the title, kebab-case)
2. Run:

```bash
glab mr create \
  --title "<title>" \
  --label "<label>" \
  --milestone "<milestone>" \
  --description "$(cat /tmp/mr-<slug>.md)" \
  --source-branch "<current-branch>" \
  --target-branch "<base-branch>"
```

3. Return the created MR URL.

---

## glab CLI rules

- Use `--description`, NOT `--body` (`--body` is a `gh` flag, not a `glab` flag).
- For descriptions containing backticks or `$`: always use `$(cat /tmp/file.md)`.
- To add a comment: `glab mr note`, NOT `glab mr comment`.
