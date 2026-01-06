#!/usr/bin/env bash
# bat - A cat clone with syntax highlighting
# Only loads aliases if bat is installed

command -v bat >/dev/null 2>&1 || return 0

# Override cat with bat for better output
# --style=plain: No decorations, just syntax highlighting
# --paging=never: Output directly without pager
alias cat="bat --style=plain --paging=never"
