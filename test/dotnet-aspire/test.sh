#!/bin/bash
set -e

# Import the test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Execute commands and check their exit codes
check "aspire command is available on PATH" command -v aspire
check "aspire executes successfully" aspire --version

# Report the results of the checks
reportResults
