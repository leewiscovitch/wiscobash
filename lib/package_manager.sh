#!/usr/bin/env bash
# Package manager module for WiscoBash
# Cross-distribution package installation with state tracking
# State file: ~/.config/wiscobash/installed_packages
# Supports: Debian/Ubuntu, RHEL/Fedora, Arch-based distros

WISCOBASH_STATE_DIR="$HOME/.config/wiscobash"
WISCOBASH_STATE_FILE="$WISCOBASH_STATE_DIR/installed_packages"
mkdir -p "$WISCOBASH_STATE_DIR"
touch "$WISCOBASH_STATE_FILE"

# State tracking functions
wb_package_installed() { grep -q "^$1$" "$WISCOBASH_STATE_FILE" 2>/dev/null; }
wb_mark_installed() { wb_package_installed "$1" || echo "$1" >> "$WISCOBASH_STATE_FILE"; }
wb_mark_uninstalled() { [ -f "$WISCOBASH_STATE_FILE" ] && sed -i "/^$1$/d" "$WISCOBASH_STATE_FILE"; }
wb_list_installed() { [ -f "$WISCOBASH_STATE_FILE" ] && cat "$WISCOBASH_STATE_FILE"; }

# wb_get_package_name - Map generic package ID to distro-specific name
# Args: $1 = generic package ID (e.g., "docker", "python3")
# Returns: Distro-specific package name or returns 1 if unknown
wb_get_package_name() {
    local pkg="$1"
    local name

    # Map generic package IDs to distro-specific package names
    case "$pkg" in
        git|curl|wget|vim|htop|tree|tmux|jq|unzip|zip|rsync)
            name="$pkg" ;;
        docker)
            case "$DISTRO_FAMILY" in
                debian) name="docker.io" ;;
                *) name="docker" ;;
            esac ;;
        docker-compose)
            name="docker-compose" ;;
        python3)
            case "$DISTRO_FAMILY" in
                arch) name="python" ;;
                *) name="python3" ;;
            esac ;;
        python-pip)
            case "$DISTRO_FAMILY" in
                debian) name="python3-pip" ;;
                rhel) name="python3-pip" ;;
                arch) name="python-pip" ;;
            esac ;;
        nodejs|npm)
            name="$pkg" ;;
        build-essential)
            case "$DISTRO_FAMILY" in
                debian) name="build-essential" ;;
                rhel) name="gcc-c++ make" ;;
                arch) name="base-devel" ;;
            esac ;;
        net-tools)
            name="net-tools" ;;
        openssh-server)
            case "$DISTRO_FAMILY" in
                arch) name="openssh" ;;
                *) name="openssh-server" ;;
            esac ;;
        sqlite)
            case "$DISTRO_FAMILY" in
                debian) name="sqlite3" ;;
                *) name="sqlite" ;;
            esac ;;
        postgresql-client)
            case "$DISTRO_FAMILY" in
                debian) name="postgresql-client" ;;
                *) name="postgresql" ;;
            esac ;;
        redis-tools)
            case "$DISTRO_FAMILY" in
                debian) name="redis-tools" ;;
                *) name="redis" ;;
            esac ;;
        *)
            return 1 ;;
    esac

    echo "$name"
    return 0
}

# wb_install - Install a package by generic ID
# Args: $1 = package ID, $2 = optional "--force" flag
# Returns: 0 on success, 1 on failure
# Example: wb_install docker
wb_install() {
    local pkg="$1" force=false
    [ "$2" = "--force" ] && force=true
    wb_log_section_start "Install: $pkg"
    if ! $force && wb_package_installed "$pkg"; then
        echo "✓ $pkg already installed"
        wb_log_package_install "$pkg" "skipped"
        wb_log_section_end "Install: $pkg" "skipped"
        return 0
    fi
    local name
    name=$(wb_get_package_name "$pkg")
    [ -z "$name" ] && echo "✗ Unknown: $pkg" && wb_log_error "Unknown: $pkg" && return 1
    echo "Installing $pkg ($name)..."
    wb_log_info "Installing $pkg as $name"
    case "$DISTRO_FAMILY" in
        debian) sudo apt-get install -y "$name" && wb_mark_installed "$pkg" && echo "✓ Installed $pkg" && wb_log_package_install "$pkg" "success" && return 0 ;;
        rhel) (sudo dnf install -y "$name" 2>/dev/null || sudo yum install -y "$name") && wb_mark_installed "$pkg" && echo "✓ Installed $pkg" && wb_log_package_install "$pkg" "success" && return 0 ;;
        arch) sudo pacman -S --noconfirm "$name" && wb_mark_installed "$pkg" && echo "✓ Installed $pkg" && wb_log_package_install "$pkg" "success" && return 0 ;;
    esac
    echo "✗ Failed: $pkg"
    wb_log_package_install "$pkg" "failed"
    return 1
}

# wb_install_multi - Install multiple packages
# Args: List of package IDs
# Example: wb_install_multi git curl docker
wb_install_multi() { for p in "$@"; do wb_install "$p" || echo "Failed: $p"; done; }

# wb_check - Check installation status of packages
# Args: List of package IDs
# Example: wb_check git docker python3
wb_check() { for p in "$@"; do wb_package_installed "$p" && echo "✓ $p" || echo "✗ $p"; done; }

# wb_packages_list - Show available package IDs
wb_packages_list() {
    echo "Available: git curl wget vim htop tree tmux docker docker-compose"
    echo "           python3 python-pip nodejs npm build-essential jq"
    echo "           unzip zip rsync openssh-server sqlite"
}

# wb_reset_state - Clear package installation state (for debugging)
wb_reset_state() { true > "$WISCOBASH_STATE_FILE"; echo "State reset"; }
