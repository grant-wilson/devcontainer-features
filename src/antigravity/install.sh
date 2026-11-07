#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root." >&2
    exit 1
fi

VERSION="${VERSION:-latest}"
if [[ "${VERSION}" != "latest" && ! "${VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Invalid Antigravity CLI version: ${VERSION}. Use latest or a release version such as 1.5.3." >&2
    exit 1
fi

case "$(uname -m)" in
    x86_64) ASSET_ARCH="x64" ;;
    aarch64|arm64) ASSET_ARCH="arm64" ;;
    *)
        echo "Unsupported architecture: $(uname -m). Antigravity CLI requires amd64 or arm64." >&2
        exit 1
        ;;
esac

if ! command -v apt-get &> /dev/null; then
    echo "This feature requires a Debian/Ubuntu-based container with apt-get." >&2
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends curl ca-certificates tar gzip git

RELEASE_URL="https://github.com/google-antigravity/antigravity-cli/releases"
if [ "${VERSION}" = "latest" ]; then
    DOWNLOAD_URL="${RELEASE_URL}/latest/download/agy_cli_linux_${ASSET_ARCH}.tar.gz"
else
    DOWNLOAD_URL="${RELEASE_URL}/download/${VERSION}/agy_cli_linux_${ASSET_ARCH}.tar.gz"
fi

INSTALL_DIR="$(mktemp -d)"
trap 'rm -rf "${INSTALL_DIR}"' EXIT

echo "Installing Google Antigravity CLI (${VERSION}, ${ASSET_ARCH})..."
curl -fsSL --retry 3 "${DOWNLOAD_URL}" -o "${INSTALL_DIR}/agy.tar.gz"
tar -xzf "${INSTALL_DIR}/agy.tar.gz" -C "${INSTALL_DIR}" antigravity
install -m 0755 "${INSTALL_DIR}/antigravity" /usr/local/bin/agy

agy --version
echo "Google Antigravity CLI installation complete. Run agy as your container user to sign in."
