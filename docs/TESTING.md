# Testing

This repo ships test suites for the scripts that mutate external state — file sync, plugin trees, `$HOME` symlinks, and launchd services. Everything else (one-shot installers, `defaults write` chains, simple aliases) is intentionally not covered.

## Suites

| Suite | Cases | Target |
|---|---|---|
| `scripts/test-audio-backup.sh` | 36 tests / 57 assertions | `scripts/audio-backup-sync.sh` end-to-end + `audio-backup-manage.sh` dispatch and plist generation |
| `scripts/test-audio-volume-guard.sh` | 14 tests / 35 assertions | `scripts/audio-volume-guard.sh` — four-state resolution (mounted/unverified/squatter/absent), fail-closed `--check`, `--repair` refusing a populated *or* unreadable squatter, notification cooldown armed only by a delivered notification, honest `--status` during a squatter; mocks `terminal-notifier` + `osascript` and attaches a throwaway disk image so mounted-state detection runs against a real mount |
| `scripts/test-audio-plugin-cleanup.py` | 22 unittest cases | `scripts/audio-plugin-cleanup.py` suffix stripping, dupe detection, no-twin invariant, scan/candidate filtering |
| `scripts/test-install-symlink.sh` | 7 tests / 14 assertions | `scripts/install.sh::create_symlink` — first-time creation, idempotency, file backup, `--dry-run`, source-is-symlink guard, and a known data-loss gap (TEST 7) |
| `scripts/test-install-profile.sh` | 21 tests | `scripts/install.sh` profile gating — default profile, `~/.dotfiles-profile` persistence (and not under `DRY_RUN`), which configs each profile links, neomutt skipped on `work`, the placeholder git identity (`.invalid` TLD, no personal address, existing file untouched), package-profile selection via a stubbed `install-packages.sh`, a regression guard that no bare `brew bundle` is attempted, and `--profile` validation |
| `scripts/test-install-seed-templates.sh` | 6 tests / 13 assertions | `scripts/install.sh::seed_templates` — new-destination copy + content fidelity, destination-exists skip, `DRY_RUN` no-write, mixed-state counts + summary, filenames-with-spaces round-trip, cp-failure isolation (one failure doesn't abort the loop) |
| `scripts/test-tm-backup-staleness.sh` | 8 tests / 14 assertions | `scripts/tm-backup-staleness-check.sh` — fresh-within-threshold no-op, stale-beyond-threshold notify (title + body), destination-unreachable path, cooldown suppression within window, cooldown-expired re-notify + marker-lives-in-STATE_DIR assertion, `--check` mode exit code by freshness + no notify, one-time LOG_DIR → STATE_DIR marker migration (old marker removed, new marker keeps original timestamp, cooldown honoured post-migration), `TM_NOTIFY_ENABLED=0` silences everything, with `tmutil` and `terminal-notifier` mocked |
| `mail/scripts/test-manage-sync.sh` | 10 tests / 10 assertions | `mail/scripts/manage-sync.sh` lifecycle (status/start/stop/restart/logs) with a mocked `launchctl` |
| `terminal/zsh/test-config.sh` | 53 assertions | zsh config loads cleanly with the modular `aliases/` + `functions/` layout |
| `terminal/zsh/test-newgig.sh` | 7 tests / 14 assertions | `functions/dev.sh::newgig` — scaffold shape (with/without project), refuses existing dir, input validation for client + project names, template interpolation, rollback on mid-write failure |
| `terminal/zsh/test-media-stack.sh` | 28 tests | `functions/media-stack.sh::plex` — subcommand dispatch routing (boot/halt/up/down/restart/status/update/fix/web/autostart), help & per-command usage, unknown-command handling, with `docker`/`colima`/`brew`/`open`/`launchctl` mocked |

## Continuous integration

`.github/workflows/ci.yml` runs all of this on push and on pull requests, in
three jobs on `macos-latest`:

| Job | What it does |
|---|---|
| `lint` | shellcheck at warning level, `bash -n` / `zsh -n`, `py_compile`, and `scripts/check-docs.py` |
| `test` | the ten hermetic suites below |
| `fresh-install` | a real `install.sh --yes --profile work` on the runner's own `$HOME`, then asserts what was linked, what was not, that the shell starts without plugin warnings, that profile gating holds, and that the package profile resolves |

`fresh-install` is the job that justifies the rest. Every defect worth fixing
in this repo has been one that could only fail on a machine that was not the
author's, so a green local run proved nothing about it. A runner is a genuinely
clean macOS install, which is the one thing a laptop cannot simulate.

Two things it deliberately does not do: install the 147 packages of the `work`
profile (it dry-runs the selection instead, which would have caught the bug
that was there), and apply the 192 `defaults write` calls, which tell you
nothing on a VM about to be destroyed. `chsh` is short-circuited by presetting
`SHELL`, since changing the login shell of a disposable runner proves nothing
and needs a password.

Note that suites have to be machine-independent to run here. The profile cases
in `test-config.sh` originally asserted that an undeclared profile means
`personal`, which held only because the development machine had no
`~/.dotfiles-profile`; it failed the first time it ran after a work install.
They now build a throwaway `$HOME` per probe and test the precedence rule
itself.

## Documentation checks

`scripts/check-docs.py` verifies the markdown against the tree: that
repo-relative path references resolve, that relative links resolve, that every
referenced script exists, and that nothing refers to a directory that has been
renamed away. It runs in CI and takes under a second.

It exists because a sweep of all 54 docs found drift in 14 of them — including
17 references to a `shell/` directory renamed long ago and two scripts that
had been deleted — all of it mechanically detectable.

```sh
python3 scripts/check-docs.py        # 0 clean, 1 on any problem
```

## Running

Each suite is self-contained — no shared fixtures, no test runner, no install step.

```sh
# From repo root
scripts/test-audio-backup.sh
scripts/test-audio-volume-guard.sh
scripts/test-install-symlink.sh
scripts/test-install-seed-templates.sh
scripts/test-install-profile.sh
scripts/test-tm-backup-staleness.sh
python3 scripts/test-audio-plugin-cleanup.py
mail/scripts/test-manage-sync.sh
terminal/zsh/test-config.sh
terminal/zsh/test-newgig.sh
terminal/zsh/test-media-stack.sh
```

The three `terminal/zsh/` suites are zsh scripts and declare it in their
shebang; invoking them with `bash` will report spurious failures.

Exit code is `0` on success, non-zero on any failure. The shell suites print per-test `PASS`/`FAIL` lines and end with a summary; the Python suite uses `unittest`'s default reporter.

## Conventions

- **Sandboxed tempdirs.** Every suite creates a `mktemp -d` workspace and runs entirely inside it. Nothing under `$HOME` or the live filesystem is touched.
- **Mock binaries on `$PATH`.** `launchctl`, `rclone`, `rsync`, `networksetup`, and `route` are shadowed by shell-script stubs in the sandbox's `bin/` so the script-under-test runs unmodified but talks to fakes.
- **No network.** The mock `rclone` synthesises responses from a fake remote directory; no real Drive call is ever made.
- **Production-script BASH_SOURCE guards.** Scripts that get sourced for testing (`audio-backup-manage.sh`, `install.sh`) gate their dispatch on `[[ "${BASH_SOURCE[0]}" == "${0}" ]]` so the test can import internal functions without triggering the CLI.

## What's covered, what isn't

**Covered (the risk-bearing paths):**
- rclone/rsync push/pull with junk excludes (Live regeneratables, `.DS_Store`, `Analysis Files/`, `Autosaves/`)
- Sync gates: missing mount sentinel, untrusted router, missing filters file, missing rclone remote
- Forced-run bandwidth logic: hotspot cap, untrusted-router cap, explicit `--bwlimit` override
- Plist generation (`plutil -lint` on the emitted file)
- launchd lifecycle for both `audio-backup` and `mail` sync via mocked `launchctl`
- Symlink creation, idempotent re-link, file backup, dry-run, source-is-symlink rejection
- Template seeding — copy-on-empty, destination-exists skip, dry-run no-write, mixed-state counter accuracy, filenames-with-spaces round-trip, cp-failure isolation
- TM staleness monitor — fresh/stale threshold gating, destination-unreachable detection, cooldown-guarded notify, `--check` mode contract, notification kill switch (`TM_NOTIFY_ENABLED=0`), with `tmutil` and `terminal-notifier` mocked
- Plugin-cleanup keep/dupe invariants — the 7 paid VST2 plugins (FM8 FX, Lounge Lizard, Reaktor 6 FX, Strum, Ultra Analog, VCV Rack 2 FX, ZOOM MS Decoder) live in the keep list and never appear in `--list`
- `newgig` scaffold shape, input validation (rejects `../`, leading dots, slashes, empty), template interpolation (`$client`, today's date), and trap-based rollback when a heredoc write fails mid-scaffold — proven via a mocked `cat` that returns non-zero on the CLAUDE.md write
- `plex` media-stack dispatcher — every subcommand routes to the correct `docker`/`colima`/`brew`/`open` invocation (verified against a call-log of mocked binaries); help/usage/unknown-command paths; and the composite `boot` (Colima → compose up → gluetun-health wait → qB reconnect) and `halt` (graceful stop → brew stop → agent-safe `colima stop`) sequences

**Not covered (by design):**
- `defaults write` chains in `scripts/macos/*.sh` and `macos-setup.sh` — hard to mock, low return
- `scripts/bootstrap.sh` — curl|bash entry point, runs before the repo exists locally
- `scripts/uninstall.sh`, `scripts/restore.sh`, `scripts/health-check.sh` — admin/repair tools, one-shot
- `scripts/update-music-plugins.sh`, `scripts/sync-portable-configs.sh`, `scripts/arturia-fix-presets.py`
- `mail/scripts/sync-mail.sh` (drives real `mbsync`), `mail/scripts/setup-gmail-sync.sh` (one-shot setup)
- `packages/install-packages.sh` and `packages/sync-packages.sh` (thin wrappers over `brew bundle`)
- Individual zsh `aliases/` and `functions/` shims beyond config-load

The shape is deliberate: every script that mutates external state has a test; the ones that wrap `defaults write` or one-shot install commands don't.

**Known gaps (worth a suite, not yet written):**
- `scripts/tm-fast-backup.sh` — real branching around the destination-info gate (`timeout` vs the portable-bash fallback in `run_with_timeout`), the `--gentle`/`--fast` path split, and the pre-run throttle knob capture/restore. A hermetic suite would mock `tmutil`, `sysctl`, `timeout`, and `sudo` in a `TESTROOT_BIN` directory the same way the audio-backup suite does, then drive the entry point through the happy path, the gate-wedge fallback, and each early-exit.

## Adding a suite

1. Name it `test-<thing>.sh` (or `.py`) and put it next to the script under test.
2. Create a `mktemp -d` sandbox and a `TESTROOT_BIN` directory; prepend `TESTROOT_BIN` to `$PATH`.
3. Mock any external binary by writing a small shell stub into `TESTROOT_BIN`.
4. Source the script under test (or invoke it with a fake `$HOME`) — never let it touch the real filesystem.
5. Add it to the suites table above.
