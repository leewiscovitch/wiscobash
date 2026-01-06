#!/usr/bin/env bash
# HashiCorp Tools Installer
# Installs HashiCorp tools (terraform, packer, vault, etc.) via official repos
# Falls back to binary installation if repos unavailable

HASHICORP_REPO_ADDED=false

# wb_add_hashicorp_repo - Add official HashiCorp repository
# Returns: 0 on success, 1 if not supported for this distro
wb_add_hashicorp_repo() {
    # Check if already added
    $HASHICORP_REPO_ADDED && return 0

    echo "Adding HashiCorp repository for $DISTRO_FAMILY..."
    wb_log_info "Adding HashiCorp repository"

    case "$DISTRO_FAMILY" in
        debian)
            # Add HashiCorp GPG key and repository for Debian/Ubuntu
            if ! command -v gpg >/dev/null 2>&1; then
                echo "Installing gnupg..."
                sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
            fi

            wget -O- https://apt.releases.hashicorp.com/gpg | \
                gpg --dearmor | \
                sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null

            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
                sudo tee /etc/apt/sources.list.d/hashicorp.list

            sudo apt-get update
            HASHICORP_REPO_ADDED=true
            wb_log_success "HashiCorp repository added"
            return 0
            ;;

        rhel)
            # Add HashiCorp repository for RHEL/Fedora/CentOS
            sudo dnf install -y dnf-plugins-core 2>/dev/null || sudo yum install -y yum-utils

            # Use appropriate repo URL based on distro
            if [ "$DISTRO" = "fedora" ]; then
                sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo 2>/dev/null
            else
                sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo 2>/dev/null || \
                    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo 2>/dev/null
            fi

            # Test if the repo actually works by checking metadata
            if ! sudo dnf makecache --repo=hashicorp 2>/dev/null; then
                wb_log_warning "HashiCorp repo added but metadata unavailable (unsupported version)"
                return 1
            fi

            HASHICORP_REPO_ADDED=true
            wb_log_success "HashiCorp repository added and verified"
            return 0
            ;;

        arch)
            # Arch has community packages, no need for extra repo
            echo "Using Arch community packages for HashiCorp tools"
            HASHICORP_REPO_ADDED=true
            return 0
            ;;

        *)
            wb_log_warning "HashiCorp repo not supported for $DISTRO_FAMILY"
            return 1
            ;;
    esac
}

# wb_install_hashicorp_tool - Install a HashiCorp tool via repo or binary
# Args: $1 = tool name (terraform, packer, vault, etc.)
#       $2 = optional version (latest if not specified)
wb_install_hashicorp_tool() {
    local tool="$1"
    local version="${2:-latest}"

    [ -z "$tool" ] && echo "Usage: wb_install_hashicorp_tool <tool> [version]" && return 1

    wb_log_section_start "Install HashiCorp: $tool"

    # Try to add repo first
    if wb_add_hashicorp_repo; then
        echo "Installing $tool via package manager..."

        case "$DISTRO_FAMILY" in
            debian)
                if [ "$version" = "latest" ]; then
                    sudo apt-get install -y "$tool" && wb_log_success "Installed $tool via apt"
                else
                    sudo apt-get install -y "${tool}=${version}" && wb_log_success "Installed $tool $version via apt"
                fi
                ;;
            rhel)
                if [ "$version" = "latest" ]; then
                    sudo dnf install -y "$tool" 2>/dev/null || sudo yum install -y "$tool"
                    wb_log_success "Installed $tool via dnf/yum"
                else
                    sudo dnf install -y "${tool}-${version}" 2>/dev/null || sudo yum install -y "${tool}-${version}"
                    wb_log_success "Installed $tool $version via dnf/yum"
                fi
                ;;
            arch)
                if [ "$version" = "latest" ]; then
                    sudo pacman -S --noconfirm "$tool" && wb_log_success "Installed $tool via pacman"
                else
                    echo "Version pinning not supported on Arch via pacman"
                    sudo pacman -S --noconfirm "$tool" && wb_log_success "Installed $tool via pacman"
                fi
                ;;
        esac

        if [ $? -eq 0 ]; then
            wb_log_section_end "Install HashiCorp: $tool" "success"
            return 0
        fi
    fi

    # Fallback to binary installation
    echo "Repository installation failed or unavailable, trying binary installation..."
    wb_install_hashicorp_binary "$tool" "$version"
}

# wb_install_hashicorp_binary - Download and install HashiCorp tool binary
# Args: $1 = tool name, $2 = version (latest if not specified)
wb_install_hashicorp_binary() {
    local tool="$1"
    local version="${2:-latest}"
    local install_dir="$HOME/wiscobash/bin"

    mkdir -p "$install_dir"

    # Detect architecture
    local arch
    case "$(uname -m)" in
        x86_64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
        armv7l) arch="arm" ;;
        *) echo "Unsupported architecture: $(uname -m)" && return 1 ;;
    esac

    local os="linux"

    # Get latest version if not specified
    if [ "$version" = "latest" ]; then
        echo "Fetching latest $tool version..."
        version=$(curl -sL "https://api.releases.hashicorp.com/v1/releases/${tool}/latest" | grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4)
        [ -z "$version" ] && echo "Failed to fetch latest version" && return 1
        echo "Latest version: $version"
    fi

    local download_url="https://releases.hashicorp.com/${tool}/${version}/${tool}_${version}_${os}_${arch}.zip"
    local temp_dir=$(mktemp -d)

    echo "Downloading $tool $version..."
    wb_log_info "Downloading $tool $version from $download_url"

    if ! curl -sL "$download_url" -o "$temp_dir/${tool}.zip"; then
        echo "Failed to download $tool"
        rm -rf "$temp_dir"
        return 1
    fi

    echo "Extracting $tool..."
    if ! command -v unzip >/dev/null 2>&1; then
        echo "unzip not found, installing..."
        wb_install unzip
    fi

    unzip -q "$temp_dir/${tool}.zip" -d "$temp_dir"

    # Install binary
    chmod +x "$temp_dir/$tool"
    mv "$temp_dir/$tool" "$install_dir/"

    # Cleanup
    rm -rf "$temp_dir"

    # Verify installation
    if [ -x "$install_dir/$tool" ]; then
        echo "✓ Installed $tool $version to $install_dir"
        wb_log_success "Installed $tool $version (binary)"
        return 0
    else
        echo "✗ Failed to install $tool"
        wb_log_error "Failed to install $tool"
        return 1
    fi
}

# Convenience functions for common HashiCorp tools
wb_install_terraform() { wb_install_hashicorp_tool terraform "$@"; }
wb_install_packer() { wb_install_hashicorp_tool packer "$@"; }
wb_install_vault() { wb_install_hashicorp_tool vault "$@"; }
wb_install_consul() { wb_install_hashicorp_tool consul "$@"; }
wb_install_nomad() { wb_install_hashicorp_tool nomad "$@"; }
