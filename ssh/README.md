# SSH Configuration

SSH client configuration with split portable / machine-local layout, mirroring the `git/` pattern.

## Layout

| File | Purpose | Tracked? |
|---|---|---|
| `ssh/config` | Portable defaults: agent settings, host-agnostic identity, GitHub-specific bypass of 1Password | yes |
| `ssh/config.local.example` | Template for personal/per-machine host blocks | yes |
| `~/.ssh/config.local` | Actual personal hosts (LAN boxes, work hosts, etc.) | **no** |

`~/.ssh/config` is a symlink to `~/dotfiles/ssh/config`. The tracked config pulls in `~/.ssh/config.local` via SSH's `Include` directive, so private hosts stay local while the structural config is versioned.

## Setup on a new machine

```bash
# 1. Symlink the tracked config
ln -sf ~/dotfiles/ssh/config ~/.ssh/config

# 2. Create the local override file (or leave it absent — Include is silent if missing)
cp ~/dotfiles/ssh/config.local.example ~/.ssh/config.local
nvim ~/.ssh/config.local

# 3. Cache the GitHub key's passphrase in the macOS Keychain and load the agent.
#    The zsh config repeats this automatically on every login shell; running it
#    once here primes the Keychain so the automated load stays prompt-free.
ssh-add --apple-use-keychain ~/.ssh/id_rsa

# 4. Verify
ssh -G github.com | grep -i 'identityagent\|identityfile'
# identityagent ~/.ssh/agent.sock    ← github bypasses 1Password
# identityfile ~/.ssh/id_rsa
```

## Why the block order matters

SSH config is **first-match-wins** per parameter (see `man ssh_config`). The blocks in `ssh/config` are ordered so that:

1. `Host *` global defaults set baseline identity/agent options.
2. `Include ~/.ssh/config.local` loads early — machine-local host blocks get to override anything the later global blocks would otherwise impose.
3. `Host github.com` opts out of 1Password (uses `~/.ssh/agent.sock`, a stable symlink to the macOS launchd agent + Keychain-cached passphrase).
4. `Host *` 1Password block catches everything else.

If you flip 3 and 4, the 1Password line wins for `github.com` and the opt-out is silently ignored. Watch for this if you ever rearrange.

## Why GitHub bypasses 1Password

1Password's SSH agent auto-locks on idle. When it's locked, the agent serves no keys, and the on-disk `id_rsa` is passphrase-encrypted — so signing fails in any non-interactive shell (cron jobs, Claude Code subprocesses, etc.) and you see `Permission denied (publickey)`.

Routing GitHub through the macOS launchd agent with `UseKeychain yes` + `AddKeysToAgent yes` solves it: the passphrase lives in the Keychain, the agent is restored on every login, and signing always works. Other hosts keep going through 1Password as before.

## Why the stable `~/.ssh/agent.sock` symlink

The macOS launchd agent gets a **new socket path each boot**, and a long-lived tmux server freezes a stale `SSH_AUTH_SOCK` in its environment — so panes (and headless tools like Claude Code that inherit the pane env) end up pointing at a dead socket, and `ssh-add` reports `Connection refused` while git falls through to `ssh-askpass` and fails with `Permission denied (publickey)`.

The fix is a stable indirection: the zsh config maintains `~/.ssh/agent.sock` as a symlink to the current launchd socket (repointed whenever a login shell inherits a real socket) and loads `id_rsa` into the agent. `Host github.com` pins `IdentityAgent ~/.ssh/agent.sock`, and `tmux.conf` pins the same path — so every consumer resolves to the live agent regardless of a stale inherited `SSH_AUTH_SOCK`. `IdentityFile` + `UseKeychain` remain as a fallback when the agent is empty.

## Related

- [git/README.md](../git/README.md) — same split-pattern, with longer rationale
- [Main README](../README.md) — dotfiles overview
