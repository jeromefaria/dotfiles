# Security

Outstanding security obligations and a log of leaked-and-rotated credentials. The repo is **public** at github.com/jeromefaria/dotfiles — anything that ever reached `master` is assumed scraped.

## Outstanding actions

Anything in this section is a personal todo that survives shell history and conversation rot.

- [ ] **Rotate the Discogs personal API token** at https://www.discogs.com/settings/developers. The previous token was committed in plaintext in `config/beets/config.yaml:143` (added in commit `daf2ede`, removed in `8eece6a`). It remains valid in git history at every commit prior to `8eece6a` until rotated at the upstream.

## Resolved actions

| Component | Action | When | Notes |
|---|---|---|---|
| Reddit OAuth (tuir) | App deleted at reddit.com/prefs/apps | resolved by uninstalling tuir | Client ID + secret were committed in `config/tuir/tuir.cfg:78-79`; tuir is no longer in use and the whole directory was removed in `8eece6a`. Imgur client_id in the same file was also redacted. |
| AWS Client VPN config (former employer) | Directory removed from HEAD | `8eece6a` | Files contained CA cert (expired 2024-03-18), internal hostname `vpn.intra.linkfire.co`, AWS endpoint ID, and contact email. Cert expiration limited the technical impact; professional-disclosure risk is the real consideration. |
| Picard.ini + vifminfo state | Untracked from HEAD | `a0f4080` | Recent-paths state embedded `~/Work/helpr/` paths and internal codebase names (smart-assistance, core-ionic2, HelprApp Core Data Flow). Untracking stops new leaks; the values remain in history. |

## Why history rewrites aren't required

Once a credential or path is rotated/invalidated at its source, the git-history copies become inert — they can no longer authenticate anywhere or reach any reachable system. `git filter-repo` + force-push is therefore optional cleanup, not a security requirement.

The exception would be a credential that **can't** be rotated (a hard-coded API key on a service you don't control, a TLS private key that can't be re-issued, etc.). None of the items above fall in that bucket.

## Configuration hygiene patterns

These patterns are in place to prevent future leaks:

- `.gitignore` covers known secret-bearing files: `config/op/config`, `config/gh/hosts.yml`, `config/rclone/rclone.conf`, `config/beets/discogs_token.json`, `config/beets/secrets.yaml`, `config/AWSVPNClient/`, `ssh/config.local`.
- SSH and Git configs use a split portable / local pattern: `git/gitconfig.local.example` and `ssh/config.local.example` are tracked templates; the real `~/.gitconfig.local` and `~/.ssh/config.local` are untracked. See `git/README.md` and `ssh/README.md` for the conventions.
- macOS Keychain (`security` CLI + `UseKeychain yes` in SSH config) holds passphrases and tokens. Examples: GitHub SSH key passphrase, `mail/scripts/get-gmail-pass.sh` retrieves Gmail app password from Keychain.

## Reporting

If you find a credential or PII still committed to this repo, open a GitHub issue at https://github.com/jeromefaria/dotfiles/issues — no need to disclose the exact value in the issue body; just link to the line.
