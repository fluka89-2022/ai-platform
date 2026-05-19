---
name: doc-standard
description: Enforces Markdown formatting, style, frontmatter, and Italian language rules for team documents. Use before writing any .md file (specs, READMEs, audit reports, ADRs, runbooks) or when the user asks for document standards.
---

# Skill: Document standard

Load this skill before producing any Markdown document (`.md` file).

Applies to: functional analyses, specs, technical designs, implementation plans, READMEs,
audit reports, benchmark reports, runbooks, ADRs, architecture docs, CONTRIBUTING.

---

## No emoji

Zero emoji in any position: headings, body text, blockquotes, table cells, lists, inline code.

Semantic blockquote labels:

```text
> **NOTE:** text
> **WARNING:** text
> **EXAMPLE:** text
> **DEPRECATED:** text
> **KNOWN ISSUE:** text
> **REFERENCE:** text
```

---

## Writing style

- **Short sentences.** One idea per sentence. Split if over 25 words.
- **Active voice.** Subject performs the action. "The worker reads from the queue" — not passive.
- **Verifiable facts only.** Every statement derives from code, config, or a document — not inference.
- **Declared uncertainty.** "Purpose unclear — no comment in the source." / "Behaviour undocumented — verify before modifying."
- **No padding.** Write what the section requires, nothing more.
- **Stable technical terms.** Do not use synonyms for stylistic variety.
- **Acronym expansion.** Expand every acronym on first occurrence: "Application Programming Interface (API)" — then "API".

### Banned words and constructs

Rewrite any sentence containing the following.

**Adjectives without supporting data:** robust, powerful, solid, scalable, advanced, sophisticated,
simple, intuitive, easy, immediate, transparent (without demonstration), modern, efficient,
optimised (without metrics), flexible (without listed use cases).

**Opening phrases:** "It is important to note that", "It is worth highlighting that", "As can be seen",
"In this context", "In light of the above", "As mentioned previously".

**Redundant connectives:** "Furthermore", "Moreover", "Additionally", "Likewise",
"In addition to the above", "In this regard".

**Avoidable passive:** "is used" → "uses"; "it is possible to perform" → "you can";
"it becomes necessary" → "requires"; "turns out to be" → "is".

**Closing formulas:** "In summary", "In conclusion", "In short", "In essence", "Overall",
"In general", "To summarise", "Ultimately".

**Unsolicited editorial:** "Unfortunately", "Fortunately", "Surprisingly", any non-technical judgement.

---

## Frontmatter

Every produced Markdown file includes YAML frontmatter:

```yaml
---
title: "<Human-readable document title>"
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
status: <draft | active | archived | deprecated>
tags: [<tag1>, <tag2>]
---
```

Update `updated` on every revision. Additional fields by document type:

| document type | additional fields |
| --- | --- |
| Go documentation | `go_version`, `module` |
| Analysis and report | `severity_summary`, `project` |
| ADR | `decision_status`, `deciders` |
| Runbook | `service`, `last_verified` |

---

## Document structure

- Title lives in frontmatter (`title:`). Do not add a `#` in the body — linter flags MD025.
- `##` main sections. `###` subsections. `####` specific entries. Maximum four levels.
- Do not skip levels.
- Sentence case headings, no trailing period.
- Proper nouns and acronyms keep their standard capitalisation.
- `---` between `##` sections when more than three. No `***` or `___`.
- 100 characters max per text line. No limit for code blocks and table cells.

---

## Formatting

**Bold:** technical concepts at first occurrence in a section, blockquote labels, field headings.
Not for generic emphasis.

**Italic:** external document titles, foreign terms not yet standard. Not for emphasis.

**Inline code:** backticks for function names, variables, types, file paths, short shell commands,
config values, package names. Never use italic or bold instead.

**Code blocks:** always include a language tag (`go`, `bash`, `yaml`, `sql`, `json`, `text`).
No block exceeds 50 lines.

**Bullet lists:** genuinely unordered items only. If order matters: numbered list.
If key-value pairs: table. No nesting beyond two levels.

**Tables:** header row required. One piece of information per cell. Empty cells: `—`.
Column headings lowercase, no trailing period.

**Links:** inline for single references. Link text describes the destination —
not "click here", "here", or "see this".

**Mermaid diagrams:** use `mermaid` tag. Full readable names, no abbreviations.
Label edges when relationship type is not obvious. At least one sentence of context.

| type | when to use |
| --- | --- |
| `graph TD` | Architecture, component dependencies |
| `sequenceDiagram` | Request/response flows, service interactions |
| `erDiagram` | Data schema, entity relationships |
| `flowchart LR` | Pipelines, transformations, decision trees |

---

## Italian documents

Applies to team-facing documents: specs, designs, audit reports, READMEs, CHANGELOG,
anything in `docs/`.

Base language: Italian.

Always in English regardless of context: function/method/type/variable/constant names,
file paths, shell commands, code block content, package/module/library names,
acronyms (API, HTTP, REST, UUID, CLI, SDK, URL, JSON, YAML),
terms with no Italian industry equivalent (middleware, goroutine, payload, endpoint, channel, mutex).

### Italian banned words

**Aggettivi senza dati:** robusto, potente, solido, scalabile, avanzato, sofisticato, semplice,
intuitivo, immediato, trasparente (senza dimostrazione), moderno, efficiente, ottimizzato
(senza metriche), flessibile (senza casi d'uso elencati).

**Frasi iniziali:** "È importante notare che", "Vale la pena evidenziare che", "Come si può vedere",
"In questo contesto", "Alla luce di quanto sopra", "Come menzionato in precedenza".

**Connettivi ridondanti:** "Inoltre", "Peraltro", "Analogamente", "Allo stesso modo",
"A questo riguardo".

**Passivi evitabili:** "viene utilizzato" → "utilizza"; "è possibile effettuare" → forma diretta;
"risulta necessario" → "richiede"; "si rivela essere" → "è".

**Formule conclusive:** "In sintesi", "In conclusione", "In breve", "In sostanza",
"Nel complesso", "In generale", "Per riassumere", "In definitiva".

**Giudizi non tecnici:** "Purtroppo", "Fortunatamente", "Sorprendentemente".

---

## Pre-output checklist

- [ ] Frontmatter complete (`title`, `created`, `updated`, `status`, `tags`)
- [ ] Acronyms expanded on first occurrence
- [ ] No emoji in any position
- [ ] No word from the English banned list
- [ ] If Italian: all text in Italian except English-only elements; no word from Italian banned list
- [ ] Every sentence active voice, or passive justified
- [ ] Every statement derived from source, not inferred
- [ ] No code block exceeds 50 lines
- [ ] Every table has a header and no empty cells
- [ ] Every Mermaid diagram has context text
- [ ] No heading level skipped
- [ ] Proper nouns and acronyms in headings correctly capitalised
- [ ] No link with generic text
- [ ] Text lines within 100 characters
