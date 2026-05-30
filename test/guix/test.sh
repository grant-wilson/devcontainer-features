#!/bin/bash
set -e

source dev-container-features-test-lib

check "guix command is available on PATH" command -v guix
check "guix reports a version" guix --version
check "default channels file exists" test -f /etc/guix/channels.scm
check "default guix channel is configured" grep -q "https://git.savannah.gnu.org/git/guix.git" /etc/guix/channels.scm

reportResults
