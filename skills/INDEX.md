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

## GitLab sub-skills (dispatched from `gitlab`)

| Skill (`name`) | When to invoke |
| -------------- | -------------- |
| `gitlab-issue` | Creating a GitLab issue (bug / feature / technical-debt / documentation) via glab |
| `gitlab-mr` | Creating a merge request description via glab |
| `gitlab-milestone` | Creating a milestone via glab |
| `gitlab-resolve` | Implementing an existing GitLab issue (short or long path by label) |
| `gitlab-parent-issue` | Creating a parent issue that groups existing issues under a single review artifact |

## Layout

```text
skills/
├── INDEX.md
├── doc-standard/SKILL.md
├── technical-writing/SKILL.md
├── codebase-analysis/SKILL.md
├── go-audit/SKILL.md
├── go-readme/SKILL.md
└── gitlab/
    ├── SKILL.md
    ├── assets/              # issue/MR/milestone templates
    ├── issue/SKILL.md
    ├── mr/SKILL.md
    ├── milestone/SKILL.md
    └── resolve/SKILL.md
```

## External plugins

| Plugin | When to use |
| ------ | ----------- |
| `cc-skills-golang:*` | Go idioms, patterns, testing, concurrency — loaded automatically by the plugin system |
| `superpowers:*` | Extended capabilities (parallel agents, TDD, debugging, planning) — loaded automatically |
