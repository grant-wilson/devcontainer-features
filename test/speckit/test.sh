#!/bin/bash
set -e

# Import the test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Execute commands and check their exit codes
check "specify command is available on PATH" command -v specify
check "specify tool executes successfully" specify --help

# Report the results of the checks
reportResults
