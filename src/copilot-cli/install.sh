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

echo "Installing GitHub Copilot CLI..."
# Running as root installs the binary to /usr/local/bin/copilot
curl -fsSL https://gh.io/copilot-install | bash

echo "GitHub Copilot CLI installation complete."
/usr/local/bin/copilot --version
