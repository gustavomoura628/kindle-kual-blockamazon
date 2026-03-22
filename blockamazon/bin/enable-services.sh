#!/bin/sh
# Re-enable all Amazon services.
# Reverses disable-services.sh.

UPSTART=/etc/upstart
SERVICES="otaupd otav3 todo clickstream_logging fastmetrics stored whisperstore dynconfig progressivedownloads register_oobe"

mntroot rw

for svc in $SERVICES; do
    if [ -f "$UPSTART/${svc}.conf.disabled" ]; then
        mv "$UPSTART/${svc}.conf.disabled" "$UPSTART/${svc}.conf"
    fi
done

mntroot ro
