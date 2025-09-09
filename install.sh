#!/bin/sh
# CheetSheetz CLI Installer
# Automatically detects platform and installs the appropriate binary

set -e

# Configuration
PROGRAM_NAME="cheatsheetz"
GITHUB_ORG="cheatsheetz"
GITHUB_REPO="cli"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

# Colors for output
if [ -t 1 ] && [ "${NO_COLOR:-}" = "" ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' BOLD='' RESET=''
fi

# Utility functions
error() {
    printf "${RED}Error:${RESET} %s\n" "$*" >&2
    exit 1
}

info() {
    printf "${BLUE}Info:${RESET} %s\n" "$*"
}

success() {
    printf "${GREEN}✓${RESET} %s\n" "$*"
}

warning() {
    printf "${YELLOW}Warning:${RESET} %s\n" "$*"
}

# Platform detection
detect_platform() {
    local os
    local arch
    
    # Detect OS
    case "$(uname -s)" in
        Linux*)     os="linux" ;;
        Darwin*)    os="darwin" ;;
        FreeBSD*)   os="freebsd" ;;
        OpenBSD*)   os="openbsd" ;;
        *)          os="unknown" ;;
    esac
    
    # Detect architecture
    case "$(uname -m)" in
        x86_64|amd64)   arch="amd64" ;;
        i386|i686)      arch="386" ;;
        aarch64|arm64)  arch="arm64" ;;
        armv7l)         arch="arm" ;;
        *)              arch="unknown" ;;
    esac
    
    if [ "$os" = "unknown" ] || [ "$arch" = "unknown" ]; then
        warning "Unknown platform, using universal shell script"
        echo "universal"
    else
        echo "$os-$arch"
    fi
}

# Check if we have permission to install
check_install_permission() {
    if [ "$INSTALL_DIR" = "/usr/local/bin" ] && [ "$(id -u)" -ne 0 ]; then
        error "Installing to $INSTALL_DIR requires sudo. Run: sudo $0"
    fi
    
    if [ ! -d "$(dirname "$INSTALL_DIR")" ]; then
        error "Directory $(dirname "$INSTALL_DIR") does not exist"
    fi
}

# Download file
download_file() {
    local url="$1"
    local output="$2"
    
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$output" || error "Failed to download $url"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$url" -O "$output" || error "Failed to download $url"
    else
        error "Neither curl nor wget found. Please install one of them."
    fi
}

# Get latest release info
get_latest_release() {
    local api_url="https://api.github.com/repos/$GITHUB_ORG/$GITHUB_REPO/releases/latest"
    local temp_file
    temp_file=$(mktemp)
    
    download_file "$api_url" "$temp_file"
    
    if command -v jq >/dev/null 2>&1; then
        jq -r '.tag_name' "$temp_file"
    else
        # POSIX fallback
        grep '"tag_name"' "$temp_file" | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/'
    fi
    
    rm -f "$temp_file"
}

# Main installation function
install_cli() {
    local platform
    local version
    local download_url
    local temp_dir
    local temp_file
    
    info "Detecting platform..."
    platform=$(detect_platform)
    success "Platform: $platform"
    
    info "Getting latest release..."
    version=$(get_latest_release)
    success "Latest version: $version"
    
    # Check permissions
    check_install_permission
    
    # Create temp directory
    temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" EXIT
    
    if [ "$platform" = "universal" ]; then
        # Download universal shell script
        download_url="https://github.com/$GITHUB_ORG/$GITHUB_REPO/releases/download/$version/$PROGRAM_NAME-universal.sh"
        temp_file="$temp_dir/$PROGRAM_NAME"
        
        info "Downloading universal shell script..."
        download_file "$download_url" "$temp_file"
        chmod +x "$temp_file"
        
    else
        # Download platform-specific binary
        local package_name="$PROGRAM_NAME-$platform"
        download_url="https://github.com/$GITHUB_ORG/$GITHUB_REPO/releases/download/$version/$package_name.tar.gz"
        local archive_file="$temp_dir/$package_name.tar.gz"
        
        info "Downloading $package_name..."
        download_file "$download_url" "$archive_file"
        
        info "Extracting archive..."
        cd "$temp_dir"
        tar -xzf "$archive_file" || error "Failed to extract archive"
        
        temp_file="$temp_dir/$package_name/$PROGRAM_NAME"
        
        if [ ! -f "$temp_file" ]; then
            error "Binary not found in archive"
        fi
    fi
    
    # Install binary
    info "Installing to $INSTALL_DIR..."
    mkdir -p "$INSTALL_DIR"
    cp "$temp_file" "$INSTALL_DIR/$PROGRAM_NAME"
    chmod +x "$INSTALL_DIR/$PROGRAM_NAME"
    
    success "CheetSheetz CLI installed successfully!"
    echo ""
    echo "${BOLD}Next steps:${RESET}"
    echo "  $PROGRAM_NAME help              # Show help"
    echo "  $PROGRAM_NAME show git          # View git cheat sheet"
    echo "  $PROGRAM_NAME search docker     # Search for docker"
    echo ""
    echo "Add $INSTALL_DIR to your PATH if not already included."
}

# Show usage if no arguments
if [ $# -eq 0 ]; then
    cat << EOF
${BOLD}CheetSheetz CLI Installer${RESET}

This script will download and install the latest CheetSheetz CLI.

${BOLD}Usage:${RESET}
  $0                          # Install to /usr/local/bin (requires sudo)
  INSTALL_DIR=~/.local/bin $0 # Install to custom directory

${BOLD}Options:${RESET}
  Set environment variables before running:
  - INSTALL_DIR: Custom installation directory
  - NO_COLOR: Disable colored output

${BOLD}Examples:${RESET}
  sudo $0                     # System-wide install
  INSTALL_DIR=~/.local/bin $0 # User install
  
EOF
    read -p "Install CheetSheetz CLI to $INSTALL_DIR? [y/N] " response
    case "$response" in
        [yY]|[yY][eE][sS]) ;;
        *) echo "Installation cancelled."; exit 0 ;;
    esac
fi

# Run installation
install_cli