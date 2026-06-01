#!/bin/bash
set -e

source dev-container-features-test-lib

check "guix command is available on PATH" command -v guix
check "guix reports a version" guix --version
check "default channels file exists" test -f /etc/guix/channels.scm
check "default guix channel is configured" grep -q "https://git.savannah.gnu.org/git/guix.git" /etc/guix/channels.scm

# guix-daemon must actually be reachable at runtime, otherwise commands like
# `guix pull` fail with "failed to connect to the daemon socket".
check "daemon entrypoint is installed" test -x /usr/local/share/guix-start-daemon.sh

# Start the daemon exactly as the entrypoint does when the container boots.
/usr/local/share/guix-start-daemon.sh true

for _ in $(seq 1 30); do
    [ -S /var/guix/daemon-socket/socket ] && break
    sleep 1
done

check "guix-daemon socket is available" test -S /var/guix/daemon-socket/socket
check "guix can reach the daemon" guix processes

reportResults
