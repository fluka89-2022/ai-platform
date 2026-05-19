---
title: "Implementation plan: [Feature name]"
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
status: bozza
tags: [implementation-plan, <project-name>]
---

## Definition of done

Applies to every story:

- [ ] All acceptance criteria have a passing test.
- [ ] `go test ./...` produces no failures.
- [ ] `go vet ./...` reports no issues.
- [ ] No new lint errors.
- [ ] API documentation updated if endpoints have changed.
- [ ] No debug artifacts or commented-out code.

---

## Stories

### Story 1: [Name]

**GitLab issue:** [#N — link]
**Estimate:** [N days / N points]
**Depends on:** [Story N, or "none"]

**Acceptance criteria:**

- [ ] Given [context], when [action], then [result].
- [ ] Given [context], when [action], then [result].

**Tasks:**

1. [ ] Write the failing integration test for [behavior]
2. [ ] Implement [handler/service/repository]
3. [ ] Write unit tests for [edge cases]
4. [ ] Update the OpenAPI spec / proto file

---

### Story 2: [Name]

**GitLab issue:** [#N — link]
**Estimate:** [N days / N points]
**Depends on:** Story 1

**Acceptance criteria:**

- [ ] Given [context], when [action], then [result].

**Tasks:**

1. [ ] ...

---

## Story sequence

[Dependency graph — which stories must be in production before others can begin.]

```text
Story 1 → Story 2 → Story 4
               ↘ Story 3
```

---

## Total estimate

| Story | Estimate |
| ----- | -------- |
| Story 1 | [N days] |
| Story 2 | [N days] |
| **Total** | **[N days]** |

*Estimates are indicative (±50%) unless stated otherwise.*

---

## Required coordination

[Stories that require changes across multiple repos or coordinated deploys.]

| Story | Services involved | Notes |
| ----- | ----------------- | ----- |
| [Story N] | [service-a, service-b] | [deploy order] |

---

*Next step: `/feature:gitlab`*
