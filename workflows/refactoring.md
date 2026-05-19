# Workflow: Refactoring

## Purpose

Improve code structure, readability, or performance without changing observable behavior.

## Principles

- Refactoring never changes behavior. If tests break, you changed behavior.
- Tests must exist before refactoring. If they don't, write them first.
- Scope is agreed upfront. No scope creep during the refactor.
- One logical change per commit. Multiple small commits beat one large one.

## Process

### 1. Define the goal and scope

Ask the user:
- What's wrong with the current code? (too complex, too slow, hard to extend, unclear?)
- What's the target state? (simpler interface, better separation, extracted package?)
- What is explicitly out of scope?

Agree on the scope before starting. Write it down as a short list.

### 2. Verify test coverage

Before touching any code, assess the test coverage for the area being refactored:
- Run existing tests to confirm they pass.
- If coverage is thin for the code being changed, write characterization tests first.
  (Characterization tests capture *current* behavior — they're safety nets, not specifications.)

### 3. Plan the refactoring

For larger refactors, propose the sequence of changes:
- Each step should leave the code in a working state (all tests pass after each step).
- Order changes to minimize the diff at any given point.
- Identify any changes that require updating call sites across multiple files or repos.

Confirm the plan with the user before starting.

### 4. Execute incrementally

Make one logical change at a time:
- Change the code.
- Run tests.
- Confirm they pass.
- Then make the next change.

Do not batch unrelated changes.

### 5. Review the result

After completing all changes:
- All tests pass.
- No new linting errors.
- The diff is coherent — a reviewer can follow the intent.

Ask the user:
> "Refactoring complete. Would you like to review the changes before committing?"

Summarize what changed and why the code is better now.
