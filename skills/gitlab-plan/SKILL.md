---
name: gitlab-plan
description: "GitLab milestone author. Use when the user asks to create, update, or close a GitLab milestone to organize work into time-boxed goals. Not for issues (→ gitlab-track) or merge requests (→ gitlab-review)."
user-invocable: true
license: MIT
metadata:
  author: codeskine
  version: "1.2.1"
  source: "https://github.com/codeskine/gitlab-workflow"
allowed-tools: Read Edit Write Glob Grep Bash(git:*) Bash(glab:*) Agent AskUserQuestion
---

# GitLab Plan — Milestone Author

Crea, aggiorna e chiude milestone GitLab via `glab`. Persona: Product Owner, PM o
Project Manager responsabile della pianificazione.

---

## Modalità

| Modalità | Trigger |
| --- | --- |
| **Create** | "crea una milestone", "nuova milestone", "nuovo sprint" |
| **Update** | "aggiorna la milestone", "modifica le date", "cambia il titolo" |
| **Close/Reopen** | "chiudi la milestone", "riapri la milestone" |

---

## Workflow: Create

### 1. Identificare titolo e date

L'utente deve fornire:
- **Titolo**: inferred from sprint name, git tags, or branches if not stated
- **Date** (start e due): infer from sprint cadence or git tag history; ask once if unavailable

```bash
glab milestone list --state active
git tag --sort=-creatordate | head -10
git log --oneline -10
```

Se titolo e date non sono deducibili, chiedere una sola volta.

### 2. Estrarre contesto (silenzioso)

Nessun output intermedio.

```bash
git log --oneline -20
glab milestone list --state active
```

### 3. Comporre la bozza

Leggere `assets/milestone.md` e compilare tutte le sezioni con il contesto estratto.
La descrizione deve contenere **almeno 2 frasi** sull'obiettivo del milestone.

### 4. Draft gate

Mostrare la bozza completa in chat. **Non pubblicare ancora.** Attendere conferma:

> "Bozza pronta. Procedo a creare la milestone su GitLab con titolo '`<title>`',
> date `<start>` → `<due>`? (sì/modifiche/annulla)"

Applicare le modifiche richieste e ripresentare fino ad approvazione.

### 5. Pubblicare

Dopo approvazione esplicita:

```bash
# Scrivere la descrizione su file temporaneo
cat > /tmp/milestone-<slug>.md << 'EOF'
<description>
EOF

glab milestone create \
  --title "<title>" \
  --start-date "<YYYY-MM-DD>" \
  --due-date "<YYYY-MM-DD>" \
  --description "$(cat /tmp/milestone-<slug>.md)"
```

Restituire l'URL della milestone creata.

### 6. Assegnare issue candidate (opzionale)

Dopo la creazione, chiedere se si vogliono assegnare issue candidate:

> "Vuoi assegnare issue esistenti a questa milestone? (sì/no)"

Se sì, elencare le issue con `workflow::ready` senza milestone e chiedere quali assegnare.

---

## Workflow: Update

```bash
glab milestone list --state active
```

Mostrare le milestone attive, chiedere quale modificare se non specificata.
Confermare le modifiche prima di eseguire:

```bash
glab milestone edit <id> [--title "..."] [--due-date "..."] [--description "..."]
```

Aggiornare **solo i campi modificati**.

---

## Workflow: Close/Reopen

```bash
glab milestone edit <id> --state close    # chiude
glab milestone edit <id> --state activate # riapre
```

Chiedere conferma esplicita prima di eseguire.
Dopo la chiusura, offrire di spostare le issue aperte alla milestone successiva o al backlog.

---

## Template

Vedi [assets/milestone.md](assets/milestone.md).
