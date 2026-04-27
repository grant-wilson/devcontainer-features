#!/usr/bin/env bash
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root."
    exit 1
fi

MACHINE=$(uname -m)
if [ "${MACHINE}" != "x86_64" ]; then
    echo "sqlpackage is only available for Linux x86_64 (got: ${MACHINE})."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends curl ca-certificates unzip libunwind8

INSTALL_DIR="/usr/local/lib/sqlpackage"
mkdir -p "${INSTALL_DIR}"

echo "Downloading sqlpackage for Linux..."
curl -fsSL "https://aka.ms/sqlpackage-linux" -o /tmp/sqlpackage-linux.zip

unzip -o /tmp/sqlpackage-linux.zip -d "${INSTALL_DIR}"
rm /tmp/sqlpackage-linux.zip

chmod a+x "${INSTALL_DIR}/sqlpackage"

ln -sf "${INSTALL_DIR}/sqlpackage" /usr/local/bin/sqlpackage

echo "sqlpackage installation complete."
sqlpackage /version
