#!/usr/bin/env bash
set -e

VERSION=${VERSION:-"latest"}

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root."
    exit 1
fi

if ! command -v uv &> /dev/null; then
    echo "uv not found. Installing uv globally..."
    curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="/usr/local/bin" sh
fi

echo "Installing GitHub Spec Kit (specify-cli)..."

export UV_TOOL_DIR="/opt/uv-tools"
export UV_TOOL_BIN_DIR="/usr/local/bin"
export UV_PYTHON_INSTALL_DIR="/opt/uv-python" 

if [ "${VERSION}" = "latest" ]; then
    uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
else
    uv tool install specify-cli --from "git+https://github.com/github/spec-kit.git@${VERSION}"
fi

chmod -R a+rx /opt/uv-tools
chmod -R a+rx /opt/uv-python

echo "GitHub Spec Kit installed successfully!"
