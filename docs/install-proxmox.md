# Install on Proxmox VE

The simplest home for the server on Proxmox VE is a small unprivileged Debian container on your
network's bridge. The container has its own address on your network, so Guidelane Studio finds
the server there over mDNS. The Linux installer sets the server up as a service in the container.

## With the script

On the Proxmox VE host, as root, run:

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/guidelane-io/guidelane-library/master/deploy/proxmox/create-lxc.sh)"
```

The script, [`deploy/proxmox/create-lxc.sh`](../deploy/proxmox/create-lxc.sh), does this:

1. It downloads the newest Debian container template, if the host does not have it yet.
2. It creates an unprivileged container with 1 core, 1 GB of memory and an 8 GB disk on
   `vmbr0`, with an address from DHCP. The container starts with the host.
3. It runs the [Linux installer](install-linux.md) in the container.

To change what the script creates, set environment variables before `bash`:

```sh
LIBRARY_NAME="Acme library" CTID=150 IP=192.168.1.20/24 GATEWAY=192.168.1.1 \
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/guidelane-io/guidelane-library/master/deploy/proxmox/create-lxc.sh)"
```

| Variable | Default | What it sets |
|---|---|---|
| `LIBRARY_NAME` | `Guidelane library` | The server's name on your network. |
| `CTID` | the next free ID | The container's ID. |
| `CT_HOSTNAME` | `guidelane-library` | The container's host name. |
| `BRIDGE` | `vmbr0` | The bridge the container joins. |
| `VLAN` | none | A VLAN tag for the container's network. |
| `IP` | `dhcp` | `dhcp`, or a static address such as `192.168.1.20/24`. |
| `GATEWAY` | none | The gateway, with a static address. |
| `STORAGE` | the first storage for containers | Where the container's disk goes, such as `local-lvm` or `local-zfs`. |
| `TEMPLATE_STORAGE` | the first storage for templates | Where the Debian template goes, such as `local`. |
| `DISK_GB` | `8` | The disk's size in GB. |
| `MEMORY_MB` | `1024` | The container's memory in MB. |
| `CORES` | `1` | The container's CPU cores. |

When the script finishes, read the setup code for the admin page:

```sh
pct exec <ctid> -- journalctl -u guidelane-library
```

Then go on with [First start](first-start.md).

## By hand

1. In the Proxmox VE web interface, choose "Create CT". Leave "Unprivileged container" on, and
   pick a Debian template. Give it 1 core, 1 GB of memory and an 8 GB disk, and put its network
   on your LAN's bridge.
2. Start the container, open its console, and run:

   ```sh
   apt-get update && apt-get install -y curl ca-certificates
   curl -fsSL https://downloads.guidelane.io/library/install.sh | sh -s -- --name "Acme library"
   ```

   The console already runs as root, so the installer needs no `sudo`.
3. Read the setup code with `journalctl -u guidelane-library`.

## In a virtual machine

If you would rather run containers, create a Debian or Ubuntu virtual machine, install Docker,
and follow [Docker](install-docker.md) with `--network host`, so the server can announce itself
on your network.

## Backups

Include the container in a Proxmox VE backup job, or back up
`/var/lib/guidelane-library` inside it. [Backups, upgrades and removal](operations.md) has
more.
