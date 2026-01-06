#!/usr/bin/env bash
# eza - Modern replacement for ls with colors and icons
# Only loads aliases if eza is installed

# Check for eza
if ! command -v eza >/dev/null 2>&1; then
    return 0
fi

# Basic ls replacement
alias ls="eza"
alias lsx="eza -la"

# Additional useful aliases
alias ll="eza -l"                    # Long format
alias la="eza -a"                    # Show hidden files
alias lt="eza -T"                    # Tree view
alias lg="eza -l --git"              # Long format with git status
alias lsd="eza -lD"                  # List directories only
alias lst="eza -l --sort=modified"   # Sort by modification time
