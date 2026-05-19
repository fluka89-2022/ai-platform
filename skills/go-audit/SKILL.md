---
name: go-audit
description: Audits a Go module with parallel domain agents, optional pprof input, and a severity-classified findings report. Use when the user runs /audit or asks for security, quality, or performance review of a Go component.
---

# Skill: Go Audit

Audits a Go module via 6 parallel specialized agents. Each agent covers one domain and invokes
the relevant `cc-skills-golang` skills. Findings are aggregated into a structured report saved
under `docs/audit/`.

Before producing the report, invoke the `doc-standard` skill.

---

## Input

```text
/audit <component-path>
```

Path relative to the workspace root (e.g. `scrapers/platform-scraper`).
If omitted, ask for the path before proceeding.
If `<path>/go.mod` does not exist, stop with:

```text
Error: <path> is not a Go module (go.mod not found).
```

Read the `module` field from `go.mod` — use it as the module name in the report.
Build the absolute path: `<ABS-PATH>` = current working directory + "/" + `<component-path>`.
Use this in all agent prompts.

---

## pprof detection

Before dispatching agents, check whether the user has attached `.pprof` files
(`cpu.pprof`, `mem.pprof`, `block.pprof`, `mutex.pprof`).

- **Files present**: activate pprof mode. Pass `cpu.pprof` and `mem.pprof` to the PERF agent;
  pass `block.pprof` and `mutex.pprof` to the CONC agent.
- **No files**: static analysis only. Add at the top of the report:

```text
> **NOTE:** Analysis performed on a static basis only. To correlate findings with runtime
> data, generate profiles using the commands in the Performance section and attach them to
> the next audit session.
```

---

## Step 1 — Dispatch 6 agents in parallel

Launch all 6 agents simultaneously with the Agent tool.
Replace `<ABS-PATH>` with the actual absolute path of the component.

### Agent arch — Architecture

```text
You are the ARCH agent for a Go audit. Analyze the module at <ABS-PATH>.

1. Invoke cc-skills-golang:golang-design-patterns, cc-skills-golang:golang-structs-interfaces,
   and cc-skills-golang:golang-project-layout.
2. Read Go files. Analyze: directory layout (cmd/internal/pkg), layer violations, potential
   cyclic imports, init() usage, dependency injection vs global state, interface segregation
   (> 7 methods), business logic in main().
3. For each issue, produce a finding in this format (finding text in Italian,
   code references in English):

### [ARCH-NNN] — Titolo breve
**Severità:** CRITICO | ALTO | MEDIO | BASSO
**File:** `path/file.go` (righe N-M)
**Problema:** descrizione concisa in italiano
**Fix:** azione concreta in italiano

4. Close with exactly: SUMMARY: N CRITICAL, N HIGH, N MEDIUM, N LOW

Do not modify source files. Read-only.
```

### Agent conc — Concurrency

```text
You are the CONC agent for a Go audit. Analyze the module at <ABS-PATH>.

1. Invoke cc-skills-golang:golang-concurrency and cc-skills-golang:golang-context.
2. Analyze: goroutines without WaitGroup/errgroup/cancel, shared maps without mutex,
   sync.Mutex copied by value, nil channels or channels closed from multiple goroutines,
   context.WithTimeout without defer cancel(), select{} without context.Done().
3. If block.pprof or mutex.pprof were attached:
   - block.pprof: channel/mutex blocks > 5% of total → CRITICAL; 1-5% → HIGH.
   - mutex.pprof: mutex delay > 1% of total → HIGH; locate the protected variable.
   - Static finding confirmed by profile: raise severity one level, add Source: pprof-confirmed.
   - Profile hotspot not in static analysis: new finding, add Source: pprof-unique.
4. For each issue, produce a finding (text in Italian, code refs in English):

### [CONC-NNN] — Titolo breve
**Severità:** CRITICO | ALTO | MEDIO | BASSO
**File:** `path/file.go` (righe N-M)
**Problema:** descrizione concisa in italiano
**Fix:** azione concreta in italiano
[**Fonte:** pprof-confirmed | pprof-unique  ← only when pprof was analyzed]

5. Close with: SUMMARY: N CRITICAL, N HIGH, N MEDIUM, N LOW

Do not modify source files. Read-only.
```

### Agent err — Error handling

