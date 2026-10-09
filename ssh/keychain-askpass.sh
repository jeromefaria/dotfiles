#!/bin/bash
# ============================================================================
# ssh/keychain-askpass.sh — answer ssh-add's passphrase prompt from the Keychain
# ============================================================================
# `ssh-add --apple-use-keychain` reports "Identity added" and loads the key, but
# persists nothing on macOS 26.7.1 / OpenSSH 10.3p1. Verified three ways:
#
#   - an add with every input path blocked still prints "Enter passphrase for …"
#     and fails to load
#   - `ssh-add --apple-load-keychain` loads nothing at all
#   - no Keychain item appears under any service name ssh-add uses, and the
#     generic-password count is unchanged across a "successful" add
#
# So the agent is empty after every reboot and the first login shell prompts on
# the TTY. This does explicitly what --apple-use-keychain is supposed to do.
#
# `ssh-keygen -Y sign` (git commit signing, gpg.format=ssh) reads the agent and
# does NOT honour ssh_config's UseKeychain, so the signing key has to be loaded
# proactively — ssh's own keychain path would not cover it even if it worked.
#
# Passphrases are stored base64-encoded on purpose: `security -w` returns a
# hex-encoded blob for any secret containing non-ASCII bytes, and that hex is
# indistinguishable from a passphrase that happens to be all hex digits. base64
# output is always printable ASCII, so it comes back verbatim.
#
# Usage:
#   keychain-askpass.sh --store [key …]   prompt once per key, save to Keychain
#   keychain-askpass.sh --status          report which keys have a stored secret
#   keychain-askpass.sh --forget <key>    delete a key's stored passphrase
#   keychain-askpass.sh "<prompt text>"   askpass mode (invoked by ssh-add)
# ============================================================================

set -uo pipefail

readonly SERVICE="ssh-passphrase"
readonly DEFAULT_KEYS=("${HOME}/.ssh/id_ed25519" "${HOME}/.ssh/id_rsa")

die() { printf '%s\n' "$*" >&2; exit 1; }

# `security` keys items by account; use the key's absolute path so two keys with
# the same basename in different directories cannot collide.
key_account() {
  local key="$1"
  [ -e "$key" ] && (cd "$(dirname "$key")" && printf '%s/%s' "$(pwd -P)" "$(basename "$key")") || printf '%s' "$key"
}

store_passphrase() {
  local key account prompt encoded
  key="$1"
  [ -f "$key" ] || die "no such key: $key"
  account="$(key_account "$key")"

  printf 'Passphrase for %s: ' "$(basename "$key")" >&2
  IFS= read -rs prompt
  printf '\n' >&2
  [ -n "$prompt" ] || die "empty passphrase, nothing stored"

  encoded="$(printf '%s' "$prompt" | base64)"
  unset prompt

  # -U updates in place if the item already exists. The encoded value is visible
  # in this process's argv for the moment security runs; that is the one-time
  # setup cost of not having security read from stdin.
  #
  # security's stderr is captured and reported rather than discarded: a swallowed
  # error here is what made --apple-use-keychain's failure invisible for months,
  # and the same mistake in this script cost a round trip. The message cannot
  # contain the secret — only the service and account are passed in argv.
  # -A grants access without an ACL prompt. This is required, not merely
  # convenient: without it the item carries an ACL, and the *read* by askpass
  # mode can raise an authorisation prompt — which would defeat the entire
  # point, since SSH_ASKPASS_REQUIRE=force leaves nothing able to answer one.
  # It also avoids errSecInteractionNotAllowed (36) on the write, which is what
  # the ACL-bearing form hit here.
  #
  # The trade-off, stated plainly: any process running as this user can read the
  # passphrase back via `security`. That is the same exposure `--apple-use-keychain`
  # would have given, since ssh-agent reads its stored passphrases unprompted too.
  local output status
  output="$(security add-generic-password -A -U -s "$SERVICE" -a "$account" -w "$encoded" 2>&1)"
  status=$?

  if [ "$status" -eq 0 ]; then
    printf 'stored: %s\n' "$account" >&2
  else
    printf 'could not write the Keychain item for %s\n' "$account" >&2
    printf '  security exit %s: %s\n' "$status" "${output:-<no output>}" >&2

    # errSecInteractionNotAllowed. The login keychain is only unlocked by
    # loginwindow at GUI login, so over SSH it is locked and there is no UI to
    # prompt for the unlock. Same reason a Background session cannot show the
    # ACL dialog. Both are recoverable, so say how rather than just failing.
    if [ "$status" -eq 36 ]; then
      printf '\n' >&2
      printf 'The login keychain is locked in this session (managername: %s%s).\n' \
        "$(launchctl managername 2>/dev/null)" \
        "${SSH_CONNECTION:+, over ssh}" >&2
      printf 'Unlock it first, then re-run:\n' >&2
      printf '  security unlock-keychain %s\n' "$HOME/Library/Keychains/login.keychain-db" >&2
      printf 'Or run this from a terminal on the machine itself, where loginwindow\n' >&2
      printf 'has already unlocked it.\n' >&2
    fi
    exit 1
  fi
}

read_passphrase() {
  local account encoded
  account="$(key_account "$1")"
  encoded="$(security find-generic-password -s "$SERVICE" -a "$account" -w 2>/dev/null)" || return 1
  [ -n "$encoded" ] || return 1
  printf '%s' "$encoded" | base64 --decode 2>/dev/null
}

# ssh-add hands the whole prompt in as $1, shaped like
#   Enter passphrase for /Users/me/.ssh/id_rsa:
#   Enter passphrase for key '/Users/me/.ssh/id_rsa':
# Pull the path back out so one helper serves every key.
key_from_prompt() {
  printf '%s' "$1" \
    | sed -nE "s/.*[Ff]or (key )?'?([^':]+)'?:?[[:space:]]*$/\2/p" \
    | sed -E "s/^[[:space:]]+|[[:space:]]+$//g"
}

cmd_status() {
  local key account
  for key in "$@"; do
    account="$(key_account "$key")"
    printf '  %-34s ' "$(basename "$key")"
    if [ ! -f "$key" ]; then
      printf 'key file absent\n'
    elif security find-generic-password -s "$SERVICE" -a "$account" >/dev/null 2>&1; then
      printf 'passphrase stored\n'
    else
      printf 'NOT stored — run --store\n'
    fi
  done
}

case "${1:-}" in
  --store)
    shift
    [ "$#" -gt 0 ] || set -- "${DEFAULT_KEYS[@]}"
    for k in "$@"; do [ -f "$k" ] && store_passphrase "$k"; done
    ;;
  --status)
    shift
    [ "$#" -gt 0 ] || set -- "${DEFAULT_KEYS[@]}"
    cmd_status "$@"
    ;;
  --forget)
    [ -n "${2:-}" ] || die "usage: $(basename "$0") --forget <key>"
    security delete-generic-password -s "$SERVICE" -a "$(key_account "$2")" >/dev/null 2>&1 \
      && printf 'forgotten: %s\n' "$2" >&2 \
      || die "no stored passphrase for $2"
    ;;
  -h|--help|"")
    sed -n '/^# Usage:/,/^# ===/p' "$0" | sed -E 's/^# ?//; /^=+$/d'
    ;;
  *)
    # askpass mode: stdout goes straight to ssh-add, so nothing else may print there.
    target="$(key_from_prompt "$1")"
    [ -n "$target" ] || exit 1
    read_passphrase "$target" || exit 1
    ;;
esac
