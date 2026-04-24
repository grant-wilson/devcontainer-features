#!/bin/bash
set -e

# Import the test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Execute commands and check their exit codes
check "sqlcmd command is available on PATH" command -v sqlcmd
check "sqlcmd executes successfully" sqlcmd --version

# Report the results of the checks
reportResults
