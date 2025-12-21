# Starship Configuration

Fast, customizable shell prompt with vi mode indicator.

## Overview

[Starship](https://starship.rs/) is a minimal, blazing-fast shell prompt written in Rust. This dotfiles uses a minimal configuration focused on:

- **Vi mode indicator** - Shows current Vim mode (like Neovim's status line)
- **Clean output** - Most language/tool modules disabled for speed
- **Fast startup** - Typically <10ms prompt render time
- **Cross-shell compatible** - Works with ZSH, Bash, Fish, etc.

## Quick Links

- [Configuration](#configuration)
- [Vi Mode Indicator](#vi-mode-indicator)
- [Customization](#customization)
- [Available Modules](#available-modules)
- [Troubleshooting](#troubleshooting)

---

## Installation

### Prerequisites

```bash
# Install Starship
brew install starship
```

### Configuration

Starship is configured automatically via dotfiles:

**Symlink (created by install script):**
```bash
config/starship.toml → ~/.config/starship.toml
```

**Shell integration (in shell/zshrc):**
```bash
eval "$(starship init zsh)"
```

## Configuration

### Current Setup

This dotfiles uses a **minimal configuration** (25 lines total):

```toml
# Vi Mode Indicator (primary feature)
[character]
success_symbol = "[❯](bold green)"    # Normal mode, command succeeded
error_symbol = "[❯](bold red)"        # Normal mode, command failed
vicmd_symbol = "[❮](bold yellow)"     # Vi command mode (Esc in vi-mode)

# Disabled modules for clean, fast prompt
[nodejs]
disabled = true

[php]
disabled = true

[aws]
disabled = true

[ruby]
disabled = true
```

### What It Does

**The prompt shows:**
1. **Current directory** (automatic, enabled by default)
2. **Git branch and status** (automatic, enabled by default)
3. **Vi mode indicator** (custom configuration)
   - `❯` in green - Normal/insert mode, last command succeeded
   - `❯` in red - Normal/insert mode, last command failed
   - `❮` in yellow - Vi command mode (when you press Esc)

**Example prompts:**
```bash
# Normal mode, in a git repo
~/dotfiles master ❯

# Vi command mode (after pressing Esc in vi-mode)
~/dotfiles master ❮

# Last command failed
~/dotfiles master ❯  # (red)
```

---

## Vi Mode Indicator

### What It Shows

The prompt character changes based on your shell's vi mode:

| Symbol | Color | Mode | Meaning |
|--------|-------|------|---------|
| `❯` | Green | Insert/Normal | Last command succeeded |
| `❯` | Red | Insert/Normal | Last command failed |
| `❮` | Yellow | Command | Vi command mode (Esc pressed) |

### Why It's Useful

When using ZSH vi-mode (enabled in `shell/zshrc`):
- Press `Esc` or `jj`/`jk` → Enter command mode → Prompt shows `❮`
- Press `i` or `a` → Enter insert mode → Prompt shows `❯`
- Visual feedback like Vim/Neovim's mode indicator

### Integration with Vi Mode

**ZSH vi-mode settings (in shell/zshrc):**
```bash
# Vi mode plugin loaded
plugins=(... vi-mode ...)

# Key bindings for vi mode
bindkey 'jk' vi-cmd-mode
bindkey 'jj' vi-cmd-mode
```

Starship automatically detects the vi mode and updates the prompt.

---

## Customization

### Enabling More Modules

To show language versions, tools, or other info, edit `~/.config/starship.toml`:

```toml
# Show Node.js version
[nodejs]
disabled = false
format = "via [⬢ $version](bold green) "

# Show Python version
[python]
disabled = false
format = "via [🐍 $version](bold yellow) "

# Show command duration
[cmd_duration]
min_time = 500
format = "took [$duration](bold yellow) "
```

### Changing Symbols

**Customize the vi mode symbols:**
```toml
[character]
success_symbol = "[➜](bold green)"
error_symbol = "[✗](bold red)"
vicmd_symbol = "[N](bold yellow)"
```

**Other popular symbols:**
- `→`, `»`, `›`, `▶`, `➤` - Various arrows
- `$`, `%`, `#` - Traditional shell prompts
- `λ`, `ƛ` - Lambda symbols (functional programming)
- Custom text: `"[INS]"`, `"[CMD]"`

### Adding Git Info

Git is already enabled by default. To customize:

```toml
[git_branch]
symbol = " "
truncation_length = 20

[git_status]
ahead = "⇡${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
behind = "⇣${count}"
```

### Directory Display

```toml
[directory]
truncation_length = 3
truncate_to_repo = true
format = "[$path]($style)[$read_only]($read_only_style) "
```

---

## Available Modules

Common modules you can enable by removing `disabled = true`:

### Development Tools

| Module | Shows | Default Symbol |
|--------|-------|----------------|
| `nodejs` | Node.js version | ⬢ |
| `python` | Python version | 🐍 |
| `ruby` | Ruby version | 💎 |
| `rust` | Rust version | 🦀 |
| `golang` | Go version | 🐹 |
| `php` | PHP version | 🐘 |
| `java` | Java version | ☕ |

### Cloud & Infrastructure

| Module | Shows | Info |
|--------|-------|------|
| `aws` | AWS profile | Current AWS_PROFILE |
| `gcloud` | GCP project | Active GCP project |
| `kubernetes` | K8s context | Current cluster |
| `docker_context` | Docker context | Active context |
| `terraform` | Terraform workspace | Current workspace |

### System Info

| Module | Shows | Info |
|--------|-------|------|
| `battery` | Battery level | Percentage |
| `time` | Current time | HH:MM:SS |
| `username` | Current user | Username |
| `hostname` | Machine name | Hostname |
| `cmd_duration` | Command time | Execution duration |

### Full Module List

See [Starship Configuration Reference](https://starship.rs/config/) for all 50+ modules.

---

## Presets

Starship has pre-built themes. To use one:

```bash
# View available presets
starship preset -l

# Apply a preset (overwrites current config)
starship preset nerd-font-symbols -o ~/.config/starship.toml

# Preview a preset
starship preset pure-preset
```

**Popular Presets:**
- `nerd-font-symbols` - Rich icons (requires Nerd Font)
- `no-nerd-font` - ASCII-only symbols
- `pure-preset` - Minimal like Pure ZSH theme
- `pastel-powerline` - Colorful Powerline style
- `tokyo-night` - Tokyo Night theme colors

**After applying a preset, re-add vi mode indicator if desired.**

---

## Performance

Starship is designed for speed:

**Benchmark your prompt:**
```bash
time starship prompt
```

**Expected performance:**
```
real    0m0.008s    # <10ms is excellent
user    0m0.005s
sys     0m0.003s
```

**Optimization tips:**
1. Disable unused modules (already done in this config)
2. Use `starship config` to find slow modules
3. Limit directory truncation: `truncation_length = 3`
4. Disable git status in large repos: `[git_status] disabled = true`

---

## Troubleshooting

### Issue: Prompt not showing

**Check if Starship is loaded:**
```bash
echo $STARSHIP_SHELL
# Should output: zsh
```

**Solution:** Ensure `eval "$(starship init zsh)"` is in your `.zshrc`

```bash
grep "starship init" ~/dotfiles/shell/zshrc
```

### Issue: Vi mode indicator not working

**Check vi-mode plugin:**
```bash
echo $plugins | grep vi-mode
```

**Solution:** Enable vi-mode in shell/zshrc:
```bash
plugins=(... vi-mode ...)
```

### Issue: Icons/symbols not displaying

**Install a Nerd Font:**
```bash
brew tap homebrew/cask-fonts
brew install font-hack-nerd-font
# or
brew install font-fira-code-nerd-font
```

**Set in your terminal:**
- iTerm2: Preferences → Profiles → Text → Font
- Terminal.app: Preferences → Profiles → Font

### Issue: Git status slow in large repos

**Disable git status temporarily:**
```toml
[git_status]
disabled = true
```

Or only in specific repos:
```bash
git config --local starship.disable true
```

### Issue: Wrong colors

**Check terminal support:**
```bash
echo $TERM
# Should be: xterm-256color or similar
```

**Fix:**
```bash
export TERM=xterm-256color
# Add to ~/.zshrc.local
```

---

## Comparison

### Starship vs Other Prompts

| Feature | Starship | Powerlevel10k | Pure | Oh My ZSH Default |
|---------|----------|---------------|------|-------------------|
| Speed | ⚡⚡⚡ | ⚡⚡ | ⚡⚡⚡ | ⚡⚡ |
| Customization | High | Very High | Low | Medium |
| Setup | Easy | Wizard | Easy | Easy |
| Language | Rust | ZSH | ZSH | ZSH |
| Cross-shell | Yes | No | No | No |
| Vi mode indicator | Yes ✅ | Yes | No | No |

**Why Starship?**
- **Fast:** Written in Rust, parallel module execution
- **Simple:** Easy to configure with TOML
- **Universal:** Works in Bash, ZSH, Fish, PowerShell
- **Maintained:** Active development, frequent updates
- **Minimal:** This config is 25 lines

---

## Migration from Other Prompts

### From Oh My Zsh Themes

Starship replaces Oh My Zsh themes. Keep Oh My Zsh for plugins:

```bash
# In ~/.zshrc - remove theme line:
# ZSH_THEME="robbyrussell"  ← Delete or comment out

# Starship is already initialized in shell/zshrc
eval "$(starship init zsh)"
```

### From Powerlevel10k

1. **Remove Powerlevel10k:**
   ```bash
   # Remove from ~/.zshrc
   # source ~/.powerlevel10k/powerlevel10k.zsh-theme
   ```

2. **Starship is already configured** in this dotfiles

3. **Reload shell:**
   ```bash
   source ~/.zshrc
   ```

---

## Related Documentation

- [Shell Configuration](../../shell/README.md) - ZSH setup and vi-mode
- [Architecture](../../docs/ARCHITECTURE.md) - How components integrate
- [Configuration Index](../../CONFIGURATION-INDEX.md) - All configurations

## Resources

- [Official Documentation](https://starship.rs/)
- [Configuration Reference](https://starship.rs/config/)
- [Presets Gallery](https://starship.rs/presets/)
- [GitHub Repository](https://github.com/starship/starship)
- [Advanced Config Examples](https://starship.rs/advanced-config/)

---

## Related Documentation

- [Shell Configuration](../../shell/README.md) - ZSH setup and vi-mode
- [Configuration Index](../../CONFIGURATION-INDEX.md) - All configurations
- [Architecture](../../docs/ARCHITECTURE.md) - How components integrate
- [Troubleshooting](../../docs/TROUBLESHOOTING.md) - Common issues

## Getting Help

- Run health check: `./scripts/health-check.sh`
- Review [Troubleshooting Guide](../../docs/TROUBLESHOOTING.md)
- Check [Shell documentation](../../shell/README.md)

---

**Status:** ✅ Complete
**Last Updated:** 2025-12-20
