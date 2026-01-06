#!/usr/bin/env bash
# Git Configuration Setup
# Configures git with user preferences and sensible defaults

echo "=== Configuring Git ==="

# User identity
git config --global user.email "lee@wiscovitch.org"
git config --global user.name "Lee Wiscovitch"

echo "✓ Git configured successfully"
echo ""
echo "Current git config:"
git config --global --list | grep -E "user\."
