#!/usr/bin/env bash
# bat - A cat clone with syntax highlighting
# Only loads aliases if bat is installed
# Handles both 'bat' and 'batcat' (Ubuntu/Debian naming)

# Check for bat or batcat
if command -v bat >/dev/null 2>&1; then
    BAT_CMD="bat"
elif command -v batcat >/dev/null 2>&1; then
    BAT_CMD="batcat"
    # Create bat alias for batcat on Ubuntu/Debian
    alias bat="batcat"
else
    return 0
fi

# Override cat with bat for better output
# --style=plain: No decorations, just syntax highlighting
# --paging=never: Output directly without pager
alias cat="$BAT_CMD --style=plain --paging=never"
