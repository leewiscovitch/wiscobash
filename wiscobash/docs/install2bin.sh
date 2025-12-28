#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="$HOME/wiscobash/bin"

# -----------------------------
# Default artifacts
# -----------------------------
DEFAULT_ARTIFACTS=(
"https://github.com/gtema/openstack/releases/latest/download/openstack_cli-x86_64-unknown-linux-gnu.tar.xz:osc"
"https://github.com/gtema/openstack/releases/latest/download/openstack_tui-x86_64-unknown-linux-gnu.tar.xz:ostui"
)

# -----------------------------
# Flags
# -----------------------------
DRY_RUN=false
LIST_ONLY=false
DEBUG=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --list)
      LIST_ONLY=true
      shift
      ;;
    --debug)
      DEBUG=true
      shift
      ;;
    *)
      break
      ;;
  esac
done

# Enable debug mode if requested
if $DEBUG; then
    set -x
fi

# -----------------------------
# Preflight check for download tool and extraction tools
# -----------------------------
DOWNLOAD_CMD=""
if command -v curl >/dev/null 2>&1; then
    DOWNLOAD_CMD="curl -fsSL"
elif command -v wget >/dev/null 2>&1; then
    DOWNLOAD_CMD="wget -qO-"
else
    echo "ERROR: Neither 'curl' nor 'wget' is installed. Please install one to continue."
    exit 1
fi

if ! command -v tar >/dev/null 2>&1; then
    echo "ERROR: 'tar' is required but not installed."
    exit 1
fi

if ! command -v unzip >/dev/null 2>&1; then
    echo "WARNING: 'unzip' is not installed. ZIP archives won't work."
fi

$DEBUG && echo "[DEBUG] Using download command: $DOWNLOAD_CMD"

# -----------------------------
# Install artifact function
# -----------------------------
install_artifact() {
  local url="$1"
  local selector="$2"

  # Strip hidden characters from URL
  url=$(echo -n "$url" | tr -d '\r' | tr -d '\n')

  if [[ -z "$url" ]]; then
    echo "ERROR: URL is empty! Exiting."
    exit 1
  fi

  local tmpdir
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' RETURN

  local archive="$tmpdir/${url##*/}"

  $DEBUG && echo "[DEBUG] tmpdir=$tmpdir"
  $DEBUG && echo "[DEBUG] archive=$archive"
  $DEBUG && echo "[DEBUG] url='$url'"
  $DEBUG && echo "[DEBUG] selector='$selector'"

  echo "Downloading $url..."
  if [[ $DOWNLOAD_CMD == curl* ]]; then
      curl -fsSL "$url" -o "$archive"
  else
      wget -qO "$archive" "$url"
  fi

  echo "Extracting $archive..."
  case "$archive" in
    *.tar.gz|*.tgz)
      tar -xzf "$archive" -C "$tmpdir"
      ;;
    *.tar.xz)
      tar -xJf "$archive" -C "$tmpdir"
      ;;
    *.zip)
      if ! command -v unzip >/dev/null 2>&1; then
          echo "ERROR: Cannot extract ZIP archive because 'unzip' is missing."
          exit 1
      fi
      unzip -q "$archive" -d "$tmpdir"
      ;;
    *)
      echo "ERROR: Unsupported archive format: $archive"
      exit 1
      ;;
  esac

  local bins
  if [[ "$selector" == "all" || "$selector" == "*" ]]; then
    mapfile -t bins < <(find "$tmpdir" -type f -perm -u+x)
    if [[ ${#bins[@]} -eq 0 ]]; then
      echo "ERROR: No executable files found in archive"
      exit 1
    fi
  else
    local bin_path
    bin_path="$(find "$tmpdir" -type f -name "$selector" -perm -u+x | head -n 1)"
    if [[ -z "$bin_path" ]]; then
      echo "ERROR: Binary '$selector' not found"
      exit 1
    fi
    bins=("$bin_path")
  fi

  for bin in "${bins[@]}"; do
    local name
    name="$(basename "$bin")"
    if $LIST_ONLY; then
      echo "[LIST] $name"
      continue
    fi

    echo "Installing $name..."
    if $DRY_RUN; then
      echo "[DRY-RUN] Would install to $INSTALL_DIR/$name"
    else
      mkdir -p "$INSTALL_DIR"
      install -m 0755 "$bin" "$INSTALL_DIR/$name"
    fi
  done
}

# -----------------------------
# Main execution
# -----------------------------
if [[ $# -ge 1 ]]; then
  if [[ $# -ne 2 ]]; then
    echo "Usage:"
    echo "  $0 [--list] [--dry-run] [--debug]                   # install default artifacts"
    echo "  $0 [--list] [--dry-run] [--debug] <url> <binary|all>  # install custom artifact"
    exit 1
  fi
  install_artifact "$1" "$2"
else
  for entry in "${DEFAULT_ARTIFACTS[@]}"; do
    entry_clean=$(echo -n "$entry" | tr -d '\r' | tr -d '\n')
    url="${entry_clean%:*}"
    bin_name="${entry_clean##*:}"
    install_artifact "$url" "$bin_name"
  done
fi

echo "Done."

