#!/bin/bash
set -e

# Import the test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Execute commands and check their exit codes
check "sqlpackage command is available on PATH" command -v sqlpackage
check "sqlpackage executes successfully" sqlpackage /version

# Report the results of the checks
reportResults
