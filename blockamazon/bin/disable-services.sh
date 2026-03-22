#!/bin/sh
# Disable Amazon telemetry, updates, and store services.
# Renames upstart configs so they won't start on boot.
# Reversible with enable-services.sh.

UPSTART=/etc/upstart
SERVICES="otaupd otav3 todo clickstream_logging fastmetrics stored whisperstore dynconfig progressivedownloads register_oobe"

mntroot rw

for svc in $SERVICES; do
    if [ -f "$UPSTART/${svc}.conf" ]; then
        mv "$UPSTART/${svc}.conf" "$UPSTART/${svc}.conf.disabled"
    fi
done

mntroot ro
