#!/bin/bash
set -e

# Import the test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Execute commands and check their exit codes
check "copilot command is available on PATH" command -v copilot
check "copilot tool executes successfully" copilot --version

# Report the results of the checks
reportResults
