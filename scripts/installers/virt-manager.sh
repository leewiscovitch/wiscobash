#!/usr/bin/env bash
# Virt-Manager Installer
# Installs virt-manager and required virtualization packages

# wb_install_virt_manager - Install virt-manager and dependencies
wb_install_virt_manager() {
    wb_log_section_start "Install virt-manager"

    # Check if already installed
    if command -v virt-manager >/dev/null 2>&1; then
        echo "✓ virt-manager already installed"
    else
        echo "Installing virt-manager and virtualization packages..."

        case "$DISTRO_FAMILY" in
            debian)
                # Install virt-manager and all dependencies
                if sudo apt-get install -y \
                    virt-manager \
                    qemu-kvm \
                    libvirt-daemon-system \
                    libvirt-clients \
                    bridge-utils \
                    virtinst; then
                    echo "✓ Installed virt-manager and dependencies"
                else
                    echo "✗ Failed to install virt-manager"
                    wb_log_package_install "virt-manager" "failed"
                    wb_log_section_end "Install virt-manager" "failed"
                    return 1
                fi
                ;;

            rhel)
                # Install virt-manager and all dependencies
                if sudo dnf install -y \
                    virt-manager \
                    libvirt \
                    qemu-kvm \
                    virt-install \
                    virt-viewer 2>/dev/null || \
                   sudo yum install -y \
                    virt-manager \
                    libvirt \
                    qemu-kvm \
                    virt-install \
                    virt-viewer; then
                    echo "✓ Installed virt-manager and dependencies"
                else
                    echo "✗ Failed to install virt-manager"
                    wb_log_package_install "virt-manager" "failed"
                    wb_log_section_end "Install virt-manager" "failed"
                    return 1
                fi
                ;;

            arch)
                # Install virt-manager and all dependencies
                if sudo pacman -S --noconfirm \
                    virt-manager \
                    qemu \
                    libvirt \
                    ebtables \
                    dnsmasq \
                    bridge-utils \
                    virt-viewer; then
                    echo "✓ Installed virt-manager and dependencies"
                else
                    echo "✗ Failed to install virt-manager"
                    wb_log_package_install "virt-manager" "failed"
                    wb_log_section_end "Install virt-manager" "failed"
                    return 1
                fi
                ;;

            *)
                echo "✗ Unsupported distribution family: $DISTRO_FAMILY"
                wb_log_package_install "virt-manager" "failed"
                wb_log_section_end "Install virt-manager" "failed"
                return 1
                ;;
        esac
    fi

    # Enable and start libvirtd service
    echo ""
    echo "Configuring libvirt service..."
    if sudo systemctl enable libvirtd 2>/dev/null && sudo systemctl start libvirtd 2>/dev/null; then
        echo "✓ libvirtd service enabled and started"
    else
        echo "⚠ Warning: Could not enable/start libvirtd service"
    fi

    # Add user to libvirt group
    echo ""
    echo "Adding user to libvirt group..."
    local libvirt_group="libvirt"

    # Check which group exists (libvirt or libvirtd)
    if getent group libvirtd >/dev/null 2>&1; then
        libvirt_group="libvirtd"
    fi

    if sudo usermod -aG "$libvirt_group" "$USER"; then
        echo "✓ Added $USER to $libvirt_group group"
        echo "  Note: Log out and back in for group changes to take effect"
    else
        echo "⚠ Warning: Could not add user to $libvirt_group group"
    fi

    wb_mark_installed "virt-manager"
    echo ""
    echo "✓ virt-manager installed and configured!"
    echo "  Launch with: virt-manager"
    echo "  User added to: $libvirt_group group"
    echo "  Service: libvirtd enabled and running"
    echo ""
    echo "IMPORTANT: Log out and back in for group membership to take effect"
    wb_log_package_install "virt-manager" "success"
    wb_log_section_end "Install virt-manager" "success"
    return 0
}
