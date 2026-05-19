# Memoria e Contesto in Claude Code
### Guida pratica per sviluppatori — con applicazione a ai-platform

**Versione:** 1.0  
**Lingua:** Italiano  

---

## Indice

1. [Il modello mentale fondamentale](#1-il-modello-mentale-fondamentale)
2. [I quattro livelli di memoria](#2-i-quattro-livelli-di-memoria)
3. [La finestra di contesto](#3-la-finestra-di-contesto)
4. [Strumenti di gestione](#4-strumenti-di-gestione)
5. [Strategie operative](#5-strategie-operative)
6. [Applicazione a ai-platform](#6-applicazione-a-ai-platform)
7. [Errori comuni da evitare](#7-errori-comuni-da-evitare)
8. [Riferimento rapido](#8-riferimento-rapido)

---

## 1. Il modello mentale fondamentale

Claude Code non ha memoria persistente tra sessioni nel senso tradizionale. Ogni sessione parte da zero — ma con un sistema di livelli che permettono di simulare la continuità.

Il modo corretto di pensarci:

> **Il contesto è una risorsa finita con rendimenti decrescenti.**  
> Più si riempie, peggio l'agente performa. Non è un problema di quantità di informazioni, ma di qualità del segnale che riesce a estrarre da esse.

Questo ha una conseguenza pratica immediata: **non è vero che "più contesto = agente più capace"**. Un agente con 20.000 token di contesto ben strutturato performa meglio di uno con 150.000 token di conversazione accumulata.

Il tuo obiettivo come sviluppatore è trovare il **set minimo di token ad alto segnale** che massimizza la qualità dell'output.

---

## 2. I quattro livelli di memoria

Claude Code usa un'architettura a quattro livelli, dal più prioritario al meno:

```
┌─────────────────────────────────────────────────┐
│  1. Enterprise Policy                           │  ← Regole organizzazione IT
├─────────────────────────────────────────────────┤
│  2. Project Memory  (CLAUDE.md)                 │  ← Istruzioni progetto/workspace
├─────────────────────────────────────────────────┤
│  3. Project Rules   (.claude/rules/)            │  ← Regole modulari per contesto
├─────────────────────────────────────────────────┤
│  4. User Memory     (~/.claude/CLAUDE.md)       │  ← Preferenze personali sviluppatore
└─────────────────────────────────────────────────┘
```

### Livello 1 — Enterprise Policy
Regole globali dell'organizzazione, massima priorità, non sovrascrivibili. Rilevante solo per setup aziendali gestiti centralmente.

### Livello 2 — Project Memory (CLAUDE.md)
Il file più importante. Claude Code lo cerca automaticamente nella directory corrente e in tutta la gerarchia verso l'alto. Supporta la sintassi `@path/to/file` per includere altri file — questo è il meccanismo che rende possibile ai-platform.

Regola pratica: **80–120 righe massimo**. Oltre quella soglia l'agente inizia a perdere istruzioni, non perché le ignori intenzionalmente, ma perché il budget di istruzioni è finito. Claude Code occupa già ~50 slot con il proprio system prompt interno — ne rimangono 100–150 per le tue istruzioni.

### Livello 3 — Project Rules (.claude/rules/)
File Markdown modulari in `.claude/rules/`. Supportano frontmatter con `globs` per applicarsi solo a certi file:

```markdown
---
globs: ["**/*.go", "**/go.mod"]
---
# Go Rules
...
```

Questo permette di caricare regole specifiche solo quando si lavora su file Go, non su file Markdown di documentazione. Efficiente e preciso.

### Livello 4 — User Memory (~/.claude/CLAUDE.md)
Preferenze personali dello sviluppatore: stile di comunicazione preferito, tool preferiti, shortcut. Non va nel repo, è locale alla macchina.

### Auto-memory
Claude Code mantiene note autonome in `~/.claude/projects/[path]/memory/`. Registra automaticamente pattern osservati nel codice, convenzioni inferite, dipendenze scoperte. Il comando `/memory` mostra tutto quello che ha imparato. **Non sprecare righe di CLAUDE.md per cose che Claude impara da solo dopo una sessione.**

---

## 3. La finestra di contesto

### Cos'è
La finestra di contesto contiene tutto ciò che Claude "vede" in un dato momento: l'intera cronologia della conversazione, ogni file letto, ogni output di comando, il system prompt interno, i tool. Non è una memoria — è la RAM della sessione corrente.

### Dimensioni disponibili (maggio 2026)
- **Pro / Max:** ~200.000 token
- **Team / Enterprise con Sonnet 4.6 e Opus 4.6:** fino a 1.000.000 token

### Il problema del context rot
Con l'aumentare dei token, la capacità dell'agente di richiamare informazioni dal contesto diminuisce — anche prima di raggiungere il limite fisico. Una sessione di debug con output verbosi può generare decine di migliaia di token irrilevanti che "diluiscono" le informazioni utili.

### Cosa consuma il contesto
In ordine di impatto tipico:

| Fonte | Impatto |
|---|---|
| Cronologia conversazione | Alto — cresce a ogni messaggio |
| File letti dall'agente | Alto — specialmente codebase grandi |
| Output di comandi | Medio — build log, test output |
| CLAUDE.md e regole | Basso se ben scritti |
| System prompt interno | Fisso ~50 slot istruzioni |

### Come misurarlo
```
/cost     → costo sessione + token usati + dimensione contesto
/context  → breakdown dettagliato per fonte (system, tools, memory, conversazione)
```

La barra di stato in fondo al terminale mostra la percentuale in tempo reale. **A 70% è il momento di agire.**

---

## 4. Strumenti di gestione

### /compact — compressione intelligente
Comprime la cronologia della conversazione in un riassunto ad alta fedeltà. L'agente continua nella stessa sessione con contesto ridotto.

```bash
/compact
# oppure con istruzioni su cosa preservare:
/compact Focus on the authentication migration decisions and current file state
```

Usalo **proattivamente**, non aspettare che scatti automaticamente. I momenti ideali:
- Dopo una fase di esplorazione/analisi, prima di iniziare l'implementazione
- Dopo una sessione di debug, una volta trovato il problema
- Prima di un task complesso, per massimizzare lo spazio disponibile
- Quando l'agente inizia a "dimenticare" istruzioni date poco prima

Puoi personalizzare il comportamento di `/compact` nel CLAUDE.md:
```markdown
When compacting, always preserve:
- List of modified files
- Current task and next steps
- Any test commands that were run
```

### /clear — reset completo
Azzera l'intera cronologia della conversazione. Il CLAUDE.md e le regole vengono rilette da capo. Usalo quando cambi task completamente o quando il contesto è troppo degradato per essere salvato.

```bash
/clear
```

### /compact parziale — con checkpoint
Puoi fare compaction parziale: `Esc + Esc` o `/rewind`, seleziona un checkpoint e scegli:
- **Summarize from here** — comprime da quel punto in avanti, mantiene il contesto precedente intatto
- **Summarize up to here** — comprime il passato, mantiene recente in full

### /btw — domande fuori contesto
Per domande rapide che non devono entrare nella cronologia:
```bash
/btw qual è la sintassi di errors.As in Go?
```
La risposta appare in un overlay e non viene mai aggiunta al contesto. Utile per consultazioni veloci senza sprecare token.

### Riprendere sessioni
```bash
claude --continue          # riprende la sessione più recente
claude --resume            # mostra lista sessioni da cui scegliere
/rename oauth-migration    # dai un nome descrittivo alla sessione corrente
```

Le sessioni sono salvate localmente. Trattale come branch: ogni workstream ha la sua sessione con il proprio contesto.

---

## 5. Strategie operative

### Sessioni focalizzate, non lunghe
Il nemico della qualità non è il numero di sessioni, è la sessione monolitica che accumula contesto. Una sessione per task specifico è sempre preferibile a una sessione dove si fa tutto.

Struttura consigliata:
```
Sessione 1: analisi e planning      → /compact prima di chiudere
Sessione 2: implementazione task A  → /compact prima di chiudere  
Sessione 3: implementazione task B  → /compact prima di chiudere
```

### I documenti come meccanismo di persistenza
Il modo più robusto per trasferire contesto tra sessioni non è la memoria di Claude — sono i **file prodotti durante il lavoro**. Un `technical-design.md` committato è leggibile, versionato e non soggetto a compaction lossy.

All'inizio di una nuova sessione:
```
Riprendi da docs/feature-x/technical-design.md
Siamo allo step 4 dell'implementation-plan.md
Il task corrente è [nome task nel piano]
```

### Il ciclo operativo di una sessione
```
Inizio sessione
  → claude --continue (o nuova sessione con contesto da file)

Ogni 30-45 minuti
  → /cost  (verifica token usati)
  → se > 70% → /compact Focus on [priorità]

Fine di una fase (analisi, debug, implementazione)
  → /compact prima di cambiare attività

Fine sessione
  → commit git (i file sono lo stato)
  → /compact con summary del lavoro fatto e prossimi step
```

### Subagenti per ricerca e analisi
Quando devi esplorare una codebase o fare ricerca su un problema complesso, usa i subagenti invece di fare tutto nella sessione principale:

```
Use a subagent to investigate how the authentication service handles 
token refresh, then report back a summary.
```

Il subagente legge i file in un context window separato e riporta solo il summary — la sessione principale non si appesantisce con centinaia di file letti.

---

## 6. Applicazione a ai-platform

### Come ai-platform gestisce il contesto

L'architettura di ai-platform è progettata esattamente intorno ai principi di gestione del contesto descritti sopra. Ogni scelta ha una motivazione precisa.

#### Il workspace CLAUDE.md è solo un dispatcher
```markdown
<!-- workspace/CLAUDE.md -->
@ai-platform/CLAUDE.md
@project-docs/CLAUDE.md

## Workspace
Questo workspace contiene [nome progetto].
```
Non contiene regole. Le regole vivono in ai-platform e vengono incluse con `@path`. Questo mantiene il file leggibile e la responsabilità separata.

#### ai-platform/CLAUDE.md importa solo le rules/
```markdown
<!-- ai-platform/CLAUDE.md -->
@ai-platform/rules/core.md
@ai-platform/rules/microservices.md
```
Le skill **non** vengono caricate all'avvio — vengono lette on-demand dall'agente quando `skills/INDEX.md` le indica come rilevanti. Questo è il meccanismo che mantiene basso il contesto di base.

#### Il budget di regole core
`rules/core.md` + `rules/microservices.md` insieme non devono superare **500 token**. È un vincolo di progettazione, non una raccomandazione. Ogni regola che aggiungi deve guadagnarsi il suo posto — se Claude la sa già o la inferisce dal codice, non va nel file.

#### Le skill come lazy loading
`skills/INDEX.md` è una mappa leggera (trigger → skill `name`) che l'agente consulta prima di ogni task complesso. Ogni skill è una cartella con `SKILL.md`; il contenuto viene caricato solo se pertinente. Questo è equivalente al lazy loading in programmazione: paghi il costo solo quando serve.

```markdown
<!-- skills/INDEX.md -->
## Skill index

| Trigger | Skill | File |
|---|---|---|
| analisi codebase, review sistematica | Codebase Analysis | Skill(`codebase-analysis`) |
| documento tecnico, spec, analisi funzionale | Technical Writing | Skill(`technical-writing`) |
| issue, branch, MR, GitLab | GitLab | Skill(`gitlab`) |
```

#### I documenti della pipeline come contesto persistente
Ogni step del workflow feature produce un documento committato. Questo è il meccanismo di persistenza più affidabile del sistema:

```
functional-analysis.md   → sopravvive a qualsiasi /compact o /clear
functional-spec.md       → è nel repo, è leggibile da tutti
technical-design.md      → è il punto di ripresa naturale tra sessioni
implementation-plan.md   → è il task board della sessione di sviluppo
```

All'inizio di ogni sessione di sviluppo, l'agente legge il documento dello step precedente come primo atto — il contesto è ricostruito in pochi secondi.

#### Sessioni per step di pipeline
Il workflow feature è naturalmente segmentato in sessioni:

```
/feature:analyze   → sessione dedicata → /compact → commit functional-analysis.md
/feature:describe  → nuova sessione → /compact → commit functional-spec.md
/feature:design    → nuova sessione → /compact → commit technical-design.md
...
```

Non c'è bisogno di mantenere il contesto dell'analisi quando stai scrivendo il codice — il documento è lì.

### CLAUDE.md dei singoli servizi
Il `CLAUDE.md` di ogni microservizio deve essere **breve e specifico**. Non ripetere le regole Go (ci pensa ai-platform). Devi solo dire:

```markdown
<!-- service-auth/CLAUDE.md -->
## Questo servizio
Gestisce autenticazione e autorizzazione. Espone gRPC internamente 
e REST esternamente.

## Struttura
- /cmd/server — entrypoint
- /internal/auth — logica di dominio
- /internal/transport — handler HTTP e gRPC

## Dipendenze critiche
- Dipende da: service-user (gRPC), PostgreSQL, Redis
- È dipendenza di: service-api-gateway, service-payments

## Convenzioni specifiche
[solo le eccezioni alle regole di ai-platform]
```

### Regola per i nuovi sviluppatori del team
Prima di iniziare qualsiasi sessione di lavoro su un progetto nuovo:

1. Esegui `ai-platform/scripts/setup-workspace.sh`
2. Leggi il `CLAUDE.md` del workspace per capire cosa è già in contesto
3. Leggi il `CLAUDE.md` del servizio su cui lavorerai
4. Inizia la sessione con: *"Leggi implementation-plan.md e dimmi qual è il primo task aperto"*

---

## 7. Errori comuni da evitare

**CLAUDE.md troppo lungo**  
Oltre 120 righe l'agente inizia a perdere istruzioni. Non è un bug, è un limite fisico del budget di istruzioni. Taglia senza pietà.

**Regole generiche che Claude sa già**  
*"Scrivi codice pulito"*, *"sii un senior engineer"*, *"pensa step by step"* non cambiano il comportamento. Occupano slot senza ritorno. Scrivi solo regole specifiche alle vostre scelte di team.

**Sessioni monolitiche**  
Una sessione di 4 ore che attraversa analisi, design e implementazione è inefficiente. Il contesto si degrada, l'agente inizia a fare errori che non farebbe a contesto pulito. Segmenta per fase.

**Affidarsi solo alla memoria dell'agente tra sessioni**  
La auto-memory è utile ma non affidabile per stato critico. I file committati sono lo stato canonico. Se è importante, mettilo in un documento.

**Non usare /compact proattivamente**  
Aspettare la compaction automatica significa lavorare con contesto degradato per molto tempo prima che scatti. A 70% di utilizzo, compatta manualmente con istruzioni su cosa preservare.

**Duplicare contesto tra livelli**  
Se una regola è in `rules/core.md`, non va ripetuta nel `CLAUDE.md` del workspace o del servizio. La duplicazione crea conflitti e spreca budget.

---

## 8. Riferimento rapido

### Comandi essenziali

| Comando | Quando usarlo |
|---|---|
| `/cost` | Ogni 30-45 min per monitorare i token |
| `/context` | Quando vuoi capire dove vanno i token |
| `/compact` | A 70% utilizzo o tra fasi diverse |
| `/compact [istruzioni]` | Quando vuoi controllare cosa preservare |
| `/clear` | Cambio task completo o contesto degradato |
| `/btw [domanda]` | Domande rapide fuori contesto |
| `/memory` | Debug: verificare quali regole sono attive |
| `/rename [nome]` | Inizio sessione su un workstream specifico |
| `claude --continue` | Riprendere la sessione più recente |
| `claude --resume` | Scegliere da lista di sessioni |

### Soglie operative

| Soglia | Azione |
|---|---|
| < 50% contesto | Lavora normalmente |
| 50–70% contesto | Considera /compact alla fine della fase corrente |
| > 70% contesto | /compact subito con istruzioni |
| > 90% contesto | /compact o /clear, poi riparti da documento |

### Gerarchia di persistenza (dalla più alla meno affidabile)

```
1. File committati nel repo          ← canonici, versionati, condivisi
2. CLAUDE.md (versionato)            ← regole stabili del team
3. Auto-memory (~/.claude/projects/) ← apprendimento autonomo, locale
4. /compact summary                  ← contesto di sessione compresso
5. Cronologia conversazione          ← volatile, soggetta a degradazione
```

---

*Questa guida va aggiornata quando cambiano le versioni di Claude Code o le strategie operative del team.*  
*Versione basata su Claude Code v2.1.x — maggio 2026.*