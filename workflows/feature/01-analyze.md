# Workflow: Feature Analyze (Step 1 of 6)

## Purpose

Explore the problem space for a feature request. Produce a functional analysis that surfaces open questions, risks, and directions — without committing to a solution yet.

## Prerequisites

- A feature request or idea (can be vague — that's what this step is for).
- Access to the `[project]-docs` repository in the workspace.

## Input

- User's description of the feature (from the command argument or conversation).
- Existing project documentation (architecture docs, prior specs, ADRs).

## Process

### 1. Understand the request

Ask the user to describe the feature. Explore with focused questions, one at a time:
- What problem does this solve?
- Who experiences this problem and how often?
- What's the current workaround, if any?
- Is there a deadline or business driver?

Do not jump to solutions yet.

### 2. Load the codebase analysis skill

Invoke the `codebase-analysis` skill to guide how you explore existing documentation and service code.

### 3. Research existing context

Explore the `[project]-docs` repo for relevant prior documents:
- Architecture decisions (ADRs)
- Existing feature specs that relate
- API documentation
- Data model documentation

Explore the relevant service repos to understand current behavior.

### 4. Brainstorm

Explore the solution space with the user:
- What are the main approaches?
- What are the constraints (technical, timeline, team)?
- What are the biggest unknowns?
- What questions need answers before we can design a solution?

Present options, don't prescribe. Use "we could" framing.

### 5. Produce the output document

Invoke the `technical-writing` skill → section "Writing a Functional Analysis".
Read `templates/functional-analysis.md` for the required structure.

Write the document to: `[project]-docs/features/[feature-slug]/functional-analysis.md`

The document must include all open questions discovered during step 4.

### 6. Stop and request approval

Present the document content to the user. Then say explicitly:

> "The functional analysis is complete. Please review it and let me know if anything needs to change.
> When you're ready to continue, run `/feature:describe`."

Do not proceed further. Wait for the user to run the next command.

## Output

→ `[project]-docs/features/[feature-slug]/functional-analysis.md`
→ Template: `templates/functional-analysis.md`
