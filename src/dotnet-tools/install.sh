#!/usr/bin/env bash
set -e

TOOLS=${TOOLS:-""}

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root."
    exit 1
fi

# Verify dotnet SDK is available
if ! command -v dotnet &> /dev/null; then
    echo "ERROR: 'dotnet' was not found on PATH."
    echo "Please ensure the .NET SDK is installed before this feature (e.g. via ghcr.io/devcontainers/features/dotnet)."
    exit 1
fi

echo "Detected .NET SDK: $(dotnet --version)"

if [ -z "${TOOLS}" ]; then
    echo "No .NET tools specified (options.tools is empty). Nothing to install."
    exit 0
fi

echo "Installing .NET global tools: ${TOOLS}"

# Parse comma-separated list and install each tool to /usr/local/bin
# so tools are on PATH for all container users, not just root.
IFS=',' read -ra TOOL_LIST <<< "${TOOLS}"
for tool in "${TOOL_LIST[@]}"; do
    # Strip leading/trailing whitespace
    tool="${tool#"${tool%%[![:space:]]*}"}"
    tool="${tool%"${tool##*[![:space:]]}"}"

    if [ -z "$tool" ]; then
        continue
    fi

    echo "Installing dotnet tool: ${tool}"
    dotnet tool install --tool-path /usr/local/bin "${tool}"
    echo "Successfully installed: ${tool}"
done

echo "All specified .NET global tools installed successfully."
