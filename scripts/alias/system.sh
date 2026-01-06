#!/usr/bin/env bash
# System utility aliases

# Network and system info
alias wget="wget -c"                          # Resume downloads by default
alias psx="sudo ps auxf"                      # Show all processes in tree format
alias ports="sudo ss -tunlap"                 # Show listening ports and connections
alias meminfo="free -mlth"                    # Memory info in human-readable format
alias extip="curl ifconfig.co -4"             # Get external IP address (IPv4)

# File system
alias df="df -h"                              # Disk usage in human-readable format

# File operations with progress
alias cpx="rsync -ah --info=progress2"        # Copy with progress bar

# Navigation
alias cd..="cd .."                            # Fix common typo
