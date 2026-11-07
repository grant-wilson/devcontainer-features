#!/bin/bash
set -e

source dev-container-features-test-lib

check "agy command is available on PATH" command -v agy
check "agy is installed system-wide" test -x /usr/local/bin/agy
check "Antigravity CLI executes successfully" agy --version
check "git is available for workspace operations" git --version

reportResults
