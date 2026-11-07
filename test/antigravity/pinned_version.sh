#!/bin/bash
set -e

source dev-container-features-test-lib

check "agy command is available to the remote user" command -v agy
check "Antigravity CLI has the requested version" bash -c '[[ "$(agy --version)" == "1.5.3" ]]'
check "scenario runs as a non-root user" bash -c '[[ "$(id -u)" -ne 0 ]]'

reportResults
