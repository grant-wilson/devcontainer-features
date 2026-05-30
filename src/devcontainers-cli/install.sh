#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root."
    exit 1
fi

if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
    echo "Installing curl..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends curl ca-certificates
    rm -rf /var/lib/apt/lists/*
fi

echo "Installing Dev Containers CLI..."
curl -fsSL https://raw.githubusercontent.com/devcontainers/cli/main/scripts/install.sh | sh -s -- --prefix /usr/local/devcontainers
ln -sf /usr/local/devcontainers/bin/devcontainer /usr/local/bin/devcontainer

echo "Dev Containers CLI installation complete."
devcontainer --version
