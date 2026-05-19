Perform a code review of the changes specified. If no argument is given, review the current branch diff against main.

Target: $ARGUMENTS

## Review Checklist

Work through these areas systematically:

**Correctness**
- Does the code do what the acceptance criteria require?
- Are edge cases handled?
- Are error paths correct and tested?

**Tests**
- Does every behavior change have a corresponding test?
- Do tests cover the failure cases, not just the happy path?
- Are tests readable and maintainable?

**Go conventions**
- Does the code follow `rules/overrides/golang-conventions.md`?
- Are errors handled idiomatically?
- Is context propagated correctly?

**Design**
- Is the change appropriately scoped? No feature creep?
- Are abstractions justified by current need, not hypothetical future need?
- Does the public API (interfaces, function signatures) make sense?

**Security**
- Any injection risks (SQL, command, log)?
- Are secrets handled correctly (not logged, not hardcoded)?
- Are inputs validated at system boundaries?

**Operational**
- Is logging adequate for debugging in production?
- Are there metrics or traces for new code paths?
- Will this deploy safely? Any migration risks?

## Output Format

Summarize findings as:

**Must fix**: Issues that block merging.
**Should fix**: Important improvements that aren't blockers.
**Consider**: Minor suggestions or style notes.
**Good**: Things done well — worth noting for the team.
