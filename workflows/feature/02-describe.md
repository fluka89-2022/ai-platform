# Workflow: Feature Describe (Step 2 of 6)

## Purpose

Transform the functional analysis into a precise functional specification — a document that defines *what* will be built from the user's perspective. This is the product contract.

## Prerequisites

- `functional-analysis.md` exists and is approved by the user.

## Input

Read `[project]-docs/features/[feature-slug]/functional-analysis.md`.

If the file does not exist, tell the user:
> "I don't see a functional analysis for this feature. Please run `/feature:analyze` first."

## Process

### 1. Review the functional analysis

Read the analysis. Note:
- The open questions — are they resolved? If not, ask the user before writing the spec.
- The proposed direction — this becomes the basis for the spec.
- The risks and unknowns — some may become explicit out-of-scope items.

### 2. Resolve open questions

For each open question listed in the analysis, ask the user for a decision. One question at a time.
Do not write the spec until the questions that affect scope are answered.

### 3. Draft the functional specification

Invoke the `technical-writing` skill → section "Writing a Functional Specification".
Read `templates/functional-spec.md` for the required structure.

For each user story:
- Write it in the standard format: `As a [role], I want [action] so that [benefit]`.
- Write acceptance criteria in Given/When/Then format.
- Criteria must be testable — no vague language.

Explicitly list what is out of scope. This is as important as what's in scope.

### 4. Review with user

Before writing the file, present the draft. Ask:
> "Does this accurately describe what we want to build? Is anything missing or wrong?"

Incorporate feedback, then write the file.

### 5. Write the output document

Write to: `[project]-docs/features/[feature-slug]/functional-spec.md`

### 6. Stop and request approval

> "The functional specification is complete. Please review it carefully — this is the product contract for this feature.
> When you're ready to continue, run `/feature:design`."

Do not proceed further.

## Output

→ `[project]-docs/features/[feature-slug]/functional-spec.md`
→ Template: `templates/functional-spec.md`
