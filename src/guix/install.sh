#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root."
    exit 1
fi

INSTALL_NONGUIX="${INSTALL_NONGUIX:-${INSTALLNONGUIX:-false}}"
EXTRA_CHANNELS="${EXTRA_CHANNELS:-${EXTRACHANNELS:-}}"
PINNED_CHANNELS="${PINNED_CHANNELS:-${PINNEDCHANNELS:-}}"
AUTHORIZED_SUBSTITUTES="${AUTHORIZED_SUBSTITUTES:-${AUTHORIZEDSUBSTITUTES:-}}"
INSTALLER_URL="${INSTALLER_URL:-${INSTALLERURL:-https://git.savannah.gnu.org/cgit/guix.git/plain/etc/guix-install.sh}}"

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends bash curl ca-certificates gnupg
rm -rf /var/lib/apt/lists/*

tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

installer_path="${tmp_dir}/guix-install.sh"
if ! curl -fsSL "${INSTALLER_URL}" -o "${installer_path}"; then
    fallback_url="https://guix.gnu.org/install.sh"
    echo "Primary installer URL failed; falling back to ${fallback_url}"
    curl -fsSL "${fallback_url}" -o "${installer_path}"
fi

chmod +x "${installer_path}"
yes '' | bash "${installer_path}"

if [ -f /root/.config/guix/current/etc/profile ]; then
    # shellcheck disable=SC1091
    source /root/.config/guix/current/etc/profile
fi

if ! command -v guix >/dev/null 2>&1 && [ -x /root/.config/guix/current/bin/guix ]; then
    ln -sf /root/.config/guix/current/bin/guix /usr/local/bin/guix
fi

if ! command -v guix >/dev/null 2>&1; then
    echo "Failed to locate guix after installation."
    exit 1
fi

declare -A channel_pins
if [ -n "${PINNED_CHANNELS}" ]; then
    IFS=',' read -ra pin_defs <<< "${PINNED_CHANNELS}"
    for pin_def in "${pin_defs[@]}"; do
        pin_def="$(echo "${pin_def}" | xargs)"
        [ -z "${pin_def}" ] && continue
        channel_name="${pin_def%%=*}"
        channel_commit="${pin_def#*=}"
        if [ -z "${channel_name}" ] || [ "${channel_name}" = "${channel_commit}" ]; then
            echo "Invalid pinned channel definition: ${pin_def}"
            exit 1
        fi
        channel_pins["${channel_name}"]="${channel_commit}"
    done
fi

channel_file="/etc/guix/channels.scm"
mkdir -p /etc/guix /root/.config/guix

write_channel() {
    local name="$1"
    local url="$2"
    local branch="$3"
    local intro_commit="$4"
    local intro_fingerprint="$5"
    local pinned_commit="${channel_pins[${name}]:-}"

    {
        echo "  (channel"
        echo "    (name '${name})"
        echo "    (url \"${url}\")"
        if [ -n "${branch}" ]; then
            echo "    (branch \"${branch}\")"
        fi
        if [ -n "${pinned_commit}" ]; then
            echo "    (commit \"${pinned_commit}\")"
        fi
        if [ -n "${intro_commit}" ] && [ -n "${intro_fingerprint}" ]; then
            echo "    (introduction"
            echo "      (make-channel-introduction"
            echo "        \"${intro_commit}\""
            echo "        (openpgp-fingerprint"
            echo "          \"${intro_fingerprint}\"))))"
        else
            echo "    )"
        fi
    } >> "${channel_file}"
}

cat > "${channel_file}" <<'EOF'
(list
EOF

write_channel \
    "guix" \
    "https://git.savannah.gnu.org/git/guix.git" \
    "" \
    "9edb3f66fd807b096b48283debdcddccfea34bad" \
    "BBB0 2DDF 2CEA F6A8 0D1D E643 A2A0 6DF2 A33A 54FA"

if [ "${INSTALL_NONGUIX}" = "true" ]; then
    write_channel \
        "nonguix" \
        "https://gitlab.com/nonguix/nonguix" \
        "" \
        "897c1a470da759236cc11798f4e0a5f7d4d59fbc" \
        "2A39 3FFF 68F4 EF7A 3D29 12AF 6F51 20A0 22FB B2D5"
fi

if [ -n "${EXTRA_CHANNELS}" ]; then
    IFS=';' read -ra extra_defs <<< "${EXTRA_CHANNELS}"
    for extra_def in "${extra_defs[@]}"; do
        extra_def="$(echo "${extra_def}" | xargs)"
        [ -z "${extra_def}" ] && continue
        IFS='|' read -r name url branch intro_commit intro_fingerprint <<< "${extra_def}"
        if [ -z "${name:-}" ] || [ -z "${url:-}" ]; then
            echo "Invalid extra channel definition: ${extra_def}"
            exit 1
        fi
        write_channel "${name}" "${url}" "${branch:-}" "${intro_commit:-}" "${intro_fingerprint:-}"
    done
fi

echo ")" >> "${channel_file}"
cp "${channel_file}" /root/.config/guix/channels.scm

substitute_url_file="/etc/guix/substitute-urls"
acl_dir="/etc/guix/acl"
mkdir -p "${acl_dir}"
: > "${substitute_url_file}"

if [ -n "${AUTHORIZED_SUBSTITUTES}" ]; then
    IFS=';' read -ra substitute_defs <<< "${AUTHORIZED_SUBSTITUTES}"
    for substitute_def in "${substitute_defs[@]}"; do
        substitute_def="$(echo "${substitute_def}" | xargs)"
        [ -z "${substitute_def}" ] && continue
        IFS='|' read -r substitute_url key_source <<< "${substitute_def}"
        if [ -z "${substitute_url:-}" ]; then
            echo "Invalid substitute definition: ${substitute_def}"
            exit 1
        fi
        echo "${substitute_url}" >> "${substitute_url_file}"
        if [ -n "${key_source:-}" ]; then
            key_file_hash="$(printf '%s' "${substitute_url}" | sha256sum | cut -c1-16)"
            key_target="${acl_dir}/${key_file_hash}.pub"
            if [[ "${key_source}" == base64:* ]]; then
                printf '%s' "${key_source#base64:}" | base64 -d > "${key_target}"
            elif [[ "${key_source}" =~ ^https?:// ]]; then
                curl -fsSL "${key_source}" -o "${key_target}"
            elif [ -f "${key_source}" ]; then
                cp "${key_source}" "${key_target}"
            else
                printf '%s\n' "${key_source}" > "${key_target}"
            fi
        fi
    done
fi

if [ -s "${substitute_url_file}" ]; then
    substitute_urls="$(paste -sd' ' "${substitute_url_file}")"
    cat > /etc/profile.d/guix-substitutes.sh <<EOF
export GUIX_SUBSTITUTE_URLS="${substitute_urls}"
EOF
    chmod 0644 /etc/profile.d/guix-substitutes.sh
fi

echo "Guix installation complete."
guix --version
