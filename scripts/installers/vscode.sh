#!/usr/bin/env bash
# VS Code Installer
# Installs Visual Studio Code from official Microsoft repositories

# wb_install_vscode - Install Visual Studio Code
wb_install_vscode() {
    wb_log_section_start "Install vscode"

    # Check if already installed
    if command -v code >/dev/null 2>&1; then
        echo "✓ vscode already installed: $(code --version | head -n1)"
        wb_log_section_end "Install vscode" "success"
        return 0
    fi

    echo "Installing Visual Studio Code..."

    case "$DISTRO_FAMILY" in
        debian)
            # Add Microsoft GPG key and repository
            echo "Adding Microsoft repository..."

            # Install prerequisites
            sudo apt-get install -y wget gpg apt-transport-https

            # Add Microsoft GPG key
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
            sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
            rm -f /tmp/packages.microsoft.gpg

            # Add repository
            echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
                sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

            # Update and install
            sudo apt-get update
            if sudo apt-get install -y code; then
                wb_mark_installed "vscode"
                echo "✓ Installed Visual Studio Code"
            else
                echo "✗ Failed to install Visual Studio Code"
                wb_log_package_install "vscode" "failed"
                wb_log_section_end "Install vscode" "failed"
                return 1
            fi
            ;;

        rhel)
            # Add Microsoft repository
            echo "Adding Microsoft repository..."

            # Import Microsoft GPG key
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

            # Add repository
            sudo tee /etc/yum.repos.d/vscode.repo > /dev/null <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

            # Install
            if sudo dnf install -y code 2>/dev/null || sudo yum install -y code; then
                wb_mark_installed "vscode"
                echo "✓ Installed Visual Studio Code"
            else
                echo "✗ Failed to install Visual Studio Code"
                wb_log_package_install "vscode" "failed"
                wb_log_section_end "Install vscode" "failed"
                return 1
            fi
            ;;

        arch)
            # Install from AUR
            echo "Installing from AUR..."

            # Try yay first, then paru
            if command -v yay >/dev/null 2>&1; then
                if yay -S --noconfirm visual-studio-code-bin; then
                    wb_mark_installed "vscode"
                    echo "✓ Installed Visual Studio Code"
                else
                    echo "✗ Failed to install Visual Studio Code via yay"
                    wb_log_package_install "vscode" "failed"
                    wb_log_section_end "Install vscode" "failed"
                    return 1
                fi
            elif command -v paru >/dev/null 2>&1; then
                if paru -S --noconfirm visual-studio-code-bin; then
                    wb_mark_installed "vscode"
                    echo "✓ Installed Visual Studio Code"
                else
                    echo "✗ Failed to install Visual Studio Code via paru"
                    wb_log_package_install "vscode" "failed"
                    wb_log_section_end "Install vscode" "failed"
                    return 1
                fi
            else
                echo "✗ AUR helper (yay or paru) not found"
                echo "  Please install yay or paru first, then try again"
                wb_log_package_install "vscode" "failed"
                wb_log_section_end "Install vscode" "failed"
                return 1
            fi
            ;;

        *)
            echo "✗ Unsupported distribution family: $DISTRO_FAMILY"
            wb_log_package_install "vscode" "failed"
            wb_log_section_end "Install vscode" "failed"
            return 1
            ;;
    esac

    # Set as default text editor
    if command -v xdg-mime >/dev/null 2>&1; then
        echo "Setting VS Code as default text editor..."
        xdg-mime default code.desktop text/plain
        echo "✓ Set as default text editor"
    fi

    wb_mark_installed "vscode"
    echo ""
    echo "✓ Visual Studio Code installed!"
    echo "  Launch with: code"
    echo "  Set as default text editor for text/plain files"
    wb_log_package_install "vscode" "success"
    wb_log_section_end "Install vscode" "success"
    return 0
}
