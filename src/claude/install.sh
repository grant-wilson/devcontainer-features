#!/usr/bin/env bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root."
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo "Installing missing dependencies..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends curl ca-certificates
    rm -rf /var/lib/apt/lists/*
fi

echo "Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash

# The native installer may place the binary in a user-local directory.
# Ensure it is accessible system-wide for all container users.
if ! command -v claude &> /dev/null; then
    for candidate_dir in "$HOME/.claude/bin" "$HOME/.local/bin" "$HOME/.nvm/versions/node/"*/bin; do
        if [ -f "$candidate_dir/claude" ]; then
            echo "Linking $candidate_dir/claude -> /usr/local/bin/claude"
            ln -sf "$candidate_dir/claude" /usr/local/bin/claude
            break
        fi
    done
fi

echo "Claude Code installation complete."
claude --version
