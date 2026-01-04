#!/usr/bin/env bash
mkcd() { mkdir -p "$1" && cd "$1" || return; }
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
ff() { find . -type f -iname "*$1*"; }
fd() { find . -type d -iname "*$1*"; }
usage() { du -h --max-depth=1 | sort -hr; }
backup() { cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"; }
sysinfo() {
    echo "=== System Info ==="
    echo "Host: $(hostname)"
    echo "Distro: $DISTRO ($DISTRO_FAMILY)"
    echo "Kernel: $(uname -r)"
    echo "CPU: $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)"
    echo "Memory: $(free -h | awk '/^Mem:/ {print $3 " / " $2}')"
    echo "Disk: $(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')"
}
