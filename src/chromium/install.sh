#!/bin/bash

USERNAME=${USERNAME:-"automatic"}
CHROME_PROFILE_DIR=${CHROME_PROFILE_DIR:-"/usr/local/chrome"}

set -eux
export DEBIAN_FRONTEND=noninteractive

# Setup STDERR.
err() {
    echo "(!) $*" >&2
}

# Ensure the appropriate root user is running the script.
if [ "$(id -u)" -ne 0 ]; then
    err 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

disto="$(lsb_release -is)"
if [ "${disto}" != "Debian" ]; then
    err "Distributor $disto unsupported."
    exit 1
fi

# Ensure that login shells get the correct path if the user updated the PATH using ENV.
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

# Determine the appropriate non-root user.
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u "${CURRENT_USER}" > /dev/null 2>&1; then
            USERNAME="${CURRENT_USER}"
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

apt_update()
{
    echo "Running apt update..."
    apt update -y
}

# Check if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_update
        apt -y install --no-install-recommends "$@"
    fi
}

# Install dependencies
check_packages chromium chromium-sandbox

# Add user so we don't need --no-sandbox
# if ! cat /etc/group | grep -e "^chromium:" > /dev/null 2>&1; then
#     groupadd -r chromium
# fi

# usermod -a -G chromium "${USERNAME}"
# mkdir -p $CHROME_PROFILE_DIR
# chown -R "${USERNAME}:chromium" "${CHROME_PROFILE_DIR}"
# chmod -R g+r+w "${CHROME_PROFILE_DIR}"

echo "Done!"
