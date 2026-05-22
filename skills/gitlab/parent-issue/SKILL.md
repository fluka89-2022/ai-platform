---
name: gitlab-parent-issue
description: Creates a parent issue that groups existing GitLab issues under a single review artifact. Use when the user wants to group issues for feature planning or audit remediation, or when dispatched from the gitlab skill.
---

# Skill: GitLab parent issue

Crea una issue padre che raggruppa issue GitLab esistenti sotto un unico artefatto di revisione.
La issue padre è destinata al responsabile degli sviluppi: fornisce una visione d'insieme delle
issue correlate senza richiedere la lettura di ognuna.

Non applicare la skill `doc-standard`. Gli artefatti GitLab seguono i template in `../assets/`.

---

## Quando usarla

- Pianificazione feature: una funzionalità richiede più issue di implementazione coordinate.
- Risoluzione criticità da audit: un audit ha prodotto più findings da gestire insieme.

---

## Input

L'utente deve fornire:

1. **Numeri delle issue figlie**: lista dei numeri delle issue da raggruppare (es. `#42 #43 #47`).
2. **Frase di contesto**: breve descrizione del motivo del raggruppamento (usata per proporre l'AMBITO).

Se uno dei due manca, chiedere una sola volta prima di procedere.

---

## Workflow

### 0. Individuare il repository root

Prima di eseguire qualsiasi comando `glab`, determinare la root del repository git.

```bash
git -C <service-path> rev-parse --show-toplevel
```

Memorizzare il risultato come `$REPO_ROOT`. Prefissare ogni comando `glab` con `cd "$REPO_ROOT" &&`.

### 1. Fetch delle issue figlie

Per ogni numero di issue fornito:

```bash
cd "$REPO_ROOT" && glab issue view <N> --output json
```

Estrarre per ogni issue:
- `iid`: numero dell'issue
- `title`: titolo
- `web_url`: URL completo
- `labels`: lista label (usata per derivare la severità)
- `description`: primi 120 caratteri, usati come descrizione sintetica

### 2. Derivazione della severità

Cercare nelle label di ogni issue:
- `severity::alta`, `severity::media`, `severity::bassa`
- `priority::high` → `alta`, `priority::medium` → `media`, `priority::low` → `bassa`

Se nessuna label corrisponde per una o più issue, raccogliere tutti i casi mancanti e chiedere in un unico messaggio:

> "Le issue #NNN, #MMM non hanno un label di severità. Che severità assegni? (alta / media / bassa per ciascuna)"

Se l'utente non fornisce risposta per una issue, lasciare la cella severità vuota e continuare.

### 3. Proposta AMBITO

Derivare un valore dalla frase di contesto fornita dall'utente. Valori predefiniti:

| Valore | Contesto tipico |
| --- | --- |
| `FEATURE` | Pianificazione di una nuova funzionalità |
| `AUDIT` | Criticità emerse da un audit |
| `SECURITY` | Vulnerabilità o hardening di sicurezza |
| `HOTFIX` | Hotfix multipli correlati urgenti |
| `FIX` | Correzioni correlate non urgenti |
| `TEST` | Attività di copertura test coordinate |
| `OBSERVABILITY` | Interventi di osservabilità (logging, metriche, tracing) |
| `CONCURRENCY` | Problemi o refactoring di concorrenza |
| `IMPROVEMENT` | Miglioramenti funzionali o di processo non legati a una singola feature |
| `CODEQUALITY` | Interventi di qualità del codice (refactoring, lint, naming, struttura) |

Proporre il valore e chiedere conferma:

> "Per questo raggruppamento propongo l'ambito `[FEATURE]`. Va bene o preferisci un altro valore?"

L'utente può confermare o fornire un valore alternativo, incluso un valore libero.

### 3b. Proposta milestone

```bash
cd "$REPO_ROOT" && glab milestone list --state active
```

Selezionare la milestone attiva più pertinente. Mostrare la scelta nel draft gate.
Se nessuna milestone è pertinente, lasciare il campo vuoto.

### 4. Convention del titolo

Il titolo della issue padre segue lo schema:

```
[<AMBITO>]: <descrizione>
```

- `AMBITO`: il valore validato al passo 3, in maiuscolo, tra parentesi quadre.
- `descrizione`: in italiano, nominale/descrittiva, massimo 60 caratteri. Esprime l'obiettivo
  del gruppo, non elenca le issue figlie. Identificatori di codice in inglese.

Esempi:

| Contesto | Titolo |
| --- | --- |
| Pianificazione feature | `[FEATURE]: gestione inventory multi-cloud` |
| Criticità da audit | `[AUDIT]: vulnerabilità autenticazione API` |
| Hotfix correlati | `[HOTFIX]: instabilità aws-scraper in produzione` |

### 5. Draft gate

Compilare il template `../assets/issue-group.md` con i dati raccolti.

Mostrare la bozza completa in chat. Non pubblicare ancora. Chiedere conferma esplicita:

> "Bozza pronta. Procedo a creare la issue padre su GitLab con titolo '`<title>`',
> label `type::parent`, milestone `<milestone|nessuna>`? (si/modifiche/annulla)"

Applicare le modifiche richieste e mostrare nuovamente la bozza. Ripetere fino all'approvazione.

### 6. Pubblicazione

Dopo l'approvazione esplicita:

1. Scrivere la bozza approvata in `/tmp/issue-group-<slug>.md`
   (slug = primi 5–7 token del titolo senza parentesi, kebab-case).
2. Eseguire:

```bash
cd "$REPO_ROOT" && glab issue create \
  --title "[<AMBITO>]: <descrizione>" \
  --label "type::parent" \
  --milestone "<milestone>" \
  --description "$(cat /tmp/issue-group-<slug>.md)"
```

3. Restituire l'URL della issue padre creata.

### Label

La skill propone il label `type::parent`. Se il progetto non usa label scoped, proporre `parent`.
L'utente può sostituirlo nel draft gate.
Il comando `glab issue create` al passo 6 usa il label approvato nel draft gate.

---

## Regole glab CLI

- Usare `--description`, non `--body` (`--body` è un flag di `gh`, non di `glab`).
- Per descrizioni con backtick o `$`: sempre `$(cat /tmp/file.md)`.
- Per aggiungere un commento: `glab issue note`, non `glab issue comment`.
- Mai includere "Aprire una Merge Request" nella lista delle Attività.
