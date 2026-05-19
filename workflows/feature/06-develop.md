# Workflow: Feature Develop (Step 6 of 6)

## Purpose

Implement one story at a time using TDD. This workflow is iterative — run `/feature:develop` once per story, in dependency order.

## Prerequisites

- `implementation-plan.md` with GitLab issue references exists.
- Feature branch checked out.
- The story to implement is specified (by title or issue number).

## Input

Read `[project]-docs/features/[feature-slug]/implementation-plan.md`.
Read `[project]-docs/features/[feature-slug]/technical-design.md`.
Invoke the `codebase-analysis` skill.

## Process

### 1. Confirm the story

Identify which story to implement. If the user specified a story in the command argument, use that. Otherwise, ask:
> "Which story should we implement? Here are the pending stories: [list]"

Read the story's acceptance criteria and task list from the implementation plan.

### 2. Explore the relevant code

Before writing any code:
- Read the files that will be modified.
- Understand the existing patterns in the service.
- Identify where new files/packages will live.

Ask questions if something is unclear — do not guess at conventions.

### 3. Implement task by task (TDD)

For each task in the story, follow this order:

**a. Write the test first**
- Write a failing test that covers the acceptance criteria for this task.
- Confirm the test is runnable and fails as expected before writing implementation.
- For integration tests: set up the test environment correctly.

**b. Write the implementation**
- Write the minimum code to make the test pass.
- Follow `rules/overrides/golang-conventions.md` and the plugin `cc-skills-golang@samber`.
- Do not add features not covered by a test.

**c. Refactor**
- Clean up without changing behavior.
- Tests should still pass.

**d. Confirm before next task**
After each task:
> "Task [n] complete: [test name] passes. Ready to continue with task [n+1]?"

Wait for confirmation before proceeding.

### 4. Handle unexpected complexity

If during implementation you discover:
- The technical design needs revision → stop, discuss, potentially update `technical-design.md`.
- A convention question → check `rules/` and `skills/`, ask the user if still unclear.
- A scope question → stop and align before writing code.

Do not silently expand scope or make architectural decisions without discussion.

### 5. Completion checklist

Before marking a story complete, verify:
- [ ] All acceptance criteria have a corresponding test.
- [ ] All tests pass.
- [ ] No new linting errors (`go vet`, `golangci-lint` if configured).
- [ ] API documentation updated if endpoints changed.
- [ ] No dead code or debug artifacts left behind.

### 6. Report and link to issue

> "Story '[name]' is implemented. All acceptance criteria verified by tests.
>
> Changes: [brief summary of files changed]
>
> GitLab issue #[n] can now be moved to review. Ready to create an MR, or continue with the next story?"

## Notes

- One story per `/feature:develop` invocation — do not implement multiple stories in one session.
- If a story turns out to be larger than expected, propose splitting it before writing more code.
- The feature branch accumulates commits across stories. Each story should have clean, logical commits.
