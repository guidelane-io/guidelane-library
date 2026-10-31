# Guidelane Library

Guidelane Library is a lightweight server that hosts one shared library for
[Guidelane Studio](https://get.guidelane.io/studio/) guides inside your own network. Your team
connects Guidelane Studio to it, and everyone works from the same guides, kept in sync on every
device. Your guides stay on your network.

This repository contains the documentation, the installers, the Docker Compose files and the
Helm chart. The server itself is distributed as a binary and as a container image.

## Install

Choose the option that matches your infrastructure. Each option sets up the server the first time
it starts and restarts it automatically, for example after a reboot.

| Platform | Command | Guide |
|---|---|---|
| Docker | `docker run -d --name guidelane-library --restart unless-stopped -p 7443:7443 -v guidelane-library:/data ghcr.io/guidelane-io/guidelane-library` | [Docker](docs/install-docker.md) |
| Kubernetes | `helm install library oci://ghcr.io/guidelane-io/charts/guidelane-library` | [Kubernetes](docs/install-kubernetes.md) |
| Linux (systemd) | `curl -fsSL https://downloads.guidelane.io/library/install.sh \| sudo sh` | [Linux](docs/install-linux.md) |
| macOS | `brew install guidelane-io/tap/guidelane-library` | [macOS](docs/install-macos.md) |
| Windows | `guidelane-library.exe service install` | [Windows](docs/install-windows.md) |
| Proxmox VE | A script that creates a Debian container and installs the server in it | [Proxmox VE](docs/install-proxmox.md) |

When the server starts, it prints the address of its admin page, such as
`https://192.168.1.20:7443/admin`. Open that address in your browser and follow
[First start](docs/first-start.md).

## How it works

- The server listens on TCP port 7443 and uses HTTPS. It generates its own certificate, or you
  can give it one from your company's certificate authority.
- Guidelane Studio finds the server on the local network over mDNS. You can also connect by IP
  address or host name.
- You approve each device on the admin page, or send it a one-time invitation code. To connect
  many devices at once, use an enrollment code, which you can also deploy through managed
  settings.
- Guidelane Library is part of the Guidelane Studio Business plan. Devices need a Business
  license or an active trial to connect and open guides.
- The server stores all of its data in one folder: the guides, the connected devices, the
  enrollment codes, the server's name, the admin password and the server's private key. To back
  up the library, back up that folder.

## Documentation

- [Requirements](docs/requirements.md)
- Install: [Docker](docs/install-docker.md), [Kubernetes](docs/install-kubernetes.md),
  [Linux](docs/install-linux.md), [macOS](docs/install-macos.md),
  [Windows](docs/install-windows.md), [Proxmox VE](docs/install-proxmox.md)
- [First start](docs/first-start.md)
- [Joining devices](docs/joining-devices.md)
- [Rolling out to managed devices](docs/managed-devices.md)
- [Licenses](docs/licenses.md)
- [Networking](docs/networking.md)
- [Certificates](docs/certificates.md)
- [Configuration and commands](docs/configuration.md)
- [Backups, upgrades and removal](docs/operations.md)
- [Security](docs/security.md)
- [Troubleshooting](docs/troubleshooting.md)

## Versions

Releases use version numbers such as `1.0.1`. Container images are tagged with the version number
and with `latest`. The Helm chart uses the same version number as the server. To install a
specific version with the installer, pass `--version`. See
[Backups, upgrades and removal](docs/operations.md) for how to pin a version and how to upgrade.

The files for each release and their SHA-256 checksums are at
`https://downloads.guidelane.io/library/<version>/`. The current version is listed in
`https://downloads.guidelane.io/library/latest.json`. The download server keeps the three most
recent versions. Every version of the container image and the Helm chart stays available in the
registry.

## Support

Open an issue in this repository for any problems with the documentation, the installers or the
chart. For any problems with your license, write to support@guidelane.io.

## License

The documentation, scripts, Compose files and Helm chart in this repository are licensed under
the [MIT License](LICENSE). The Guidelane Library server, as a binary and as a container image,
is proprietary software under the [Guidelane Library license](EULA.txt), not the MIT License.
