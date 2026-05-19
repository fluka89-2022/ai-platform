---
name: codebase-analysis
description: Analyzes Go microservice codebases for impact, dependencies, entry points, and data flow. Use before technical designs that touch existing services, during bugfix tracing, or for systematic codebase exploration.
---

# Codebase Analysis Skill

## Purpose

Guidelines for systematically analyzing Go microservice codebases — understanding structure, tracing dependencies, mapping impact of changes.

Use this skill before writing any technical design that touches existing services.

## Analysis Goals

Before starting, be clear about which type of analysis you need:

| Goal | What to look for |
|------|-----------------|
| Impact analysis | What breaks if X changes? |
| Dependency mapping | What does service A depend on? |
| Entry point discovery | Where does a request start? |
| Data flow tracing | How does data move through the system? |
| Contract review | What does this service expose to others? |

## Service Exploration Protocol

When exploring an unfamiliar service:

1. **Read the README first** — understand the purpose before reading code.
2. **Look at `main.go` or `cmd/`** — understand startup, config, dependencies wired.
3. **Read the top-level package layout** — understand the logical structure (`internal/`, `pkg/`, `api/`).
4. **Find the public contracts** — proto files, OpenAPI specs, or handler files.
5. **Read interfaces, not implementations** — understand what the service promises before how it delivers.
6. **Check tests** — integration tests often reveal behavior better than production code.

Do not read the entire codebase. Be surgical.

## Impact Analysis Protocol

When assessing the impact of a change:

1. Identify the surface being changed (function signature, data model field, API endpoint, message schema).
2. Find all callers/consumers:
   - For Go functions: search for the function name across the repo.
   - For API endpoints: search for the path string in other services.
   - For message schemas: search for the topic/subject name across all repos.
   - For data model changes: identify all code that reads/writes the affected table/field.
3. Classify each dependency:
   - **Compile-time**: will break the build if not updated.
   - **Runtime**: will fail at runtime; may not be caught by tests.
   - **Behavioral**: subtle behavior change; may require test updates.
4. Document the dependency map in the technical design.

## Cross-Service Analysis

In a multirepo microservice environment:

- You cannot grep across repos automatically. Ask the user to open the relevant repos in the workspace.
- When uncertain whether another service depends on something, say so explicitly — do not assume.
- Flag any dependency that crosses a service boundary as a coordination risk.

## Common Patterns to Recognize

### Repository Pattern
```go
type UserRepository interface {
    GetByID(ctx context.Context, id string) (*User, error)
    Save(ctx context.Context, u *User) error
}
```
Look for interface + implementation pairs. The interface defines the contract; the implementation is swappable.

### Service Layer
```go
type UserService struct {
    repo UserRepository
    // other deps
}
```
Business logic lives here. Domain rules should not leak into handlers or repositories.

### Handler/Controller
```go
func (h *Handler) GetUser(w http.ResponseWriter, r *http.Request) { ... }
```
Thin layer: validate input, call service, format response. No business logic here.

### Event Producer/Consumer
Look for `Publish(topic, message)` and subscribe/consume patterns.
Identify the message schema — this is the inter-service contract.

## Reporting Findings

Structure your analysis report as:

```
## Service: [name]

### Purpose
One paragraph.

### Public Contracts
- REST API: [endpoints affected]
- Events published: [topics]
- Events consumed: [topics]

### Impact of [change]
- [file/function]: [type of impact]
- ...

### Open Questions
- [anything that requires clarification from the team]
```

Keep findings factual. Flag uncertainty explicitly rather than guessing.
