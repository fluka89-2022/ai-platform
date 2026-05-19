# Workflow: Documentation

## Purpose

Create or update the technical documentation for a component: README, architecture, API, runbook, ADR. Produces ready-made Markdown files conforming to the `doc-standard` skill.

## Supported document types

| Type | Output | Skill to load |
| ---- | ------ | ------------- |
| Go component README | `README.md` in the repo root | `go-readme` |
| Architecture documentation | `docs/architecture/*.md` | `codebase-analysis` |
| API documentation | `docs/api/*.md` | — |
| ADR (Architecture Decision Record) | `docs/adr/*.md` | — |
| Runbook | `docs/runbooks/*.md` | — |
| CONTRIBUTING | `CONTRIBUTING.md` in the root | — |

## Process

### 1. Identify the type and target

Ask the user (or derive from context):

- What type of document should be produced?
- For which component?
- Does a version already exist to update, or is it being created from scratch?

### 2. Load the appropriate skill

- For Go README: invoke the `go-readme` skill.
- For architecture analysis: invoke the `codebase-analysis` skill.
- For all types: invoke the `doc-standard` skill before writing.

### 3. Explore the source

Do not invent content. Every statement in the document must derive from:

- The source code (`go.mod`, directory structure, handlers, configurations).
- Existing configuration files (`.golangci.*`, `Dockerfile`, Helm charts).
- Documentation already present in the repo (even partial).

If something is unclear in the source, state it explicitly in the document:
"Purpose unclear — no comment in the source."

### 4. Propose the structure

For long documents, present the proposed outline before writing the content:
> "I propose this structure for the README: [list of sections]. Do you want to add, remove, or reorder anything?"

For short documents, proceed directly.

### 5. Produce the document

Follow the guidelines of the loaded skill.
Apply the `doc-standard` skill checklist before writing the final file.

For Go READMEs, check the split logic toward `docs/`:
if a section exceeds the threshold indicated in the `go-readme` skill, move it to a separate file.

### 6. Stop and request approval

Present the produced document. Then:

> "The document is ready. Should I save it to [path], or do you want to change something first?"

Do not write the file without explicit confirmation.

### 7. Write the file

Write to the agreed path. Confirm the write to the user with the exact path.

## Operational notes

- Operate **one component at a time** in multirepo workspaces: read `go.mod` and the target repo structure before starting.
- For updates: read the existing file before modifying it. Do not rewrite sections that were not touched.
- `updated:` in the frontmatter must be updated with every file modification.

## Output

→ Markdown file at the agreed path, conforming to the `doc-standard` skill.
