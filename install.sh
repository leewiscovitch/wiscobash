#!/usr/bin/env bash
set -e
WISCOBASH_DIR="$HOME/wiscobash"
BASHRC="$HOME/.bashrc"
MARKER="# >>> wiscobash initialize >>>"
echo "Installing WiscoBash..."
[ ! -f "$WISCOBASH_DIR/install.sh" ] && echo "Error: Run from $WISCOBASH_DIR" && exit 1
grep -q "$MARKER" "$BASHRC" 2>/dev/null && echo "Already installed. Run ./uninstall.sh first" && exit 1
cp "$BASHRC" "$BASHRC.backup.$(date +%Y%m%d_%H%M%S)"
cat >> "$BASHRC" << 'MARK'

# >>> wiscobash initialize >>>
[ -f "$HOME/wiscobash/config/bashrc_additions" ] && source "$HOME/wiscobash/config/bashrc_additions"
# <<< wiscobash initialize <<<<
MARK
echo "✓ Installed! Run: source ~/.bashrc"
