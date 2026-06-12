---
name: gitlab
description: Configures team GitLab conventions and dispatches to sub-skills for issues, merge requests, milestones, and issue resolution. Use for GitLab artifacts, branch naming, glab workflows, or when the user mentions issues, MRs, or milestones.
---

# GitLab Skill

<!-- STUB — fill in team-specific configuration before using this skill -->

## Instance

<!-- TODO:
     - GitLab URL (e.g., https://gitlab.yourcompany.com)
     - Authentication method (PAT, OAuth, SSH)
     - How developers store/access their tokens
-->

## Groups and projects

<!-- TODO:
     - Top-level group structure
     - Which groups contain service repos vs docs repos?
     - Naming convention for project slugs
-->

## Branch conventions

Format with issue: `type/NNN-short-description`
Format without issue: `type/short-description`

Valid types: `feature`, `fix`, `hotfix`, `chore`, `release`

Rules:

- Lowercase only, hyphen separator (kebab-case).
- Description: 4-5 words max.
- Include `NNN` only when a GitLab issue exists; omit entirely otherwise (no placeholder).

Examples:

```text
feature/42-add-oauth-login
feature/add-oauth-login
fix/99-null-pointer-on-startup
fix/null-pointer-on-startup
hotfix/critical-memory-leak
chore/update-go-dependencies
release/1.4.0
```

MR parsing (used by the `gitlab-mr` skill):

- Branch with number → `Closes #NNN` (fix/hotfix) or `Related to #NNN` (feature)
- Branch without number → no automatic issue reference

## Issue conventions

<!-- TODO:
     - Labels in use (type::, priority::, team::, status::?)
     - Milestone usage policy
     - Linking issues to MRs (Closes #123, Related to #456)
-->

## Merge request conventions

<!-- TODO:
     - MR title format
     - Required reviewers / approval rules
     - CI pipeline requirements before merge
     - Draft MR usage policy
-->

---

## Artifact authoring

To create or publish GitLab artifacts, load the relevant sub-skill before proceeding.

| Artifact | Sub-skill (`Skill(...)`) |
| --- | --- |
| Issue (bug / feature / technical-debt / documentation) | `gitlab-issue` |
| Child issue (new issue linked to a parent) | `gitlab-child-issue` |
| Parent issue (group of related issues) | `gitlab-parent-issue` |
| Merge request | `gitlab-mr` |
| Milestone | `gitlab-plan` |
| Resolve existing issue | `gitlab-resolve` |

Each sub-skill defines the workflow, template reference, and glab CLI rules.
Apply team labels and conventions from the stub sections above once they are filled in.

---

## Interaction rules

1. Confirm the target project/group before creating anything.
2. Show a complete draft to the user before publishing (each sub-skill has a draft gate step).
3. Return the direct URL after every creation.
4. For bulk operations (e.g., creating multiple issues from a plan): create one at a time, confirm each.
