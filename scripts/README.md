# Dotfiles Scripts

This directory contains utility scripts for managing your dotfiles installation.

## Available Scripts

### Core Scripts

- **`install.sh`** - Main installation script that sets up symlinks and dependencies
- **`health-check.sh`** - Verifies installation and checks system health
- **`bootstrap.sh`** - One-liner bootstrap for new system setup
- **`restore.sh`** - Restores configuration from backups
- **`uninstall.sh`** - Removes dotfiles symlinks
- **`config.sh`** - Shared configuration and utilities (sourced by other scripts)

### Utility Scripts

- **`update-music-plugins.sh`** - Updates music plugin managers (Logic Pro, Ableton, etc.)
- **`macos-setup.sh`** - macOS-specific system configuration

## Script Quality & Linting

All bash scripts in this repository follow strict coding standards and are regularly checked with [ShellCheck](https://www.shellcheck.net/).

### ShellCheck Manual Workflow

#### Installation

ShellCheck is available via Homebrew:

```bash
brew install shellcheck
```

#### Running ShellCheck

To check all bash scripts in the repository:

```bash
# Check all main scripts
shellcheck scripts/*.sh bootstrap/*.sh packages/*.sh mail/scripts/*.sh

# Check ZSH files (with bash compatibility mode)
shellcheck --shell=bash terminal/zsh/aliases/*.sh terminal/zsh/functions/*.sh
```

#### Common Issues and Fixes

##### 1. SC2155: Declare and assign separately

**Issue:** Declaring and assigning in one line masks command return values.

```bash
# ❌ Bad
local filename=$(basename "$file")

# ✅ Good
local filename
filename=$(basename "$file")
```

##### 2. SC2164: Use 'cd ... || exit' or 'cd ... || return'

**Issue:** cd can fail and should be handled.

```bash
# ❌ Bad
cd "$directory"

# ✅ Good
cd "$directory" || exit
```

##### 3. SC2181: Check exit code directly

**Issue:** Using $? is indirect and harder to read.

```bash
# ❌ Bad
command
if [ $? -eq 0 ]; then

# ✅ Good
if command; then
```

##### 4. SC2162: read without -r will mangle backslashes

**Issue:** read should use -r flag to preserve backslashes.

```bash
# ❌ Bad
read -p "Enter value: " var

# ✅ Good
read -r -p "Enter value: " var
```

##### 5. SC2207: Prefer mapfile or read -a

**Issue:** Using `$()` in array assignment doesn't handle whitespace correctly.

**Note:** On macOS (bash 3.2), `mapfile` is not available. Use a while loop instead.

```bash
# ❌ Bad
local items=($(find . -name "*.txt"))

# ✅ Good (bash 4+)
mapfile -t items < <(find . -name "*.txt")

# ✅ Good (bash 3.2+ compatible - macOS)
local items=()
while IFS= read -r line; do
  items+=("$line")
done < <(find . -name "*.txt")
```

##### 6. SC2086: Double quote to prevent globbing

**Issue:** Unquoted variables can cause unexpected word splitting.

```bash
# ❌ Bad
if [ $count -eq $total ]; then

# ✅ Good
if [ "$count" -eq "$total" ]; then
```

#### Ignored Warnings

Some ShellCheck warnings are false positives for this codebase:

- **SC2034 (Unused variables)** - Many variables are exported or used in sourced files
- **SC1091 (Can't follow source)** - Dynamic sourcing is intentional
- **SC1090 (Can't follow non-constant source)** - Expected for modular configuration

These can be safely ignored during manual reviews.

#### Integration into Workflow

**Option 1: Manual Checks (Current)**

Run ShellCheck manually before committing changes:

```bash
# Quick check
shellcheck scripts/*.sh

# Full check
shellcheck scripts/*.sh bootstrap/*.sh packages/*.sh mail/scripts/*.sh
```

**Option 2: Pre-commit Hook (Future)**

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
echo "Running ShellCheck..."
shellcheck scripts/*.sh bootstrap/*.sh || {
  echo "ShellCheck found issues. Commit aborted."
  exit 1
}
```

Make it executable:

```bash
chmod +x .git/hooks/pre-commit
```

## Error Handling

All scripts use strict error handling:

```bash
set -euo pipefail
```

This means:
- `-e`: Exit on any command failure
- `-u`: Treat undefined variables as errors
- `-o pipefail`: Return exit code of first failed command in pipeline

## Platform Support

- **macOS**: Full support (primary platform)
- **Linux**: Partial support (some features may require adaptation)
- **Windows (Git Bash)**: Basic support via `bootstrap/gitbash-setup.sh`

## Testing

After making changes to scripts, run the health check:

```bash
./scripts/health-check.sh
```

This verifies:
- Repository structure
- Symlinks are correctly configured
- Required tools are installed
- Shell performance (startup time)
- No broken symlinks

## Contributing

When adding new scripts:

1. Add shebang: `#!/bin/bash`
2. Use strict mode: `set -euo pipefail`
3. Add descriptive comments
4. Run ShellCheck before committing
5. Test on clean system if possible
6. Update this README with new script description

## Maintenance

### Performance Monitoring

The `health-check.sh` script includes performance monitoring:

- ZSH startup time should be < 250ms (excellent)
- 250-500ms is acceptable
- \> 500ms indicates performance issues

### Backup Management

Backups are created automatically during installation:

- Format: `~/.dotfiles-backup-YYYYMMDD-HHMMSS`
- Use `restore.sh` to restore from backups
- Clean old backups manually when no longer needed

## Troubleshooting

### Common Issues

**"command not found"**
- Run `./scripts/health-check.sh` to verify dependencies
- Install missing tools via Homebrew

**"Permission denied"**
- Make scripts executable: `chmod +x scripts/*.sh`

**"Symlink already exists"**
- Run `./scripts/uninstall.sh` to clean up
- Then run `./scripts/install.sh` again

**"zsh: command not found: mapfile"**
- This is expected on macOS (bash 3.2)
- Scripts have been updated to use bash 3.2-compatible alternatives

## Resources

- [ShellCheck Wiki](https://www.shellcheck.net/wiki/)
- [Bash Best Practices](https://mywiki.wooledge.org/BashGuide/Practices)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
