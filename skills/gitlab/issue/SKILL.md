---
name: gitlab-issue
description: Creates structured GitLab issues in Italian and publishes them via glab. Use when opening a bug, feature, technical-debt, or documentation issue, or when dispatched from the gitlab skill.
---

# Skill: GitLab issue

Creates structured GitLab issues in Italian, ready to publish via `glab issue create`.

Do not apply the `doc-standard` skill. GitLab artifacts follow the templates in `../assets/`.

---

## Issue types

| Type | Template | Default label |
| --- | --- | --- |
| `bug` | [assets/issue-bug.md](../assets/issue-bug.md) | `bug` |
| `feature` | [assets/issue-feature.md](../assets/issue-feature.md) | `feature` |
| `technical-debt` | [assets/issue-technical-debt.md](../assets/issue-technical-debt.md) | `type::technical-debt` |
| `documentation` | [assets/issue-documentation.md](../assets/issue-documentation.md) | `documentation` |

Default labels are indicative. If the user specifies different labels or the project uses different
scoped labels, apply those instead.

---

## Workflow

### 0. Locate the repository root

Before running any `glab` command, determine the git repository root for the service being
discussed. Use the file open in the IDE, the service path from context, or ask once if unclear.

```bash
git -C <service-path> rev-parse --show-toplevel
```

Store the result as `$REPO_ROOT`. Prefix **every** subsequent `glab` (and `git`) command with
`cd "$REPO_ROOT" &&` — never run `glab` from an arbitrary working directory.

### 1. Identify the type

The user must specify the type. If missing, ask once:

> "Che tipo di issue vuoi aprire? bug / feature / technical-debt / documentation"

### 2. Load the template

Read only the template for the chosen type. Do not read the others.

### 3. Gather context

Run silently — no intermediate output. Everything feeds into the draft.

**From git (always):**

```bash
git log --oneline -20
git diff HEAD
```

For `bug` and `technical-debt`, also run:

```bash
git blame <file> -L <start>,<end>
```

**From the codebase:**

Use Read, Grep, Glob to open relevant files, resolve symbol references to exact `file:line`
locations, and collect code snippets. Include 5–20 lines per snippet with `path/file.ext` line N.

### 3b. Suggest milestone

```bash
cd "$REPO_ROOT" && glab milestone list --state active
```

Select the most relevant active milestone. If none applies, leave blank.
Show the choice in the draft gate.

### 4. Apply diagram policy

| Issue type | Diagram | Condition |
| --- | --- | --- |
| `bug` | `sequenceDiagram` | When ≥ 2 actors / goroutines / components are involved |
| `technical-debt` | `sequenceDiagram` | When describing a call chain or problematic flow |
| `feature` | `flowchart` (optional) | Only when the proposal already has a defined flow |
| `documentation` | None | Never by default |

Mermaid labels: descriptive names in Italian, code identifiers in English.

### 4b. Naming convention — titolo

Apply this rule before drafting the title:

```text
<componente>: <descrizione del problema o obiettivo>
```

- **Lingua:** italiano; identificatori di codice (struct, package, funzioni) in inglese
- **Formato:** nominale/descrittivo — non imperativo
- **Lunghezza:** massimo 72 caratteri
- **Componente:** area tecnica o modulo coinvolto
  - identificatore di codice → inglese (es. `ServiceExecutor`, `go.mod`)
  - area funzionale → italiano (es. `autenticazione`, `scraper AWS`)
  - preferibilmente non il nome del servizio/repository (già espresso da label/milestone); accettabile se non esiste un componente più specifico
- **Nessun prefisso** per tipo o servizio: sono gestiti da label e milestone

Esempi:

| Tipo | Titolo |
| --- | --- |
| `bug` | `ServiceExecutor: goroutine leak in RunServices senza recover` |
| `bug` | `Elasticsearch client: connessione non chiusa alla shutdown` |
| `feature` | `Inventory API: filtro risorse per tag cloud` |
| `technical-debt` | `go.mod: dipendenze non aggiornate a Go 1.22` |
| `technical-debt` | `ConfigLoader: accoppiamento diretto a viper senza interfaccia` |
| `documentation` | `aws-scraper: README mancante per setup locale` |

### 5. Draft gate

Show the complete draft in chat. Do NOT publish yet. Ask for explicit confirmation:

> "Bozza pronta. Procedo a creare l'issue su GitLab con titolo '`<title>`', label `<label>`,
> milestone `<milestone|nessuna>`? (si/modifiche/annulla)"

Apply requested changes and show the draft again. Repeat until approved.

### 6. Publish

After explicit approval:

1. Write the approved draft to `/tmp/issue-<type>-<slug>.md`
   (slug = first 5–7 tokens of the title, kebab-case)
2. Run:

```bash
cd "$REPO_ROOT" && glab issue create \
  --title "<title>" \
  --label "<label>" \
  --milestone "<milestone>" \
  --description "$(cat /tmp/issue-<type>-<slug>.md)"
```

3. Return the created issue URL.

---

## glab CLI rules

- Use `--description`, NOT `--body` (`--body` is a `gh` flag, not a `glab` flag).
- For descriptions containing backticks or `$`: always use `$(cat /tmp/file.md)`.
- To add a comment: `glab issue note`, NOT `glab issue comment`.
- Never include "Aprire una Merge Request" in any issue activities checklist.
