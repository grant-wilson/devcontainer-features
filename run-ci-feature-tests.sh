#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

if ! command -v devcontainer &> /dev/null; then
  echo "Installing Dev Containers CLI..."
  curl -fsSL https://raw.githubusercontent.com/devcontainers/cli/main/scripts/install.sh | sh
fi

export PATH="$HOME/.devcontainers/bin:$PATH"

features=(
  speckit
  claude
  copilot-cli
  sqlcmd
  dotnet-aspire
  devcontainers-cli
)

base_images=(
  debian:latest
  ubuntu:latest
  mcr.microsoft.com/devcontainers/base:ubuntu
  mcr.microsoft.com/devcontainers/base:ubuntu-24.04
  mcr.microsoft.com/devcontainers/typescript-node:4-24-trixie
  mcr.microsoft.com/devcontainers/dotnet:dev-10.0-noble
)

dotnet_tools_base_images=(
  mcr.microsoft.com/devcontainers/dotnet:1-9.0-bookworm
  mcr.microsoft.com/devcontainers/dotnet:1-8.0-bookworm
  mcr.microsoft.com/devcontainers/dotnet:dev-10.0-noble
)

for feature in "${features[@]}"; do
  for base_image in "${base_images[@]}"; do
    echo "Running ${feature} on ${base_image} (--skip-scenarios)"
    devcontainer features test -f "$feature" -i "$base_image" --skip-scenarios
  done
done

for base_image in "${dotnet_tools_base_images[@]}"; do
  echo "Running dotnet-tools on ${base_image}"
  devcontainer features test -f dotnet-tools -i "$base_image"
done

echo "All CI-equivalent feature tests completed successfully."
