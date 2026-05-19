# GitLab Resolve Skill — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Creare la skill `skills/gitlab/resolve.md` che implementa una issue GitLab esistente con routing automatico (percorso breve o lungo) basato sulle label, e aggiornare la dispatch table in `skills/gitlab.md`.

**Architecture:** Una sub-skill nella famiglia `skills/gitlab/`, analoga a `issue.md` e `mr.md`. Non invoca i workflow `feature:*` — è self-contained per issue singole già definite. Routing basato su label GitLab: `bug/fix/chore/technical-debt` → percorso breve (con piano da task esistenti se presenti); `feature` → percorso lungo con design inline.

**Tech Stack:** Markdown, YAML frontmatter, `glab` CLI, `git`.

---

## File map

| Azione | File |
|---|---|
| Create | `skills/gitlab/resolve.md` |
| Modify | `skills/gitlab.md` (tabella "Artifact authoring") |

---

### Task 1: Creare `skills/gitlab/resolve.md`

**Files:**
- Create: `skills/gitlab/resolve.md`

- [ ] **Step 1: Scrivere il file**

Creare `skills/gitlab/resolve.md` con questo contenuto esatto:

```markdown
---
name: gitlab-resolve
description: Use when starting work on an existing GitLab issue — reads the issue, routes to short path (bug/fix/chore) or long path (feature/technical-debt) based on labels, implements with TDD, and commits. Dispatched from the gitlab skill.
---

# Skill: GitLab resolve issue

Implementa una issue GitLab esistente, dal branch al commit. Routing automatico basato sulle label.

Non invocare i workflow `feature:*` (riservati al ciclo completo a 6 step con documenti nel repo docs).

---

## 1. Risoluzione del numero di issue

In ordine di priorità:

1. Argomento esplicito (es. `/resolve 42`).
2. Branch corrente: estrai `NNN` dal pattern `type/NNN-description`.
   ```bash
   git branch --show-current
   ```
3. Se nessuno dei due è disponibile: chiedi all'utente.

Leggi l'issue:

```bash
glab issue view <N> --comments=false
```

---

## 2. Classificazione e routing

Leggi le label dell'issue e scegli il percorso:

| Label | Percorso |
|---|---|
| `bug`, `type::fix`, `type::chore`, `type::technical-debt` | Breve |
| `feature` | Lungo |
| Assente / non riconosciuta | Chiedi: "Percorso breve (fix diretta) o lungo (con design)?" |

Prima di procedere, annuncia la scelta:

> "Issue #N classificata come `<label>` → percorso <breve|lungo>. Procedo?"

---

## 3. Percorso breve (bug / fix / chore / technical-debt)

### 3.1 Branch

Se non sei già su un branch corrispondente, crealo:

```bash
git checkout -b fix/N-short-description    # bug / fix
git checkout -b chore/N-short-description  # chore / technical-debt
```

Mostra il nome proposto e attendi conferma prima di crearlo.

### 3.2 Esplorazione del codice

Leggi i file referenziati nell'issue (stack trace, path, simboli). Usa Read, Grep, Glob silenziosamente — nessun output intermedio.

### 3.3 Piano di esecuzione (se le attività sono già elencate)

Dopo aver letto l'issue, verifica se contiene una lista di attività/task (checklist, elenco puntato, sezione "Tasks" o simile).

**Se le attività sono presenti:**

Deriva da esse un piano ordinato e mostralo all'utente:

> "Ho trovato le seguenti attività nell'issue. Ecco il piano:
>
> 1. [task 1]
> 2. [task 2]
> …
>
> Procedo con questo piano? (si/modifiche/annulla)"

Attendi approvazione esplicita. Poi implementa ogni task seguendo TDD (§ 3.4).

**Se le attività non sono presenti:**

Procedi direttamente con TDD (§ 3.4), derivando i task dai criteri di accettazione.

### 3.4 Implementazione TDD

Per ogni task:

1. Scrivi il test in rosso (failing).
2. Eseguilo e verifica che fallisca.
3. Scrivi l'implementazione minima per farlo passare.
4. Refactor senza cambiare comportamento.
5. Chiedi conferma prima del task successivo:
   > "Task [n] completato: `[test name]` passa. Continuo con il task [n+1]?"

### 3.5 Completion checklist

Prima di dichiarare l'issue risolta:

- [ ] Ogni criterio di accettazione / task ha un test corrispondente.
- [ ] Tutti i test passano.
- [ ] Nessun errore `go vet`.
- [ ] Nessun codice morto o artefatto di debug.

### 3.6 Commit

Un commit per task:

```bash
git commit -m "fix: <descrizione> (closes #N)"      # bug / fix
git commit -m "refactor: <descrizione> (closes #N)" # chore / technical-debt
```

---

## 4. Percorso lungo (feature)

### 4.1 Branch

```bash
git checkout -b feature/N-short-description
```

Mostra e attendi conferma prima di creare.

### 4.2 Design tecnico (inline)

Produci in chat:

- Componenti coinvolti e loro responsabilità.
- Schema delle modifiche principali (file, interfacce, strutture dati).
- Diagramma Mermaid se ≥ 2 attori / goroutine / componenti sono coinvolti.

Attendi approvazione esplicita prima di continuare.

### 4.3 Piano di implementazione (inline)

Lista ordinata di task derivata dai criteri di accettazione dell'issue. Non viene scritta su file.

### 4.4 Esecuzione TDD

Identica al percorso breve §§ 3.4–3.5.

### 4.5 Commit

```bash
git commit -m "feat: <descrizione> (related to #N)"
```

---

## glab CLI rules

- Usa `--comments=false` quando leggi le issue (evita rumore).
- Per aggiungere un commento: `glab issue note`, NON `glab issue comment`.
- Usa `--description`, NON `--body` (`--body` è un flag di `gh`, non di `glab`).
```

