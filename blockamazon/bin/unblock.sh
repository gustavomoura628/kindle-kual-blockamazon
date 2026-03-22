#!/bin/sh
# Unblock everything: restore stock hosts + services + DNS.

UPSTART=/etc/upstart
SERVICES="otaupd otav3 todo clickstream_logging fastmetrics stored whisperstore dynconfig progressivedownloads register_oobe"
RESOLVD=/etc/resolv.d

mntroot rw

# Restore stock hosts
cp /mnt/us/extensions/blockamazon/hosts/hosts-default /etc/hosts

# Re-enable Amazon services
for svc in $SERVICES; do
    if [ -f "$UPSTART/${svc}.conf.disabled" ]; then
        mv "$UPSTART/${svc}.conf.disabled" "$UPSTART/${svc}.conf"
    fi
done

# Restore Amazon DNS (uncomment originals, remove Cloudflare)
for f in "$RESOLVD"/resolv.conf.*; do
    sed -i 's/^# nameserver/nameserver/' "$f"
    sed -i '/^nameserver 1\.1\.1\.1$/d' "$f"
    sed -i '/^nameserver 1\.0\.0\.1$/d' "$f"
done

mntroot ro
