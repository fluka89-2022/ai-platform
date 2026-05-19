# Branch Naming Convention — Design

**Data:** 2026-05-18

## Decisione

La naming convention per i branch Git segue il formato:

- **Con issue GitLab:** `tipo/NNN-descrizione-breve`
- **Senza issue GitLab:** `tipo/descrizione-breve`

## Tipi validi

| Tipo | Quando usarlo |
|------|---------------|
| `feature` | Nuova funzionalità |
| `fix` | Correzione di un bug non urgente |
| `hotfix` | Correzione urgente in produzione |
| `chore` | Lavoro tecnico senza impatto funzionale (aggiornamenti dipendenze, CI, ecc.) |
| `release` | Preparazione di una release |

## Regole

- Tutto minuscolo.
- Separatore: trattino `-`.
- La descrizione è kebab-case, massimo 4-5 parole.
- Il numero dell'issue (`NNN`) viene incluso solo se esiste un'issue GitLab collegata; in caso contrario si omette senza placeholder.

## Esempi

```
feature/42-add-oauth-login
feature/add-oauth-login

fix/99-null-pointer-on-startup
fix/null-pointer-on-startup

hotfix/critical-memory-leak
chore/update-go-dependencies
release/1.4.0
```

## Parsing per la MR

La skill `gitlab/mr.md` analizza il nome del branch per estrarre il riferimento all'issue:

- Branch con numero → `Closes #NNN` (per `fix`) o `Related to #NNN` (per `feature`)
- Branch senza numero → nessun riferimento automatico all'issue

## File da aggiornare

- `skills/gitlab.md` — sezione `## Branch conventions`
