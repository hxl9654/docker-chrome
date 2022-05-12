#!/usr/bin/with-contenv sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

export HOME=/config
mkdir -p /config/profile
exec /usr/bin/chromium_wrapper --disable-dev-shm-usage --user-data-dir=/config/profile
