# jerome-tooling

Shared config for the personal session-tooling scripts (`session-close.py`, `standup.py`, `sprint-status.py`, `build-session-starter.py`).

## Location

Canonical: `~/dotfiles/config/jerome-tooling/config.json`. The `~/.config` parent is already a symlink to `~/dotfiles/config`, so scripts can read either path interchangeably.

Override per-shell via `JEROME_TOOLING_CONFIG=/path/to/config.json`.

`config.json` is gitignored (contains identifying info — work email, client name, Jira URL). Copy `config.example.json` to bootstrap a new install.

## Schema

| Section | Purpose |
|---------|---------|
| `user` | Identity — keychain account for Jira auth, email, GitHub handle, Jira account ID. |
| `project` | Workspace layout — workspace root, doc dir, primary repo, CLAUDE.md path, project-state file, git repos to scan for commit history. Paths starting with `~` are expanded. |
| `jira` | Jira instance — base URL, anchor ticket for sprint lookup, custom field IDs (sprint = `customfield_10020`, points = `customfield_10028`). |
| `github` | List of GitHub `org/repo` slugs scanned for PR history. |
| `locale` | `region` (informational) + `bank_holidays` (YYYY-MM-DD list) used to compute the practical sprint-end date. |

## Adding a new project

The scripts assume a single active project at a time. Edit `config.json` when switching contexts, or point `JEROME_TOOLING_CONFIG` at a per-project file. A `--project <name>` selector with multi-project layouts is a planned follow-up.
