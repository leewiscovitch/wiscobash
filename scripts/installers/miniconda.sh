#!/usr/bin/env bash
# Miniconda Installer
# Installs Miniconda to ~/wiscobash/opt/miniconda with custom configuration

# wb_install_miniconda - Install miniconda
wb_install_miniconda() {
    wb_log_section_start "Install miniconda"

    local install_dir="$HOME/wiscobash/opt/miniconda"
    local envs_dir="$HOME/wiscobash/envs"
    local etc_dir="$HOME/.wiscobash/etc"
    local condarc="$etc_dir/condarc"

    # Check if already installed
    if [ -d "$install_dir" ] && [ -x "$install_dir/bin/conda" ]; then
        echo "✓ miniconda already installed: $($install_dir/bin/conda --version)"
        wb_mark_installed "miniconda"
        wb_log_package_install "miniconda" "skipped"
        wb_log_section_end "Install miniconda" "skipped"
        return 0
    fi

    echo "Installing miniconda..."

    # Detect architecture
    local arch
    case "$(uname -m)" in
        x86_64) arch="x86_64" ;;
        aarch64|arm64) arch="aarch64" ;;
        *)
            echo "✗ Unsupported architecture: $(uname -m)"
            wb_log_error "Miniconda installation not supported for: $(uname -m)"
            wb_log_section_end "Install miniconda" "failed"
            return 1
            ;;
    esac

    # Create directories
    mkdir -p "$install_dir"
    mkdir -p "$envs_dir"
    mkdir -p "$etc_dir"

    # Download installer
    local installer_url="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-${arch}.sh"
    echo "Downloading Miniconda installer for ${arch}..."
    if ! wget -q "$installer_url" -O "$install_dir/installer.sh"; then
        echo "✗ Failed to download Miniconda installer"
        wb_log_package_install "miniconda" "failed"
        wb_log_section_end "Install miniconda" "failed"
        return 1
    fi

    # Install Miniconda
    echo "Installing Miniconda (this may take a few minutes)..."
    if ! bash "$install_dir/installer.sh" -b -u -m -p "$install_dir"; then
        echo "✗ Failed to install Miniconda"
        rm -f "$install_dir/installer.sh"
        wb_log_package_install "miniconda" "failed"
        wb_log_section_end "Install miniconda" "failed"
        return 1
    fi

    # Clean up installer
    rm -f "$install_dir/installer.sh"
    echo "✓ Installed Miniconda to $install_dir"

    # Create condarc configuration
    echo "Creating conda configuration..."
    cat > "$condarc" << 'EOF'
channel_priority: strict
channels:
  - conda-forge
  - defaults
default_channels:
  - https://repo.anaconda.com/pkgs/main
envs_dirs:
  - ~/wiscobash/envs
auto_activate_base: false
EOF
    echo "✓ Created $condarc"

    # Create application script for initialization
    local app_script="$HOME/wiscobash/scripts/applications/miniconda.sh"
    echo "Creating conda initialization script..."
    cat > "$app_script" << 'EOF'
#!/usr/bin/env bash
# miniconda - Python environment manager
# Initializes conda if installed

# Check if miniconda is installed
if [ ! -d "$HOME/wiscobash/opt/miniconda" ]; then
    return 0
fi

# Initialize conda
__conda_setup="$('$HOME/wiscobash/opt/miniconda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/wiscobash/opt/miniconda/etc/profile.d/conda.sh" ]; then
        . "$HOME/wiscobash/opt/miniconda/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/wiscobash/opt/miniconda/bin:$PATH"
    fi
fi
unset __conda_setup

# Set custom condarc location
export CONDARC=~/.wiscobash/etc/condarc

# Deactivate base environment (workaround for auto_activate_base)
conda deactivate 2>/dev/null

# Conda aliases
alias ca='conda activate'
alias cda='conda deactivate'
alias cenv='conda env list'
alias cup='conda update --all'
alias cpkg='conda list'
EOF
    chmod +x "$app_script"
    echo "✓ Created $app_script"

    wb_mark_installed "miniconda"
    echo ""
    echo "✓ Miniconda installed and configured!"
    echo "  Install location: $install_dir"
    echo "  Environments: $envs_dir"
    echo "  Config: $condarc"
    echo ""
    echo "Aliases available after restart:"
    echo "  ca <env>  - Activate environment"
    echo "  cda       - Deactivate environment"
    echo "  cenv      - List environments"
    echo "  cup       - Update all packages"
    echo "  cpkg      - List installed packages"
    echo ""
    echo "Note: Run 'wb_refresh' to activate conda in current shell"
    wb_log_package_install "miniconda" "success"
    wb_log_section_end "Install miniconda" "success"
    return 0
}
