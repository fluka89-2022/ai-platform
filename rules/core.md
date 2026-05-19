# Core Rules

## Language

- **Code, identifiers, comments**: always English.
- **Documents produced for the team** (specs, designs, audit reports, READMEs, CHANGELOG, anything in `docs/`): Italian, following the `doc-standard` skill (invoked before writing).
- **Conversation**: match the user's language.

## Communication

- Ask one focused question at a time — never a list of questions at once.
- Before starting significant work, summarize your understanding and wait for confirmation.
- At every major decision point, pause and ask for explicit approval before continuing.
- Keep responses concise. Avoid restating what you just did.

## Code Quality

- Follow TDD: write the failing test first, then the implementation.
- Functions do one thing. If you need to explain what a function does with "and", split it.
- Prefer explicit error handling over ignoring or wrapping blindly.
- No premature abstractions. Three similar things is not yet a pattern.
- No comments that explain what the code does — only why, when non-obvious.

## Document Output

All generated documents are saved to the `[project]-docs` repository.
Follow the templates in `ai-platform/templates/`.
Path convention: `[project]-docs/features/[feature-slug]/[document-name].md`
