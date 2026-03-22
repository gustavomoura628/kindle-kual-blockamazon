#!/bin/sh
# Block Amazon but allow S3. Services disabled, DNS replaced.

UPSTART=/etc/upstart
SERVICES="otaupd otav3 todo clickstream_logging fastmetrics stored whisperstore dynconfig progressivedownloads register_oobe"
RESOLVD=/etc/resolv.d

mntroot rw

# Sinkhole Amazon domains (S3 unblocked)
cp /mnt/us/extensions/blockamazon/hosts/hosts-allow-s3 /etc/hosts

# Disable Amazon services
for svc in $SERVICES; do
    if [ -f "$UPSTART/${svc}.conf" ]; then
        mv "$UPSTART/${svc}.conf" "$UPSTART/${svc}.conf.disabled"
    fi
done

# Replace Amazon DNS with Cloudflare (comment originals, idempotent)
for f in "$RESOLVD"/resolv.conf.*; do
    sed -i '/^nameserver 1\.1\.1\.1$/d' "$f"
    sed -i '/^nameserver 1\.0\.0\.1$/d' "$f"
    sed -i 's/^nameserver/# nameserver/' "$f"
    echo "nameserver 1.1.1.1" >> "$f"
    echo "nameserver 1.0.0.1" >> "$f"
done

mntroot ro
