#!/bin/bash
set -e

source dev-container-features-test-lib

check "guile load path profile script exists" test -f /etc/profile.d/guix-guile-load-path.sh
check "GUILE_LOAD_PATH export is configured" grep -q 'export GUILE_LOAD_PATH="/workspaces/myrepo/packages' /etc/profile.d/guix-guile-load-path.sh
check "GUILE_LOAD_COMPILED_PATH export is configured" grep -q 'export GUILE_LOAD_COMPILED_PATH="/workspaces/myrepo/packages' /etc/profile.d/guix-guile-load-path.sh
check "existing GUILE_LOAD_PATH is preserved" grep -q 'GUILE_LOAD_PATH:+:$GUILE_LOAD_PATH' /etc/profile.d/guix-guile-load-path.sh
check "GUILE_LOAD_PATH is set after sourcing profile script" sh -c '. /etc/profile.d/guix-guile-load-path.sh; echo "$GUILE_LOAD_PATH" | grep -q "/workspaces/myrepo/packages"'

reportResults
