# Workflow: Audit Go

## Purpose

Run a complete audit of a Go module: static analysis across six domains, correlation with pprof profiles when available, and production of a structured report with classified findings and a prioritized backlog.

## Prerequisites

- The Go module to analyze is accessible in the workspace (directory containing `go.mod`).
- `golangci-lint` installed (optional but recommended).
- `.pprof` files attached to the chat (optional — activates runtime mode).

## Process

### 1. Load the skill

Invoke the `go-audit` skill before proceeding.

### 2. Identify the target

If the workspace contains multiple Go modules (multirepo), ask the user:
> "Which component should we audit? Here are the available modules: [list]."

Analyze **one module at a time**. Operate from the directory containing `go.mod`.

### 3. Run the analysis

Follow the process described in the `go-audit` skill:

- Check whether `.pprof` files are attached → activate static or static+runtime mode.
- Analyze the six domains in the indicated order.
- Collect all data before synthesizing.

### 4. Produce the report

- Create `docs/audit/go-audit-<YYYY-MM-DD>.md` in the component directory.
- Follow the format and frontmatter defined in the `go-audit` skill.
- Apply the `doc-standard` skill for style and language (invoke it if not already loaded).

### 5. Present the summary and stop

Show the summary box in chat (CRITICAL / HIGH / MEDIUM / LOW / EPICS),
the top 3 immediate actions, and the report path. Then ask:

> "Report saved to `docs/audit/go-audit-<date>.md`. Should I prepare GitLab issues for the CRITICAL and HIGH findings, or do you want to review the report first?"

Do not proceed further without a response.

## Output

→ `docs/audit/go-audit-<YYYY-MM-DD>.md` in the analyzed component directory.
