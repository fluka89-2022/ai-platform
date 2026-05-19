# ai-platform

Configurazione centralizzata di Claude Code per il team: regole, skill, workflow e comandi condivisi per i nostri microservizi Go.

---

## Setup workspace (nuovo sviluppatore)

### Prerequisiti

- [Claude Code](https://claude.ai/code) installato
- [glab CLI](https://gitlab.com/gitlab-org/cli) installato e configurato (`glab auth login --hostname <gitlab-host>`)
- I repo dei servizi clonati nella stessa directory workspace

### Struttura attesa del workspace

```
workspace/
├── ai-platform/          ← questo repo
├── service-[name]/       ← repo dei tuoi servizi
├── [project]-docs/       ← repo documentazione di progetto
└── CLAUDE.md             ← creato dallo script di setup
```

### Setup in 3 passi

**1. Clona questo repo nel tuo workspace:**

```bash
cd ~/workspace   # o dove tieni i tuoi repo
git clone <url-di-ai-platform>
```

**2. Esegui lo script di setup:**

```bash
./ai-platform/scripts/setup-workspace.sh
```

Lo script crea:
- `.claude/commands/` → symlink a `ai-platform/commands/` (i comandi slash)
- `.claude/settings.json` → da `scripts/settings.template.json` (permessi e plugin)
- `CLAUDE.md` → entry point del workspace

**3. Personalizza il tuo workspace:**

Apri `CLAUDE.md` e compila la lista dei servizi e del repo docs:

```markdown
# Workspace Configuration

@ai-platform/CLAUDE.md

## Services in this workspace
- service-payments/   — payment processing
- service-users/      — user management

## Documentation repo
- myproject-docs/
```

**4. Apri Claude Code nella directory workspace:**

```bash
claude .
```

I plugin (`superpowers@claude-plugins-official`, `cc-skills-golang@samber`) vengono installati automaticamente al primo avvio.

---

## Come funziona

### Regole (sempre in contesto)

Le regole sono caricate all'avvio tramite `CLAUDE.md → @rules/`:

| File | Contenuto |
|------|-----------|
| `rules/core.md` | Comportamento generale, comunicazione, qualità del codice |
| `rules/microservices.md` | Convenzioni specifiche dei nostri servizi Go |
| `rules/overrides/golang-conventions.md` | Le nostre scelte Go che si discostano dal plugin esterno |

### Skill (on demand)

Le skill vengono caricate dall'agente solo quando servono, **senza che tu le elenchi o le
referenzi manualmente**. Il meccanismo in due parti:

1. `CLAUDE.md` importa `@skills/INDEX.md` — l'indice viene caricato ad ogni sessione, così
   l'agente sa quali skill esistono e quando usarle.
2. `.claude/skills/` (symlink a `ai-platform/skills/`, creato da `setup-workspace.sh`) permette
   al plugin di trovare i file quando invoca `Skill("nome")`.

| Skill | Quando viene usata |
|-------|-------------------|
| `doc-standard` | Prima di scrivere qualsiasi documento Markdown |
| `technical-writing` | Analisi funzionali, spec, design, piani |
| `gitlab` | Interazione con la nostra istanza GitLab |
| `codebase-analysis` | Analisi di impatto, mappatura dipendenze |
| `go-audit` | Audit codice Go (sicurezza, qualità, performance) |
| `go-readme` | Scrittura README per servizi Go |
| Plugin `cc-skills-golang@samber` | Idiomi e pattern Go — caricato automaticamente |

### Pipeline feature

Il workflow principale è una pipeline a 6 step con approvazione umana ad ogni passaggio:

```
/feature:analyze   → functional-analysis.md   (brainstorming sul requisito)
/feature:describe  → functional-spec.md        (cosa costruiamo)
/feature:design    → technical-design.md       (come lo costruiamo)
/feature:plan      → implementation-plan.md    (stories e task)
/feature:gitlab    → issues + branch su GitLab
/feature:develop   → implementazione TDD, uno story alla volta
```

Ogni comando legge il documento prodotto dallo step precedente e si ferma chiedendo approvazione prima di passare al successivo.

### Altri comandi

| Comando | Uso |
|---------|-----|
| `/bugfix <descrizione>` | Diagnosi e fix di un bug con TDD |
| `/refactor <obiettivo>` | Refactoring senza cambiare comportamento |
| `/audit <componente>` | Audit codice Go: sicurezza, qualità, performance |
| `/benchmark <funzione>` | Benchmark e analisi performance |
| `/doc <tipo e componente>` | Generazione documentazione |
| `/branch <operazione>` | Gestione branch Git |
| `/plan <contesto>` | Planning di sprint o milestone |
| `/review [target]` | Code review strutturata |

---

## Aggiornare il workspace

Quando vengono aggiunti nuovi comandi o modificati i workflow:

```bash
cd ~/workspace
git -C ai-platform pull
./ai-platform/scripts/update-workspace.sh
```

Lo script aggiorna il symlink dei comandi. Non sovrascrive `settings.json` o `CLAUDE.md`.

---

## Struttura del repo

```
ai-platform/
├── CLAUDE.md                         ← entry point: importa le rules/
├── rules/
│   ├── core.md                       ← regole generali (sempre in contesto)
│   ├── microservices.md              ← convenzioni microservizi (sempre in contesto)
│   └── overrides/
│       └── golang-conventions.md    ← override rispetto al plugin Go
├── skills/
│   ├── INDEX.md                      ← indice skill (caricato via CLAUDE.md)
│   ├── doc-standard/SKILL.md
│   ├── technical-writing/SKILL.md
│   ├── codebase-analysis/SKILL.md
│   ├── go-audit/SKILL.md
│   ├── go-readme/SKILL.md
│   └── gitlab/
│       ├── SKILL.md
│       ├── assets/                   ← template issue/MR/milestone
│       ├── issue/SKILL.md
│       ├── mr/SKILL.md
│       ├── milestone/SKILL.md
│       └── resolve/SKILL.md
├── workflows/
│   ├── feature/                      ← 01-analyze ... 06-develop
│   ├── bugfix.md
│   ├── refactoring.md
│   └── planning.md
├── commands/                         ← slash commands (symlinked da workspace)
│   ├── feature/
│   └── bugfix.md, refactor.md, ...
├── templates/                        ← struttura dei documenti prodotti
│   ├── functional-analysis.md
│   ├── functional-spec.md
│   ├── technical-design.md
│   └── implementation-plan.md
└── scripts/
    ├── setup-workspace.sh
    ├── update-workspace.sh
    └── settings.template.json
```

---

## Contribuire a questo repo

Per modificare regole, skill o workflow:

1. Apri una MR con la modifica proposta.
2. Descrivi cosa cambia e perché (impatto sul comportamento di Claude).
3. Dopo il merge, avvisa il team: tutti devono eseguire `update-workspace.sh`.

I file contrassegnati come `<!-- STUB -->` attendono input dal team — vedi le issue di progetto.
