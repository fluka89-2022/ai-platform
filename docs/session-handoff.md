---
title: "Session handoff — ai-platform"
created: 2026-05-18
updated: 2026-05-18
status: active
tags: [handoff, progetto, decisioni, prossimi-step]
---

## Stato attuale del progetto

`ai-platform` è un repository centralizzato di configurazione Claude Code per un team Go a
microservizi. Contiene regole sempre in contesto (`CLAUDE.md` + `rules/`), skill caricate
su richiesta (`skills/`), workflow (`workflows/`), comandi (`commands/`), e template
(`templates/`).

Il repository è funzionale per il pipeline feature completo (`/feature:analyze` →
`/feature:develop`) e per i workflow di audit, benchmark, documentazione e GitLab.

---

## Decisioni prese

### Lingua dei file per agenti

Tutti i file consumati da Claude o agenti (regole, skill, workflow, comandi, template) sono
in inglese, compatti, specifici. I documenti prodotti per il team (spec, design, audit
report, README, CHANGELOG, tutto in `docs/`) restano in italiano.

### Separazione md-standard / md-italian

Le regole di formattazione Markdown sono state suddivise in due file:

- `rules/md-standard.md` — regole linguisticamente neutre (no emoji, stile, struttura,
  frontmatter, elementi di formattazione)
- `rules/md-italian.md` — supplemento italiano (lingua base, parole vietate in italiano,
  elementi che restano sempre in inglese)

Entrambi i file esistono su disco ma non sono caricati da `CLAUDE.md`.

### Skill on-demand per la documentazione

`rules/md-standard.md` e `rules/md-italian.md` sono stati unificati in un singolo skill
`skills/doc-standard.md`, caricato su richiesta prima di produrre qualsiasi file `.md`.
Questo mantiene il budget di contesto sempre-in-contesto sotto la soglia specificata
nell'analisi funzionale (Application Programming Interface (FA): ≤500 token).

Ogni skill e workflow che produce documenti include un'istruzione esplicita per caricare
`skills/doc-standard.md`.

### Integrazione gitlab-author-skills

Il pacchetto `experiment/_skills/gitlab-author-skills/` (originariamente formato npm per
Cursor) è stato adattato e integrato in ai-platform come skill interne. L'adattamento ha:

- rimosso le istruzioni npm/Cursor e il frontmatter `SKILL.md`
- convertito le istruzioni al pattern Claude Code (lettura on-demand)
- scritto le istruzioni per agenti in inglese
- mantenuto i template GitLab in italiano (output per il team)

---

## File creati

| file | descrizione |
| --- | --- |
| `skills/doc-standard.md` | Skill unificata per la scrittura di documenti Markdown |
| `rules/md-italian.md` | Supplemento italiano alle regole Markdown |
| `skills/gitlab.md` | Skill GitLab ristrutturata con dispatch table verso le sotto-skill |
| `skills/gitlab/issue.md` | Workflow creazione issue via `glab` |
| `skills/gitlab/mr.md` | Workflow creazione Merge Request (MR) via `glab` |
| `skills/gitlab/milestone.md` | Workflow creazione milestone via `glab` |
| `skills/gitlab/templates/issue-bug.md` | Template italiano per issue di tipo bug |
| `skills/gitlab/templates/issue-feature.md` | Template italiano per issue di tipo feature |
| `skills/gitlab/templates/issue-technical-debt.md` | Template italiano per debito tecnico |
| `skills/gitlab/templates/issue-documentation.md` | Template italiano per issue documentazione |
| `skills/gitlab/templates/mr.md` | Template italiano per Merge Request |
| `skills/gitlab/templates/milestone.md` | Template italiano per milestone |

---

## File modificati

| file | modifica |
| --- | --- |
| `CLAUDE.md` | Rimossi i riferimenti a `@rules/md-standard.md` e `@rules/md-italian.md` |
| `rules/core.md` | Aggiornato riferimento da `rules/md-standard.md` a `skills/doc-standard.md` |
| `rules/md-standard.md` | Rimossa sezione 1 (Lingua), rinumerazione sezioni, rimozione regole solo-italiane |
| `skills/INDEX.md` | Aggiunto `doc-standard.md`; voce GitLab espansa in 4 righe separate |
| `skills/technical-writing.md` | Aggiunta istruzione di caricamento `doc-standard.md`; rimossa sezione "Formatting Rules" ridondante con MD025 |
| `skills/go-audit.md` | Sostituita dipendenza da `rules/md-standard.md` con `skills/doc-standard.md` |
| `skills/go-readme.md` | Tutti i riferimenti a `rules/md-standard.md` → `skills/doc-standard.md` |
| `workflows/audit.md` | Step 4: applicare `skills/doc-standard.md` invece di `rules/md-standard.md` |
| `workflows/benchmark.md` | Step 7: caricare `skills/doc-standard.md` |
| `workflows/documentation.md` | Tutti i riferimenti aggiornati; rimosso commento "già in contesto" |

