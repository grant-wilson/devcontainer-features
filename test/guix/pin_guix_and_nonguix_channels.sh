#!/bin/bash
set -e

source dev-container-features-test-lib

check "guix channel pin is present" grep -q "9edb3f66fd807b096b48283debdcddccfea34bad" /etc/guix/channels.scm
check "nonguix channel pin is present" grep -q "897c1a470da759236cc11798f4e0a5f7d4d59fbc" /etc/guix/channels.scm

reportResults
