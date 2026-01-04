# WiscoBash

Modular bash configuration for Debian, RHEL, and Arch-based Linux distributions.

## Quick Install

```bash
cd ~
git clone https://github.com/leewiscovitch/wiscobash.git
cd wiscobash
./install.sh
source ~/.bashrc
```

## Features

- Cross-distribution package management
- Modular aliases, functions, and app configs
- Smart logging with debug/verbose modes
- State tracking for installed packages

## Usage

```bash
# Package management
wb_install git
wb_install_multi curl vim htop
wb_check docker

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
├── config/bashrc_additions
├── lib/{distro_detect,logging,package_manager}.sh
├── scripts/
│   ├── alias/{common,git}.sh
│   ├── functions/{system,navigation}.sh
│   ├── applications/docker.sh
│   └── setup/essential_packages.sh
```

See full docs at https://github.com/yourusername/wiscobash
