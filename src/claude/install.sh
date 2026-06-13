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
export npm_config_cafile=/etc/ssl/certs/ca-certificates.crt

if ! npm install -g @anthropic-ai/claude-code; then
    echo "Failed to install Claude Code from npm."
    exit 1
fi

CLAUDE_PREFIX="$(npm prefix -g)"
CLAUDE_BIN="$(command -v claude 2>/dev/null || true)"

if [ -z "$CLAUDE_BIN" ] || [ ! -x "$CLAUDE_BIN" ]; then
    echo "Claude binary was not installed at the expected location: $CLAUDE_BIN"
    exit 1
fi

if [ "$CLAUDE_BIN" != "$CLAUDE_PREFIX/bin/claude" ]; then
    echo "Claude binary resolved outside npm's global prefix: $CLAUDE_BIN"
    exit 1
fi

echo "Claude Code installation complete."
"$CLAUDE_BIN" --version
