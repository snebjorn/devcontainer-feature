#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'color' feature with no options.
#
# Eg:
# {
#    "image": "<..some-base-image...>",
#    "features": {
#      "chromium": {}
#    }
# }
#
# Thus, the value of all options, 
# will fall back to the default value in the feature's 'devcontainer-feature.json'
# For the 'color' feature, that means the default favorite color is 'red'.
# 
# This test can be run with the following command (from the root of this repo)
#    devcontainer features test \ 
#               --features chromium \
#               --base-image mcr.microsoft.com/devcontainers/base:ubuntu .

set -e

# USERNAME=""
# POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
# for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
#     if id -u "${CURRENT_USER}" > /dev/null 2>&1; then
#         USERNAME="${CURRENT_USER}"
#         break
#     fi
# done
# if [ "${USERNAME}" = "" ]; then
#     echo "Unable to find non-root user to run Chromium as. Chromium doesn't support running as root."
#     exit 1
# fi

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# echo "Running Chromium as ${USERNAME}"

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "version" chromium --headless --disable-gpu --dump-dom https://www.chromestatus.com/ | grep 'Chrome Platform Status'

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
