# Workflow: Planning

## Purpose

Structure work for a sprint, iteration, or milestone — prioritizing, sequencing, and estimating a set of issues or ideas.

## Use Cases

- Sprint planning from a backlog of GitLab issues.
- Milestone planning for a set of features.
- Breaking down a large initiative into sequenced work.

## Process

### 1. Gather the inputs

Ask the user:
- What is the planning horizon? (sprint, milestone, quarter?)
- What are the inputs? (GitLab issues, ideas, technical debt list?)
- What are the constraints? (team size, known dependencies, release date?)
- What's the goal of this planning session? (fill a sprint, sequence a roadmap, estimate effort?)

### 2. Collect the items

If working from GitLab issues:
- Invoke the `gitlab` skill for how to query our instance.
- Fetch the relevant issues (milestone, label filter, or explicit list).

If working from a list the user provides:
- Capture each item with its description and any known constraints.

### 3. Analyze and clarify

For each item:
- Is it clear enough to estimate? If not, flag it — it needs a spec before planning.
- Are there dependencies between items? Map them.
- Are there hidden risks or unknowns that affect the estimate?

Ask clarifying questions one at a time. Don't try to resolve everything at once.

### 4. Propose structure

Depending on the planning goal:

**Sprint filling**: Group items into a proposed sprint, respecting capacity and dependencies.
Present the proposal: "Here's what I'd put in this sprint and why: [list with reasoning]."

**Sequencing**: Order items considering: dependencies, risk (higher risk earlier), value (higher value earlier), team constraints.
Present as a numbered sequence with rationale.

**Estimation**: Provide story point or day estimates per item. Flag rough estimates.

### 5. Iterate

Present the proposed plan and ask for feedback:
> "Here's the proposed plan. Does this match your constraints? Anything to add, remove, or reprioritize?"

Adjust based on feedback. Repeat until the user is satisfied.

### 6. Output

Summarize the final plan in a clear list:
- Items in priority/sequence order.
- Estimate per item.
- Total estimate.
- Key dependencies or risks called out.

If needed, offer to update GitLab (milestone assignments, labels) — but confirm before making any changes.
