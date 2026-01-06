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
                    virtinst \
                    libguestfs-tools \
                    cloud-init; then
                    echo "✓ Installed virt-manager and dependencies"
                else
                    echo "✗ Failed to install virt-manager"
                    wb_log_package_install "virt-manager" "failed"
                    wb_log_section_end "Install virt-manager" "failed"
                    return 1
                fi
                ;;

            rhel)
                # Ensure EPEL is installed (virt-manager requires it on RHEL/Rocky)
                echo "Checking for EPEL repository..."
                if ! rpm -q epel-release >/dev/null 2>&1; then
                    echo "Installing EPEL repository..."
                    if sudo dnf install -y epel-release 2>/dev/null || sudo yum install -y epel-release; then
                        echo "✓ EPEL repository installed"
                        # Refresh repo metadata
                        sudo dnf makecache 2>/dev/null || sudo yum makecache
                    else
                        echo "⚠ Warning: Could not install EPEL repository"
                    fi
                else
                    echo "✓ EPEL repository already installed"
                fi

                # Install virt-manager and all dependencies
                if sudo dnf install -y \
                    virt-manager \
                    libvirt \
                    qemu-kvm \
                    virt-install \
                    virt-viewer \
                    libguestfs \
                    cloud-init 2>/dev/null || \
                   sudo yum install -y \
                    virt-manager \
                    libvirt \
                    qemu-kvm \
                    virt-install \
                    virt-viewer \
                    libguestfs \
                    cloud-init; then
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
                    virt-viewer \
                    libguestfs \
                    cloud-init; then
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

    # Add user to libvirt and kvm groups
    echo ""
    echo "Adding user to virtualization groups..."
    local libvirt_group="libvirt"

    # Check which group exists (libvirt or libvirtd)
    if getent group libvirtd >/dev/null 2>&1; then
        libvirt_group="libvirtd"
    fi

    # Add to both libvirt and kvm groups
    local groups_to_add="$libvirt_group"
    if getent group kvm >/dev/null 2>&1; then
        groups_to_add="$libvirt_group,kvm"
    fi

    if sudo usermod -aG "$groups_to_add" "$USER"; then
        echo "✓ Added $USER to $groups_to_add groups"
    else
        echo "⚠ Warning: Could not add user to virtualization groups"
    fi

    # Create storage pool directories
    echo ""
    echo "Creating storage pools..."
    local virt_dir="$HOME/wiscobash/virt"
    mkdir -p "$virt_dir"/{wiscobash-cloud,wiscobash-iso,wiscobash-disks,wiscobash-nvram}

    # Define and start storage pools
    # Note: Using sudo -u $USER to run virsh as the user, not root
    export LIBVIRT_DEFAULT_URI="qemu:///system"

    for pool in wiscobash-cloud wiscobash-iso wiscobash-disks wiscobash-nvram; do
        if ! virsh pool-info "$pool" >/dev/null 2>&1; then
            virsh pool-define-as --name "$pool" --type dir --target "$virt_dir/$pool" && \
            virsh pool-start "$pool" && \
            virsh pool-autostart "$pool" && \
            echo "✓ Created and started storage pool: $pool"
        else
            echo "✓ Storage pool already exists: $pool"
        fi
    done

    # Configure safe shutdown for VMs
    echo ""
    echo "Configuring safe VM shutdown..."
    local libvirt_guests_config=""
    case "$DISTRO_FAMILY" in
        debian)
            libvirt_guests_config="/etc/default/libvirt-guests"
            ;;
        rhel|arch)
            libvirt_guests_config="/etc/sysconfig/libvirt-guests"
            ;;
    esac

    if [ -n "$libvirt_guests_config" ]; then
        sudo mkdir -p "$(dirname "$libvirt_guests_config")"
        sudo tee "$libvirt_guests_config" > /dev/null << 'EOF'
ON_SHUTDOWN="shutdown"
SHUTDOWN_TIMEOUT=60
EOF
        echo "✓ Configured safe VM shutdown"

        # Enable libvirt-guests service
        if sudo systemctl enable --now libvirt-guests 2>/dev/null; then
            echo "✓ libvirt-guests service enabled and started"
        else
            echo "⚠ Warning: Could not enable libvirt-guests service"
        fi
    fi

    # Create application script to set LIBVIRT_DEFAULT_URI
    echo ""
    echo "Creating libvirt environment configuration..."
    local app_script="$HOME/wiscobash/scripts/applications/virt-manager.sh"
    cat > "$app_script" << 'EOF'
#!/usr/bin/env bash
# virt-manager - Virtualization management
# Sets LIBVIRT_DEFAULT_URI for system-level operations (required for Terraform)

# Check if virt-manager is installed
if ! command -v virt-manager >/dev/null 2>&1; then
    return 0
fi

# Set libvirt to operate at system level (required for Terraform and proper VM management)
export LIBVIRT_DEFAULT_URI="qemu:///system"
EOF
    chmod +x "$app_script"
    echo "✓ Created libvirt environment configuration"

    wb_mark_installed "virt-manager"
    echo ""
    echo "✓ virt-manager installed and configured!"
    echo "  Launch with: virt-manager"
    echo "  User added to: $groups_to_add"
    echo "  Services: libvirtd and libvirt-guests enabled and running"
    echo "  Storage pools created in: $virt_dir"
    echo "  LIBVIRT_DEFAULT_URI: qemu:///system (for Terraform compatibility)"
    echo ""
    echo "IMPORTANT: Log out and back in for group membership to take effect"
    echo "           Then run 'wb_refresh' to activate libvirt environment"
    wb_log_package_install "virt-manager" "success"
    wb_log_section_end "Install virt-manager" "success"
    return 0
}
