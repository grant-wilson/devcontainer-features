#!/bin/bash
set -e

# Import the test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Execute commands and check their exit codes
check "claude command is available on PATH" command -v claude
check "claude tool executes successfully" claude --version

# Report the results of the checks
reportResults
