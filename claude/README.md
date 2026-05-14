# claude

Canonical home for the personal-layer `CLAUDE.md` — cross-project instructions auto-loaded by Claude Code in every session.

## Location

Canonical: `~/dotfiles/claude/CLAUDE.md`. Symlinked to `~/.claude/CLAUDE.md`, which is where Claude Code looks for user-level instructions.

The file is intentionally project-agnostic — no client names, employer paths, work emails, ticket-system IDs, or repo slugs. Project-specific specialisation belongs in each project's own `CLAUDE.md` (typically gitignored at the project root) via a "project instantiations" table that maps personal-layer placeholders (base branch, test commands, reviewer handles, ticket URLs, etc.) to concrete project values.

## What goes here

- **Claude Code Rules** — personal preferences (no Claude attribution, modern JS, clean code, blank-line discipline, `--force-with-lease`, descriptive names, etc.)
- **Task Workflow** — cross-project discipline: starting → development → code review → pre-reset gates → soft reset + draft PR + body template → post-reset checks → mark ready → merge → stacked-PR recipe → after-merge
- **Task Estimation** — format conventions and story-point scale (project layer supplies the Stream and Parent epic)

## What does NOT go here

- Stack details (Vue, React, Python, etc.) — project layer
- Test/lint/type-check commands — project layer
- Branch names, ticket URLs, reviewer handles, Jira IDs — project layer
- Client / employer / repo names — project layer
- Anything that wouldn't make sense across every project Jerome works on
