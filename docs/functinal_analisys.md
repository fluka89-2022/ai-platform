# Analisi Funzionale — ai-platform

**Versione:** 0.1  
**Stato:** Bozza — in attesa di approvazione  
**Data:** 2026-05-15  

---

## 1. Contesto e problema

Il team sviluppa prodotti software basati su microservizi in Go, distribuiti su più repository. Con l'adozione di agenti AI (Claude Code) nel flusso di lavoro quotidiano, emerge un problema strutturale: **ogni sviluppatore configura e usa l'agente in modo autonomo e differente**, con risultati inconsistenti tra colleghi che lavorano sullo stesso progetto.

I problemi concreti che questo genera:

- L'agente produce codice Go che non rispetta le convenzioni del team
- Il comportamento dell'agente varia da sviluppatore a sviluppatore sullo stesso codebase
- Non esiste un processo condiviso e riproducibile per task ricorrenti (nuova feature, bugfix, refactoring)
- Le conoscenze sulle best practice di utilizzo dell'AI sono siloed nei singoli
- Non c'è separazione tra contesto generico riusabile e contesto specifico del singolo progetto

---

## 2. Obiettivo

Creare un repository condiviso — `ai-platform` — che funga da **fonte unica di verità** per la configurazione degli agenti AI nel team, garantendo:

- Comportamento coerente degli agenti tra tutti i colleghi
- Processi riproducibili per i workflow di sviluppo più frequenti
- Separazione netta tra regole generiche (riusabili) e contesto specifico di progetto
- Onboarding semplificato per nuovi membri del team

---

## 3. Utenti e casi d'uso

### Utenti primari

**Sviluppatore** — usa Claude Code quotidianamente sul proprio workspace locale. Vuole che l'agente si comporti in modo prevedibile, conosca le convenzioni del team, e guidi il processo di sviluppo senza dover spiegare ogni volta il contesto.

**Tech Lead** — definisce e mantiene le convenzioni del team. Vuole uno strumento per formalizzare e distribuire quelle convenzioni in modo che l'agente le rispetti automaticamente.

**Nuovo membro del team** — deve essere operativo rapidamente. Vuole un setup guidato che lo metta subito in condizione di lavorare con gli stessi strumenti e gli stessi standard dei colleghi.

---

## 4. Funzionalità principali

### 4.1 Regole condivise

Definizione centralizzata delle convenzioni del team, sempre attive nel contesto dell'agente:

- **Regole core**: comportamento dell'agente, stile di comunicazione, gestione dei checkpoint umani, convenzioni git
- **Regole microservizi**: pattern architetturali Go del team, struttura dei servizi, gestione degli errori, API contracts, messaging
- **Override skill di terze parti**: personalizzazioni specifiche del team rispetto a skill Go esterne (es. `cc-skills-golang`)

### 4.2 Skill on-demand

Istruzioni specializzate che l'agente carica solo quando pertinenti, per non appesantire il contesto di base:

- Skill per la produzione di documenti tecnici
- Skill per l'interazione con GitLab (issues, branch, MR)
- Skill per l'analisi sistematica di codebase esistenti

### 4.3 Workflow strutturati

Processi step-by-step per i task più frequenti, con checkpoint espliciti di approvazione umana a ogni passaggio. Il workflow principale è la **pipeline feature**, composta da sei step sequenziali:

| Step | Input | Output | Checkpoint |
|---|---|---|---|
| Analyze | Documentazione di progetto | `functional-analysis.md` | ✋ Approva analisi |
| Describe | functional-analysis.md | `functional-spec.md` | ✋ Approva spec funzionale |
| Design | functional-spec.md | `technical-design.md` | ✋ Approva soluzione tecnica |
| Plan | technical-design.md | `implementation-plan.md` | ✋ Approva piano |
| GitLab | implementation-plan.md | Issues + branch | ✋ Conferma su GitLab |
| Develop | Issues + branch | Codice committato | ✋ Per ogni task |

Workflow aggiuntivi: bugfix, refactoring, pianificazione milestone.

### 4.4 Comandi slash

Slash commands Claude Code (`.claude/commands/`) per attivare workflow e skill in modo esplicito, senza dover formulare prompt ogni volta:

```
/feature:analyze
/feature:describe
/feature:design
/feature:plan
/feature:gitlab
/feature:develop
/bugfix
/refactor
/review
/plan
```

### 4.5 Template documenti

Struttura standardizzata per i documenti prodotti dalla pipeline, garantendo che tutti i colleghi producano artefatti con lo stesso formato e gli stessi metadati.

### 4.6 Setup workspace

Script e configurazione per inizializzare rapidamente il workspace locale di ogni sviluppatore, inclusa l'installazione dei plugin Claude Code richiesti dal team.

---

## 5. Requisiti non funzionali

**Leggerezza del contesto** — Le regole sempre attive devono essere sintetiche. Il contesto di base (regole core + microservizi) non deve superare i 500 token. Le skill sono caricate on-demand.

**Manutenibilità** — Ogni file ha una responsabilità singola e chiaramente definita. L'aggiornamento di una regola non richiede modifiche in più file.

**Versionamento** — Il repository è versionato con git. Le modifiche alle regole passano per review del team. I progetti possono pinnarsi a una versione specifica di ai-platform.

**Adottabilità** — Il setup iniziale deve richiedere meno di 10 minuti. La documentazione per un nuovo sviluppatore deve essere autocontenuta nel README.

**Separazione dei contesti** — Netta distinzione tra:
- Contenuto generico e riusabile (in `ai-platform`)
- Contesto specifico del progetto (nel `CLAUDE.md` del singolo repo)
- Contesto specifico del workspace (nel `CLAUDE.md` della root del workspace)

---

## 6. Confini del sistema

### Dentro lo scope

- Regole, skill, workflow, comandi e template
- Script di setup e aggiornamento workspace
- Documentazione per sviluppatori e tech lead
- Meccanismo di override per convenzioni specifiche del team

### Fuori dallo scope

- Skill Go generiche (delegate a `cc-skills-golang@samber`)
- Metodologia agente generica (delegata a `superpowers@claude-plugins-official`)
- Configurazione CI/CD o infrastructure
- Contenuto specifico dei singoli progetti (vive nei repo di progetto)

---

## 7. Dipendenze esterne

| Dipendenza | Motivo | Installazione |
|---|---|---|
| `cc-skills-golang@samber` | Skill Go standard, lazy loading | Plugin Claude Code |
| `superpowers@claude-plugins-official` | Metodologia agente e workflow base | Plugin Claude Code |

---

## 8. Criteri di accettazione

- Uno sviluppatore nuovo può configurare il proprio workspace e iniziare a lavorare in meno di 10 minuti seguendo il README
- L'agente rispetta le convenzioni Go del team senza prompt espliciti
- Due sviluppatori che eseguono `/feature:analyze` sullo stesso requisito producono documenti con la stessa struttura
- I workflow si fermano e chiedono approvazione a ogni checkpoint definito
- Le regole core non superano i 500 token totali

---

*Documento prodotto nella fase di analisi. Richiede approvazione prima di procedere alla functional spec.*