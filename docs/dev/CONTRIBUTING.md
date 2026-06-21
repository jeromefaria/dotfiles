# Contributing Guide

Thank you for considering contributing to this dotfiles repository!

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
- [Development Guidelines](#development-guidelines)
- [Documentation Requirements](#documentation-requirements)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Pull Request Process](#pull-request-process)

---

## Code of Conduct

### Our Standards

**Be respectful and constructive:**
- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

**Not acceptable:**
- Trolling, insulting/derogatory comments, and personal attacks
- Public or private harassment
- Publishing others' private information without permission
- Other conduct which could reasonably be considered inappropriate

---

## How to Contribute

### Reporting Issues

**Before submitting an issue:**

1. **Check existing issues:**
   - Search [open issues](https://github.com/jeromefaria/dotfiles/issues)
   - Check [closed issues](https://github.com/jeromefaria/dotfiles/issues?q=is%3Aissue+is%3Aclosed)

2. **Gather information:**
   - Run health check: `./scripts/health-check.sh`
   - Check relevant logs
   - Note your macOS version, shell version, etc.

**When submitting an issue:**

- **Use a clear and descriptive title**
- **Provide detailed steps to reproduce**
- **Include your environment:**
  ```
  - macOS version:
  - ZSH version:
  - Homebrew version:
  - Relevant tool versions:
  ```
- **Attach logs or screenshots** if applicable
- **Describe expected vs. actual behavior**

**Issue templates:**

```markdown
**Description:**
Brief description of the issue.

**Steps to Reproduce:**
1. Step 1
2. Step 2
3. ...

**Expected Behavior:**
What should happen.

**Actual Behavior:**
What actually happens.

**Environment:**
- macOS: 14.x Sonoma
- ZSH: 5.9
- Output of health-check.sh: [paste output]

**Logs:**
[Paste relevant logs]

**Additional Context:**
Any other information that might be helpful.
```

### Suggesting Enhancements

**Enhancement suggestions are welcome!**

**Before suggesting:**
- Check if it already exists
- Check if it's in the [ROADMAP](ROADMAP.md)
- Consider if it fits the scope of personal dotfiles

**When suggesting:**

```markdown
**Feature Request: [Short description]**

**Problem:**
Describe the problem this solves or the use case.

**Proposed Solution:**
How you envision this working.

**Alternatives Considered:**
Other approaches you've thought about.

**Additional Context:**
Screenshots, examples, links to similar implementations.
```

### Submitting Changes

**Contribution process:**

1. **Fork the repository:**
   ```bash
   # On GitHub, click "Fork"
   ```

2. **Clone your fork:**
   ```bash
   git clone https://github.com/YOUR-USERNAME/dotfiles.git
   cd dotfiles
   ```

3. **Create a feature branch:**
   ```bash
   git checkout -b feature/descriptive-name
   # or
   git checkout -b fix/issue-description
   ```

4. **Make your changes:**
   - Follow coding standards (see below)
   - Add/update documentation
   - Test thoroughly

5. **Commit your changes:**
   ```bash
   git add .
   git commit -m "feat(component): description"
   ```

6. **Push to your fork:**
   ```bash
   git push origin feature/descriptive-name
   ```

7. **Open a Pull Request:**
   - Go to original repository on GitHub
   - Click "New Pull Request"
   - Select your fork and branch
   - Fill out PR template (see below)

---

## Development Guidelines

### Testing Changes

**Before submitting a PR:**

1. **Test locally:**
   ```bash
   # Test shell config
   zsh -n ~/dotfiles/terminal/zsh/zshrc

   # Test in subshell
   zsh -c "source ~/dotfiles/terminal/zsh/zshrc"

   # Run health check
   ./scripts/health-check.sh
   ```

2. **Test installation:**
   ```bash
   # On a separate test system or VM
   ./scripts/bootstrap.sh
   ```

3. **Check for errors:**
   ```bash
   # Shell errors
   source ~/.zshrc && echo "OK" || echo "ERROR"

   # Neovim errors
   nvim --headless -c "quit" && echo "OK" || echo "ERROR"

   # Tmux errors
   tmux source ~/.tmux.conf && echo "OK" || echo "ERROR"
   ```

### Code Style

#### Shell Scripts

**Standard:**
- Use `#!/usr/bin/env bash` or `#!/usr/bin/env zsh`
- Include error handling
- Add usage documentation
- Quote variables: `"$variable"`
- Use meaningful variable names
- Add comments for non-obvious logic

**Example:**

```bash
#!/usr/bin/env bash
# Description: Creates and enters a directory

function mkd() {
  # Validate input
  if [[ -z "$1" ]]; then
    echo "Usage: mkd <directory_name>"
    return 1
  fi

  # Create directory and change into it
  mkdir -p "$@" && cd "$_" || return 1
}
```

**Linting:**
```bash
# Optional: Use shellcheck
brew install shellcheck
shellcheck scripts/*.sh
```

#### Configuration Files

**General:**
- Follow existing formatting style
- Add comments for non-obvious settings
- Group related settings together
- Use consistent indentation (2 spaces for most configs)

**YAML:**
```yaml
# Good
setting:
  key1: value1
  key2: value2

# Bad
setting:
 key1: value1
    key2:      value2
```

**Lua (Neovim):**
```lua
-- Good
return {
  "plugin/name",
  opts = {
    setting = true,
  },
}

-- Bad
return {"plugin/name",opts={setting=true}}
```

#### Vimscript

```vim
" Good - Descriptive comments, clear structure
" Enable line numbers
set number

" Bad - No context
set number
```

---

## Documentation Requirements

**All new configurations MUST include:**

1. **README.md with standard structure:**
   - See [Development README](README.md#documentation-standards)
   - Use component README template
   - Include all required sections

2. **Cross-references to related docs:**
   - Link from main README.md
   - Link from related component docs
   - Add to architecture doc if it's a major component

4. **Troubleshooting section:**
   - Include common issues
   - Provide solutions
   - Link to relevant logs/diagnostics

### Documentation Style

**Markdown standards:**

- Use ATX-style headers (`#` not `===`)
- Use fenced code blocks with language tags
- Use relative links: `[text](../path/file.md)`
- Include table of contents for docs > 100 lines
- Add "Status" and "Last Updated" at bottom

**Code blocks:**

````markdown
```bash
# Always specify language
command --flag value
```
````

**Links:**

```markdown
<!-- Good -->
See the [Neovim Configuration](../editors/neovim/README.md) for details.

<!-- Bad -->
See [here](../editors/neovim/README.md) for details.
```

---

## Commit Message Guidelines

### Format

Use **Conventional Commits** format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Historical Note

**Repository-wide Conventional Commits compliance:**

As of December 2025, the entire commit history (642 commits dating back to 2015) was rewritten to follow Conventional Commits format. This ensures consistency throughout the repository's lifetime and makes it easier to:

- Generate automated changelogs
- Understand changes at a glance
- Navigate commit history semantically
- Maintain professional standards across all contributions

All commits now follow the format specified in this guide, providing a clean foundation for future contributions.

### Type

**Must be one of:**

- **feat:** New feature
- **fix:** Bug fix
- **docs:** Documentation only changes
- **style:** Code style changes (formatting, no logic change)
- **refactor:** Code refactoring (no feat or fix)
- **perf:** Performance improvement
- **test:** Adding or updating tests
- **chore:** Maintenance tasks (no src/docs changes)

### Scope

**Component being modified:**

- `shell` - Shell configuration
- `neovim` - Neovim config
- `vim` - Vim config
- `git` - Git configuration
- `tmux` - Tmux configuration
- `mail` - Email configuration
- `packages` - Package management
- `scripts` - Installation/utility scripts
- `docs` - Documentation
- `config` - General config directory
- Component name (e.g., `yabai`, `beets`, `skhd`)

### Subject

- Use imperative mood: "add" not "added" or "adds"
- Don't capitalize first letter
- No period at the end
- Max 72 characters

### Body (optional)

- Explain **what** and **why**, not how
- Separate from subject with blank line
- Wrap at 72 characters

### Footer (optional)

- Reference issues: `Fixes #123`, `Closes #456`
- Note breaking changes: `BREAKING CHANGE: description`

### Examples

**Good commits:**

```
feat(shell): add zoxide integration for smart directory jumping

Replaces fasd with zoxide as it's more actively maintained and faster.
Updates cd alias to use z command. Adds zi for interactive picker.

Closes #45
```

```
fix(neovim): correct LSP configuration for Python

Python LSP wasn't attaching due to incorrect pyright setup.
Updated lua/plugins/lsp.lua to fix server configuration.

Fixes #67
```

```
docs(mail): update Gmail sync setup instructions

Gmail API changes required updating authentication steps.
Added troubleshooting section for common auth errors.
```

```
chore(packages): update Brewfile dependencies

Removed deprecated packages, added new CLI tools.
```

**Bad commits:**

```
# Bad: No type, vague
Updated some files
```

```
# Bad: Not descriptive
fix: bug
```

```
# Bad: Multiple unrelated changes
feat(shell): add alias and update neovim and fix git bug
```

---

## Pull Request Process

### PR Template

When opening a PR, use this template:

```markdown
## Description

Brief description of changes.

## Type of Change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to change)
- [ ] Documentation update

## Changes Made

- Change 1
- Change 2
- Change 3

## Testing Done

- [ ] Tested on macOS [version]
- [ ] Ran health-check.sh successfully
- [ ] Shell loads without errors
- [ ] Neovim opens without errors (if relevant)
- [ ] Tested affected components

## Documentation

- [ ] Updated component README
- [ ] Updated main README.md navigation (if new component)
- [ ] Added troubleshooting section (if applicable)

## Screenshots/Output

[If applicable, add screenshots or command output]

## Related Issues

Closes #[issue number]
```

### Review Process

**After submitting PR:**

1. **Automated checks** (if implemented):
   - Linting passes
   - No broken links
   - Shell script validation

2. **Manual review:**
   - Code quality
   - Documentation completeness
   - Test coverage
   - Breaking changes noted

3. **Feedback:**
   - Address review comments
   - Push updates to PR branch
   - Re-request review

4. **Approval:**
   - Once approved, PR will be merged
   - Squash commits if requested

### PR Checklist

**Before requesting review:**

- [ ] **Code:**
  - [ ] Follows code style guidelines
  - [ ] No unnecessary changes (whitespace, unrelated fixes)
  - [ ] Error handling included
  - [ ] Variables properly quoted

- [ ] **Documentation:**
  - [ ] README.md created/updated
  - [ ] Troubleshooting section added
  - [ ] Cross-references updated

- [ ] **Testing:**
  - [ ] Tested on fresh install
  - [ ] No shell errors
  - [ ] health-check.sh passes
  - [ ] Components work as expected

- [ ] **Git:**
  - [ ] Commits follow conventional format
  - [ ] Commits are logical and atomic
  - [ ] No merge commits (rebase if needed)
  - [ ] Branch is up to date with master

- [ ] **Other:**
  - [ ] Updated CHANGELOG.md if needed
  - [ ] Updated MIGRATION-GUIDE.md if breaking change
  - [ ] Added to ROADMAP.md if applicable

### After PR is Merged

**Clean up:**

```bash
# Update local master
git checkout master
git pull origin master

# Delete feature branch
git branch -d feature/branch-name

# Delete remote branch
git push origin --delete feature/branch-name
```

---

## Questions?

**Need help contributing?**

1. **Review documentation:**
   - [Development README](README.md)
   - [Architecture](../ARCHITECTURE.md)

2. **Check existing PRs:**
   - See how others contribute
   - Learn from PR feedback

3. **Open a discussion:**
   - [GitHub Discussions](https://github.com/jeromefaria/dotfiles/discussions)
   - Tag as "question"

4. **Open an issue:**
   - [GitHub Issues](https://github.com/jeromefaria/dotfiles/issues)
   - Tag as "question" or "help wanted"

---

## Thank You!

Your contributions make this dotfiles repository better for everyone. Whether it's:
- Reporting a bug
- Suggesting an enhancement
- Improving documentation
- Submitting code

**Every contribution is valued and appreciated!** 🎉

---

**Status:** ✅ Complete
**Last Updated:** 2025-12-20
