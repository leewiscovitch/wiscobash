#!/usr/bin/env bash
# WiscoBash Essential Packages Installer
# Supports both interactive and non-interactive modes
#
# Usage:
#   ./essential_packages.sh                  # Interactive menu
#   ./essential_packages.sh --essentials     # Install essential packages
#   ./essential_packages.sh --dev            # Install dev tools
#   ./essential_packages.sh --all            # Install both
#   ./essential_packages.sh --status         # Show installed packages
#   ./essential_packages.sh --skip           # Do nothing (for scripting)

ESSENTIAL=(git curl wget vim htop tree unzip zip)
DEV=(tmux jq build-essential python3 python-pip)

install_essentials() {
    echo "=== Installing Essentials ==="
    local todo=()
    for p in "${ESSENTIAL[@]}"; do wb_package_installed "$p" && echo "✓ $p" || todo+=("$p"); done
    [ ${#todo[@]} -gt 0 ] && echo "Installing: ${todo[*]}" && wb_install_multi "${todo[@]}" || echo "All installed!"
}

install_dev() {
    echo "=== Installing Dev Tools ==="
    local todo=()
    for p in "${DEV[@]}"; do wb_package_installed "$p" && echo "✓ $p" || todo+=("$p"); done
    [ ${#todo[@]} -gt 0 ] && echo "Installing: ${todo[*]}" && wb_install_multi "${todo[@]}" || echo "All installed!"
}

show_status() {
    echo "=== Installed Packages ==="
    wb_list_installed
}

# Only run if executed directly (not sourced)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # Load required libraries
    source "$HOME/wiscobash/lib/logging.sh"
    source "$HOME/wiscobash/lib/distro_detect.sh"
    source "$HOME/wiscobash/lib/package_manager.sh"

    # Check for command-line arguments (non-interactive mode)
    if [ $# -gt 0 ]; then
        case "$1" in
            --essentials)
                install_essentials
                ;;
            --dev)
                install_dev
                ;;
            --all)
                install_essentials
                install_dev
                ;;
            --status)
                show_status
                ;;
            --skip)
                echo "Skipping package installation"
                ;;
            --help|-h)
                echo "Usage: $0 [OPTION]"
                echo ""
                echo "Options:"
                echo "  --essentials    Install essential packages (git, curl, wget, vim, htop, tree, unzip, zip)"
                echo "  --dev           Install development tools (tmux, jq, build-essential, python3, python-pip)"
                echo "  --all           Install both essentials and dev tools"
                echo "  --status        Show installed packages"
                echo "  --skip          Skip package installation"
                echo "  --help, -h      Show this help message"
                echo ""
                echo "If no option is provided, an interactive menu will be shown."
                ;;
            *)
                echo "Unknown option: $1"
                echo "Run '$0 --help' for usage information"
                exit 1
                ;;
        esac
    else
        # Interactive mode (no arguments)
        echo "1) Essentials  2) Dev tools  3) Both  4) Status  5) Exit"
        read -r -p "Choose: " c
        case $c in
            1) install_essentials ;;
            2) install_dev ;;
            3) install_essentials; install_dev ;;
            4) show_status ;;
            5) exit 0 ;;
            *) echo "Invalid choice" ;;
        esac
    fi
fi
