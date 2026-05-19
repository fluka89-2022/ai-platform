# Design: skill `gitlab/resolve` — Risoluzione di una issue GitLab

**Data:** 2026-05-18
**Stato:** Approvato

---

## Contesto

Esiste già `skills/gitlab/issue.md` per *creare* issue su GitLab.
Esiste già `workflows/feature/` per sviluppare feature nuove dal bisogno fino all'implementazione (6 step, con documenti nel repo docs).

Manca uno strumento per il flusso inverso: *partire da una issue esistente* e implementarla. Questa skill colma quel gap, coprendo sia fix semplici che feature/technical-debt, con routing automatico basato sulle label GitLab.

---

## Posizione nel progetto

```
skills/gitlab/resolve.md   ← nuovo file
```

Aggiunta alla famiglia esistente `skills/gitlab/`, affiancata a `issue.md`, `mr.md`, `milestone.md`. Referenziata nella tabella "Artifact authoring" di `skills/gitlab.md`.

---

## Input

La skill risolve il numero di issue nel seguente ordine di priorità:

1. Argomento esplicito (es. `/resolve 42`)
2. Branch corrente: estrae `NNN` dal pattern `type/NNN-description` via `git branch --show-current`
3. Se nessuno dei due è disponibile: chiede all'utente

Lettura dell'issue:

```bash
glab issue view <N> --comments=false
```

---

## Classificazione e routing

La skill legge le label dell'issue e sceglie il percorso automaticamente:

| Label GitLab | Percorso |
|---|---|
| `bug`, `type::fix`, `type::chore`, `type::technical-debt` | Breve |
| `feature` | Lungo |
| Assente / non riconosciuta | Chiede all'utente |

Prima di procedere, mostra la scelta all'utente:

> "Issue #42 classificata come `bug` → percorso breve. Procedo?"

---

## Percorso breve (bug / fix / chore / technical-debt)

### 1. Branch

Se non esiste, crea il branch seguendo `skills/gitlab.md`:

```
fix/42-short-description    ← bug / fix
chore/42-short-description  ← chore / technical-debt
```

Mostra il nome e chiede conferma prima di crearlo.

### 2. Esplorazione del codice

Legge i file rilevanti menzionati nell'issue (stack trace, simboli, path). Esegue silenziosamente Read/Grep/Glob senza output intermedio.

### 3. Piano di esecuzione (se le attività sono già elencate)

Dopo aver letto l'issue, verifica se contiene una lista di attività/task da svolgere (checklist, elenco puntato, sezione "Tasks", ecc.).

**Se le attività sono presenti:**

Deriva da esse un piano di esecuzione ordinato e mostralo all'utente:

> "Ho trovato le seguenti attività nell'issue. Ecco il piano:
>
> 1. [task 1]
> 2. [task 2]
> …
>
> Procedo con questo piano? (si/modifiche/annulla)"

Attendi approvazione esplicita prima di iniziare. Implementa poi ogni attività seguendo TDD (§ 4).

**Se le attività non sono presenti:**

Procedi direttamente con TDD (§ 4), derivando i task dai criteri di accettazione dell'issue.

### 4. Implementazione TDD

Per ogni task:

1. Scrive il test (failing)
2. Scrive l'implementazione minima per farlo passare
3. Refactor
4. Chiede conferma prima di passare al task successivo:

   > "Task [n] completato: `[test name]` passa. Continuo con il task [n+1]?"

### 5. Completion checklist

Prima di dichiarare l'issue risolta:

- [ ] Tutti i criteri di accettazione / task hanno un test corrispondente
- [ ] Tutti i test passano
- [ ] Nessun errore `go vet`
- [ ] Nessun codice morto o artefatto di debug

### 6. Commit

Un commit per task completato:

```
fix: <descrizione> (closes #42)      ← bug / fix
refactor: <descrizione> (closes #42) ← chore / technical-debt
```

---

## Percorso lungo (feature)

Le issue `feature` sono già strutturate con contesto e acceptance criteria (prodotte da `skills/gitlab/issue.md`). Si salta la functional analysis e si parte dal design tecnico.

Questo percorso è **self-contained nella skill** e non invoca i workflow `feature:*` (che generano documenti nel repo docs e richiedono il ciclo completo a 6 step). È appropriato per issue singole già ben definite.

### 1. Branch

```
feature/42-short-description
```

Stessa logica di conferma del percorso breve.

### 2. Design tecnico (in chat)

La skill produce inline un design tecnico snello:

- Componenti coinvolti e loro responsabilità
- Schema delle modifiche principali (file, interfacce, strutture dati)
- Diagramma Mermaid se il flusso coinvolge ≥ 2 attori / goroutine / componenti

Attende approvazione esplicita dell'utente prima di procedere.

### 3. Piano di implementazione (in chat)

Lista ordinata di task derivata dai criteri di accettazione dell'issue. Non viene scritta su file.

### 4. Esecuzione TDD

Identica al percorso breve §§ 4–5: un task alla volta, test prima dell'implementazione, conferma tra task.

### 5. Commit

```
feat: <descrizione> (related to #42)
```

---

## Fuori scope

- Apertura della Merge Request (gestita dalla skill `skills/gitlab/mr.md`)
- Chiusura manuale dell'issue (avviene via auto-close o MR)
- Generazione di documenti nel repo docs (riservata al ciclo `workflows/feature/`)

---

## Aggiornamenti a file esistenti

| File | Modifica |
|---|---|
| `skills/gitlab.md` | Aggiungere riga nella tabella "Artifact authoring": `Resolve issue → skills/gitlab/resolve.md` |
