#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root."
    exit 1
fi

PACKAGES_TO_INSTALL=()
if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
    PACKAGES_TO_INSTALL+=(curl ca-certificates)
fi
if ! command -v xz &> /dev/null; then
    PACKAGES_TO_INSTALL+=(xz-utils)
fi

if [ ${#PACKAGES_TO_INSTALL[@]} -gt 0 ]; then
    echo "Installing dependencies: ${PACKAGES_TO_INSTALL[*]}..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends "${PACKAGES_TO_INSTALL[@]}"
    rm -rf /var/lib/apt/lists/*
fi

echo "Installing Dev Containers CLI..."
curl -fsSL https://raw.githubusercontent.com/devcontainers/cli/main/scripts/install.sh | sh -s -- --prefix /usr/local/devcontainers
ln -sf /usr/local/devcontainers/bin/devcontainer /usr/local/bin/devcontainer

echo "Dev Containers CLI installation complete."
devcontainer --version
