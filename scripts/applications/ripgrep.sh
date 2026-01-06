#!/usr/bin/env bash
# ripgrep - Fast grep alternative
# Only loads aliases if ripgrep is installed

command -v rg >/dev/null 2>&1 || return 0

# Commonly used ripgrep aliases
alias rgg='rg --hidden --no-ignore'  # Search including hidden and ignored files
alias rgf='rg --files'                # List files that would be searched
alias rgi='rg --ignore-case'          # Case-insensitive search
