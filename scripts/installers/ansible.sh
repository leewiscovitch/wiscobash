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
            # Debian/Ubuntu require pip installation
            echo "Installing ansible via pip3..."

            # Check if pip3 is available
            if ! command -v pip3 >/dev/null 2>&1; then
                echo "Error: pip3 not found. Installing python3-pip first..."
                wb_install python-pip || {
                    echo "✗ Failed to install python3-pip"
                    wb_log_error "Failed to install python3-pip (required for ansible)"
                    wb_log_section_end "Install ansible" "failed"
                    return 1
                }
            fi

            # Install ansible via pip3
            if pip3 install --user ansible; then
                # Add ~/.local/bin to PATH if not already there
                if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
                    export PATH="$HOME/.local/bin:$PATH"
                    echo "Added ~/.local/bin to PATH"
                fi

                wb_mark_installed "ansible"
                echo "✓ Installed ansible via pip3"
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
            # RHEL/Fedora/Rocky use native repos
            echo "Installing ansible via dnf..."
            if sudo dnf install -y ansible 2>/dev/null || sudo yum install -y ansible; then
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
