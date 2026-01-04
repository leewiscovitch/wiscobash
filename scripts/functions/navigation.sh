#!/usr/bin/env bash
up() {
    local d="" limit="${1:-1}"
    for ((i=1; i<=limit; i++)); do d="../$d"; done
    cd "$d" || return
}
goto() {
    case "$1" in
        wb|wiscobash) cd ~/wiscobash || return ;;
        proj|projects) cd ~/projects 2>/dev/null || cd ~/Projects 2>/dev/null || echo "Not found" ;;
        dl|downloads) cd ~/Downloads 2>/dev/null || cd ~/downloads 2>/dev/null || echo "Not found" ;;
        docs|documents) cd ~/Documents 2>/dev/null || cd ~/documents 2>/dev/null || echo "Not found" ;;
        *) echo "Unknown: $1. Available: wb, proj, dl, docs" ;;
    esac
}
tree() {
    command -v tree >/dev/null 2>&1 && command tree "$@" || find "${1:-.}" -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'
}
