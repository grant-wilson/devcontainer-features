#!/bin/bash
set -e

# Import the test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Execute commands and check their exit codes
check "devcontainer command is available on PATH" command -v devcontainer
check "devcontainer tool executes successfully" devcontainer --version

# Report the results of the checks
reportResults
