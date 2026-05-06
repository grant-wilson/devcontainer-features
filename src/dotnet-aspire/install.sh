#!/usr/bin/env bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "Installing dependencies..."
apt-get update

# The Aspire CLI is a .NET Native AOT binary and requires an ICU runtime library
# for globalization support.  Detect the correct package name (e.g. libicu74 on
# Ubuntu 24.04, libicu72 on Debian 12) and install it together with curl.
ICU_PKG=$(apt-cache search '^libicu[0-9]' 2>/dev/null | sort -V | tail -1 | awk '{print $1}')
PKGS="curl ca-certificates${ICU_PKG:+ $ICU_PKG}"
# shellcheck disable=SC2086
apt-get install -y --no-install-recommends $PKGS
rm -rf /var/lib/apt/lists/*

echo "Installing Aspire CLI..."
curl -sSL https://aspire.dev/install.sh | bash

# The installer places the binary at $HOME/.aspire/bin/aspire and adds it to
# $PATH via .bashrc.  Copy to /usr/local/bin so all container users can access it.
ASPIRE_BIN=$(command -v aspire 2>/dev/null || true)

if [ -z "$ASPIRE_BIN" ]; then
    for candidate in \
        "$HOME/.aspire/bin/aspire" \
        "/root/.aspire/bin/aspire" \
        "$HOME/.local/bin/aspire" \
        "/root/.local/bin/aspire"; do
        if [ -f "$candidate" ]; then
            ASPIRE_BIN="$candidate"
            break
        fi
    done
fi

if [ -z "$ASPIRE_BIN" ]; then
    echo "Could not locate the aspire binary after installation."
    exit 1
fi

if [ "$ASPIRE_BIN" != "/usr/local/bin/aspire" ]; then
    echo "Copying aspire binary to /usr/local/bin for all-user access..."
    cp "$ASPIRE_BIN" /usr/local/bin/aspire
    chmod 0755 /usr/local/bin/aspire
fi

echo "Aspire CLI installation complete."
aspire --version
