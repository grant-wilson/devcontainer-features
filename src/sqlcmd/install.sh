#!/usr/bin/env bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends curl ca-certificates bzip2

MACHINE=$(uname -m)
case "${MACHINE}" in
    x86_64)        ASSET_ARCH="linux-amd64" ;;
    aarch64|arm64) ASSET_ARCH="linux-arm64" ;;
    s390x)         ASSET_ARCH="linux-s390x" ;;
    *)
        echo "Unsupported architecture: ${MACHINE}"
        exit 1
        ;;
esac

echo "Fetching latest sqlcmd (Go) release for ${ASSET_ARCH}..."

DOWNLOAD_URL=$(curl -fsSL https://api.github.com/repos/microsoft/go-sqlcmd/releases/latest \
    | grep '"browser_download_url"' \
    | grep "sqlcmd-${ASSET_ARCH}\.tar\.bz2" \
    | head -1 \
    | cut -d '"' -f 4)

if [ -z "${DOWNLOAD_URL}" ]; then
    echo "Could not resolve a download URL for sqlcmd (${ASSET_ARCH})"
    exit 1
fi

echo "Downloading sqlcmd from ${DOWNLOAD_URL}"
curl -fsSL "${DOWNLOAD_URL}" | tar -xj -C /usr/local/bin sqlcmd
chmod 0755 /usr/local/bin/sqlcmd

echo "sqlcmd installation complete."
sqlcmd --version
