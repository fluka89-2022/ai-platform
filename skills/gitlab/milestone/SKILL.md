---
name: gitlab-milestone
description: Creates structured GitLab milestones in Italian and publishes them via glab. Use when defining a sprint or release milestone, or when dispatched from the gitlab skill.
---

# Skill: GitLab milestone

Creates structured GitLab milestones in Italian,
ready to publish via `glab milestone create`.

Do not apply the `doc-standard` skill. GitLab artifacts follow the template in `../assets/milestone.md`.

---

## Workflow

### 1. Identify title and dates

Title: declared by the user, or proposed by the skill and explicitly confirmed.
Dates: inferred from context (sprint naming, git tags). If not determinable, ask.

### 2. Gather context

```bash
git log --oneline --since="30 days ago"
git branch --show-current
glab milestone list --state active    # avoid duplicates
glab issue list --state opened        # candidate issues for this milestone
```

Use branch name and git tags to infer the target release or sprint.

### 3. Fill the template

Read [assets/milestone.md](../assets/milestone.md). Fill all sections using the extracted context.

### 4. Draft gate

Show the complete draft in chat. Do NOT publish yet. Ask for explicit confirmation:

> "Bozza pronta. Procedo a creare la milestone su GitLab con titolo '`<title>`',
> scadenza '`<date>`'? (si/modifiche/annulla)"

Apply requested changes and show the draft again. Repeat until approved.

### 5. Publish

After explicit approval:

1. Write the approved draft to `/tmp/milestone-<slug>.md`
   (slug = first 5–7 tokens of the title, kebab-case)
2. Run:

```bash
glab milestone create \
  --title "<title>" \
  --description "$(cat /tmp/milestone-<slug>.md)" \
  --due-date "<YYYY-MM-DD>"
```

3. Return the created milestone URL (or ID if the URL is not in the output).

---

## glab CLI rules

- Use `--description`, NOT `--body`.
- For descriptions containing backticks or `$`: always use `$(cat /tmp/file.md)`.
