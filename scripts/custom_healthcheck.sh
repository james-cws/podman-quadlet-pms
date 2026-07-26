#!/bin/sh

# This is a VERY simple EXAMPLE script where we extend the built in
# healthcheck to include monitoring the SSL PKCS credential file for
# changes.
#
# DO NOT USE THIS SCRIPT IN A PRODUCTION ENVIRONMENT

MONITORED_FILE="/ssl/credential.pfx"
STATE_FILE="/config/.sslcheck_state"

# Run the original image health check
/healthcheck.sh || exit 1

# Then run SSL monitoring logic
if [ ! -f "$MONITORED_FILE" ]; then
    exit 1
fi

CURRENT_MTIME=$(stat -c %Y "$MONITORED_FILE")

if [ ! -f "$STATE_FILE" ]; then
    echo "$CURRENT_MTIME" > "$STATE_FILE"
    exit 0
fi

LAST_MTIME=$(cat "$STATE_FILE")

if [ "$CURRENT_MTIME" != "$LAST_MTIME" ]; then
    echo "$CURRENT_MTIME" > "$STATE_FILE"
    exit 1
fi

exit 0
