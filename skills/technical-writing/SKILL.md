---
name: technical-writing
description: Guides structure and style for functional analyses, specs, technical designs, and implementation plans in the feature pipeline. Use when writing feature documentation or when workflows reference technical-writing sections.
---

# Technical Writing Skill

Before producing any document, invoke the `doc-standard` skill.

## Purpose

Guidelines for producing clear, structured technical documentation in the feature pipeline.
Use this skill whenever writing functional analyses, functional specs, technical designs, or implementation plans.

## General Principles

- **Audience-aware**: know who will read each document (product, tech, both) and calibrate detail level.
- **One idea per section**: don't mix concerns. A "Technical Design" doesn't contain user stories.
- **Explicit scope**: every document states what is in scope and what is explicitly out of scope.
- **Living documents**: mark status clearly (`Draft`, `In Review`, `Approved`) and include the next step.
- **Verifiable criteria**: acceptance criteria must be testable — avoid "should work well" style language.

## Document Hierarchy

```
functional-analysis.md   ← exploration, open questions, no commitments
       ↓
functional-spec.md       ← what we build (user-facing), approved by product
       ↓
technical-design.md      ← how we build it, approved by tech lead
       ↓
implementation-plan.md   ← stories, tasks, estimates, approved by team
```

Each document builds on the previous. Never skip levels.

## Writing a Functional Analysis

Goal: explore the problem space, surface unknowns, align on direction.

Structure:
1. **Overview** — one paragraph, plain language, no jargon.
2. **Problem Statement** — what pain exists today, for whom, how often.
3. **Current Behavior** — factual description of today's system.
4. **Proposed Direction** — high-level what we might build (not how).
5. **Open Questions** — explicitly listed, each with an owner if known.
6. **Risks and Unknowns** — technical, product, or organizational.
7. **Related Documents** — links to existing specs, ADRs, issues.

Style: exploratory, not prescriptive. Use "we could" not "we will".

## Writing a Functional Specification

Goal: define precisely what will be built from the user's perspective.

Structure:
1. **Overview** — one paragraph summary.
2. **Scope** — in scope (bulleted list) | out of scope (bulleted list).
3. **User Stories** — format: `As a [role], I want [action] so that [benefit]`.
4. **Acceptance Criteria** — per story, format: `Given [context], When [action], Then [outcome]`.
5. **Business Rules** — invariants, constraints, edge cases.
6. **Data Requirements** — what data is created, read, updated, deleted.
7. **Non-Functional Requirements** — performance, availability, security constraints.

Style: precise and unambiguous. A developer should be able to implement from this document alone.

## Writing a Technical Design

Goal: describe the technical solution and its impact on the system.

Structure:
1. **Overview** — what we're building and the key technical decisions.
2. **Context and Constraints** — why we designed it this way (not obvious reasons).
3. **Architecture** — diagrams or ASCII art where helpful.
4. **API Changes** — new/modified endpoints with request/response schemas.
5. **Data Model Changes** — new tables/fields/indexes with migration strategy.
6. **Service Impact** — which services change and how; new inter-service calls.
7. **Implementation Approach** — phasing, rollout strategy, feature flags if any.
8. **Risks and Mitigations** — what could go wrong and how we'd handle it.
9. **Alternatives Considered** — other approaches and why we rejected them.

Style: technical and precise. Include enough detail for a code review to be meaningful.

## Writing an Implementation Plan

Goal: break work into executable units with clear acceptance criteria.

Structure:
1. **Stories** — one per independently deployable unit of work.
   - Story title: `[VERB] [NOUN]` (e.g., "Add user profile endpoint")
   - Acceptance criteria: bulleted, testable statements
   - Tasks: numbered, each completable in a single work session
2. **Dependencies** — ordering constraints between stories.
3. **Estimate** — story points or days per story (mark as rough if uncertain).
4. **Definition of Done** — shared criteria applying to all stories (tests, docs, etc.).

Style: actionable. Every task should have a clear "done" state.

## Feature pipeline navigation

Include at the bottom of each feature pipeline document:

```text
---
*Next step: /feature:[next-command]*
```
