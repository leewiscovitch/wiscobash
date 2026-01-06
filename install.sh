#!/usr/bin/env bash
# WiscoBash Installer
# Installs WiscoBash and optionally installs essential packages
#
# Usage:
#   ./install.sh                    # Interactive installation
#   ./install.sh --with-essentials  # Install with essential packages
#   ./install.sh --with-dev         # Install with dev tools
#   ./install.sh --with-cli-tools   # Install with CLI tools
#   ./install.sh --with-all         # Install with all packages
#   ./install.sh --no-packages      # Install without packages (non-interactive)
#   ./install.sh --force            # Force reinstall even if already installed

set -e
WISCOBASH_DIR="$HOME/wiscobash"
BASHRC="$HOME/.bashrc"
MARKER="# >>> wiscobash initialize >>>"
PACKAGE_MODE=""
FORCE_INSTALL=false

# Parse command-line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --with-essentials)
            PACKAGE_MODE="essentials"
            shift
            ;;
        --with-dev)
            PACKAGE_MODE="dev"
            shift
            ;;
        --with-cli-tools)
            PACKAGE_MODE="cli-tools"
            shift
            ;;
        --with-all)
            PACKAGE_MODE="all"
            shift
            ;;
        --no-packages)
            PACKAGE_MODE="skip"
            shift
            ;;
        --force)
            FORCE_INSTALL=true
            shift
            ;;
        --help|-h)
            echo "WiscoBash Installer"
            echo ""
            echo "Usage: $0 [OPTION]"
            echo ""
            echo "Options:"
            echo "  --with-essentials   Install WiscoBash with essential packages"
            echo "  --with-dev          Install WiscoBash with dev tools"
            echo "  --with-cli-tools    Install WiscoBash with CLI tools"
            echo "  --with-all          Install WiscoBash with all packages"
            echo "  --no-packages       Install WiscoBash without installing packages"
            echo "  --force             Force reinstall even if already installed"
            echo "  --help, -h          Show this help message"
            echo ""
            echo "If no option is provided, you'll be prompted to choose."
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Run '$0 --help' for usage information"
            exit 1
            ;;
    esac
done

echo "Installing WiscoBash..."
[ ! -f "$WISCOBASH_DIR/install.sh" ] && echo "Error: Run from $WISCOBASH_DIR" && exit 1

# Check if already installed (unless --force is used)
if ! $FORCE_INSTALL && grep -q "$MARKER" "$BASHRC" 2>/dev/null; then
    echo "Already installed. Use --force to reinstall or run ./uninstall.sh first"
    exit 1
fi

# If force reinstalling, remove old markers first
if $FORCE_INSTALL && grep -q "$MARKER" "$BASHRC" 2>/dev/null; then
    echo "Force reinstalling (removing old installation)..."
    # Remove old wiscobash block
    sed -i '/# >>> wiscobash initialize >>>/,/# <<< wiscobash initialize <<<</ d' "$BASHRC"
fi

# Backup and install
cp "$BASHRC" "$BASHRC.backup.$(date +%Y%m%d_%H%M%S)"
cat >> "$BASHRC" << 'MARK'

# >>> wiscobash initialize >>>
[ -f "$HOME/wiscobash/config/bashrc_additions" ] && source "$HOME/wiscobash/config/bashrc_additions"
# <<< wiscobash initialize <<<<
MARK
echo "✓ WiscoBash installed!"

# Handle package installation
if [ -z "$PACKAGE_MODE" ]; then
    # Interactive mode - ask the user
    echo ""
    echo "Would you like to install packages?"
    echo "1) Essential packages (git, curl, wget, vim, htop, tree, unzip, zip)"
    echo "2) Dev tools (tmux, jq, build-essential, python3, python-pip)"
    echo "3) CLI tools (btop, ripgrep, bat, ncdu, p7zip-gui, xmlstarlet)"
    echo "4) All packages"
    echo "5) Skip (install later with ~/wiscobash/scripts/setup/essential_packages.sh)"
    read -r -p "Choose [1-5]: " choice
    case "$choice" in
        1) PACKAGE_MODE="essentials" ;;
        2) PACKAGE_MODE="dev" ;;
        3) PACKAGE_MODE="cli-tools" ;;
        4) PACKAGE_MODE="all" ;;
        *) PACKAGE_MODE="skip" ;;
    esac
fi

# Install packages based on selection
if [ "$PACKAGE_MODE" != "skip" ]; then
    echo ""
    echo "Loading WiscoBash libraries..."
    source "$WISCOBASH_DIR/config/bashrc_additions"
    echo ""
    "$WISCOBASH_DIR/scripts/setup/essential_packages.sh" "--$PACKAGE_MODE"
fi

echo ""
echo "✓ Installation complete!"
echo "Run: source ~/.bashrc"
