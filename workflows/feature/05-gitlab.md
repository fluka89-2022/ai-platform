# Workflow: Feature GitLab (Step 5 of 6)

## Purpose

Create GitLab issues from the implementation plan and set up the feature branch.

## Prerequisites

- `implementation-plan.md` exists and is approved.
- GitLab access is configured (token, `glab` CLI or API access).

## Input

Read `[project]-docs/features/[feature-slug]/implementation-plan.md`.
Invoke the `gitlab` skill for team GitLab conventions.

## Process

### 1. Confirm target project

Ask the user:
- Which GitLab project(s) will these issues be created in? (Some stories may span multiple services.)
- Which milestone or iteration should they be assigned to?
- Which labels should be applied?

Do not create anything until this is confirmed.

### 2. Prepare issues

For each story in the implementation plan, draft a GitLab issue:

**Title**: `[Story title from plan]`

**Description**:
```
## Context
[One paragraph from the implementation plan summarizing this story]

## Acceptance Criteria
[Copied from the implementation plan]

## Tasks
[Copied from the implementation plan]

## Links
- Functional Spec: [link to functional-spec.md in docs repo]
- Technical Design: [link to technical-design.md in docs repo]
- Implementation Plan: [link to implementation-plan.md in docs repo]
```

**Labels**: follow team conventions from the `gitlab` skill.

Show the draft issues to the user before creating them. Confirm the content and target project.

### 3. Create issues

Create issues one at a time. After each one:
- Show the created issue URL.
- Note the issue number (needed for branch naming and cross-references).

Update the implementation plan with the issue numbers/links after creation.

### 4. Set up the feature branch

Following the branch naming convention from the `gitlab` skill, create the feature branch in the primary service repo.

Confirm the branch name with the user before creating.

If the feature spans multiple repos, discuss which repo gets the feature branch (typically the "entry point" service).

### 5. Update the implementation plan

Add GitLab issue numbers/URLs to the implementation plan document.
Write the updated file.

### 6. Stop and report

List all created issues with their URLs. Then:

> "GitLab issues and branch are set up. Here's a summary:
> [list of issues]
> Branch: [branch-name]
>
> When you're ready to start implementing, run `/feature:develop [story-title or issue-number]` to work on the first story."

## Output

→ GitLab issues created (links in implementation plan)
→ Feature branch created
→ `implementation-plan.md` updated with issue references
