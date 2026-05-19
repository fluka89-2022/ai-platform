# Workflow: Bug Fix

## Purpose

Diagnose and fix a bug systematically — understanding root cause before writing any code.

## Process

### 1. Understand the bug

Ask the user to describe:
- What is the observed behavior?
- What is the expected behavior?
- How can it be reproduced? (steps, input data, environment)
- Is there an error message or log entry?
- When did it start happening? (regression? always been there?)

Do not start debugging until you can reproduce the problem mentally or in the environment.

### 2. Reproduce with a failing test

Before touching production code:
- Write a test that reproduces the bug (it should fail).
- If the bug is hard to test directly, write the test at the highest practical level (integration test over unit test).
- Confirm the test fails in the expected way.

This test is the definition of "fixed" — it passes when the bug is resolved.

### 3. Find the root cause

Invoke the `codebase-analysis` skill for guidance on tracing through unfamiliar code.

Trace the execution path from the entry point to the failure:
- Don't guess. Follow the data.
- If you're unsure, add temporary logging or read more code.
- Identify the exact line/function where behavior diverges from expectation.

State the root cause explicitly before proposing a fix:
> "The root cause is: [precise description]. The fix is: [approach]."

Ask the user to confirm before implementing.

### 4. Implement the fix

- Make the minimum change to fix the root cause.
- Do not refactor or improve unrelated code in the same commit.
- If fixing the bug requires a larger refactor, discuss and plan that separately.

### 5. Verify

- The failing test from step 2 now passes.
- Existing tests still pass.
- No new linting errors.

### 6. Document

If the bug was caused by a non-obvious constraint or edge case, add a short comment explaining the invariant — not what the code does, but why this specific behavior is required.

Summarize the fix:
> "Fixed. Root cause was [X]. Changed [Y] in [file]. The test [test name] now passes."