---

## Prossimi step

### Obbligatori per il funzionamento completo

1. **Completare `skills/gitlab.md`** — i stub di configurazione team bloccano
   `feature:gitlab` e `/plan`. Richiedono input dell'utente:
   - URL istanza GitLab e metodo di autenticazione
   - Struttura gruppi e progetti
   - Convenzioni di branch (formato nome, branch protetti)
   - Label in uso per issue e MR
   - Regole di approvazione e requisiti Continuous Integration (CI)

2. **Completare `rules/microservices.md`** — stub intenzionale, da popolare dopo aver
   testato ai-platform sui progetti esistenti.

3. **Completare `rules/overrides/golang-conventions.md`** — stub intenzionale, stessa
   motivazione.

### Miglioramenti identificati nell'analisi funzionale

4. **Aggiornare `README.md`** — la sezione "Struttura del repo" mostra un albero di file
   obsoleto: mancano `md-standard.md`, `md-italian.md`, `go-audit.md`, `go-readme.md`,
   `doc-standard.md`, la sotto-struttura `gitlab/`.

5. **Meccanismo di versioning** — l'analisi funzionale richiede che i progetti possano
   fissare una versione specifica di ai-platform. Nessun tag git o file di versione è stato
   implementato.

6. **`workflows/planning.md` senza output** — il workflow non produce nessun documento al
   termine. Nessun template associato.

7. **`commands/review.md` auto-contenuto** — l'unico comando con checklist inline invece
   di delegare a `workflows/`. Incoerente con il pattern degli altri comandi.

8. **`functinal_analisys.md`** — il file ha tre problemi: nome con typo, posizione errata
   (root invece di `docs/features/[feature-slug]/`), nessun frontmatter YAML.

### Non urgenti

9. **Verifica nomi plugin in `settings.template.json`** — il file usa
   `Skill(cc-skills-golang:golang-observability)` ma README e INDEX usano
   `cc-skills-golang@samber`. Verificare che il nome nella chiave `permissions` corrisponda
   alla registrazione effettiva del plugin.

---

## Convenzioni apprese

### Regole di caricamento skill

Le skill non sono in contesto di default. Prima di qualsiasi task specializzato, leggere
`skills/INDEX.md` per trovare la skill rilevante, poi leggere il file della skill.

Ogni skill o workflow che produce file Markdown include `Read skills/doc-standard.md`
come primo passo.

### Budget contesto sempre-in-contesto

L'analisi funzionale specifica ≤500 token per le regole sempre in contesto. La soglia
vincola quali contenuti possono stare in `CLAUDE.md` con la sintassi `@path`.

### Pattern draft gate per GitLab

Tutte le operazioni `glab` (issue, MR, milestone) seguono il pattern:
1. Raccogliere contesto da git e codebase
2. Riempire il template
3. Mostrare la bozza completa in chat
4. Attendere conferma esplicita dell'utente
5. Pubblicare via `glab`

L'utente conferma prima della pubblicazione. Nessuna eccezione.

### CLI `glab` vs `gh`

`glab issue create` usa `--description`, non `--body` (flag di `gh`). Per descrizioni
multi-riga, usare `$(cat /tmp/file.md)`. Per aggiungere commenti a issue esistenti,
usare `glab issue note`, non `glab issue comment`.

### Template GitLab non seguono doc-standard

I template in `skills/gitlab/templates/` hanno la propria formattazione italiana definita
dai commenti HTML interni. Non applicare `skills/doc-standard.md` a questi file.

### Diagrammi Mermaid per tipo issue

| tipo issue | diagramma |
| --- | --- |
| bug | `sequenceDiagram` quando ≥2 attori coinvolti |
| technical-debt | `sequenceDiagram` quando descrive una catena di chiamata |
| feature | `flowchart` opzionale, solo se il flusso è definito |
| documentation | nessun diagramma |

### Snippet di codice nei template GitLab

5–20 righe per snippet, con citazione `path/file.ext` riga N.
