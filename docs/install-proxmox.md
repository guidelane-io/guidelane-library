# Install on Proxmox VE

The easiest way to run the server on Proxmox VE is in a small unprivileged Debian container on
your network's bridge. The container gets its own address on your network, so Guidelane Studio
can find the server over mDNS. The Linux installer sets up the server as a service inside the
container.

## With the script

On the Proxmox VE host, run as root:

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/guidelane-io/guidelane-library/master/deploy/proxmox/create-lxc.sh)"
```

The script, [`deploy/proxmox/create-lxc.sh`](../deploy/proxmox/create-lxc.sh):

1. Downloads the latest Debian container template, if the host doesn't have it yet.
2. Creates an unprivileged container with 1 core, 1 GB of memory and an 8 GB disk on `vmbr0`,
   with an address from DHCP. The container starts automatically with the host.
3. Runs the [Linux installer](install-linux.md) inside the container.

To change what the script creates, set environment variables before `bash`:

```sh
LIBRARY_NAME="Acme library" CTID=150 IP=192.168.1.20/24 GATEWAY=192.168.1.1 \
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/guidelane-io/guidelane-library/master/deploy/proxmox/create-lxc.sh)"
```

| Variable | Default | Description |
|---|---|---|
| `LIBRARY_NAME` | `Guidelane library` | The server's name on your network. |
| `CTID` | the next free ID | The container's ID. |
| `CT_HOSTNAME` | `guidelane-library` | The container's host name. |
| `BRIDGE` | `vmbr0` | The bridge the container connects to. |
| `VLAN` | none | A VLAN tag for the container's network. |
| `IP` | `dhcp` | `dhcp`, or a static address such as `192.168.1.20/24`. |
| `GATEWAY` | none | The gateway, for a static address. |
| `STORAGE` | the first storage for containers | The storage for the container's disk, such as `local-lvm` or `local-zfs`. |
| `TEMPLATE_STORAGE` | the first storage for templates | The storage for the Debian template, such as `local`. |
| `DISK_GB` | `8` | The disk size in GB. |
| `MEMORY_MB` | `1024` | The container's memory in MB. |
| `CORES` | `1` | The container's CPU cores. |

When the script has finished, get the setup code for the admin page:

```sh
pct exec <ctid> -- journalctl -u guidelane-library
```

Then continue with [First start](first-start.md).

## Manual install

1. In the Proxmox VE web interface, choose "Create CT". Keep "Unprivileged container" turned on,
   and choose a Debian template. Give the container 1 core, 1 GB of memory and an 8 GB disk, and
   connect it to your LAN's bridge.
2. Start the container, open its console, and run:

   ```sh
   apt-get update && apt-get install -y curl ca-certificates
   curl -fsSL https://downloads.guidelane.io/library/install.sh | sh -s -- --name "Acme library"
   ```

   The console already runs as root, so the installer doesn't need `sudo`.
3. Get the setup code with `journalctl -u guidelane-library`.

## Upgrade

On the Proxmox VE host, run the installer again inside the container:

```sh
pct exec <ctid> -- sh -c 'curl -fsSL https://downloads.guidelane.io/library/install.sh | sh'
```

The installer replaces the server, restarts the service, and doesn't change the data folder.
Every device stays connected.

## In a virtual machine

If you prefer to run containers, create a Debian or Ubuntu virtual machine, install Docker, and
follow [Docker](install-docker.md) with `--network host`, so the server can announce itself on
your network.

## Backups

Include the container in a Proxmox VE backup job, or back up `/var/lib/guidelane-library`
inside the container. See [Backups, upgrades and removal](operations.md) for more.
