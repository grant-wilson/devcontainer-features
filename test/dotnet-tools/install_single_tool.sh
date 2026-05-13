#!/bin/bash
set -e

# Import the test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Scenario: install_single_tool
# Verifies that dotnet-ef is installed and functional when tools="dotnet-ef"
check "dotnet-ef is available on PATH" command -v dotnet-ef
check "dotnet-ef reports its version" dotnet-ef --version

# Report the results of the checks
reportResults
