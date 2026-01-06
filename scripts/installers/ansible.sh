#!/usr/bin/env bash
# Ansible Installer
# Handles installation across different distributions
# RHEL/Arch: Uses native package manager
# Debian/Ubuntu: Uses pip3 (requires python3-pip)

# wb_install_ansible - Install ansible using appropriate method for distro
wb_install_ansible() {
    wb_log_section_start "Install ansible"

    case "$DISTRO_FAMILY" in
        debian)
            # Try apt first (ansible is available in Ubuntu 24.04+ repos)
            echo "Checking for ansible in apt repositories..."
            if apt-cache show ansible >/dev/null 2>&1; then
                echo "Installing ansible via apt..."
                if sudo apt-get install -y ansible; then
                    wb_mark_installed "ansible"
                    echo "✓ Installed ansible via apt"
                    wb_log_package_install "ansible" "success"
                    wb_log_section_end "Install ansible" "success"
                    return 0
                fi
            fi

            # If not in repos, try pipx (recommended for newer Ubuntu/Debian)
            echo "ansible not in apt repos, trying pipx..."

            # Check if pipx is available, install if needed
            if ! command -v pipx >/dev/null 2>&1; then
                echo "Installing pipx..."
                sudo apt-get install -y pipx || {
                    echo "✗ Failed to install pipx"
                    wb_log_error "Failed to install pipx (required for ansible)"
                    wb_log_section_end "Install ansible" "failed"
                    return 1
                }
                # Ensure pipx path is set up
                pipx ensurepath >/dev/null 2>&1
            fi

            # Install ansible via pipx
            echo "Installing ansible via pipx..."
            if pipx install ansible; then
                # Add ~/.local/bin to PATH if not already there
                if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
                    export PATH="$HOME/.local/bin:$PATH"
                    echo "Added ~/.local/bin to PATH"
                fi

                wb_mark_installed "ansible"
                echo "✓ Installed ansible via pipx"
                wb_log_package_install "ansible" "success"
                wb_log_section_end "Install ansible" "success"
                return 0
            else
                echo "✗ Failed to install ansible"
                wb_log_package_install "ansible" "failed"
                wb_log_section_end "Install ansible" "failed"
                return 1
            fi
            ;;

        rhel)
            # RHEL/Fedora/Rocky - package name changed to ansible-core in newer versions
            echo "Installing ansible..."

            # Try ansible-core first (RHEL 9+, Rocky 9+/10+, Fedora)
            if sudo dnf install -y ansible-core 2>/dev/null || sudo yum install -y ansible-core 2>/dev/null; then
                wb_mark_installed "ansible"
                echo "✓ Installed ansible-core"
                wb_log_package_install "ansible" "success"
                wb_log_section_end "Install ansible" "success"
                return 0
            fi

            # Fall back to ansible package (RHEL 8 and older)
            echo "Trying ansible package..."
            if sudo dnf install -y ansible 2>/dev/null || sudo yum install -y ansible; then
                wb_mark_installed "ansible"
                echo "✓ Installed ansible"
                wb_log_package_install "ansible" "success"
                wb_log_section_end "Install ansible" "success"
                return 0
            fi

            echo "✗ Failed to install ansible"
            wb_log_package_install "ansible" "failed"
            wb_log_section_end "Install ansible" "failed"
            return 1
            ;;

        arch)
            # Arch has ansible in community repos
            echo "Installing ansible via pacman..."
            if sudo pacman -S --noconfirm ansible; then
                wb_mark_installed "ansible"
                echo "✓ Installed ansible"
                wb_log_package_install "ansible" "success"
                wb_log_section_end "Install ansible" "success"
                return 0
            else
                echo "✗ Failed to install ansible"
                wb_log_package_install "ansible" "failed"
                wb_log_section_end "Install ansible" "failed"
                return 1
            fi
            ;;

        *)
            echo "✗ Unsupported distribution: $DISTRO"
            wb_log_error "Ansible installation not supported for: $DISTRO"
            wb_log_section_end "Install ansible" "failed"
            return 1
            ;;
    esac
}
