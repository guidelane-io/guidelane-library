#!/usr/bin/env bash
# Creates a Debian container on a Proxmox VE host and installs Guidelane Library in it. Run it on
# the host, as root:
#
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/guidelane-io/guidelane-library/master/deploy/proxmox/create-lxc.sh)"
#
# Change what it creates with these environment variables, set before bash:
#
#   LIBRARY_NAME      The server's name on your network. "Guidelane library" unless set.
#   CTID              The container's ID. The next free ID unless set.
#   CT_HOSTNAME       The container's host name. guidelane-library unless set.
#   BRIDGE            The bridge the container joins. vmbr0 unless set.
#   VLAN              A VLAN tag for the container's network, if your network uses one.
#   IP                dhcp, or a static address such as 192.168.1.20/24. dhcp unless set.
#   GATEWAY           The gateway for a static address.
#   STORAGE           The storage for the container's disk. The first that holds containers.
#   TEMPLATE_STORAGE  The storage for the Debian template. The first that holds templates.
#   DISK_GB           The disk's size in GB. 8 unless set.
#   MEMORY_MB         The container's memory in MB. 1024 unless set.
#   CORES             The container's CPU cores. 1 unless set.
#
# The container is unprivileged, starts with the host, and is on the bridge like any other
# computer on your network, so Guidelane Studio finds the server there over mDNS.

set -euo pipefail

fail() {
	printf '%s\n' "$*" >&2
	exit 1
}

command -v pct >/dev/null 2>&1 || fail "Run this on a Proxmox VE host. pct is not here."
[ "$(id -u)" -eq 0 ] || fail "Run this as root."

LIBRARY_NAME=${LIBRARY_NAME:-Guidelane library}
CTID=${CTID:-$(pvesh get /cluster/nextid)}
CT_HOSTNAME=${CT_HOSTNAME:-guidelane-library}
BRIDGE=${BRIDGE:-vmbr0}
VLAN=${VLAN:-}
IP=${IP:-dhcp}
GATEWAY=${GATEWAY:-}
STORAGE=${STORAGE:-$(pvesm status -content rootdir | awk 'NR > 1 { print $1; exit }')}
TEMPLATE_STORAGE=${TEMPLATE_STORAGE:-$(pvesm status -content vztmpl | awk 'NR > 1 { print $1; exit }')}
DISK_GB=${DISK_GB:-8}
MEMORY_MB=${MEMORY_MB:-1024}
CORES=${CORES:-1}

[ -n "$STORAGE" ] || fail "No storage on this host holds containers. Set STORAGE."
[ -n "$TEMPLATE_STORAGE" ] || fail "No storage on this host holds templates. Set TEMPLATE_STORAGE."
if pct status "$CTID" >/dev/null 2>&1; then
	fail "A container with the ID $CTID exists already. Set CTID to a free one."
fi

echo "Looking for the newest Debian template."
pveam update >/dev/null
template=$(pveam available --section system | awk '{ print $2 }' |
	grep -E '^debian-[0-9]+-standard_' | sort -V | tail -n 1)
[ -n "$template" ] || fail "Proxmox VE lists no Debian template."
if ! pveam list "$TEMPLATE_STORAGE" | grep -q "$template"; then
	echo "Downloading $template to $TEMPLATE_STORAGE."
	pveam download "$TEMPLATE_STORAGE" "$template" >/dev/null
fi

network="name=eth0,bridge=$BRIDGE,ip=$IP"
if [ -n "$GATEWAY" ]; then network="$network,gw=$GATEWAY"; fi
if [ -n "$VLAN" ]; then network="$network,tag=$VLAN"; fi

echo "Creating container $CTID ($CT_HOSTNAME) on $STORAGE."
pct create "$CTID" "$TEMPLATE_STORAGE:vztmpl/$template" \
	--hostname "$CT_HOSTNAME" \
	--ostype debian \
	--unprivileged 1 \
	--features nesting=1 \
	--cores "$CORES" \
	--memory "$MEMORY_MB" \
	--swap 512 \
	--rootfs "$STORAGE:$DISK_GB" \
	--net0 "$network" \
	--onboot 1 \
	--start 1 >/dev/null

echo "Waiting for the container's network."
for _ in $(seq 1 60); do
	if pct exec "$CTID" -- getent hosts downloads.guidelane.io >/dev/null 2>&1; then
		break
	fi
	sleep 2
done
pct exec "$CTID" -- getent hosts downloads.guidelane.io >/dev/null 2>&1 ||
	fail "Container $CTID cannot reach downloads.guidelane.io. Check its network, then run the installer in it."

echo "Installing Guidelane Library in container $CTID."
pct exec "$CTID" -- env DEBIAN_FRONTEND=noninteractive sh -c \
	'apt-get update -qq && apt-get install -y -qq curl ca-certificates >/dev/null'
# The name reaches the installer as a variable of the container's shell, so it is never re-parsed.
# shellcheck disable=SC2016
pct exec "$CTID" -- env LIBRARY_NAME="$LIBRARY_NAME" sh -c \
	'curl -fsSL https://downloads.guidelane.io/library/install.sh | sh -s -- --name "$LIBRARY_NAME"'

echo
echo "Guidelane Library runs in container $CTID."
echo "To read the admin page's setup code, run: pct exec $CTID -- journalctl -u guidelane-library"
