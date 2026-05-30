#!/bin/bash
set -e

source dev-container-features-test-lib

check "nonguix channel is present" grep -q "https://gitlab.com/nonguix/nonguix" /etc/guix/channels.scm
check "nonguix introduction is configured" grep -q "897c1a470da759236cc11798f4e0a5f7d4d59fbc" /etc/guix/channels.scm

reportResults
