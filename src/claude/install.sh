#!/usr/bin/env bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root."
    exit 1
fi

PACKAGES_TO_INSTALL=()

if ! command -v npm &> /dev/null; then
    PACKAGES_TO_INSTALL+=(nodejs npm)
fi

if [ ! -f /etc/ssl/certs/ca-certificates.crt ]; then
    PACKAGES_TO_INSTALL+=(ca-certificates)
fi

if [ ${#PACKAGES_TO_INSTALL[@]} -gt 0 ]; then
    echo "Installing missing dependencies..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends "${PACKAGES_TO_INSTALL[@]}"
    rm -rf /var/lib/apt/lists/*
fi

echo "Installing Claude Code..."
export NODE_OPTIONS="${NODE_OPTIONS:+$NODE_OPTIONS }--use-openssl-ca"
npm_config_cafile=/etc/ssl/certs/ca-certificates.crt npm install -g @anthropic-ai/claude-code
CLAUDE_BIN="$(npm prefix -g)/bin/claude"

echo "Claude Code installation complete."
"$CLAUDE_BIN" --version
