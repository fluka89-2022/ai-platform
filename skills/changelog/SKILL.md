---
name: changelog
description: Genera un CHANGELOG in italiano in formato Keep a Changelog confrontando due branch Git. Usa questa skill ogni volta che l'utente vuole generare un changelog, preparare le release notes, documentare le modifiche tra versioni o branch, anche se non usa esplicitamente la parola "changelog" — ad esempio "cosa è cambiato tra main e develop", "prepara le note di rilascio", "aggiorna il changelog per la release".
---

# Changelog Generator

Genera un changelog strutturato in italiano confrontando due branch Git, seguendo il formato [Keep a Changelog](https://keepachangelog.com/it/1.0.0/).

---

## Input

```
/changelog <base> <head>
```

- `<base>`: il branch di partenza (tipicamente `main` o `master`)
- `<head>`: il branch con le modifiche (es. `develop`, `release/1.2.0`)

Se i branch non sono specificati, chiedi quale confrontare prima di procedere.
Se viene specificato un numero di versione (es. `1.2.0`), usalo come titolo della sezione; altrimenti usa `[Unreleased]`.

---

## Passi

### 1. Estrai i commit

```bash
git log <base>..<head> --no-merges --pretty=format:"%H|||%s|||%b" 
```

Usa `|||` come separatore per distinguere subject e body in modo affidabile.

Se non ci sono commit, interrompi con:
```
Nessuna differenza trovata tra <base> e <head>.
```

### 2. Categorizza ogni commit

Assegna ogni commit a una categoria Keep a Changelog. Non classificare meccanicamente: leggi il messaggio e ragiona su **cosa cambia per chi usa il software**.

| Categoria | Quando usarla |
|-----------|--------------|
| **Aggiunto** | Nuove funzionalità, nuovi endpoint, nuove opzioni di configurazione |
| **Modificato** | Comportamenti esistenti che cambiano, refactoring con impatto esterno |
| **Deprecato** | Funzionalità ancora presenti ma destinate alla rimozione |
| **Rimosso** | Funzionalità, endpoint, campi o comandi eliminati |
| **Corretto** | Bug fix, correzioni di comportamenti errati o inattesi |
| **Sicurezza** | Patch di vulnerabilità, aggiornamenti di dipendenze con CVE |

**Commit con prefisso conventional commit** (`feat:`, `fix:`, `refactor:`, ecc.): usa il tipo come segnale forte ma non assoluto — leggi comunque il messaggio.

**Commit in forma libera**: usa il contenuto per capire la natura della modifica.

**Ignora** i commit puramente tecnici senza impatto per l'utente finale:
- aggiornamenti CI/CD, Dockerfile, Makefile senza effetto funzionale
- commit di formatting, linting, typo in commenti
- bump di dipendenze senza CVE note
- commit automatici (Dependabot, Renovate, bot)

Se un commit è ambiguo, preferisci includerlo piuttosto che escluderlo.

### 3. Trasforma i messaggi in voci di changelog

Ogni voce deve essere:
- scritta in italiano
- orientata all'utente (non all'implementazione)
- concisa: una riga, inizio con lettera maiuscola, niente punto finale

**Esempi di trasformazione:**

| Commit originale | Voce changelog |
|-----------------|----------------|
| `feat: add pagination to /api/hosts` | Aggiunta paginazione all'endpoint `/api/hosts` |
| `fix: nil pointer in scraper when node is offline` | Corretto errore di nil pointer nello scraper quando il nodo è offline |
| `refactor: move auth logic to middleware` | Spostata la logica di autenticazione in un middleware dedicato |
| `chore: update go.sum` | *(ignorato)* |

### 4. Scrivi il changelog

Usa questa struttura. Includi **solo le sezioni con almeno una voce**.

```markdown
## [Unreleased]

### Aggiunto
- Aggiunta paginazione all'endpoint `/api/hosts`

### Corretto
- Corretto errore di nil pointer nello scraper quando il nodo è offline
```

### 5. Salva il risultato

Salva in `CHANGELOG.md` nella root del progetto corrente:

- Se il file **non esiste**, crea:

```markdown
# Changelog

## [Unreleased]

### Aggiunto
- ...
```

- Se il file **esiste già**, inserisci la nuova sezione subito dopo la prima riga `# Changelog` (e prima di qualsiasi sezione esistente), preservando il contenuto precedente.

Comunica all'utente il percorso del file salvato e un breve riepilogo: quanti commit analizzati, quanti inclusi, quanti ignorati.