```text
You are the ERR agent for a Go audit. Analyze the module at <ABS-PATH>.

1. Invoke cc-skills-golang:golang-error-handling and cc-skills-golang:golang-safety.
2. Analyze: errors discarded with _ on I/O or network ops, fmt.Errorf without %w,
   type assertion without comma-ok in hot paths, panic() in non-main non-test code,
   recover() absent in goroutines making external calls, http.DefaultClient (no timeout),
   no retry logic on transient errors, errors logged with log.Println instead of structured
   logger.
3. For each issue, produce a finding (text in Italian, code refs in English):

### [ERR-NNN] — Titolo breve
**Severità:** CRITICO | ALTO | MEDIO | BASSO
**File:** `path/file.go` (righe N-M)
**Problema:** descrizione concisa in italiano
**Fix:** azione concreta in italiano

4. Close with: SUMMARY: N CRITICAL, N HIGH, N MEDIUM, N LOW

Do not modify source files. Read-only.
```

### Agent perf — Performance

```text
You are the PERF agent for a Go audit. Analyze the module at <ABS-PATH>.

1. Invoke cc-skills-golang:golang-performance.
2. Analyze: slices and maps without pre-allocated capacity in loops, string concatenation
   in loops without strings.Builder, large structs returned by value from frequently called
   functions, ioutil.ReadAll on potentially large files, HTTP response bodies not closed,
   N+1 patterns, unconfigured connection pool (db.SetMaxOpenConns, db.SetMaxIdleConns).
3. If cpu.pprof or mem.pprof were attached:
   - cpu.pprof: functions with highest cumulative% → map to package/file from static analysis.
     mallocgc > 10%: CRITICAL finding PERF-MEM-001. gcBgMarkWorker > 15%: HIGH finding.
   - mem.pprof: top 10 by alloc_space → check avoidability (slice without capacity,
     unnecessary escape, interfaces). High inuse_objects with low alloc_objects: unreleased
     objects, check for caches without TTL.
   - Static finding confirmed by profile: raise severity one level, add Source: pprof-confirmed.
   - Profile hotspot not in static analysis: new finding, add Source: pprof-unique.
   Include pprof generation commands at the end of your output (see format below).
4. For each issue, produce a finding (text in Italian, code refs in English):

### [PERF-NNN] — Titolo breve
**Severità:** CRITICO | ALTO | MEDIO | BASSO
**File:** `path/file.go` (righe N-M)
**Problema:** descrizione concisa in italiano
**Fix:** azione concreta in italiano
[**Fonte:** pprof-confirmed | pprof-unique  ← only when pprof was analyzed]

5. If pprof was analyzed, append after findings:
PPROF_COMMANDS_START
go test -bench=. -benchtime=30s -cpuprofile=cpu.pprof ./...
go test -bench=. -benchtime=30s -memprofile=mem.pprof ./...
PPROF_COMMANDS_END

6. Close with: SUMMARY: N CRITICAL, N HIGH, N MEDIUM, N LOW

Do not modify source files. Read-only.
```

### Agent obs — Testing and observability

```text
You are the OBS agent for a Go audit. Analyze the module at <ABS-PATH>.

1. Invoke cc-skills-golang:golang-testing and cc-skills-golang:golang-observability.
2. Analyze: ratio of _test.go files to source files (target >= 1:1 for critical packages),
   absence of table-driven tests for pure functions with multiple cases, tests using
   time.Sleep for synchronization, no integration tests for DB/HTTP/message broker,
   Prometheus/OpenTelemetry instrumentation present, /healthz and /readyz endpoints,
   structured logging (zerolog/slog), correlation ID in logs, pprof endpoint in debug builds.
3. For each issue, produce a finding (text in Italian, code refs in English):

### [OBS-NNN] — Titolo breve
**Severità:** CRITICO | ALTO | MEDIO | BASSO
**File:** `path/file.go` (righe N-M)
**Problema:** descrizione concisa in italiano
**Fix:** azione concreta in italiano

4. Close with: SUMMARY: N CRITICAL, N HIGH, N MEDIUM, N LOW

Do not modify source files. Read-only.
```

### Agent sec — Security and dependencies

