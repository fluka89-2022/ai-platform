# Workflow: Branch management

## Purpose

Create, update, and close Git branches following team conventions. Link branches to GitLab issues and prepare merge requests.

## Premise

This workflow operates on local and remote branches. Destructive operations (force push, deletion of shared branches) require explicit user confirmation.

## Supported operations

### A. Create a feature or fix branch

**When:** starting a story from the implementation plan, or opening a bug fix.

1. Make sure you are on an up-to-date `develop`:

   ```bash
   git checkout develop && git pull origin develop
   ```

2. Determine the branch name following the convention in the `gitlab` skill.
   Propose the name to the user before creating it:
   > "I propose the branch `[name]`. Do you confirm?"

3. Create and switch to the branch:

   ```bash
   git checkout -b [branch-name]
   ```

4. If a linked GitLab issue exists, include the number in the output:
   > "Branch `[name]` created. Reference issue: #[N]."

---

### B. Keep the branch up to date with `develop`

**When:** the branch has been alive for more than a day, or `develop` has received merges in the meantime.

Prefer rebase over merge to keep the history linear:

```bash
git fetch origin
git rebase origin/develop
```

If there are conflicts, resolve them one at a time. Do not use `git rebase --skip` without verifying that the skipped commits are genuinely irrelevant.

After the rebase, push with force-with-lease (safer than `--force`):

```bash
git push --force-with-lease origin [branch-name]
```

Request user confirmation before the force push:
> "The rebase is complete. A force push is needed to update the remote. Shall I confirm?"

---

### C. Prepare a merge request

**When:** the story is complete and tests pass.

1. Make sure the branch is up to date (see operation B).

2. Verify that tests pass:

   ```bash
   go test ./...
   golangci-lint run
   ```

3. Invoke the `gitlab` skill for the team's MR conventions.

4. Propose the MR title and description:
   - Title: consistent with the story/issue title.
   - Description: references the issue (`Closes #N`), lists the main changes.
   - Show the draft to the user before creating.

5. Create the MR via `glab`:

   ```bash
   glab mr create --title "[title]" --description "[description]" \
     --source-branch [branch-name] --target-branch develop
   ```

   Report the URL of the created MR.

---

### D. Delete a branch after merge

**When:** the MR has been merged and the branch is no longer needed.

```bash
# Local
git branch -d [branch-name]

# Remote (request confirmation first)
git push origin --delete [branch-name]
```

Request confirmation before deleting the remote branch:
> "Should I delete the remote branch `[name]`? This operation is not reversible without recovery from the reflog."

---

### E. Handle a conflicted branch

**When:** the rebase fails with non-trivial conflicts.

1. Identify the conflicted files:

   ```bash
   git status
   ```

2. Resolve conflicts **one file at a time**. For each file:
   - Read both versions of the conflict.
   - Propose the resolution to the user if the intent is unclear.
   - Do not choose `ours` or `theirs` automatically without understanding the reason for the conflict.

3. After each resolved file:

   ```bash
   git add [file]
   ```

4. Continue the rebase:

   ```bash
   git rebase --continue
   ```

5. If the situation is too complex, notify the user and propose aborting:

   ```bash
   git rebase --abort
   ```

   Do not proceed autonomously if the conflicts involve unclear business logic.

## Constraints

- Do not `git push --force` to `master` or `develop`. Report the error to the user.
- Do not delete remote branches without explicit confirmation.
- Do not create branches directly from `master` for normal features — always from `develop`.
- Do not commit credentials, tokens, or `.env` files with real values.
