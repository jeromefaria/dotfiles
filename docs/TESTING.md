# Testing

This repo ships test suites for the scripts that mutate external state — file sync, plugin trees, `$HOME` symlinks, and launchd services. Everything else (one-shot installers, `defaults write` chains, simple aliases) is intentionally not covered.

## Suites

| Suite | Cases | Target |
|---|---|---|
| `scripts/test-audio-backup.sh` | 25 tests / 37 assertions | `scripts/audio-backup-sync.sh` end-to-end + `audio-backup-manage.sh` dispatch and plist generation |
| `scripts/test-audio-plugin-cleanup.py` | 22 unittest cases | `scripts/audio-plugin-cleanup.py` suffix stripping, dupe detection, no-twin invariant, scan/candidate filtering |
| `scripts/test-install-symlink.sh` | 7 tests / 14 assertions | `scripts/install.sh::create_symlink` — first-time creation, idempotency, file backup, `--dry-run`, source-is-symlink guard, and a known data-loss gap (TEST 7) |
| `mail/scripts/test-manage-sync.sh` | 10 tests / 10 assertions | `mail/scripts/manage-sync.sh` lifecycle (status/start/stop/restart/logs) with a mocked `launchctl` |
| `terminal/zsh/test-config.sh` | smoke | zsh config loads cleanly with the modular `aliases/` + `functions/` layout |

## Running

Each suite is self-contained — no shared fixtures, no test runner, no install step.

```sh
# From repo root
scripts/test-audio-backup.sh
scripts/test-install-symlink.sh
python3 scripts/test-audio-plugin-cleanup.py
mail/scripts/test-manage-sync.sh
terminal/zsh/test-config.sh
```

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
- Plugin-cleanup keep/dupe invariants — the 7 paid VST2 plugins (FM8 FX, Lounge Lizard, Reaktor 6 FX, Strum, Ultra Analog, VCV Rack 2 FX, ZOOM MS Decoder) live in the keep list and never appear in `--list`

**Not covered (by design):**
- `defaults write` chains in `scripts/macos/*.sh` and `macos-setup.sh` — hard to mock, low return
- `scripts/bootstrap.sh` — curl|bash entry point, runs before the repo exists locally
- `scripts/uninstall.sh`, `scripts/restore.sh`, `scripts/health-check.sh` — admin/repair tools, one-shot
- `scripts/update-music-plugins.sh`, `scripts/sync-portable-configs.sh`, `scripts/arturia-fix-presets.py`
- `mail/scripts/sync-mail.sh` (drives real `mbsync`), `mail/scripts/setup-gmail-sync.sh` (one-shot setup)
- `packages/install-packages.sh` and `packages/sync-packages.sh` (thin wrappers over `brew bundle`)
- Individual zsh `aliases/` and `functions/` shims beyond config-load

The shape is deliberate: every script that mutates external state has a test; the ones that wrap `defaults write` or one-shot install commands don't.

## Adding a suite

1. Name it `test-<thing>.sh` (or `.py`) and put it next to the script under test.
2. Create a `mktemp -d` sandbox and a `TESTROOT_BIN` directory; prepend `TESTROOT_BIN` to `$PATH`.
3. Mock any external binary by writing a small shell stub into `TESTROOT_BIN`.
4. Source the script under test (or invoke it with a fake `$HOME`) — never let it touch the real filesystem.
5. Add it to the suites table above.
