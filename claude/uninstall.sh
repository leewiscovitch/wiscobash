#!/usr/bin/env bash
set -e
BASHRC="$HOME/.bashrc"
START="# >>> wiscobash initialize >>>"
END_M="# <<< wiscobash initialize <<<<"
echo "Uninstalling..."
grep -q "$START" "$BASHRC" 2>/dev/null || { echo "Not installed"; exit 1; }
cp "$BASHRC" "$BASHRC.backup.$(date +%Y%m%d_%H%M%S)"
sed -i "/^$START/,/^$END_M/d" "$BASHRC"
echo "✓ Uninstalled! Restart terminal or: source ~/.bashrc"
