#!/usr/bin/env bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root."
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "Installing missing dependencies..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends nodejs npm ca-certificates
    rm -rf /var/lib/apt/lists/*
fi

echo "Installing Claude Code..."
npm install -g @anthropic-ai/claude-code

echo "Claude Code installation complete."
claude --version
