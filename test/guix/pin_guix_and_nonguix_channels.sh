#!/bin/bash
set -e

source dev-container-features-test-lib

check "guix channel pin is present" grep -q "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" /etc/guix/channels.scm
check "nonguix channel pin is present" grep -q "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb" /etc/guix/channels.scm

reportResults
