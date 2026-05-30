#!/usr/bin/env bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root."
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "Installing Node.js and npm..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends nodejs npm
    rm -rf /var/lib/apt/lists/*
fi

echo "Installing Dev Containers CLI..."
npm install -g @devcontainers/cli

echo "Dev Containers CLI installation complete."
devcontainer --version