- [ ] **Step 2: Verificare che il file esista e sia leggibile**

```bash
cat skills/gitlab/resolve.md | head -5
```

Output atteso: le prime righe del frontmatter YAML (`---`, `name: gitlab-resolve`, ...).

- [ ] **Step 3: Commit**

```bash
git add skills/gitlab/resolve.md
git commit -m "feat: add gitlab-resolve skill for implementing existing issues"
```

---

### Task 2: Aggiornare `skills/gitlab.md`

**Files:**
- Modify: `skills/gitlab.md` (sezione "Artifact authoring", tabella)

- [ ] **Step 1: Leggere il file**

```bash
cat skills/gitlab.md
```

Individuare la tabella nella sezione `## Artifact authoring`:

```markdown
| Artifact | Sub-skill |
| --- | --- |
| Issue (bug / feature / technical-debt / documentation) | `skills/gitlab/issue.md` |
| Merge request | `skills/gitlab/mr.md` |
| Milestone | `skills/gitlab/milestone.md` |
```

- [ ] **Step 2: Aggiungere la riga per `resolve`**

Sostituire la tabella con:

```markdown
| Artifact | Sub-skill |
| --- | --- |
| Issue (bug / feature / technical-debt / documentation) | `skills/gitlab/issue.md` |
| Merge request | `skills/gitlab/mr.md` |
| Milestone | `skills/gitlab/milestone.md` |
| Resolve existing issue | `skills/gitlab/resolve.md` |
```

- [ ] **Step 3: Verificare la modifica**

```bash
grep -A 6 "Artifact authoring" skills/gitlab.md
```

Output atteso: tabella con 4 righe, inclusa `Resolve existing issue`.

- [ ] **Step 4: Commit**

```bash
git add skills/gitlab.md
git commit -m "chore: add resolve sub-skill to gitlab dispatch table"
```

---

### Task 3: Baseline test (RED — senza skill)

Verifica che senza la skill un agente non segua il flusso corretto.

**Files:** nessuno (test manuale con subagent)

- [ ] **Step 1: Scenario breve senza task (bug, no checklist)**

Aprire un nuovo subagente (sessione pulita, senza la skill caricata) e fornire questo prompt:

> "Devi risolvere una issue GitLab. L'issue #42 ha label `bug` e descrive: 'nil pointer in pkg/server/init.go alla riga 45 durante lo startup. Il server crasha se la config è nil.' Non ci sono attività elencate. Implementa la fix."

Documentare:
- Ha creato un branch `fix/42-...` chiedendo conferma?
- Ha scritto il test prima dell'implementazione?
- Ha usato commit `fix: ... (closes #42)`?

- [ ] **Step 2: Scenario breve con task presenti (technical-debt, checklist)**

> "Devi risolvere una issue GitLab. L'issue #55 ha label `type::technical-debt` e descrive: 'Refactoring del package config. Tasks: 1) Estrarre ConfigLoader in un'interfaccia, 2) Rimuovere le chiamate dirette a os.Getenv, 3) Aggiungere unit test per ConfigLoader.' Implementa."

Documentare:

- Ha rilevato la lista di task nell'issue?
- Ha mostrato un piano derivato da quei task e atteso approvazione?
- Ha implementato ogni task con TDD?
- Ha usato commit `refactor: ... (closes #55)`?

- [ ] **Step 3: Scenario lungo (feature)**

> "Devi lavorare su una issue GitLab. L'issue #77 ha label `feature` e descrive: 'Aggiungere autenticazione OAuth2 via GitLab. Acceptance criteria: l'utente può fare login con il suo account GitLab, il token viene salvato in sessione, il logout revoca il token.' Inizia a implementarla."

Documentare:
- Ha prodotto un design tecnico prima di scrivere codice?
- Ha elencato un piano di task e atteso approvazione?
- Ha usato TDD?
- Ha usato commit `feat: ... (related to #77)`?

- [ ] **Step 4: Documentare le lacune**

Annotare ogni comportamento mancante. Questi sono i punti che la skill deve coprire.

---

### Task 4: Verification test (GREEN — con skill)

Verifica che con la skill caricata un agente segua il flusso corretto.

**Files:** nessuno (test manuale con subagent)

- [ ] **Step 1: Ripetere lo scenario breve con la skill**

Aprire un subagente con la skill `skills/gitlab/resolve.md` disponibile e ripetere il prompt del Task 3 Step 1.

Verificare che:
- [ ] Annunci "Issue #42 classificata come `bug` → percorso breve. Procedo?"
- [ ] Proponga branch `fix/42-nil-pointer-startup` (o simile) e attenda conferma
- [ ] Scriva il test prima dell'implementazione
- [ ] Usi commit `fix: <descrizione> (closes #42)`

- [ ] **Step 2: Ripetere lo scenario lungo con la skill**

Ripetere il prompt del Task 3 Step 2.

Verificare che:
- [ ] Annunci "Issue #77 classificata come `feature` → percorso lungo. Procedo?"
- [ ] Produca un design tecnico e attenda approvazione
- [ ] Elenchi i task dal piano prima di scrivere codice
- [ ] Usi commit `feat: <descrizione> (related to #77)`

- [ ] **Step 3: Se un test fallisce**

Se un comportamento atteso non si verifica, identificare quale sezione della skill è insufficiente e aggiornare `skills/gitlab/resolve.md` per coprire la lacuna. Poi ripetere il test.

- [ ] **Step 4: Commit finale (se modifiche alla skill)**

```bash
git add skills/gitlab/resolve.md
git commit -m "fix: strengthen gitlab-resolve skill based on test results"
```
