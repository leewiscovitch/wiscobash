#!/usr/bin/env bash
set -euo pipefail

#######################################
# Globals / Defaults
#######################################

SCRIPT_NAME="$(basename "$0")"
STATE_DIR="$HOME/.local/state/myscript"
LOG_DIR="$STATE_DIR/logs"
INIT_FILE="$STATE_DIR/initialized"
INSTALLED_PKGS_FILE="$STATE_DIR/installed_packages"

LOG_FILE="$LOG_DIR/myscript.log"
LOG_MAX_SIZE=$((10 * 1024 * 1024))

DRY_RUN=false
DEBUG=false
REINIT=false
UNINSTALL=false

OS_FAMILY=""
SUDO=""

#######################################
# Logging (Ansible-safe)
#######################################

rotate_log_if_needed() {
  [[ -f "$LOG_FILE" ]] || return 0
  local size
  size=$(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
  (( size < LOG_MAX_SIZE )) && return 0
  mv "$LOG_FILE" "$LOG_FILE.1" 2>/dev/null || true
  : > "$LOG_FILE"
}

log() {
  mkdir -p "$LOG_DIR"
  rotate_log_if_needed
  echo "$(date '+%F %T') $*" >> "$LOG_FILE"
}

info() {
  echo "[INFO] $*"
  log "[INFO] $*"
}

debug() {
  $DEBUG || return 0
  echo "[DEBUG] $*"
  log "[DEBUG] $*"
}

die() {
  echo "[ERROR] $*" >&2
  log "[ERROR] $*"
  exit 1
}

run() {
  debug "CMD: $*"
  if $DRY_RUN; then
    info "(dry-run) $*"
  else
    "$@"
  fi
}

#######################################
# Privilege handling
#######################################

detect_privileges() {
  if [[ $EUID -eq 0 ]]; then
    SUDO=""
  else
    command -v sudo >/dev/null || die "sudo required but not available"
    SUDO="sudo"
  fi
}

#######################################
# OS detection
#######################################

detect_os() {
  [[ -r /etc/os-release ]] || die "Cannot detect OS"
  . /etc/os-release

  case "$ID" in
    debian|ubuntu|linuxmint)
      OS_FAMILY="debian"
      ;;
    rhel|centos|rocky|almalinux|fedora)
      OS_FAMILY="rhel"
      ;;
    arch|cachyos)
      OS_FAMILY="arch"
      ;;
    *)
      die "Unsupported OS: $ID"
      ;;
  esac

  debug "Detected OS family: $OS_FAMILY"
}

#######################################
# Package name mapping
#######################################

pkg_name() {
  local logical="$1"
  case "$logical:$OS_FAMILY" in
    virt-manager:debian) echo "virt-manager" ;;
    virt-manager:rhel)   echo "virt-manager" ;;
    virt-manager:arch)   echo "virt-manager" ;;
    qemu:debian)         echo "qemu-system" ;;
    qemu:rhel)           echo "qemu-kvm" ;;
    qemu:arch)           echo "qemu-full" ;;
    *)
      die "No package mapping for $logical on $OS_FAMILY"
      ;;
  esac
}

#######################################
# Idempotent package handling
#######################################

is_installed() {
  local pkg="$1"
  case "$OS_FAMILY" in
    debian) dpkg -s "$pkg" &>/dev/null ;;
    rhel)   rpm -q "$pkg" &>/dev/null ;;
    arch)   pacman -Qi "$pkg" &>/dev/null ;;
  esac
}

record_installed_pkg() {
  grep -qx "$1" "$INSTALLED_PKGS_FILE" 2>/dev/null || echo "$1" >> "$INSTALLED_PKGS_FILE"
}

install_package() {
  local logical="$1"
  local pkg
  pkg="$(pkg_name "$logical")"

  if is_installed "$pkg"; then
    info "$pkg already installed"
    return 0
  fi

  info "Installing $pkg"

  case "$OS_FAMILY" in
    debian)
      run $SUDO apt update -y
      run $SUDO apt install -y "$pkg"
      ;;
    rhel)
      run $SUDO dnf install -y "$pkg"
      ;;
    arch)
      run $SUDO pacman -Sy --noconfirm "$pkg"
      ;;
  esac

  record_installed_pkg "$logical"
}

remove_package() {
  local logical="$1"
  local pkg
  pkg="$(pkg_name "$logical")"

  if ! is_installed "$pkg"; then
    info "$pkg not installed, skipping"
    return 0
  fi

  info "Removing $pkg"

  case "$OS_FAMILY" in
    debian) run $SUDO apt remove -y "$pkg" ;;
    rhel)   run $SUDO dnf remove -y "$pkg" ;;
    arch)   run $SUDO pacman -R --noconfirm "$pkg" ;;
  esac
}

#######################################
# Init / Uninstall
#######################################

cmd_uninstall() {
  detect_os
  detect_privileges

  [[ -f "$INIT_FILE" ]] || {
    info "Not initialized, nothing to uninstall"
    return 0
  }

  if [[ -f "$INSTALLED_PKGS_FILE" ]]; then
    tac "$INSTALLED_PKGS_FILE" | while read -r pkg; do
      remove_package "$pkg"
    done
  fi

  info "Removing state directory"
  run rm -rf "$STATE_DIR"
}

cmd_init() {
  detect_os
  detect_privileges

  if $UNINSTALL; then
    cmd_uninstall
    return 0
  fi

  if [[ -f "$INIT_FILE" && ! $REINIT ]]; then
    info "Already initialized"
    return 0
  fi

  if $REINIT; then
    info "Reinitializing"
    cmd_uninstall
  fi

  mkdir -p "$STATE_DIR" "$LOG_DIR"
  : > "$INSTALLED_PKGS_FILE"
  touch "$INIT_FILE"

  info "Initialization complete"
}

#######################################
# Commands
#######################################

cmd_install_virt_manager() {
  [[ -f "$INIT_FILE" ]] || die "Not initialized (run: $SCRIPT_NAME init)"
  detect_os
  detect_privileges
  install_package virt-manager
}

cmd_help() {
  cat <<EOF
Usage: $SCRIPT_NAME [options] <command>

Options:
  --dry-run
  --debug, --verbose
  --reinit        Force re-run init
  --uninstall     Remove init changes
  -h, --help

Commands:
  init
  install-virt-manager
EOF
}

#######################################
# Argument parsing
#######################################

ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    --debug|--verbose) DEBUG=true ;;
    --reinit) REINIT=true ;;
    --uninstall) UNINSTALL=true ;;
    -h|--help) cmd_help; exit 0 ;;
    *) ARGS+=("$1") ;;
  esac
  shift
done

set -- "${ARGS[@]:-}"

case "${1:-}" in
  init) cmd_init ;;
  install-virt-manager) cmd_install_virt_manager ;;
  "") cmd_help ;;
  *) die "Unknown command: $1" ;;
esac
