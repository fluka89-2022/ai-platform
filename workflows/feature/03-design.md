# Workflow: Feature Design (Step 3 of 6)

## Purpose

Produce a technical design document that describes *how* the feature will be built — architecture, API changes, data model changes, service impact — based on the approved functional specification.

## Prerequisites

- `functional-spec.md` exists and is approved.
- Access to relevant service repos for impact analysis.

## Input

Read `[project]-docs/features/[feature-slug]/functional-spec.md`.

If the file does not exist, tell the user:
> "I don't see a functional specification for this feature. Please run `/feature:describe` first."

## Process

### 1. Analyze the current system

Invoke the `codebase-analysis` skill before starting.

For each service that will be affected:
- Map the current relevant behavior.
- Identify the public contracts (APIs, events, data schemas) that will change.
- Identify consumers of those contracts in other services.

Document the dependency map explicitly — this becomes a section in the design.

### 2. Design the solution

Work through each aspect of the design with the user:

**Architecture**: What changes in the overall system? New services? New inter-service calls? 

**API Changes**: For each new or modified endpoint:
- Method, path, query params
- Request body schema
- Response body schema (success + errors)
- Auth requirements

**Data Model Changes**: For each new or modified entity:
- New fields/tables with types and constraints
- Migration strategy (backwards-compatible? requires downtime?)
- Index changes

**Service Impact**: For each affected service, describe what changes.

Discuss alternatives considered and why this approach was chosen. This context is important for future readers.

### 3. Flag risks

Explicitly call out:
- Breaking changes to any inter-service contract.
- Schema migrations that require coordination.
- Changes that affect multiple repos (require coordinated deploy).
- Performance risks.

### 4. Draft the technical design

Invoke the `technical-writing` skill → section "Writing a Technical Design".
Read `templates/technical-design.md` for the required structure.

### 5. Review with user

Present the draft. Pay special attention to:
- Does the approach make sense to the team?
- Are there constraints or conventions that weren't accounted for?
- Is the service impact assessment complete?

### 6. Write the output document

Write to: `[project]-docs/features/[feature-slug]/technical-design.md`

### 7. Stop and request approval

> "The technical design is complete. Please review it — especially the API changes and service impact sections — before we plan the implementation.
> When you're ready to continue, run `/feature:plan`."

## Output

→ `[project]-docs/features/[feature-slug]/technical-design.md`
→ Template: `templates/technical-design.md`
