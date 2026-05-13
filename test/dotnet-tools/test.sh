#!/bin/bash
set -e

# Import the test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Default test: no tools configured — verify dotnet is intact and the
# feature installed cleanly (nothing should be broken).
check "dotnet is available on PATH" command -v dotnet
check "dotnet reports its version" dotnet --version

# Report the results of the checks
reportResults
