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

# The native installer places the binary at $HOME/.local/bin/claude (e.g.
# /root/.local/bin/claude). Since /root is mode 700, a symlink from
# /usr/local/bin into that path is inaccessible to non-root container users
# (e.g. vscode). Copy the binary to /usr/local/bin so all users can run it.
CLAUDE_BIN=$(command -v claude 2>/dev/null || true)

if [ -z "$CLAUDE_BIN" ]; then
    for candidate in \
        "$HOME/.local/bin/claude" \
        "$HOME/.claude/bin/claude"; do
        if [ -f "$candidate" ]; then
            CLAUDE_BIN="$candidate"
            break
        fi
    done
fi

# Also check nvm-managed node bins
if [ -z "$CLAUDE_BIN" ]; then
    CLAUDE_BIN=$(find "$HOME/.nvm/versions/node" -name "claude" -type f 2>/dev/null | head -1 || true)
fi

if [ -n "$CLAUDE_BIN" ] && [ "$CLAUDE_BIN" != "/usr/local/bin/claude" ]; then
    echo "Copying $CLAUDE_BIN -> /usr/local/bin/claude"
    cp "$CLAUDE_BIN" /usr/local/bin/claude
    chmod 0755 /usr/local/bin/claude
fi

echo "Claude Code installation complete."
/usr/local/bin/claude --version
