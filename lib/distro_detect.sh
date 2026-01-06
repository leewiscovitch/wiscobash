#!/usr/bin/env bash
# Distribution detection module for WiscoBash
# Detects the Linux distribution and family for cross-distro compatibility
# Exports: DISTRO, DISTRO_FAMILY

# detect_distro - Detect the current Linux distribution
# Checks /etc/os-release and falls back to distro-specific files
# Returns: Distribution ID (debian, ubuntu, arch, fedora, etc.)
detect_distro() {
    if [ -f /etc/os-release ]; then . /etc/os-release; echo "$ID"
    elif [ -f /etc/debian_version ]; then echo "debian"
    elif [ -f /etc/redhat-release ]; then echo "rhel"
    elif [ -f /etc/arch-release ]; then echo "arch"
    else echo "unknown"; fi
}

# Detect distribution and family
DISTRO=$(detect_distro)
case "$DISTRO" in
    debian|ubuntu|linuxmint|pop) DISTRO_FAMILY="debian" ;;
    rhel|centos|fedora|rocky|alma) DISTRO_FAMILY="rhel" ;;
    arch|manjaro|endeavouros) DISTRO_FAMILY="arch" ;;
    *) DISTRO_FAMILY="unknown" ;;
esac
export DISTRO DISTRO_FAMILY
