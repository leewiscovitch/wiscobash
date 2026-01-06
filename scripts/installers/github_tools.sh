#!/usr/bin/env bash
# GitHub Tools Binary Installer
# Installs tools from GitHub releases when not available in repos

# wb_install_bat_binary - Install bat from GitHub releases
# Fallback for systems where bat isn't in repos or is outdated
wb_install_bat_binary() {
    local install_dir="$HOME/wiscobash/bin"
    mkdir -p "$install_dir"

    # Detect architecture
    local arch
    case "$(uname -m)" in
        x86_64) arch="x86_64" ;;
        aarch64|arm64) arch="aarch64" ;;
        armv7l) arch="arm" ;;
        *) echo "Unsupported architecture: $(uname -m)"; return 1 ;;
    esac

    echo "Fetching latest bat version from GitHub..."
    local version
    version=$(curl -sL "https://api.github.com/repos/sharkdp/bat/releases/latest" | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    [ -z "$version" ] && echo "Failed to fetch latest version" && return 1
    echo "Latest version: $version"

    local download_url="https://github.com/sharkdp/bat/releases/download/v${version}/bat-v${version}-${arch}-unknown-linux-musl.tar.gz"
    local temp_dir=$(mktemp -d)

    echo "Downloading bat $version..."
    if ! curl -sL "$download_url" -o "$temp_dir/bat.tar.gz"; then
        echo "Failed to download bat"
        rm -rf "$temp_dir"
        return 1
    fi

    echo "Extracting bat..."
    tar -xzf "$temp_dir/bat.tar.gz" -C "$temp_dir"

    # Find the bat binary (it's in a subdirectory)
    local bat_bin=$(find "$temp_dir" -name "bat" -type f)
    if [ -z "$bat_bin" ]; then
        echo "Failed to find bat binary"
        rm -rf "$temp_dir"
        return 1
    fi

    # Install binary
    chmod +x "$bat_bin"
    cp "$bat_bin" "$install_dir/bat"

    # Cleanup
    rm -rf "$temp_dir"

    # Verify installation
    if [ -x "$install_dir/bat" ]; then
        echo "✓ Installed bat $version to $install_dir"
        return 0
    else
        echo "✗ Failed to install bat"
        return 1
    fi
}

# wb_install_bat_from_github - Public function to install bat from GitHub
# Use this if package manager version is too old or unavailable
wb_install_bat_from_github() {
    echo "Installing bat from GitHub releases..."
    wb_install_bat_binary
}
