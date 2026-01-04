#!/usr/bin/env bash
WISCOBASH_STATE_DIR="$HOME/.config/wiscobash"
WISCOBASH_STATE_FILE="$WISCOBASH_STATE_DIR/installed_packages"
mkdir -p "$WISCOBASH_STATE_DIR"
touch "$WISCOBASH_STATE_FILE"
wb_package_installed() { grep -q "^$1$" "$WISCOBASH_STATE_FILE" 2>/dev/null; }
wb_mark_installed() { wb_package_installed "$1" || echo "$1" >> "$WISCOBASH_STATE_FILE"; }
wb_mark_uninstalled() { [ -f "$WISCOBASH_STATE_FILE" ] && sed -i "/^$1$/d" "$WISCOBASH_STATE_FILE"; }
wb_list_installed() { [ -f "$WISCOBASH_STATE_FILE" ] && cat "$WISCOBASH_STATE_FILE"; }
wb_get_package_name() {
    local mappings="git|git|git|git curl|curl|curl|curl wget|wget|wget|wget vim|vim|vim|vim htop|htop|htop|htop tree|tree|tree|tree tmux|tmux|tmux|tmux docker|docker.io|docker|docker docker-compose|docker-compose|docker-compose|docker-compose python3|python3|python3|python python-pip|python3-pip|python3-pip|python-pip nodejs|nodejs|nodejs|nodejs npm|npm|npm|npm build-essential|build-essential|gcc-c++ make|base-devel net-tools|net-tools|net-tools|net-tools jq|jq|jq|jq unzip|unzip|unzip|unzip zip|zip|zip|zip rsync|rsync|rsync|rsync openssh-server|openssh-server|openssh-server|openssh sqlite|sqlite3|sqlite|sqlite postgresql-client|postgresql-client|postgresql|postgresql redis-tools|redis-tools|redis|redis"
    for m in $mappings; do
        IFS='|' read -r id deb rh ar <<< "$m"
        if [ "$id" = "$1" ]; then
            case "$DISTRO_FAMILY" in
                debian) echo "$deb"; return 0 ;;
                rhel) echo "$rh"; return 0 ;;
                arch) echo "$ar"; return 0 ;;
            esac
        fi
    done
    return 1
}
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
wb_install_multi() { for p in "$@"; do wb_install "$p" || echo "Failed: $p"; done; }
wb_check() { for p in "$@"; do wb_package_installed "$p" && echo "✓ $p" || echo "✗ $p"; done; }
wb_packages_list() {
    echo "Available: git curl wget vim htop tree tmux docker docker-compose"
    echo "           python3 python-pip nodejs npm build-essential jq"
    echo "           unzip zip rsync openssh-server sqlite"
}
wb_reset_state() { true > "$WISCOBASH_STATE_FILE"; echo "State reset"; }
