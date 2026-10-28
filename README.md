# Guidelane Library

Guidelane Library is a small server that keeps one shared library of guides for
[Guidelane Studio](https://www.guidelane.io). You run it on your own network. Each
person's Guidelane Studio joins it, and every device that joined reads and saves the same guides.
The guides never leave your network.

This repository holds the documentation, the installers, the Docker Compose files and the Helm
chart. The server itself is distributed as a binary and as a container image.

## Install

Pick the way that fits your infrastructure. Each one sets the server up on first start and
keeps it running.

| Platform | Command | Guide |
|---|---|---|
| Docker | `docker run -d -p 7443:7443 -v guidelane-library:/data ghcr.io/guidelane-io/guidelane-library` | [Docker](docs/install-docker.md) |
| Kubernetes | `helm install library oci://ghcr.io/guidelane-io/charts/guidelane-library` | [Kubernetes](docs/install-kubernetes.md) |
| Linux (systemd) | `curl -fsSL https://downloads.guidelane.io/library/install.sh \| sudo sh` | [Linux](docs/install-linux.md) |
| macOS | `brew install guidelane-io/tap/guidelane-library` | [macOS](docs/install-macos.md) |
| Windows | `guidelane-library.exe service install` | [Windows](docs/install-windows.md) |
| Proxmox VE | A script that creates a Debian container and installs the server in it | [Proxmox VE](docs/install-proxmox.md) |

Then open the admin page the server prints, such as `https://192.168.1.20:7443/admin`, and
follow [First start](docs/first-start.md).

## How it works

- The server listens on TCP port 7443 and serves HTTPS with a certificate it creates for itself,
  or with one from your company's certificate authority.
- Guidelane Studio finds the server on the local network over mDNS, or reaches it by its address.
- A device joins with your approval on the admin page, with a one-time invitation, or with an
  enrollment code that you put in its managed settings.
- Guidelane Library is part of the Guidelane Studio Business plan. A device needs a Business
  license, or a trial that has not ended, to join it and open its guides.
- Everything the server keeps is in one data folder: the guides, the devices that joined and the
  admin page's password. Back up that folder and you have backed up the library.

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

Every release has a version such as `0.1.0`. The image is tagged with each version and with
`latest`. The chart has the same version as the server, and the installer takes `--version` to
install a given one. [Backups, upgrades and removal](docs/operations.md) says how to pin a
version and how to upgrade.

Each release's files and their SHA-256 checksums are at
`https://downloads.guidelane.io/library/<version>/`, and
`https://downloads.guidelane.io/library/latest.json` names the latest one.

## Support

Open an issue in this repository for a problem with the documentation, the installers or the
chart. For a problem with your license, write to support@guidelane.io.

## License

The documentation, scripts, Compose files and Helm chart in this repository are under the
[MIT License](LICENSE). The Guidelane Library server, as a binary and as a container image, is
proprietary software under the [Guidelane Library license](EULA.txt), not the MIT License.