```text
You are the SEC agent for a Go audit. Analyze the module at <ABS-PATH>.

1. Invoke cc-skills-golang:golang-security and cc-skills-golang:golang-dependency-management.
2. Analyze: crypto/md5 or crypto/sha1 for security hashing, math/rand for tokens or secrets,
   hardcoded credentials (search "password", "secret", "token", "key" in string literals),
   InsecureSkipVerify: true in TLS config, pre-v1 pinned dependencies, local replace
   directives in go.mod, go mod tidy cleanliness.
3. For each issue, produce a finding (text in Italian, code refs in English):

### [SEC-NNN] — Titolo breve
**Severità:** CRITICO | ALTO | MEDIO | BASSO
**File:** `path/file.go` (righe N-M)
**Problema:** descrizione concisa in italiano
**Fix:** azione concreta in italiano

4. Close with: SUMMARY: N CRITICAL, N HIGH, N MEDIUM, N LOW

Do not modify source files. Read-only.
```

---

## Step 2 — Consolidation

Collect the 6 outputs. For any agent that did not complete, insert in the report:
`Agente <name>: analisi non completata — <reason>`

Aggregate counters from each agent's `SUMMARY:` line.
Collect all findings and sort by severity: CRITICAL → HIGH → MEDIUM → LOW.
Identify the top 3 immediate actions.

For `Impegno stimato` in the backlog: `S` (< 1 h), `M` (1–4 h), `L` (> 4 h). Use `—` when uncertain.

Group related findings into **epiche di refactoring** when ≥ 3 findings share the same root cause.
Each epic includes: title, finding IDs, execution sequence, definition of done.

Extract any `PPROF_COMMANDS_START...PPROF_COMMANDS_END` block from the PERF agent output
and include it in the report's performance section.

---

## Step 3 — Chat summary

```text
GO AUDIT — <module-name>
────────────────────────────────────
 CRITICO  ALTO   MEDIO   BASSO
    N       N       N       N
────────────────────────────────────
Prime 3 azioni immediate:
  [XXX-NNN] CRITICO — descrizione in una riga
  [XXX-NNN] ALTO    — descrizione in una riga
  [XXX-NNN] ALTO    — descrizione in una riga

Report completo → docs/audit/go-audit-YYYY-MM-DD.md
```

If total findings < 3, show only those present. Do not invent entries.

---

## Step 4 — Report file

Create `docs/audit/` if it does not exist. Write `docs/audit/go-audit-YYYY-MM-DD.md`:

```markdown
---
title: "Go Audit — <nome-modulo>"
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: attivo
project: <nome-modulo>
pprof_attached: <sì: cpu | mem | block | mutex — oppure: no>
severity_summary:
  critico: N
  alto: N
  medio: N
  basso: N
tags: [go, audit, performance, architettura]
---

## Sommario

| Dominio | CRITICO | ALTO | MEDIO | BASSO |
|---------|---------|------|-------|-------|
| Architettura | N | N | N | N |
| Concorrenza | N | N | N | N |
| Gestione errori | N | N | N | N |
| Performance | N | N | N | N |
| Test e osservabilità | N | N | N | N |
| Sicurezza | N | N | N | N |
| **Totale** | **N** | **N** | **N** | **N** |

---

## Finding critici

[CRITICAL findings from all agents, ordered by domain then ID]

---

## Finding alti

[HIGH findings]

---

## Finding medi

[MEDIUM findings]

---

## Finding bassi

[LOW findings]

---

## Backlog prioritizzato

| ID | Severità | Dominio | Titolo | Impegno stimato |
|----|----------|---------|--------|-----------------|

---

## Epiche di refactoring

[Groups of related findings. Omit section if no epics identified.]

---

## Performance — generazione profili

[Include only if pprof was NOT attached. Extract and insert commands from PERF agent output.]

---

## Piano sprint suggerito

### Sprint 1 — Stabilità

Obiettivo: risolvere CRITICO e ALTO.

### Sprint 2 — Qualità

Obiettivo: risolvere MEDIO.

### Sprint 3 — Cleanup

Obiettivo: risolvere BASSO e hygiene dipendenze.
```

---

## Behavioral constraints

- Never modify source files during analysis.
- Do not truncate the backlog: every finding must appear.
- Fill every table cell from real observations. No placeholders.
- Cite exact paths and line ranges where code is visible in context.
- If a domain produces no findings, write: `Nessun problema rilevato in questo dominio.`
- Do not invent profiling data. If a profile does not cover a package, Source remains `static`.
- `pprof-unique` findings are ordered above static findings of the same severity in the backlog.
