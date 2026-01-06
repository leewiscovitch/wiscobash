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

# wb_install_micro_binary - Install micro editor from GitHub releases
wb_install_micro_binary() {
    local install_dir="$HOME/wiscobash/bin"
    mkdir -p "$install_dir"

    # Detect architecture
    local arch
    case "$(uname -m)" in
        x86_64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
        armv7l) arch="arm" ;;
        *) echo "Unsupported architecture: $(uname -m)"; return 1 ;;
    esac

    echo "Fetching latest micro version from GitHub..."
    local version
    version=$(curl -sL "https://api.github.com/repos/zyedidia/micro/releases/latest" | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    [ -z "$version" ] && echo "Failed to fetch latest version" && return 1
    echo "Latest version: $version"

    local download_url="https://github.com/zyedidia/micro/releases/download/v${version}/micro-${version}-linux${arch}.tar.gz"
    local temp_dir=$(mktemp -d)

    echo "Downloading micro $version..."
    if ! curl -sL "$download_url" -o "$temp_dir/micro.tar.gz"; then
        echo "Failed to download micro"
        rm -rf "$temp_dir"
        return 1
    fi

    echo "Extracting micro..."
    tar -xzf "$temp_dir/micro.tar.gz" -C "$temp_dir"

    # Find the micro binary (it's in a subdirectory)
    local micro_bin=$(find "$temp_dir" -name "micro" -type f)
    if [ -z "$micro_bin" ]; then
        echo "Failed to find micro binary"
        rm -rf "$temp_dir"
        return 1
    fi

    # Install binary
    chmod +x "$micro_bin"
    cp "$micro_bin" "$install_dir/micro"

    # Cleanup
    rm -rf "$temp_dir"

    # Verify installation
    if [ -x "$install_dir/micro" ]; then
        echo "✓ Installed micro $version to $install_dir"
        return 0
    else
        echo "✗ Failed to install micro"
        return 1
    fi
}

# wb_install_micro_from_github - Public function to install micro from GitHub
wb_install_micro_from_github() {
    echo "Installing micro from GitHub releases..."
    wb_install_micro_binary
}

# wb_install_eza_binary - Install eza from GitHub releases
wb_install_eza_binary() {
    local install_dir="$HOME/wiscobash/bin"
    mkdir -p "$install_dir"

    # Detect architecture
    local arch
    case "$(uname -m)" in
        x86_64) arch="x86_64" ;;
        aarch64|arm64) arch="aarch64" ;;
        armv7l) arch="armv7" ;;
        *) echo "Unsupported architecture: $(uname -m)"; return 1 ;;
    esac

    echo "Fetching latest eza version from GitHub..."
    local version
    version=$(curl -sL "https://api.github.com/repos/eza-community/eza/releases/latest" | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    [ -z "$version" ] && echo "Failed to fetch latest version" && return 1
    echo "Latest version: $version"

    local download_url="https://github.com/eza-community/eza/releases/download/v${version}/eza_${arch}-unknown-linux-musl.tar.gz"
    local temp_dir=$(mktemp -d)

    echo "Downloading eza $version..."
    if ! curl -sL "$download_url" -o "$temp_dir/eza.tar.gz"; then
        echo "Failed to download eza"
        rm -rf "$temp_dir"
        return 1
    fi

    echo "Extracting eza..."
    tar -xzf "$temp_dir/eza.tar.gz" -C "$temp_dir"

    # The eza binary should be directly in the temp directory
    if [ ! -f "$temp_dir/eza" ]; then
        echo "Failed to find eza binary"
        rm -rf "$temp_dir"
        return 1
    fi

    # Install binary
    chmod +x "$temp_dir/eza"
    cp "$temp_dir/eza" "$install_dir/eza"

    # Cleanup
    rm -rf "$temp_dir"

    # Verify installation
    if [ -x "$install_dir/eza" ]; then
        echo "✓ Installed eza $version to $install_dir"
        return 0
    else
        echo "✗ Failed to install eza"
        return 1
    fi
}

# wb_install_eza_from_github - Public function to install eza from GitHub
wb_install_eza_from_github() {
    echo "Installing eza from GitHub releases..."
    wb_install_eza_binary
}
