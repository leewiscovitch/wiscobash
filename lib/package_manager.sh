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
        btop|ripgrep|bat|ncdu|xmlstarlet|micro|eza)
            name="$pkg" ;;
        p7zip)
            case "$DISTRO_FAMILY" in
                debian) name="p7zip-full" ;;
                rhel) name="p7zip p7zip-plugins" ;;
                arch) name="p7zip" ;;
            esac ;;
        *)
            return 1 ;;
    esac

    echo "$name"
    return 0
}

# wb_reload_applications - Reload application-specific scripts
# Used after installing new packages to load their aliases/functions
wb_reload_applications() {
    wb_log_info "Reloading application scripts..."
    for f in "$WISCOBASH_DIR/scripts/applications"/*.sh; do
        [ -f "$f" ] && source "$f" 2>/dev/null
    done
}

# wb_install_single - Install a single package (internal function)
# Args: $1 = package ID, $2 = optional "--force" flag
wb_install_single() {
    local pkg="$1" force=false
    [ "$2" = "--force" ] && force=true
    wb_log_section_start "Install: $pkg"
    if ! $force && wb_package_installed "$pkg"; then
        echo "✓ $pkg already installed"
        wb_log_package_install "$pkg" "skipped"
        wb_log_section_end "Install: $pkg" "skipped"
        return 0
    fi

    # Special handling for packages with custom installers
    case "$pkg" in
        ansible)
            wb_install_ansible
            return $?
            ;;
        starship)
            wb_install_starship
            return $?
            ;;
        miniconda)
            wb_install_miniconda
            return $?
            ;;
    esac

    local name
    name=$(wb_get_package_name "$pkg")
    [ -z "$name" ] && echo "✗ Unknown: $pkg" && wb_log_error "Unknown: $pkg" && return 1
    echo "Installing $pkg ($name)..."
    wb_log_info "Installing $pkg as $name"
    case "$DISTRO_FAMILY" in
        debian) sudo apt-get install -y "$name" && wb_mark_installed "$pkg" && echo "✓ Installed $pkg" && wb_log_package_install "$pkg" "success" && wb_log_section_end "Install: $pkg" "success" && return 0 ;;
        rhel) (sudo dnf install -y "$name" 2>/dev/null || sudo yum install -y "$name") && wb_mark_installed "$pkg" && echo "✓ Installed $pkg" && wb_log_package_install "$pkg" "success" && wb_log_section_end "Install: $pkg" "success" && return 0 ;;
        arch) sudo pacman -S --noconfirm "$name" && wb_mark_installed "$pkg" && echo "✓ Installed $pkg" && wb_log_package_install "$pkg" "success" && wb_log_section_end "Install: $pkg" "success" && return 0 ;;
    esac
    echo "✗ Failed: $pkg"
    wb_log_package_install "$pkg" "failed"
    wb_log_section_end "Install: $pkg" "failed"
    return 1
}

# wb_install - Install one or more packages
# Args: package IDs (accepts multiple), optional --force flag
# Returns: 0 on success, 1 if any failed
# Example: wb_install docker
# Example: wb_install bat ripgrep htop
# Example: wb_install --force ansible
wb_install() {
    [ $# -eq 0 ] && echo "Usage: wb_install [--force] <package> [package2 ...]" && return 1

    local failed=0
    local installed_any=false
    local force_flag=""

    # Check for --force flag
    if [ "$1" = "--force" ]; then
        force_flag="--force"
        shift
    fi

    [ $# -eq 0 ] && echo "Usage: wb_install [--force] <package> [package2 ...]" && return 1

    # Install each package
    for pkg in "$@"; do
        if wb_install_single "$pkg" $force_flag; then
            installed_any=true
        else
            failed=$((failed + 1))
        fi
    done

    # Reload application scripts if any packages were installed
    if $installed_any; then
        echo ""
        echo "Reloading application aliases..."
        wb_reload_applications
    fi

    return $failed
}

# wb_install_multi - Install multiple packages (legacy wrapper)
# Args: List of package IDs
# Note: wb_install now handles multiple packages, so this just calls it
# Example: wb_install_multi git curl docker
wb_install_multi() { wb_install "$@"; }

# wb_check - Check installation status of packages
# Args: List of package IDs
# Example: wb_check git docker python3
wb_check() { for p in "$@"; do wb_package_installed "$p" && echo "✓ $p" || echo "✗ $p"; done; }

# wb_packages_list - Show available package IDs
wb_packages_list() {
    echo "Available: git curl wget vim htop tree tmux docker docker-compose"
    echo "           python3 python-pip nodejs npm build-essential jq"
    echo "           unzip zip rsync openssh-server sqlite ansible miniconda"
    echo "           btop ripgrep bat ncdu p7zip xmlstarlet micro eza starship"
}

# wb_reset_state - Clear package installation state (for debugging)
wb_reset_state() { true > "$WISCOBASH_STATE_FILE"; echo "State reset"; }
