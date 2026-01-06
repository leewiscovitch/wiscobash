#!/usr/bin/env bash
# Cockpit Web Console Installer
# Installs Cockpit web-based system management interface

# wb_install_cockpit - Install cockpit and modules
wb_install_cockpit() {
    wb_log_section_start "Install cockpit"

    echo "Installing Cockpit web console..."

    case "$DISTRO_FAMILY" in
        debian)
            # Install cockpit and useful modules
            if sudo apt-get install -y \
                cockpit \
                cockpit-machines \
                cockpit-podman \
                cockpit-storaged \
                cockpit-networkmanager; then
                echo "✓ Installed Cockpit and modules"
            else
                echo "✗ Failed to install Cockpit"
                wb_log_package_install "cockpit" "failed"
                wb_log_section_end "Install cockpit" "failed"
                return 1
            fi
            ;;

        rhel)
            # Install cockpit and useful modules
            if sudo dnf install -y \
                cockpit \
                cockpit-machines \
                cockpit-podman \
                cockpit-storaged \
                cockpit-networkmanager 2>/dev/null || \
               sudo yum install -y \
                cockpit \
                cockpit-machines \
                cockpit-podman \
                cockpit-storaged \
                cockpit-networkmanager; then
                echo "✓ Installed Cockpit and modules"
            else
                echo "✗ Failed to install Cockpit"
                wb_log_package_install "cockpit" "failed"
                wb_log_section_end "Install cockpit" "failed"
                return 1
            fi
            ;;

        arch)
            # Install cockpit and useful modules
            if sudo pacman -S --noconfirm \
                cockpit \
                cockpit-machines \
                cockpit-podman; then
                echo "✓ Installed Cockpit and modules"
            else
                echo "✗ Failed to install Cockpit"
                wb_log_package_install "cockpit" "failed"
                wb_log_section_end "Install cockpit" "failed"
                return 1
            fi
            ;;

        *)
            echo "✗ Unsupported distribution family: $DISTRO_FAMILY"
            wb_log_package_install "cockpit" "failed"
            wb_log_section_end "Install cockpit" "failed"
            return 1
            ;;
    esac

    # Enable and start cockpit socket
    echo ""
    echo "Enabling Cockpit service..."
    if sudo systemctl enable --now cockpit.socket; then
        echo "✓ Cockpit service enabled and started"
    else
        echo "⚠ Warning: Could not enable Cockpit service"
    fi

    # Get system IP for access instructions
    local ip_addr=$(hostname -I | awk '{print $1}')

    wb_mark_installed "cockpit"
    echo ""
    echo "✓ Cockpit installed and configured!"
    echo "  Modules installed:"
    echo "    - cockpit-machines (libvirt/KVM management)"
    echo "    - cockpit-podman (container management)"
    echo "    - cockpit-storaged (storage management)"
    echo "    - cockpit-networkmanager (network management)"
    echo ""
    echo "Access Cockpit at:"
    echo "  https://localhost:9090"
    if [ -n "$ip_addr" ]; then
        echo "  https://$ip_addr:9090"
    fi
    echo ""
    echo "Login with your system username and password"
    wb_log_package_install "cockpit" "success"
    wb_log_section_end "Install cockpit" "success"
    return 0
}
