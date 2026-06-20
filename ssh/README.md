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

# 3. Cache the GitHub key's passphrase in the macOS Keychain
ssh-add --apple-use-keychain ~/.ssh/id_rsa

# 4. Verify
ssh -G github.com | grep -i 'identityagent\|identityfile'
# identityagent SSH_AUTH_SOCK    ← github bypasses 1Password
# identityfile ~/.ssh/id_rsa
```

## Why the block order matters

SSH config is **first-match-wins** per parameter (see `man ssh_config`). The blocks in `ssh/config` are ordered so that:

1. `Host *` global defaults set baseline identity/agent options.
2. `Include ~/.ssh/config.local` loads early — machine-local host blocks get to override anything the later global blocks would otherwise impose.
3. `Host github.com` opts out of 1Password (uses `SSH_AUTH_SOCK`, i.e. the macOS launchd agent + Keychain-cached passphrase).
4. `Host *` 1Password block catches everything else.

If you flip 3 and 4, the 1Password line wins for `github.com` and the opt-out is silently ignored. Watch for this if you ever rearrange.

## Why GitHub bypasses 1Password

1Password's SSH agent auto-locks on idle. When it's locked, the agent serves no keys, and the on-disk `id_rsa` is passphrase-encrypted — so signing fails in any non-interactive shell (cron jobs, Claude Code subprocesses, etc.) and you see `Permission denied (publickey)`.

Routing GitHub through the macOS launchd agent with `UseKeychain yes` + `AddKeysToAgent yes` solves it: the passphrase lives in the Keychain, the agent is restored on every login, and signing always works. Other hosts keep going through 1Password as before.

## Related

- [git/README.md](../git/README.md) — same split-pattern, with longer rationale
- [Main README](../README.md) — dotfiles overview
