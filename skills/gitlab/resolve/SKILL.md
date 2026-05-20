---
name: gitlab-resolve
description: Implements an existing GitLab issue with TDD, routing to a short path (bug/fix/chore/technical-debt) or long path (feature) by label. Use when resolving or starting work on an issue number, or when dispatched from the gitlab skill.
---

# Skill: GitLab resolve issue

Implements an existing GitLab issue, from branch to commit. Automatic routing based on labels.

Do NOT invoke `feature:*` workflows (reserved for the full 6-step cycle with documents in the docs repo).

---

## 1. Resolve the issue number

In priority order:

1. Explicit argument (e.g., `/resolve 42`).
2. Current branch: extract `NNN` from the `type/NNN-description` pattern.
   ```bash
   git branch --show-current
   ```
3. If neither is available: ask the user.

Read the issue:

```bash
glab issue view <N> --comments=false
```

---

## 2. Classify and route

Read the issue labels and choose the path:

| Label | Path |
|---|---|
| `bug`, `type::fix`, `type::chore`, `type::technical-debt` | Short |
| `feature` | Long |
| Missing / unrecognized | Ask: "Percorso breve (fix diretta) o lungo (con design)?" |

Before proceeding, announce the choice:

> "Issue #N classificata come `<label>` → percorso <breve|lungo>. Procedo?"

---

## 3. Short path (bug / fix / chore / technical-debt)

### 3.1 Branch

If not already on a matching branch, create one:

```bash
git checkout -b fix/N-short-description    # bug / fix
git checkout -b chore/N-short-description  # chore / technical-debt (both use the chore/ prefix)
```

Show the proposed name and wait for confirmation before creating it.

### 3.2 Explore the code

Identify all independent domains referenced in the issue (stack traces, paths, symbols, package names). If there are 2 or more independent domains, dispatch one `Explore` agent per domain **in parallel** using the `Agent` tool with `subagent_type=Explore`. Each agent gets:

- A focused scope (one file, one symbol, one package).
- A self-contained prompt with the relevant excerpt from the issue.
- A specific output request: "Report where X is defined and which files reference it."

Wait for all agents to return, then consolidate findings before proceeding.

If only one domain is referenced, use Read, Grep, Glob directly — no agents needed.

### 3.3 Execution plan (if tasks are already listed)

After reading the issue, check whether it contains a task list (checklist, bullet list, "Tasks" section, or similar).

**If tasks are present:**

Derive an ordered plan from them and show it to the user:

> "Ho trovato le seguenti attività nell'issue. Ecco il piano:
>
> 1. [task 1]
> 2. [task 2]
> …
>
> Procedo con questo piano? (si/modifiche/annulla)"

Wait for explicit approval. Then implement each task following TDD (§ 3.4).

**If no tasks are present:**

Proceed directly with TDD (§ 3.4), deriving tasks from the issue's acceptance criteria.

### 3.4 TDD implementation

For each task:

1. Write the failing test.
2. Run it and confirm it fails.
3. Identify which files need to change for the implementation.
   - If 2 or more files are **independent** (no shared state, no edit on the same file), dispatch one agent per file **in parallel** using the `Agent` tool. Each agent gets: the file path, the failing test as context, and a specific instruction ("add/change X so the test passes"). Agents must not touch the test file.
   - If only one file is involved, implement directly.
4. Run the test and confirm it passes.
5. Refactor without changing behavior.
6. Ask before moving to the next task:
   > "Task [n] completato: `[test name]` passa. Continuo con il task [n+1]?"

### 3.5 Completion checklist

Before declaring the issue resolved:

- [ ] Every acceptance criterion / task has a corresponding test.
- [ ] All tests pass.
- [ ] No linter/vet errors (run the project's linter or vet tool).
- [ ] No dead code or debug artifacts.

### 3.6 Commit and handoff

One commit per task. Intermediate commits use `related to #N`; only the final commit uses `closes #N`:

```bash
git commit -m "fix: <description> (related to #N)"      # intermediate — bug / fix
git commit -m "fix: <description> (closes #N)"          # final — bug / fix
git commit -m "refactor: <description> (related to #N)" # intermediate — chore / technical-debt
git commit -m "refactor: <description> (closes #N)"     # final — chore / technical-debt
```

After the final commit, prompt the user about opening a Merge Request:

> "Issue #N implementata. Vuoi aprire una MR? Se sì, usa `/gitlab mr` (skill `gitlab-mr`)."

---

## 4. Long path (feature)

### 4.1 Branch

```bash
git checkout -b feature/N-short-description
```

Show and wait for confirmation before creating.

### 4.2 Explore the code and produce the technical design

**Exploration (parallel):** Identify the independent components/packages mentioned in the issue. If there are 2 or more, dispatch one `Explore` agent per component **in parallel** using the `Agent` tool with `subagent_type=Explore`. Each agent gets a focused scope and returns: where the component is defined, its public interface, and which files reference it.

Wait for all agents to return, then consolidate findings.

**Technical design (inline):** Produce in chat:

- Components involved and their responsibilities.
- Main changes (files, interfaces, data structures).
- Mermaid diagram if ≥ 2 actors / goroutines / components are involved.

Wait for explicit approval before continuing.

### 4.3 Implementation plan (inline)

Check whether the feature issue contains a task list. If tasks are already listed, derive the plan from them. If not, derive an ordered task list from the issue's acceptance criteria.

Show the plan in chat. Do NOT start implementation until the user approves.

### 4.4 TDD execution

Identical to short path §§ 3.4–3.5.

### 4.5 Commit and handoff

Intermediate commits use `related to #N`; only the final commit uses `closes #N`:

```bash
git commit -m "feat: <description> (related to #N)"  # intermediate commits
git commit -m "feat: <description> (closes #N)"      # final commit
```

After the final commit, prompt the user about opening a Merge Request:

> "Feature #N implementata. Vuoi aprire una MR? Se sì, usa `/gitlab mr` (skill `gitlab-mr`)."

---

## glab CLI rules

- Use `--comments=false` when reading issues (reduces noise).
- To add a comment: `glab issue note`, NOT `glab issue comment`.
- Use `--description`, NOT `--body` (`--body` is a `gh` flag, not a `glab` flag).
