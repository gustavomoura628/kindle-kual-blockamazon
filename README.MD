# blockamazon - KUAL Extension

De-Amazonify a jailbroken Kindle. Three layers of blocking, all reversible.

Based on [kindle-kual-blockamazon](https://github.com/mitchellurgero/kindle-kual-blockamazon), heavily modified.

> **WARNING:** This was built for and tested on a **Kindle Basic 8th gen (2016), firmware 5.14.3.2** (serial prefix G000K9). The upstart service names, DNS config paths, and blocked domains were extracted directly from this specific device. **Other models or firmware versions may have different service names, different paths, or additional services not covered here.** If you're on a different device, audit the scripts before running them.

## What it does

### 1. Sinkholes Amazon domains via `/etc/hosts`

Overwrites `/etc/hosts` to redirect Amazon domains to `0.0.0.0`:

```
amazon.com
www.amazon.com
kindle.amazon.com
kindle-digital-delivery.amazon.com
kindle-wifi-cn.amazon.cn
kindleatt1.amazon.com
a4k.amazon.com
www.audible.com
device-metrics-us.amazon.com
device-metrics-us-2.amazon.com
device-metrics-us-ud.amazon.com
device-messaging-na.amazon.com
dcm-device-usage-v3.amazon.com
softwareupdates.amazon.com
updates.amazon.com
firmwaredownloads.s3.amazonaws.com
amzdigitaldownloads.edgesuite.net
s3.amazonaws.com
spectrum.s3.amazonaws.com
todo-ta-g7g.amazon.com
todo-g7g.amazon.com
firs-ta-g7g.amazon.com
dogvgb9ujhybx.cloudfront.net
kindle-time.amazon.com
ntp-g7g.amazon.com
dns.kindle.com
```

### 2. Disables Amazon upstart services

Renames `/etc/upstart/*.conf` to `*.conf.disabled` so they don't start on boot:

| Service | What it does |
|---------|-------------|
| `otaupd` | OTA firmware updates |
| `otav3` | OTA updates v3 |
| `todo` | Whispersync / task queue |
| `clickstream_logging` | Clickstream telemetry |
| `fastmetrics` | Device metrics |
| `stored` | Amazon store daemon |
| `whisperstore` | Whisperstore (book delivery) |
| `dynconfig` | Dynamic config fetched from Amazon |
| `progressivedownloads` | Kindle content download manager |
| `register_oobe` | Registration prompt |

### 3. Replaces DNS configs

Comments out Amazon/Neustar nameservers in all `/etc/resolv.d/resolv.conf.*` files and appends Cloudflare DNS (`1.1.1.1`, `1.0.0.1`). Original entries are preserved as comments.

The stock configs point to:
- `207.171.165.149/150` — Amazon public DNS
- `156.154.70.1/71.1` — Neustar DNS (Amazon fallback)
- `172.22.130.x`, `10.189.9.x` — Amazon internal DNS

## KUAL Menu

| Button | Hosts | Services | DNS |
|--------|-------|----------|-----|
| **Block Amazon** | Block all | Disable | Cloudflare |
| **Block Amazon (allow S3)** | Block all except S3 | Disable | Cloudflare |
| **Unblock Everything** | Stock | Enable | Restore Amazon |
| **Disable Amazon Services** | No change | Disable | No change |
| **Enable Amazon Services** | No change | Enable | No change |

## Prerequisites

- Jailbroken Kindle (e.g. via [WinterBreak](https://kindlemodding.org/jailbreaking/WinterBreak/))
- [KUAL](https://kindlemodding.org/jailbreaking/post-jailbreak/installing-kual-mrpi/) installed
- [renameotabin](https://kindlemodding.org/jailbreaking/post-jailbreak/disable-ota.html) installed (blocks OTA updates at the binary level — this extension blocks at the DNS/service level as an additional layer)

## Install

1. Download or clone this repo.
2. Connect your Kindle via USB (make sure USBNetwork is off so it mounts as storage).
3. Copy the `blockamazon/` folder to the `extensions/` folder on your Kindle (that's `/mnt/us/extensions/` on the device).
4. Eject the Kindle.
5. Open KUAL on the Kindle and tap **"Block Amazon"** under "Network Control".
6. Reboot the Kindle to stop already-running Amazon services.

## Limitations

- `CONFIG_NETFILTER` is **not compiled** into the Kindle 8th gen kernel, so `iptables` is impossible. Blocking is DNS/hosts-only.
- Amazon has some hardcoded IPs in its configs (`207.171.165.149/150`, `156.154.70.1/71.1`), but the services that use them are disabled via upstart, and the DNS configs pointing to them are replaced. These IPs are not a practical concern with all three layers active.
- All operations are idempotent (safe to run multiple times) and persist across reboots.
- The "Unblock Everything" button fully reverses all changes (uncomments DNS, re-enables services, restores stock hosts).
