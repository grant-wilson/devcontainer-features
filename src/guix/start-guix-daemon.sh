#!/usr/bin/env bash
# Entrypoint installed by the guix dev container feature.
#
# The upstream Guix installer registers guix-daemon as a systemd service, but a
# dev container usually has no init system running, so the daemon never starts
# and commands such as `guix pull` fail with:
#   failed to connect to '/var/guix/daemon-socket/socket'
#
# This script launches guix-daemon in the background (once) before handing
# control to the next entrypoint / the container command.
set -e

daemon_socket="/var/guix/daemon-socket/socket"

start_guix_daemon() {
    local daemon_bin=""
    local candidate
    for candidate in \
        /var/guix/profiles/per-user/root/current-guix/bin/guix-daemon \
        /root/.config/guix/current/bin/guix-daemon \
        "$(command -v guix-daemon 2>/dev/null || true)"; do
        if [ -n "${candidate}" ] && [ -x "${candidate}" ]; then
            daemon_bin="${candidate}"
            break
        fi
    done

    # Guix is not installed (or guix-daemon is missing); nothing to do.
    [ -z "${daemon_bin}" ] && return 0

    # A daemon is already listening; leave it alone.
    if [ -S "${daemon_socket}" ]; then
        return 0
    fi

    # Allow each container user to create their own per-user profile directory.
    if [ -d /var/guix/profiles/per-user ]; then
        chmod 1777 /var/guix/profiles/per-user 2>/dev/null || true
    fi

    local daemon_args=()
    if getent group guixbuild >/dev/null 2>&1; then
        daemon_args+=("--build-users-group=guixbuild")
    else
        # No isolated build users were created; fall back to non-chrooted builds
        # so the daemon can still run as root inside the container.
        daemon_args+=("--disable-chroot")
    fi

    mkdir -p /var/log
    "${daemon_bin}" "${daemon_args[@]}" >>/var/log/guix-daemon.log 2>&1 &
}

if [ "$(id -u)" -eq 0 ]; then
    start_guix_daemon || true
elif command -v sudo >/dev/null 2>&1; then
    # The entrypoint may run as a non-root user; the daemon must run as root.
    sudo -n bash -c "$(declare -f start_guix_daemon); daemon_socket='${daemon_socket}'; start_guix_daemon" || true
fi

exec "$@"
