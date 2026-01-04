#!/usr/bin/env bash
detect_distro() {
    if [ -f /etc/os-release ]; then . /etc/os-release; echo "$ID"
    elif [ -f /etc/debian_version ]; then echo "debian"
    elif [ -f /etc/redhat-release ]; then echo "rhel"
    elif [ -f /etc/arch-release ]; then echo "arch"
    else echo "unknown"; fi
}
DISTRO=$(detect_distro)
case "$DISTRO" in
    debian|ubuntu|linuxmint|pop) DISTRO_FAMILY="debian" ;;
    rhel|centos|fedora|rocky|alma) DISTRO_FAMILY="rhel" ;;
    arch|manjaro|endeavouros) DISTRO_FAMILY="arch" ;;
    *) DISTRO_FAMILY="unknown" ;;
esac
export DISTRO DISTRO_FAMILY
pkg_install() {
    case "$DISTRO_FAMILY" in
        debian) sudo apt-get install -y "$@" ;;
        rhel) sudo dnf install -y "$@" 2>/dev/null || sudo yum install -y "$@" ;;
        arch) sudo pacman -S --noconfirm "$@" ;;
        *) echo "Unknown distro"; return 1 ;;
    esac
}
pkg_update() {
    case "$DISTRO_FAMILY" in
        debian) sudo apt-get update ;;
        rhel) sudo dnf check-update 2>/dev/null || sudo yum check-update ;;
        arch) sudo pacman -Sy ;;
        *) echo "Unknown distro"; return 1 ;;
    esac
}
pkg_upgrade() {
    case "$DISTRO_FAMILY" in
        debian) sudo apt-get update && sudo apt-get upgrade -y ;;
        rhel) sudo dnf upgrade -y 2>/dev/null || sudo yum upgrade -y ;;
        arch) sudo pacman -Syu --noconfirm ;;
        *) echo "Unknown distro"; return 1 ;;
    esac
}
pkg_search() {
    case "$DISTRO_FAMILY" in
        debian) apt-cache search "$@" ;;
        rhel) dnf search "$@" 2>/dev/null || yum search "$@" ;;
        arch) pacman -Ss "$@" ;;
        *) echo "Unknown distro"; return 1 ;;
    esac
}
pkg_remove() {
    case "$DISTRO_FAMILY" in
        debian) sudo apt-get remove -y "$@" ;;
        rhel) sudo dnf remove -y "$@" 2>/dev/null || sudo yum remove -y "$@" ;;
        arch) sudo pacman -R --noconfirm "$@" ;;
        *) echo "Unknown distro"; return 1 ;;
    esac
}
