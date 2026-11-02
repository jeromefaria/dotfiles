# Config Directory

This directory contains XDG-compliant application configurations. These files are designed to be symlinked to `~/.config/` for use by various applications.

## How It Works

**Source of truth**: `~/dotfiles/config/*` (this directory)
- Contains the **actual configuration files and directories**
- Tracked in git for version control
- Should contain **real files and directories, NOT symlinks** — with two
  deliberate exceptions, below

How it reaches `~/.config` depends on the install profile.

### Personal profile — the whole directory

```
~/.config → ~/dotfiles/config
```

One symlink. Everything in this directory is live the moment it lands, so
adding a config here needs no `install.sh` change. That matters: the per-item
list described below had quietly fallen eighteen configs behind what the repo
tracked, and nothing failed, because the machine it was written on already had
this link.

The trade is that `~/.config` becomes a git working tree. Any application that
writes there writes into the repo, which is why `.gitignore` carries an entry
per piece of state or credential (see **Note on Sensitive Files**). A new app
appearing in `git status` is the signal that it needs triaging into "config,
version it" or "state, ignore it".

`neomutt` and `tmuxinator` are the two exceptions to the no-symlinks rule: their
real homes are `mail/mutt` and `terminal/tmux/tmuxinator`, and inside this
directory they are **relative** symlinks pointing back out, precisely so the
whole-directory link picks them up.

### Work profile — named items only

```
~/.config/            # a real directory
~/.config/nvim   → ~/dotfiles/config/nvim
~/.config/bat    → ~/dotfiles/config/bat
```

A single link cannot filter, and a work machine has no business with the
neomutt Gmail account, the Soulseek client or the music-library tooling. So the
work profile links an explicit list instead; `scripts/install.sh::link_dotfiles`
holds it.

## ⚠️ Important: Avoiding Circular Symlinks

**DO NOT** create symlinks within `~/dotfiles/config/` that point to themselves. This creates circular references and breaks the configuration.

**WRONG** (Circular symlink):
```bash
~/dotfiles/config/nvim → /Users/username/dotfiles/config/nvim  # Points to itself!
```

**RIGHT** (Real directory):
```bash
~/dotfiles/config/nvim/  # Real directory containing files
```

`scripts/install.sh::create_symlink` carries two guards for this. The first
refuses a **source** that is itself a symlink. The second, `same_path`, refuses a
**target that already resolves to the source** — which is the sneakier case,
because under the personal layout `~/.config/nvim` *is* `config/nvim`, reached
through the symlinked parent. Neither the source nor the target is a symlink
there, so only a physical-path comparison catches it; without it, the `rm -rf`
that clears the way for a new link deletes the config it was about to link and
leaves a dangling symlink behind. `scripts/test-install-symlink.sh` TEST 8 is
the regression test.

## Structure

Each subdirectory is one application's configuration. `ls` here is the
authoritative list — an enumeration in this file is exactly the kind of thing
that goes stale, which is the lesson the per-item install list already taught.
What is worth knowing is the three kinds of thing you will find:

**Versioned configuration.** The majority: editor, shell, prompt, file-manager,
music and window-management configs, committed in full and restored verbatim on
a new machine. This is the point of the directory.

**Relative symlinks out of the tree.** Only `neomutt` and `tmuxinator`, covered
above.

**Gitignored state and credentials.** Not configuration, and deliberately not
committed — libraries and databases (`beets/library.db`), session and log files
(`musikcube/session.json`), caches (`__pycache__`), machine-local tokens
(`gh/hosts.yml`, `op/config`, `beets/discogs_token.json`). Where a tool needs a
credential to work at all, a `.template` sits beside the ignored real file so a
fresh machine knows what to fill in.

## Installation

The main `install.sh` script in the repository root handles symlinking these configurations to the appropriate locations in your home directory.

## XDG Base Directory Specification

This directory follows the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html), which standardizes configuration file locations across Unix-like systems.

Most modern applications respect the `$XDG_CONFIG_HOME` environment variable (defaults to `~/.config/`), making configuration management cleaner and more organized.

## Note on Sensitive Files

Several sensitive files are excluded from version control via `.gitignore`:
- Credentials and tokens
- Session data and history
- Cache files
- Application databases

If a tool requires sensitive configuration, you'll find a `.template` file or documentation in the tool's subdirectory.
