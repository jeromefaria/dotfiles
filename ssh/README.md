# SSH Configuration

SSH client configuration with split portable / machine-local layout, mirroring the `git/` pattern.

## Layout

| File | Purpose | Tracked? |
|---|---|---|
| `ssh/config` | Portable defaults: agent settings, host-agnostic identity, GitHub-specific bypass of 1Password | yes |
| `ssh/config.local.example` | Template for personal/per-machine host blocks | yes |
| `~/.ssh/config.local` | Actual personal hosts (LAN boxes, work hosts, etc.) | **no** |
| `ssh/keychain-askpass.sh` | `SSH_ASKPASS` helper: serves key passphrases from the Keychain, with `--store` / `--status` / `--forget` | yes |

`~/.ssh/config` is a symlink to `~/dotfiles/ssh/config`. The tracked config pulls in `~/.ssh/config.local` via SSH's `Include` directive, so private hosts stay local while the structural config is versioned.

## Setup on a new machine

```bash
# 1. Symlink the tracked config
ln -sf ~/dotfiles/ssh/config ~/.ssh/config

# 2. Create the local override file (or leave it absent — Include is silent if missing)
cp ~/dotfiles/ssh/config.local.example ~/.ssh/config.local
nvim ~/.ssh/config.local

# 3. Store each key's passphrase in the macOS Keychain, once. The zsh config
#    then loads both keys silently on the first login shell after every boot.
#    NOT `ssh-add --apple-use-keychain` — see "Why not --apple-use-keychain".
~/dotfiles/ssh/keychain-askpass.sh --store
~/dotfiles/ssh/keychain-askpass.sh --status

# 4. Verify
ssh -G github.com | grep -i 'identityagent\|identityfile'
# identityagent ~/.ssh/agent.sock    ← github bypasses 1Password
# identityfile ~/.ssh/id_rsa
```

## Why not `--apple-use-keychain`

On macOS 26.7.1 / OpenSSH 10.3p1 that flag reports `Identity added` and loads
the key, but **persists nothing**. Verified three ways:

- an `ssh-add` with every input path blocked (`SSH_ASKPASS_REQUIRE=never`,
  `</dev/null`) still prints `Enter passphrase for …` and fails to load
- `ssh-add --apple-load-keychain` loads nothing at all
- no Keychain item appears under any service name `ssh-add` uses, and the
  generic-password count is unchanged across a "successful" add

So the agent was empty after every reboot and the first login shell prompted on
the TTY — and the old `2>/dev/null` on those adds hid the only diagnostic that
would have explained it.

`ssh_config`'s own `UseKeychain yes` is a different code path and may well work,
but it would not be enough: `commit.gpgsign true` with `gpg.format ssh` makes
git sign via `ssh-keygen -Y sign`, which reads the agent and does **not** honour
`UseKeychain`. The signing key has to be loaded proactively, which means
`ssh-add`, which means the prompt. Hence an explicit askpass helper.

Passphrases are stored base64-encoded, because `security -w` returns a
hex-encoded blob for any secret containing non-ASCII bytes and that hex is
indistinguishable from a passphrase made only of hex digits.

### Sessions where this cannot work

The login keychain is unlocked by `loginwindow` at GUI login only. In an SSH
session, or any `launchctl managername: Background` context, it stays locked and
there is no UI to prompt for the unlock — so `--store` fails with
`errSecInteractionNotAllowed` (36) and askpass reads return nothing.

That is a deliberate boundary, not a bug: `SSH_ASKPASS_REQUIRE=force` means a
failed read fails fast into `~/.ssh/agent-load.log` rather than blocking the
shell on a prompt nothing can answer. To use it over SSH, unlock first:

```bash
security unlock-keychain ~/Library/Keychains/login.keychain-db
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
