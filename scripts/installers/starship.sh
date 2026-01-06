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
        # Install to ~/wiscobash/bin (no sudo required)
        local install_dir="$HOME/wiscobash/bin"
        mkdir -p "$install_dir"

        # Install using official installer with custom bin directory
        if curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir "$install_dir"; then
            echo "✓ Installed starship to $install_dir"
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

    # Copy WiscoBash custom theme
    if command -v starship >/dev/null 2>&1; then
        cp -f "$WISCOBASH_DIR/config/starship.toml" "$config_dir/starship.toml"
        echo "✓ Installed WiscoBash custom theme"
        echo "  - Gruvbox colors"
        echo "  - Conda environment on right"
        echo "  - Full path display"
        echo "  - 12-hour time format"
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
