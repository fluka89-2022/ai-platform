<!--
Template: technical-debt
Label default: type::technical-debt

Istruzioni per l'agente:
- Sezioni obbligatorie: Descrizione, Impatto, File coinvolti, Attivita'.
- Sezione opzionale: "Note su <argomento>" per vincoli di compatibilita' o interfacce stabili.
- Snippet codice 5-20 righe con riferimento `path/file.ext` riga N.
- Mermaid sequenceDiagram quando descrive una catena di chiamata o flusso problematico.
- NON includere mai "Aprire una Merge Request" nelle Attivita'.
- Niente preamboli, niente emoji, frasi tecniche dense e affermative.
- Rimuovi questo blocco di commento prima di pubblicare.
-->

## Descrizione

<!-- 1-3 frasi: cosa fa il codice oggi, perche' e' subottimale. Usa sotto-sezioni quando il debito interessa piu' metodi. -->

### <Sotto-sezione 1, es. "Metodi coinvolti">

**`<NomeMetodo>`** — `path/to/file.ext` riga N:

```<lang>
<codice attuale>
```

<!-- Spiegazione breve del problema: allocazione ripetuta, accoppiamento, mancato riuso, ecc. -->

### <Sotto-sezione 2 opzionale, es. "Catena di chiamata attuale">

```mermaid
sequenceDiagram
    participant <Attore1> as <Etichetta italiana>
    participant <Attore2> as <Identificatore di codice>

    loop <condizione>
        <Attore1>->><Attore2>: <chiamata>
        <Attore2>-->><Attore1>: <risposta>
    end
```

---

## Impatto

<!-- Conseguenze concrete: costo perf, allocazioni, GC pressure, complessita' di manutenzione, rischio di regressione. Numeri/ordini di grandezza quando possibile. -->

---

## Note su <argomento>

<!-- OPZIONALE. Rimuovi se non rilevante. Usare per vincoli di compatibilita', interfacce stabili da preservare. -->

---

## File coinvolti

- `path/to/file1.ext`
- `path/to/file2.ext` — <breve nota se rilevante>

---

## Attivita'

- [ ] <azione di refactor 1>
- [ ] Mantenere la compatibilita' con l'interfaccia <X>
- [ ] Aggiungere test unitari per verificare il nuovo comportamento
