# Skills

Project-local skills in `ai-platform/skills/`, symlinked to `.claude/skills/` by `setup-workspace.sh`.

Each skill is a directory with a required `SKILL.md` (YAML frontmatter + instructions), per
[Agent Skills best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices).
Optional subfolders: `assets/` (templates), `references/` (detailed docs), `scripts/` (utilities).

Invoke with `Skill("<name>")` — only `name` and `description` from frontmatter load at startup;
`SKILL.md` and linked files load when the skill is relevant.

## Top-level skills

| Skill (`name`) | When to invoke |
| -------------- | -------------- |
| `doc-standard` | Before writing any Markdown document — formatting, style, frontmatter, Italian rules |
| `technical-writing` | Functional analyses, functional specs, technical designs, implementation plans |
| `gitlab` | Any GitLab interaction — dispatches to sub-skills for issues, MRs, milestones |
| `codebase-analysis` | Impact analysis, dependency mapping, entry-point discovery |
| `go-audit` | Auditing a Go module — security, quality, performance, pprof |
| `go-readme` | Writing or updating a README for a Go service |
| `changelog` | Generating a Keep a Changelog entry in Italian by comparing two Git branches |

## GitLab standalone skills

| Skill (`name`) | When to invoke |
| -------------- | -------------- |
| `gitlab-init` | Initializing a GitLab project with workflow/type/kind labels |
| `gitlab-track` | Creating a GitLab issue (bug / feature / tech-debt / documentation) via glab |
| `story-breakdown` | Breaking down a user story into atomic, implementable GitLab tasks with effort estimates |
| `issue-draft` | Creating GitLab issue draft `.md` files from a task list or a single task description |
| `story-workflow` | Full story-to-issues pipeline with persistent state (breakdown → draft → review → publish) |
| `gitlab-review` | Creating or publishing a merge request on GitLab via glab |
| `gitlab-story` | Creating a story or epic with branch strategy and child issue management |
| `gitlab-plan` | Creating, updating, or closing a GitLab milestone |

## GitLab sub-skills (dispatched from `gitlab`)

| Skill (`name`) | When to invoke |
| -------------- | -------------- |
| `gitlab-issue` | Creating a GitLab issue via glab |
| `gitlab-mr` | Creating a merge request description via glab |
| `gitlab-milestone` | Creating, updating, or closing a milestone via glab |
| `gitlab-resolve` | Implementing an existing GitLab issue (short or long path by label) |

## Layout

```text
skills/
├── INDEX.md
├── doc-standard/SKILL.md
├── technical-writing/SKILL.md
├── codebase-analysis/SKILL.md
├── go-audit/SKILL.md
├── go-readme/SKILL.md
├── changelog/SKILL.md
├── gitlab-init/SKILL.md
├── gitlab-track/SKILL.md
├── story-breakdown/SKILL.md
├── issue-draft/SKILL.md
├── story-workflow/SKILL.md
├── gitlab-review/SKILL.md
├── gitlab-story/SKILL.md
└── gitlab/
    ├── SKILL.md
    ├── assets/              # issue/MR/milestone templates
    ├── issue/SKILL.md
    ├── mr/SKILL.md
    ├── plan/SKILL.md
    └── resolve/SKILL.md
```

## External plugins

| Plugin | When to use |
| ------ | ----------- |
| `cc-skills-golang:*` | Go idioms, patterns, testing, concurrency — loaded automatically by the plugin system |
| `superpowers:*` | Extended capabilities (parallel agents, TDD, debugging, planning) — loaded automatically |
