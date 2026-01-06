#!/usr/bin/env bash
# Starship Prompt Installer
# Installs starship cross-shell prompt with FiraCode Nerd Font

# wb_install_nerd_font - Download and install a Nerd Font
# Args: $1 = font name (e.g., "FiraCode", "Hack", "JetBrainsMono")
wb_install_nerd_font() {
    local font_name="${1:-FiraCode}"
    local font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"

    echo "Checking for ${font_name} Nerd Font..."

    # Check if already installed
    if fc-list | grep -qi "${font_name} Nerd Font"; then
        echo "✓ ${font_name} Nerd Font already installed"
        return 0
    fi

    echo "Installing ${font_name} Nerd Font..."

    # Get latest release version
    local version
    version=$(curl -sL "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" | grep '"tag_name"' | sed -E 's/.*"v?([^"]+)".*/\1/')
    [ -z "$version" ] && echo "⚠ Warning: Could not fetch latest version, using v3.1.1" && version="3.1.1"

    local download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${font_name}.zip"
    local temp_dir=$(mktemp -d)

    echo "Downloading ${font_name} Nerd Font v${version}..."
    if ! curl -sL "$download_url" -o "$temp_dir/${font_name}.zip"; then
        echo "✗ Failed to download ${font_name} Nerd Font"
        rm -rf "$temp_dir"
        return 1
    fi

    echo "Extracting fonts..."
    unzip -q "$temp_dir/${font_name}.zip" -d "$temp_dir/${font_name}" 2>/dev/null || {
        echo "✗ Failed to extract font archive"
        rm -rf "$temp_dir"
        return 1
    }

    # Install only the ttf fonts (ignore Windows/OTF variants)
    find "$temp_dir/${font_name}" -name "*.ttf" -exec cp {} "$font_dir/" \;

    # Update font cache
    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f "$font_dir"
    fi

    rm -rf "$temp_dir"
    echo "✓ Installed ${font_name} Nerd Font"
    return 0
}

# wb_install_firacode_nerd_font - Legacy wrapper for FiraCode
wb_install_firacode_nerd_font() {
    wb_install_nerd_font "FiraCode"
}

# wb_install_starship - Install starship prompt
wb_install_starship() {
    wb_log_section_start "Install starship"

    # Install FiraCode Nerd Font first
    wb_install_firacode_nerd_font || {
        echo "⚠ Warning: Font installation failed, continuing with starship..."
    }

    echo ""
    echo "Installing starship..."

    # Check if already installed
    if command -v starship >/dev/null 2>&1; then
        echo "✓ starship already installed: $(starship --version)"
    else
        # Install using official installer
        if curl -sS https://starship.rs/install.sh | sh -s -- -y; then
            echo "✓ Installed starship"
        else
            echo "✗ Failed to install starship"
            wb_log_package_install "starship" "failed"
            wb_log_section_end "Install starship" "failed"
            return 1
        fi
    fi

    # Configure starship
    echo ""
    echo "Configuring starship..."

    local config_dir="$HOME/.config"
    mkdir -p "$config_dir"

    # Install gruvbox-rainbow preset
    if command -v starship >/dev/null 2>&1; then
        starship preset gruvbox-rainbow -o "$config_dir/starship.toml"
        echo "✓ Installed gruvbox-rainbow preset"

        # Apply time format customization (12-hour with AM/PM)
        if grep -q "^\[time\]" "$config_dir/starship.toml"; then
            # Update existing [time] section
            sed -i '/^\[time\]/,/^$/s/use_12hr = false/use_12hr = true/' "$config_dir/starship.toml"
            sed -i '/^\[time\]/,/^$/s/disabled = true/disabled = false/' "$config_dir/starship.toml"
        else
            # Add [time] section if it doesn't exist
            echo "" >> "$config_dir/starship.toml"
            echo "[time]" >> "$config_dir/starship.toml"
            echo "disabled = false" >> "$config_dir/starship.toml"
            echo "use_12hr = true" >> "$config_dir/starship.toml"
        fi
        echo "✓ Configured 12-hour time format"

        # Apply conda customization (show base environment)
        if grep -q "^\[conda\]" "$config_dir/starship.toml"; then
            # Update existing [conda] section
            sed -i '/^\[conda\]/a ignore_base = false' "$config_dir/starship.toml"
        else
            # Add [conda] section
            echo "" >> "$config_dir/starship.toml"
            echo "[conda]" >> "$config_dir/starship.toml"
            echo "ignore_base = false" >> "$config_dir/starship.toml"
        fi
        echo "✓ Configured conda to show base environment"
    fi

    wb_mark_installed "starship"
    echo ""
    echo "✓ starship installed and configured!"
    echo "  Config: ~/.config/starship.toml"
    echo "  Font: FiraCode Nerd Font"
    echo "  Preset: gruvbox-rainbow"
    echo ""
    echo "Note: Restart your terminal to see changes"
    wb_log_package_install "starship" "success"
    wb_log_section_end "Install starship" "success"
    return 0
}
