#!/bin/bash
set -e

source dev-container-features-test-lib

check "substitute URL is configured" grep -q "https://substitutes.nonguix.org" /etc/guix/substitute-urls
check "substitute key file is written" sh -c 'find /etc/guix/acl.d -maxdepth 1 -name "*.pub" | grep -q .'
check "substitute key content is decoded" sh -c 'grep -q "fake-nonguix-signing-key" /etc/guix/acl.d/*.pub'
check "substitute profile export is configured" grep -q "GUIX_SUBSTITUTE_URLS" /etc/profile.d/guix-substitutes.sh

reportResults
