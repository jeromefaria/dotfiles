# Troubleshooting Guide

Common issues and solutions organized by symptom.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Shell Problems](#shell-problems)
- [Editor Issues](#editor-issues)
- [Git Configuration](#git-configuration)
- [Mail Configuration](#mail-configuration)
- [SSH & Keychain](#ssh--keychain)
- [External Drives & Backups](#external-drives--backups)
- [Window Management](#window-management)
- [Package Management](#package-management)
- [Performance Issues](#performance-issues)
- [Platform-Specific Problems](#platform-specific-problems)
- [Recovery Procedures](#recovery-procedures)

---

## Installation Issues

### Symptom: Install script fails with permission errors

**Possible Causes:**
- Running without proper permissions
- System Integrity Protection (SIP) blocking changes

**Solutions:**

1. **Don't use `sudo`** for the install script:
   ```bash
   # Wrong
   sudo ./scripts/install.sh

   # Right
   ./scripts/install.sh
   ```

2. **Check file permissions:**
   ```bash
   ls -la ~/dotfiles/scripts/install.sh
   chmod +x ~/dotfiles/scripts/install.sh
   ```

3. **If SIP is blocking (rare):**
   - Most operations don't require disabling SIP
   - Check specific error messages
   - See [SIP documentation](https://developer.apple.com/documentation/security/disabling_and_enabling_system_integrity_protection)

### Symptom: Symlinks not created

**Check symlink status:**
```bash
./scripts/health-check.sh
```

**If symlinks are missing:**

1. **Manually create symlinks:**
   ```bash
   ./scripts/install.sh --force
   ```

2. **Check for existing files:**
   ```bash
   ls -la ~/.zshrc ~/.config/nvim
   ```

   The install script backs up existing files, but if backups exist it won't overwrite.

3. **Remove backups and retry:**
   ```bash
   rm -rf ~/.dotfiles-backup-*
   ./scripts/install.sh
   ```

### Symptom: Homebrew installation fails

**Solutions:**

1. **Install Homebrew manually:**
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Add to PATH (Apple Silicon):**
   ```bash
   echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
   eval "$(/opt/homebrew/bin/brew shellenv)"
   ```

3. **Add to PATH (Intel — Homebrew dropped Intel Mac support on macOS 26+):**
   ```bash
   echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
   eval "$(/usr/local/bin/brew shellenv)"
   ```

### Symptom: Bootstrap script hangs

**Possible Causes:**
- Network issues
- Git authentication problems
- Large download timing out

**Solutions:**

1. **Check internet connection:**
   ```bash
   ping github.com
   ```

2. **Use manual installation instead:**
   ```bash
   git clone https://github.com/jeromefaria/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ./scripts/install.sh
   ```

3. **Check installation log:**
   ```bash
   tail -f ~/.dotfiles-install.log
   ```

---

## Shell Problems

### Symptom: `zsh: command not found` errors

**Common Missing Commands:**
- `eza`, `bat`, `fd`, `rg` - Modern CLI tools

**Solutions:**

1. **Install missing tools:**
   ```bash
   cd ~/dotfiles/packages
   ./install-profile.sh minimal    # Or dev/full
   ```

2. **Check if tools are installed:**
   ```bash
   which eza bat fd rg
   ```

3. **Aliases degrade gracefully** - if tools aren't installed, aliases won't be created:
   ```bash
   # In terminal/zsh/aliases/tools.sh
   command -v eza &> /dev/null && alias ls="eza" || alias ls="ls --color=auto"
   ```

### Symptom: Aliases not loading

**Diagnostic:**
```bash
# Check if files are sourced
type ll
type mkd
```

**Solutions:**

1. **Reload shell configuration:**
   ```bash
   source ~/.zshrc
   # or
   reload
   ```

2. **Check for syntax errors:**
   ```bash
   zsh -n ~/.zshrc
   ```

3. **Verify alias files exist:**
   ```bash
   ls -la ~/dotfiles/terminal/zsh/aliases/
   ls -la ~/dotfiles/terminal/zsh/functions/
   ```

4. **Check zshrc loads modules:**
   ```bash
   grep "aliases" ~/dotfiles/terminal/zsh/zshrc
   ```

### Symptom: zoxide not working (`cd` doesn't learn directories)

**Check installation:**
```bash
which zoxide
```

**Solutions:**

1. **Install zoxide:**
   ```bash
   brew install zoxide
   ```

2. **Verify initialization:**
   ```bash
   grep "zoxide init" ~/dotfiles/terminal/zsh/zshrc
   ```

3. **Reload shell:**
   ```bash
   exec zsh
   ```

4. **Build database:**
   ```bash
   # Navigate to frequently used directories
   cd ~/dotfiles
   cd ~/Projects
   # Then try:
   z dot    # Should jump to dotfiles
   ```

### Symptom: Oh My Zsh not loading

**Check installation:**
```bash
ls -la ~/.oh-my-zsh
```

**Solutions:**

1. **Reinstall Oh My Zsh:**
   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```

2. **Restore dotfiles zshrc:**
   ```bash
   ln -sf ~/dotfiles/terminal/zsh/zshrc ~/.zshrc
   ```

3. **Install missing plugins:**
   ```bash
   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

   git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
   ```

---

## Editor Issues

### Symptom: Neovim plugins not installed

**Check plugin manager:**
```bash
ls -la ~/.local/share/nvim/lazy
```

**Solutions:**

1. **Lazy.nvim installs automatically** on first launch:
   ```bash
   nvim
   # Wait for lazy.nvim to install plugins
   ```

2. **Manually trigger install:**
   ```bash
   nvim
   # Then run:
   :Lazy sync
   ```

3. **Check for errors:**
   ```bash
   nvim
   :checkhealth
   ```

### Symptom: LSP not working

**Check LSP status:**
```bash
nvim somefile.js
# Then in Neovim:
:LspInfo
```

**Solutions:**

1. **Install language servers:**
   ```bash
   # Check available servers:
   nvim
   :Mason

   # Install needed servers (or they install automatically)
   ```

2. **Verify treesitter parsers:**
   ```bash
   nvim
   :TSInstallInfo
   ```

3. **Check LSP logs:**
   ```bash
   tail -f ~/.local/state/nvim/lsp.log
   ```

### Symptom: Neovim keybindings not working

**Common Issues:**
- `<Space>ff` doesn't find files → Telescope not installed
- `gd` doesn't go to definition → LSP not attached
- `jk` doesn't exit insert mode → Keymap not loaded

**Solutions:**

1. **Check which-key:**
   ```bash
   nvim
   # Press <Space> and wait 1 second
   # Should show available keybindings
   ```

2. **Verify keymaps loaded:**
   ```bash
   nvim
   :nmap <Space>
   ```

3. **Reload configuration:**
   ```bash
   nvim
   :source ~/.config/nvim/init.lua
   ```

### Symptom: Vim plugins not installing

**For Vim (not Neovim):**

1. **Install vim-plug:**
   ```bash
   curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
   ```

2. **Install plugins:**
   ```bash
   vim
   :PlugInstall
   ```

---

## Git Configuration

### Symptom: Git aliases not working

**Check git config:**
```bash
git config --list | grep alias
```

**Solutions:**

1. **Verify gitconfig is symlinked:**
   ```bash
   ls -la ~/.gitconfig
   # Should point to ~/dotfiles/git/gitconfig
   ```

2. **Manually source gitconfig:**
   ```bash
   git config --global include.path ~/dotfiles/git/gitconfig
   ```

### Symptom: Git asks for credentials repeatedly

**Solutions:**

1. **Set up SSH keys:**
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   cat ~/.ssh/id_ed25519.pub
   # Add to GitHub/GitLab
   ```

2. **Or use credential helper:**
   ```bash
   git config --global credential.helper osxkeychain
   ```

### Symptom: Diff-so-fancy not working

**Check installation:**
```bash
which diff-so-fancy
```

**Install:**
```bash
brew install diff-so-fancy
```

---

## Mail Configuration

### Symptom: mbsync fails to sync

**Common errors:**
- SSL certificate verification failed
- Authentication failed
- Connection timeout

**Solutions:**

1. **Update passwords:**
   ```bash
   # For Gmail, use app-specific password
   # Settings → Security → 2-Step Verification → App passwords
   ```

2. **Test connection:**
   ```bash
   mbsync -V gmail
   ```

3. **Check mbsyncrc:**
   ```bash
   cat ~/.mbsyncrc
   # Verify paths and settings
   ```

### Symptom: notmuch search returns no results

**Solutions:**

1. **Initialize notmuch database:**
   ```bash
   notmuch new
   ```

2. **Check mail directory:**
   ```bash
   ls ~/Mail/gmail/
   ```

3. **Rebuild index:**
   ```bash
   notmuch new --full-scan
   ```

### Symptom: neomutt keybindings not working

**Solutions:**

1. **Check neomutt config:**
   ```bash
   neomutt -D | grep bind
   ```

2. **Verify config location:**
   ```bash
   ls -la ~/.config/neomutt/
   ```

3. **See full keybindings:**
   - Read [Mail Quick Reference](../mail/QUICK-REFERENCE.md)
   - Or in neomutt, press `?` for help

---

## SSH & Keychain

### Symptom: Prompted for an SSH key passphrase in every new terminal after a reboot

The agent is empty after boot and `zshrc` loads the keys on the first login
shell. If no passphrase is stored, that load prompts on the TTY.

`ssh-add --apple-use-keychain` does **not** persist on macOS 26.7.1 /
OpenSSH 10.3p1 — it reports `Identity added`, loads the key, and stores nothing.

**Check what is stored:**

```bash
~/dotfiles/ssh/keychain-askpass.sh --status
```

**Store it (once per key):**

```bash
~/dotfiles/ssh/keychain-askpass.sh --store
```

**Verify a cold load is silent** — this is the post-reboot condition:

```bash
ssh-add -d ~/.ssh/id_ed25519
SSH_ASKPASS=~/dotfiles/ssh/keychain-askpass.sh SSH_ASKPASS_REQUIRE=force \
  ssh-add ~/.ssh/id_ed25519 </dev/null
```

Failures are logged to `~/.ssh/agent-load.log` rather than prompting. See
[`ssh/README.md`](../ssh/README.md) for the evidence behind this.

### Symptom: `--store` fails with "User interaction is not allowed" (exit 36)

The login keychain is unlocked by `loginwindow` at GUI login only. Over SSH, or
in any `launchctl managername: Background` session, it stays locked and there is
no UI to prompt for the unlock.

```bash
security unlock-keychain ~/Library/Keychains/login.keychain-db
```

Then retry, or run `--store` from a terminal on the machine itself.

### Symptom: Commit signing fails with "incorrect passphrase supplied to decrypt private key"

`commit.gpgsign true` with `gpg.format ssh` signs via `ssh-keygen -Y sign`,
which reads the **agent** and does not honour `ssh_config`'s `UseKeychain`. If
`id_ed25519` is not loaded, git falls back to the key file and needs a
passphrase it cannot obtain.

```bash
ssh-add -l                       # confirm the signing key is absent
ssh-add ~/.ssh/id_ed25519        # or run --store so it loads silently
```

Note the agent's socket path changes whenever launchd restarts it, which drops
every loaded key — `~/.ssh/agent.sock` tracks the live socket, but the key
*contents* do not survive. That is why the Keychain store matters.

---

## External Drives & Backups

### Symptom: The Audio volume mounts as `/Volumes/Audio 1`

A plain directory is squatting on `/Volumes/Audio`. Installers that follow
`/Library/Arturia` (and the Softube / iZotope symlinks) while the volume is
unmounted make macOS create that path on the **boot disk**, and the real volume
then cannot claim its mount point.

```bash
~/dotfiles/scripts/audio-volume-guard.sh --status
~/dotfiles/scripts/audio-volume-guard.sh --repair   # refuses if it holds data
```

If `--repair` reports the squatter as populated, that payload exists **only
there** — merge it onto the volume before deleting anything. A `WatchPaths`
agent catches this the moment it appears; install with
`audio-volume-guard.sh install`.

### Symptom: Time Machine has not completed a backup for days

Check whether attempts are accumulating rather than finishing:

```bash
tmutil status | grep -E 'BackupPhase|Running'
ls -d /Volumes/Backup/*.inprogress /Volumes/Backup/*.interrupted 2>/dev/null | wc -l
df -h /Volumes/Backup
```

Interrupted attempts consume the space a backup needs to finish, which is
self-reinforcing: each full attempt fills the remainder, is interrupted, and
leaves another corpse. Time Machine's own `LazyThinning` may dig itself out
given room; if free space keeps falling while attempt directories persist, the
dead ones have to be cleared by hand (keep every `*.previous` — one of them is
the live backup's directory form).

A repeated **full** copy rather than an incremental means the chain is broken;
compare `_raw_totalBytes` from `tmutil status` against the Data volume's used
space to tell which is happening.

### Symptom: Drives drop off the bus under load

USB contention, typically a capture device or DisplayLink dock sharing a hub
with storage. Map the actual topology before changing cables:

```bash
# which bus each device is on, and how deep behind hubs
ioreg -w0 -rc IOUSBHostDevice -n "<product name>" | grep locationID
diskutil info <volume> | grep Protocol
```

`locationID` reads as `0xCCPPPPPP` — controller byte, then one nibble per hub
port down the chain. Devices sharing a prefix share a hub. Separate storage from
capture devices; a free Mac port is a different USB controller and the strongest
isolation available.

## Window Management

### Symptom: Yabai not tiling windows

**Check if running:**
```bash
yabai --check-sa
```

**Solutions:**

1. **Start yabai service:**
   ```bash
   yabai --start-service
   ```

2. **Grant Accessibility permissions:**
   - System Settings → Privacy & Security → Accessibility
   - Add Yabai

3. **Install scripting addition (for advanced features):**
   ```bash
   # See yabai documentation
   sudo yabai --install-sa
   ```

### Symptom: SKHD hotkeys not responding

**Check if running:**
```bash
skhd --check
```

**Solutions:**

1. **Start skhd:**
   ```bash
   skhd --start-service
   ```

2. **Check for conflicts:**
   ```bash
   # System shortcuts may override skhd
   # System Settings → Keyboard → Keyboard Shortcuts
   ```

3. **Reload config:**
   ```bash
   skhd --reload
   ```

### Symptom: Karabiner remapping not working

**Solutions:**

1. **Open Karabiner-Elements app** and grant permissions
2. **Check complex modifications are enabled:**
   - Karabiner-Elements → Complex Modifications tab
3. **Restart Karabiner:**
   ```bash
   killall karabiner_console_user_server
   ```

---

## Package Management

### Symptom: Brewfile install fails

**Check Homebrew:**
```bash
brew doctor
```

**Solutions:**

1. **Update Homebrew:**
   ```bash
   brew update
   ```

2. **Install from specific Brewfile:**
   ```bash
   cd ~/dotfiles/packages
   brew bundle install --file=Brewfile.base
   ```

3. **Skip failing packages:**
   ```bash
   brew bundle install --no-upgrade
   ```

### Symptom: brew bundle says packages are missing

**Sync current packages:**
```bash
cd ~/dotfiles/packages
./sync-packages.sh
```

**This will show:**
- Packages installed but not in Brewfiles
- Packages in Brewfiles but not installed

---

## Performance Issues

### Symptom: Shell startup is slow

**Profile startup:**
```bash
time zsh -i -c exit
```

**Solutions:**

1. **Disable slow plugins:**
   ```bash
   # Edit ~/.zshrc
   # Comment out plugins you don't need
   ```

2. **Check for slow compinit:**
   ```bash
   # Add to ~/.zshrc.local:
   skip_global_compinit=1
   ```

3. **Profile in detail:**
   ```bash
   zsh -xv 2>&1 | ts -i "%.s" | tee /tmp/zsh-profile.log
   ```

### Symptom: Neovim is slow

**Check startup time:**
```bash
nvim --startuptime /tmp/nvim-startup.log
cat /tmp/nvim-startup.log | tail -n 20
```

**Solutions:**

1. **Disable slow plugins** in `lua/plugins/`
2. **Lazy load plugins** - most already lazy load
3. **Update plugins:**
   ```bash
   nvim
   :Lazy update
   ```

---

## Platform-Specific Problems

### macOS Sonoma/Sequoia

**Symptom: Permission dialogs for every operation**

**Solution:**
Grant Full Disk Access to Terminal:
- System Settings → Privacy & Security → Full Disk Access
- Add Terminal.app or iTerm2

### Apple Silicon (M1/M2/M3)

**Symptom: Wrong Homebrew path**

**Solution:**
Homebrew location differs:
- Intel: `/usr/local` (deprecated on macOS 26+)
- Apple Silicon: `/opt/homebrew`

Update PATH:
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

---

## Recovery Procedures

### Complete Reset

**To start fresh:**

1. **Uninstall dotfiles:**
   ```bash
   cd ~/dotfiles
   ./scripts/uninstall.sh
   ```

2. **Remove dotfiles directory:**
   ```bash
   rm -rf ~/dotfiles
   ```

3. **Reinstall:**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/jeromefaria/dotfiles/master/scripts/bootstrap.sh | bash
   ```

### Restore from Backup

**List backups:**
```bash
./scripts/restore.sh --list
```

**Restore latest:**
```bash
./scripts/restore.sh --latest
```

**Restore specific backup:**
```bash
./scripts/restore.sh --backup ~/.dotfiles-backup-YYYYMMDD-HHMMSS
```

**Preview without applying:**
```bash
./scripts/restore.sh --latest --dry-run
```

### Selective Restore

**Restore just one config:**

```bash
# Example: Restore just zshrc
cd ~/.dotfiles-backup-YYYYMMDD-HHMMSS
cp zshrc ~/
```

---

## Getting More Help

If you're still stuck:

1. **Run health check:**
   ```bash
   ./scripts/health-check.sh
   ```

2. **Review logs:**
   ```bash
   cat ~/.dotfiles-install.log
   ```

3. **Check component-specific docs:**
   - [Shell README](../terminal/zsh/README.md)
   - [Neovim README](../editors/neovim/README.md)
   - [Mail README](../mail/README.md)

4. **Review architecture:**
   - [Architecture Guide](ARCHITECTURE.md)

5. **Open an issue:**
   - [GitHub Issues](https://github.com/jeromefaria/dotfiles/issues)
   - Include output from `health-check.sh`
   - Include relevant log files

---

**Status:** ✅ Complete
**Last Updated:** 2025-12-20
