---
name: go-readme
description: Defines README structure, section order, and split rules toward docs/ for Go services. Use when creating or updating a Go service README or when /doc targets a component README.
---

# Skill: Go README

Creating or updating the root README for Go projects: section structure, split towards `docs/`, reference to `CONTRIBUTING.md`.

Load this skill when the user asks to create or update the README of a Go component.

Before producing any file, invoke the `doc-standard` skill. That skill takes precedence on all formatting and style decisions.

---

## README file structure

### Order from top to bottom

1. **YAML frontmatter** — `title`, `created`, `updated`, `status`, `tags`, plus `go_version` and `module`.
2. **Document title** — a single `# <name>` line (module name from `go.mod` or service name used by the team).
3. **Introduction** — below the `#`, without a new heading: 1–3 sentences on the role and boundaries of the code. Always present.
4. **Summary card** — immediately after the introduction, below the `#` and before the first `---`. Label with bold **Summary card**. Two-column table (**Field** | **Content**): Go version, Module, Status, Entry point.
5. **Technology stack** — immediately after the summary card. Label with bold **Technology stack**. Two-column table (**Component** | **Detail**). Exclude test and indirect dependencies.
6. **Flat index** — only if the README exceeds 200 lines or contains more than six `##`. Bulleted list with links to `##` sections, no sub-tree, no link to `## Index` or `#`.
7. **`---` separator** — between `##` sections when there are more than three sections.
8. **`##` sections** — in the order of the table below.
9. **`###` / `####` subsections** — where detail is needed. `####` only under a `###`.

### Section table (order and content)

Omit a row if no verifiable facts exist in the tree; do not invent content.

| n | `##` heading | Requirement | Minimum content |
| - | ----------- | ----------- | --------------- |
| 1 | — | required | Preamble under `#`: introduction, **Summary card**, **Technology stack**. |
| 2 | Index | conditional | Flat list. Only if README > 200 lines or more than six `##`. |
| 3 | Quick start | required | `###` Prerequisites, Build, Local execution, Tests. |
| 4 | Configuration | recommended | `###` Configuration files, environment variables, CLI flags; tables with empty cells `—`. |
| 5 | Architecture | recommended | Package summary, entrypoints, main data flows. Mermaid diagram if useful. |
| 6 | Repository structure | recommended | Path → role derived from the actual repo tree. |
| 7 | Development | optional | `###` Testing, lint, code generators, conventions if present in the repo. |
| 8 | Deployment | optional | `###` Container/Compose, Kubernetes/Helm manifests; readiness and liveness probes. |
| 9 | Observability | optional | Tracing, metrics, structured logging, health endpoint if implemented. |
| 10 | Security | optional | Auth, secret management, TLS derived from code or configuration. |
| 11 | Scalability | optional | Only if horizontal/vertical design is documentable in the repo. |
| 12 | Dependencies | recommended | `###` Main dependencies from `go.mod`; `###` Internal modules if present. |
| 13 | Documentation | required if `docs/` exists | Relative links and one-line purpose per file or directory. |
| 14 | Release | optional | Tagging strategy, Go module version, CI/CD pipeline. |
| 15 | Contributing | required | Relative link to `CONTRIBUTING.md`. If it does not exist, create it. |
| 16 | License | optional | License type and link to the `LICENSE` file. |
| 17 | Useful links | optional | Only URLs already present in the repo or provided by the team. |

**Heading hierarchy:** no level skipping. Maximum four levels.

---

## Frontmatter for README and documents in `docs/`

**Root README** (and every Markdown file created or updated in `docs/`):

- Required fields from the `doc-standard` skill: `title`, `created`, `updated`, `status`, `tags`.
- For Go documentation add: `go_version` (from toolchain / `go` directive), `module` (module path from `go.mod`).
- `updated` matches `created` on first write. It must be updated on every revision.

---

## Intelligent split towards `docs/`

Before writing, analyze the repository (`go.mod`, `cmd/`, `internal/`, `pkg/`, tests, CI, `Dockerfile`, chart).
The README must remain navigable in a short read: overview, essential commands, pointers.

**Move to separate files under `docs/`** when:

- The Architecture section exceeds 40 lines or describes more than three distinct package areas → `docs/architecture/`.
- Configuration or environment variables require extended tables or multiple environments → `docs/configuration/`.
- Detailed HTTP/gRPC APIs, contracts, long examples → `docs/api/`.
- Operational procedures, troubleshooting, incidents → `docs/runbooks/`.
- Architectural decisions → `docs/adr/` (ADR format with additional fields from the `doc-standard` skill).

In the README, in the **Documentation** section, list each file with a one-line purpose and its relative path.

`CONTRIBUTING.md` stays in the repository root, not under `docs/`.

Every file in `docs/` complies with the `doc-standard` skill (same frontmatter, same style).

---

## Checklist before delivering the README

- [ ] `go.mod` read: `module` and Go version reported correctly in the frontmatter, **Summary card**, and **Technology stack**.
- [ ] `created` and `updated` fields present in the frontmatter.
- [ ] No invented sections: only what the tree and files confirm.
- [ ] Long content moved to `docs/` with links from the README.
- [ ] If `## Index` is present: flat list, no sub-tree, no link to `## Index` or `#`.
- [ ] **Contributing** section present with link to `CONTRIBUTING.md`; if the file is missing from root, it has been created.
- [ ] `## Observability` heading in English.
- [ ] No link with generic text ("here", "this", "click here").
- [ ] Full compliance with the `doc-standard` skill.
