#!/usr/bin/env bash
# starship - Cross-shell prompt
# Activates starship prompt if installed

# Check for starship
if ! command -v starship >/dev/null 2>&1; then
    return 0
fi

# Initialize starship for bash
eval "$(starship init bash)"
