#!/bin/bash
set -e

# Import the test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Scenario: install_multiple_tools
# Verifies that all tools are installed when tools="dotnet-ef,dotnet-outdated"
check "dotnet-ef is available on PATH" command -v dotnet-ef
check "dotnet-ef reports its version" dotnet-ef --version

check "dotnet-outdated is available on PATH" command -v dotnet-outdated
check "dotnet-outdated reports its version" dotnet-outdated --version


# Report the results of the checks
reportResults
