<!--
Template: bug
Label default: type::bug

Istruzioni per l'agente:
- Sezioni obbligatorie: Descrizione, Impatto, File coinvolti, Attivita'.
- Sezione opzionale: "Criticita' correlate" (rimuovila se non ci sono punti collaterali rilevanti).
- Snippet codice 5-20 righe con riferimento `path/file.ext` riga N.
- Diagramma mermaid sequenceDiagram quando la issue coinvolge >=2 attori. Etichette in italiano, identificatori di codice in inglese.
- NON includere mai "Aprire una Merge Request" nelle Attivita'.
- Niente preamboli, niente emoji, frasi tecniche dense e affermative.
- Rimuovi questo blocco di commento prima di pubblicare.
-->

## Descrizione

<!-- 1-3 frasi sul bug. Usa sotto-sezioni numerate quando ci sono piu' criticita' correlate. -->

### 1. <Sotto-sezione descrittiva>

<!-- Spiegazione tecnica del comportamento problematico. -->

```<lang>
// path/to/file.ext riga N
<codice rilevante>
```

<!-- Diagramma mermaid se coinvolge >=2 attori: -->

```mermaid
sequenceDiagram
    participant <Attore1> as <Etichetta italiana>
    participant <Attore2> as <Etichetta o identificatore di codice>

    <Attore1>->><Attore2>: <azione>
    <Attore2>-->><Attore1>: <risposta>
```

### 2. <Sotto-sezione opzionale>

<!-- Seconda criticita' correlata strutturalmente al bug principale. -->

---

## Impatto

<!-- Conseguenze concrete: crash, perdita dati, degrado performance, risorse non rilasciate. -->

---

## Criticita' correlate

<!-- OPZIONALE. Rimuovi se non ci sono criticita' correlate. -->

- <punto 1>
- <punto 2>

---

## File coinvolti

- `path/to/file1.ext`
- `path/to/file2.ext`

---

## Attivita'

- [ ] <azione 1>
- [ ] <azione 2>
- [ ] Aggiungere / aggiornare i test unitari
