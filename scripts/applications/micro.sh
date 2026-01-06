#!/usr/bin/env bash
# micro - Modern terminal-based text editor
# Sets micro as the default system editor if installed

# Check for micro
if ! command -v micro >/dev/null 2>&1; then
    return 0
fi

# Set micro as default editor
export EDITOR="micro"
export VISUAL="micro"

# Helpful aliases
alias edit="micro"
alias m="micro"
