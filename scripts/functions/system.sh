#!/usr/bin/env bash
mkcd() {
    [ -z "$1" ] && echo "Usage: mkcd <directory>" && return 1
    mkdir -p "$1" && cd "$1" || return
}
extract() {
    [ ! -f "$1" ] && echo "Not a file: $1" && return 1
    case "$1" in
        *.tar.bz2) tar xjf "$1" ;;
        *.tar.gz) tar xzf "$1" ;;
        *.bz2) bunzip2 "$1" ;;
        *.rar) unrar x "$1" ;;
        *.gz) gunzip "$1" ;;
        *.tar) tar xf "$1" ;;
        *.tbz2) tar xjf "$1" ;;
        *.tgz) tar xzf "$1" ;;
        *.zip) unzip "$1" ;;
        *.Z) uncompress "$1" ;;
        *.7z) 7z x "$1" ;;
        *) echo "Cannot extract: $1" ;;
    esac
}
ff() {
    [ -z "$1" ] && echo "Usage: ff <filename>" && return 1
    find . -type f -iname "*$1*"
}
fd() {
    [ -z "$1" ] && echo "Usage: fd <dirname>" && return 1
    find . -type d -iname "*$1*"
}
usage() { du -h --max-depth=1 | sort -hr; }
backup() {
    [ -z "$1" ] && echo "Usage: backup <file>" && return 1
    [ ! -e "$1" ] && echo "File not found: $1" && return 1
    cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
}
mvx() {
    [ $# -lt 2 ] && echo "Usage: mvx <source> <destination>" && return 1
    rsync -ah --info=progress2 --remove-source-files "$1" "$2"
    # Remove empty source directories
    find "$1" -type d -empty -delete 2>/dev/null
}
tailx() {
    local file="$1"

    # If no file specified, use distro-specific syslog
    if [ -z "$file" ]; then
        case "$DISTRO_FAMILY" in
            debian)
                file="/var/log/syslog"
                ;;
            rhel|arch)
                file="/var/log/messages"
                ;;
            *)
                # Fallback: try to find whichever exists
                if [ -f "/var/log/syslog" ]; then
                    file="/var/log/syslog"
                elif [ -f "/var/log/messages" ]; then
                    file="/var/log/messages"
                else
                    echo "Error: Could not find system log file"
                    return 1
                fi
                ;;
        esac
    fi

    if [ -f "$file" ]; then
        sudo tail -F -n 1000 "$file"
    else
        echo "Error: File '$file' does not exist"
        return 1
    fi
}
sysinfo() {
    echo "=== System Info ==="
    echo "Host: $(hostname)"
    echo "Distro: $DISTRO ($DISTRO_FAMILY)"
    echo "Kernel: $(uname -r)"
    echo "CPU: $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)"
    echo "Memory: $(free -h | awk '/^Mem:/ {print $3 " / " $2}')"
    echo "Disk: $(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')"
}
wb_update() {
    local current_dir="$PWD"
    echo "Updating WiscoBash from git..."

    cd "$WISCOBASH_DIR" || { echo "Error: Cannot access $WISCOBASH_DIR"; return 1; }

    if ! git pull; then
        echo "Error: git pull failed"
        cd "$current_dir" || return
        return 1
    fi

    cd "$current_dir" || return

    echo "Reloading WiscoBash..."
    source "$HOME/.bashrc"

    echo "✓ WiscoBash updated and reloaded!"
}
wb_refresh() {
    echo "Reloading WiscoBash..."
    source "$HOME/.bashrc"
    echo "✓ WiscoBash reloaded!"
}
