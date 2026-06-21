# Aria2 Configuration

Lightweight multi-protocol download manager with BitTorrent support.

## Overview

[aria2](https://aria2.github.io/) is a command-line download utility supporting:
- **HTTP/HTTPS/FTP** downloads
- **BitTorrent** protocol
- **Metalink** files
- **Multi-connection** downloads for speed
- **RPC interface** for remote control

**Key Features:**
- Resume interrupted downloads
- Multi-segment downloads (up to 16 connections per file)
- BitTorrent with DHT, PEX, and tracker support
- Lightweight and fast (written in C++)

## Quick Links

- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [BitTorrent Settings](#bittorrent-settings)
- [Troubleshooting](#troubleshooting)

---

## Installation

### Prerequisites

```bash
# Install aria2
brew install aria2
```

### Configuration

**Symlink (created by install script):**
```bash
config/aria2/aria2.conf → ~/.aria2/aria2.conf
```

**Create session directory:**
```bash
mkdir -p ~/.aria2
```

---

## Configuration

### Current Settings

This dotfiles configures aria2 for **optimized BitTorrent downloads**:

```conf
# BitTorrent Performance
bt-request-peer-speed-limit=1M      # Minimum peer speed: 1 MB/s
bt-stop-timeout=120                 # Stop timeout: 2 minutes
seed-ratio=1.0                      # Seed until 1.0 ratio
split=16                            # 16 segments per download
max-connection-per-server=16        # 16 connections per server

# Security & Verification
check-integrity=true                # Verify checksums
file-allocation=falloc              # Fast file allocation

# Tracker List
bt-tracker=udp://tracker.opentrackr.org:1337/announce,...
# (20 public trackers configured)
```

### Settings Explained

#### Download Performance

| Setting | Value | Description |
|---------|-------|-------------|
| `split` | 16 | Number of connections for HTTP/FTP downloads |
| `max-connection-per-server` | 16 | Maximum connections per server |
| `file-allocation` | falloc | Fast file allocation method |

**Impact:**
- Faster downloads by using multiple connections
- Better suited for high-speed internet (100+ Mbps)
- May need reduction on slower/unstable connections

#### BitTorrent Settings

| Setting | Value | Description |
|---------|-------|-------------|
| `bt-request-peer-speed-limit` | 1M | Minimum peer speed (1 MB/s) |
| `bt-stop-timeout` | 120 | Seconds before stopping inactive torrents |
| `seed-ratio` | 1.0 | Seed until upload/download ratio = 1.0 |
| `check-integrity` | true | Verify file integrity with checksums |

**Seeding Behavior:**
- Downloads seed until 100% ratio (uploaded = downloaded)
- After reaching ratio, torrent stops automatically
- Good etiquette for public torrents

#### Trackers

The configuration includes **20 public BitTorrent trackers**:
- `tracker.opentrackr.org`
- `tracker1.520.jp`
- `opentracker.i2p.rocks`
- `tracker.openbittorrent.com`
- ... and 16 more

**Purpose:**
- Help find peers for torrents
- Redundancy if some trackers are down
- Update periodically from [trackerslist](https://github.com/ngosang/trackerslist)

---

## Usage

### Basic HTTP/HTTPS Download

```bash
# Simple download
aria2c https://example.com/file.zip

# Multiple connections (uses config: 16)
aria2c https://example.com/largefile.iso

# With custom options
aria2c -x 8 -s 8 https://example.com/file.zip
# -x: max connections per server
# -s: split into N segments
```

### BitTorrent Download

```bash
# Download from torrent file
aria2c file.torrent

# Download from magnet link
aria2c 'magnet:?xt=urn:btih:...'

# With custom seed ratio
aria2c --seed-ratio=2.0 file.torrent
```

### Batch Downloads

```bash
# Create a file with URLs (one per line)
cat > urls.txt <<EOF
https://example.com/file1.zip
https://example.com/file2.tar.gz
https://example.com/file3.pdf
EOF

# Download all
aria2c -i urls.txt
```

### Resume Downloads

```bash
# Downloads resume automatically
aria2c -c https://example.com/file.zip
# -c: continue/resume download
```

### Download to Specific Directory

```bash
# Download to specific location
aria2c -d ~/Downloads https://example.com/file.zip

# Or set default in config:
# dir=/Users/username/Downloads
```

---

## Advanced Features

### Download Speed Limiting

```bash
# Limit download speed to 1 MB/s
aria2c --max-download-limit=1M https://example.com/file.zip

# Limit upload speed (for torrents)
aria2c --max-upload-limit=100K file.torrent
```

### Concurrent Downloads

```bash
# Download multiple files simultaneously
aria2c --max-concurrent-downloads=5 -i urls.txt
```

### Notifications on Completion

```bash
# Run script when download completes
aria2c --on-download-complete=/path/to/notify.sh file.torrent
```

**Example notification script:**
```bash
#!/bin/bash
# notify.sh
osascript -e 'display notification "Download complete!" with title "aria2"'
```

### Checksum Verification

```bash
# Verify with SHA-256 checksum
aria2c --checksum=sha-256=HASH https://example.com/file.zip
```

---

## BitTorrent Settings

### Optimizing for Speed

**For fast internet (100+ Mbps):**
```bash
# Edit ~/.aria2/aria2.conf
split=32
max-connection-per-server=32
bt-request-peer-speed-limit=2M
```

**For slower/unstable connections:**
```bash
split=8
max-connection-per-server=8
bt-request-peer-speed-limit=500K
```

### Private Trackers

For private trackers, disable DHT and PEX:

```bash
# Add to ~/.aria2/aria2.conf
enable-dht=false
enable-peer-exchange=false
bt-enable-lpd=false
# Use only tracker peers
```

### Updating Trackers

Trackers change over time. Update periodically:

**Get latest trackers:**
```bash
# From trackerslist (best public trackers)
curl -s https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_best.txt \
  | tr '\n' ',' > /tmp/trackers.txt

# View trackers
cat /tmp/trackers.txt
```

**Update config:**
```bash
# Edit ~/.aria2/aria2.conf
# Replace bt-tracker= line with new trackers
```

---

## RPC Interface (Optional)

Enable remote control via RPC:

### Enable RPC

**Add to ~/.aria2/aria2.conf:**
```conf
enable-rpc=true
rpc-listen-all=true
rpc-allow-origin-all=true
# For security, add:
rpc-secret=YOUR_SECRET_TOKEN
```

### Start Aria2 as Daemon

```bash
# Start aria2 RPC server
aria2c --enable-rpc --rpc-listen-all

# Or in background
aria2c --enable-rpc --rpc-listen-all --daemon=true
```

### Web UI

Use a web interface to manage downloads:

**1. Install AriaNg (recommended):**
```bash
brew install --cask ariang
```

**2. Or use online version:**
[http://ariang.mayswind.net/latest](http://ariang.mayswind.net/latest)

**3. Connect:**
- RPC URL: `http://localhost:6800/jsonrpc`
- Secret token: (if configured)

### Browser Integration

**Chrome/Firefox Extensions:**
- **Aria2 for Chrome** - Send downloads to aria2
- **Aria2 Download Manager Integration**

**Setup:**
1. Install extension
2. Configure RPC: `http://localhost:6800/jsonrpc`
3. Click download links → Opens in aria2

---

## Customization

### Changing Download Directory

**Edit ~/.aria2/aria2.conf:**
```conf
dir=/Users/username/Downloads
```

**Or specify per download:**
```bash
aria2c -d ~/Desktop https://example.com/file.zip
```

### Increasing Connections

For very fast internet (1 Gbps+):

```conf
split=64
max-connection-per-server=64
min-split-size=1M
```

### Reducing Resource Usage

For limited bandwidth or CPU:

```conf
split=4
max-connection-per-server=4
max-concurrent-downloads=1
max-overall-download-limit=500K
```

### Seeding Behavior

**Seed indefinitely:**
```conf
seed-time=0
seed-ratio=0
```

**Stop seeding after time:**
```conf
seed-time=60  # Minutes
```

**Stop seeding after ratio:**
```conf
seed-ratio=2.0  # Seed until 200% ratio
```

---

## Troubleshooting

### Issue: Downloads are slow

**Possible causes:**
- Too few connections
- Slow peers (for torrents)
- Outdated trackers

**Solutions:**

1. **Increase connections:**
   ```bash
   aria2c -x 32 -s 32 URL
   ```

2. **Update tracker list:**
   - Get latest from [trackerslist](https://github.com/ngosang/trackerslist)
   - Update `bt-tracker=` in config

3. **Check peer speeds:**
   ```bash
   # For torrents, check peer list in web UI
   # Disconnect slow peers manually
   ```

### Issue: Torrents not downloading

**Possible causes:**
- No peers available
- Firewall blocking connections
- Outdated/dead trackers

**Solutions:**

1. **Enable DHT/PEX:**
   ```conf
   enable-dht=true
   enable-peer-exchange=true
   bt-enable-lpd=true
   ```

2. **Check port forwarding:**
   - Forward port 6881-6889 on router
   - Or use UPnP: `enable-upnp=true`

3. **Verify torrent is active:**
   - Check on torrent site
   - Try different torrent

### Issue: RPC not accessible

**Check if running:**
```bash
curl http://localhost:6800/jsonrpc
```

**Solutions:**

1. **Start RPC server:**
   ```bash
   aria2c --enable-rpc --rpc-listen-all
   ```

2. **Check firewall:**
   - macOS: System Settings → Firewall → Allow aria2

3. **Verify settings:**
   ```bash
   grep rpc ~/.aria2/aria2.conf
   ```

### Issue: "File allocation failed"

**Cause:** Insufficient disk space

**Solutions:**

1. **Check available space:**
   ```bash
   df -h
   ```

2. **Change download directory:**
   ```bash
   aria2c -d /path/with/space URL
   ```

3. **Use different allocation method:**
   ```conf
   file-allocation=none  # Slower but works on full disks
   ```

---

## Configuration Reference

### All Settings

| Setting | Default | This Config | Description |
|---------|---------|-------------|-------------|
| `dir` | Current | Not set | Download directory |
| `split` | 5 | 16 | Number of segments |
| `max-connection-per-server` | 1 | 16 | Connections per server |
| `min-split-size` | 20M | Not set | Min size to split |
| `file-allocation` | prealloc | falloc | Allocation method |
| `continue` | false | Not set | Auto-resume |
| `bt-request-peer-speed-limit` | 50K | 1M | Min peer speed |
| `seed-ratio` | 1.0 | 1.0 | Seed ratio target |
| `check-integrity` | false | true | Verify checksums |

See [aria2 manual](https://aria2.github.io/manual/en/html/aria2c.html) for all options.

---

## Performance Tips

1. **Multi-connection downloads** - Increase `split` for large files on fast connections
2. **Resume support** - Add `continue=true` to auto-resume interrupted downloads
3. **Update trackers** - Keep tracker list fresh for better torrent peer discovery
4. **Monitor resources** - Adjust `max-concurrent-downloads` based on system

---

## Security Considerations

### RPC Security

If exposing RPC to network:

```conf
rpc-secret=STRONG_RANDOM_TOKEN
rpc-allow-origin-all=false
rpc-listen-all=false
rpc-listen-port=6800
```

**Generate secure token:**
```bash
openssl rand -base64 32
```

### Download Verification

Always verify important downloads:

```bash
# SHA-256 checksum
aria2c --checksum=sha-256=HASH file.zip

# Or verify after download
shasum -a 256 file.zip
```

### Private Data

For private trackers:
- Don't share torrent files
- Use VPN if required by tracker
- Disable DHT/PEX (leaks IP to public DHT)

---

## Related Documentation

- [Packages](../../packages/README.md) - Package installation

## Resources

- [Official Documentation](https://aria2.github.io/)
- [Manual](https://aria2.github.io/manual/en/html/index.html)
- [GitHub Repository](https://github.com/aria2/aria2)
- [Tracker Lists](https://github.com/ngosang/trackerslist)
- [AriaNg Web UI](https://github.com/mayswind/AriaNg)

---

## Related Documentation

- [Packages](../../packages/README.md) - Package installation
- [Troubleshooting](../../docs/TROUBLESHOOTING.md) - Common issues

## Getting Help

- Run health check: `./scripts/health-check.sh`
- Review [Troubleshooting Guide](../../docs/TROUBLESHOOTING.md)
- Check aria2 manual: `man aria2c`

---

**Status:** ✅ Complete
**Last Updated:** 2025-12-20
