# WiscoBash

Modular bash configuration for Debian, RHEL, and Arch-based Linux distributions.

## Quick Install

```bash
cd ~
git clone https://github.com/leewiscovitch/wiscobash.git
cd wiscobash
./install.sh              # Interactive - prompts for package installation
source ~/.bashrc
```

### Installation Options

```bash
# Interactive (prompts for packages)
./install.sh

# Non-interactive modes
./install.sh --with-essentials   # Install with essential packages
./install.sh --with-dev          # Install with dev tools
./install.sh --with-all          # Install with all packages
./install.sh --no-packages       # Skip package installation

# Force reinstall (useful for updates/repairs)
./install.sh --force             # Reinstall even if already installed
./install.sh --force --with-all  # Force reinstall with all packages

# Install packages later
~/wiscobash/scripts/setup/essential_packages.sh
```

## Features

- Cross-distribution package management
- HashiCorp tools installer (terraform, packer, vault, consul, nomad)
- Modular aliases, functions, and app configs
- Smart logging with debug/verbose modes
- State tracking for installed packages
- Custom binary installation to ~/wiscobash/bin

## Usage

```bash
# Package management (standard repos)
wb_install git
wb_install_multi curl vim htop
wb_check docker

# HashiCorp tools (terraform, packer, vault, etc.)
wb_install_terraform          # Install latest terraform
wb_install_packer             # Install latest packer
wb_install_terraform 1.6.0    # Install specific version

# View logs
wb_logs
wb_logs_errors
wb_debug_enable

# Aliases
ll, gs, ga, gc, gp
update, upgrade, install

# Functions
mkcd, extract, backup, sysinfo
up, goto, tree
```

## Structure

```
wiscobash/
├── install.sh, uninstall.sh
├── bin/                                         # Custom binaries (in PATH)
├── config/bashrc_additions
├── lib/{distro_detect,logging,package_manager}.sh
├── scripts/
│   ├── alias/{common,git}.sh
│   ├── functions/{system,navigation}.sh
│   ├── applications/docker.sh
│   ├── installers/hashicorp.sh                  # HashiCorp tools installer
│   └── setup/essential_packages.sh
```

See full docs at https://github.com/leewiscovitch/wiscobash
