# CheetSheetz CLI

POSIX-compliant command-line tool for quick access to developer cheat sheets with syntax highlighting.

## Quick Install

```bash
# Universal install (any POSIX system)
curl -L https://github.com/cheatsheetz/cli/releases/latest/download/cheetsheetz-universal.sh -o cheatsheetz
chmod +x cheatsheetz
sudo mv cheatsheetz /usr/local/bin/

# Or download platform-specific binary
wget https://github.com/cheatsheetz/cli/releases/latest/download/cheatsheetz-linux-amd64.tar.gz
tar -xzf cheatsheetz-linux-amd64.tar.gz && cd cheatsheetz-linux-amd64 && sudo ./install.sh
```

## Usage

| Command | Description | Example |
|---------|-------------|---------|
| `cheatsheetz search <term>` | Search cheat sheets | `cheatsheetz search docker` |
| `cheatsheetz show <tool>` | Display cheat sheet | `cheatsheetz show git` |
| `cheatsheetz list` | List all sheets | `cheatsheetz list` |
| `cheatsheetz categories` | Show categories | `cheatsheetz categories` |
| `cheatsheetz update` | Clear cache | `cheatsheetz update` |

## Options

| Option | Description |
|--------|-------------|
| `-f, --format <type>` | Output format (plain, markdown, json) |
| `-c, --category <cat>` | Filter by category |
| `-d, --difficulty <lvl>` | Filter by difficulty |
| `-n, --no-color` | Disable colored output |
| `-q, --quiet` | Suppress info messages |
| `-v, --verbose` | Enable verbose output |

## Examples

```bash
# Quick cheat sheet lookup
cheatsheetz git
cheatsheetz docker

# Search functionality
cheatsheetz search kubernetes
cheatsheetz search "sql injection"

# Category browsing
cheatsheetz list --category languages
cheatsheetz list --difficulty beginner

# Different output formats
cheatsheetz show python --format markdown
cheatsheetz show aws --format json --no-color
```

## Features

- 🔍 **Fast Search** - Find cheat sheets across 400+ tools
- 📋 **Syntax Highlighting** - Colored output for better readability
- 📱 **POSIX Compliant** - Works on Linux, macOS, BSD, Alpine
- ⚡ **Smart Caching** - Offline support with automatic updates
- 🎨 **Multiple Formats** - Plain text, Markdown, JSON output
- 🚀 **Zero Dependencies** - Pure shell script

## Platform Support

- ✅ Linux (amd64, 386, arm64)
- ✅ macOS (Intel, Apple Silicon)
- ✅ FreeBSD (amd64, 386)
- ✅ OpenBSD (amd64, 386)
- ✅ Alpine Linux
- ✅ Any POSIX shell (bash, zsh, dash, ash)

## Configuration

Config file: `~/.config/cheatsheetz/config`

```bash
# Default configuration
DEFAULT_FORMAT="plain"
CACHE_EXPIRY="3600"
API_BASE_URL="https://api.github.com"
```

## Development

```bash
# Clone repository
git clone https://github.com/cheatsheetz/cli.git
cd cli

# Test locally
./bin/cheatsheetz help
./bin/cheatsheetz show git

# Run tests
make test

# Create release
git tag v1.0.0
git push origin v1.0.0
```

---

## Resources
- [CheetSheetz Website](https://cheatsheetz.github.io)
- [GitHub Organization](https://github.com/cheatsheetz)
- [Report Issues](https://github.com/cheatsheetz/cli/issues)

---
*POSIX-compliant CLI for the CheetSheetz developer reference collection*