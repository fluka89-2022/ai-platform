# Workflow: Feature Plan (Step 4 of 6)

## Purpose

Break the approved technical design into an implementation plan: stories, tasks, acceptance criteria, and dependencies. This becomes the basis for GitLab issues.

## Prerequisites

- `technical-design.md` exists and is approved.

## Input

Read `[project]-docs/features/[feature-slug]/technical-design.md`.
Also read `[project]-docs/features/[feature-slug]/functional-spec.md` for acceptance criteria reference.

## Process

### 1. Identify stories

A story is an independently deployable unit of work. Rules for splitting:
- Each story should be completable in 1–3 days by one developer.
- Each story should be deployable without breaking other services.
- Database migrations are separate stories from the application code that uses the new schema.
- API changes that affect other services must be paired with consumer updates in the same or prior story.

Work through the technical design section by section and propose the story breakdown to the user. Discuss before writing — the user may have constraints you don't know about.

### 2. Write acceptance criteria

For each story, derive acceptance criteria from the functional spec:
- Use testable language: `Given [state], When [action], Then [observable outcome]`.
- Cover the happy path AND the main error cases.
- Reference specific acceptance criteria from the functional spec where applicable.

### 3. Write tasks

For each story, break down the implementation tasks:
- Each task is completable in a single work session (hours, not days).
- Order tasks so that tests are written before implementation (TDD).
- Include: write tests → implement → update docs/OpenAPI if applicable.

Typical task sequence for a new endpoint:
1. Write integration test (failing)
2. Write handler with stub implementation
3. Implement service layer
4. Implement repository layer
5. Wire everything together, tests pass
6. Update API documentation

### 4. Identify dependencies

Between stories: which story must be deployed before another can start?
Between repos: which services need coordinated changes?

### 5. Estimate

Propose estimates in story points or days. Mark as rough (±50%) if there are unknowns. Ask the user if the estimates make sense given their knowledge of the codebase.

### 6. Draft the implementation plan

Invoke the `technical-writing` skill → section "Writing an Implementation Plan".
Read `templates/implementation-plan.md` for the required structure.

### 7. Write the output document

Write to: `[project]-docs/features/[feature-slug]/implementation-plan.md`

### 8. Stop and request approval

> "The implementation plan is complete. Please review the story breakdown and estimates.
> When you're satisfied, run `/feature:gitlab` to create the GitLab issues and branch."

## Output

→ `[project]-docs/features/[feature-slug]/implementation-plan.md`
→ Template: `templates/implementation-plan.md`
