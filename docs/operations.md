# Backups, upgrades and removal

## Back up

The server stores all of its data in one folder: the guides, the connected devices, the
enrollment codes, the server's name, the admin password and the server's private key. To back up
the library, back up that folder.

The server never edits a file in place. It writes a new copy next to the old one, flushes it to
disk, and then renames it over the old one. A backup taken while the server is running therefore
never contains a half-written file. For a backup that is consistent across all files, stop the
server, copy the folder and start it again, or take a snapshot of the volume.

| Install | Data folder |
|---|---|
| Docker | the volume mounted at `/data` |
| Kubernetes | the `library` folder on the StatefulSet's volume |
| Linux and macOS installer | `/var/lib/guidelane-library` |
| Homebrew | `$(brew --prefix)/var/guidelane-library` |
| Windows service | `C:\ProgramData\Guidelane\Library` |
| Proxmox VE container | `/var/lib/guidelane-library` in the container, or the container's backup |

The `tls` folder contains the server's private key, so protect the backup as well as you protect
the server.

## Restore

Stop the server, restore the data folder, and start the server again. If you restore the server
with its original key, every connected device stays connected. If the server gets a new key,
every device needs to join again.

To move the server to another host, install it there, stop it, replace its data folder with the
old one, and start it. If the new host has a different address, enter it on the Server tab under
"Address". Devices that connect by DNS name keep working once the name points to the new host.

## Upgrade

Upgrading keeps the data folder, and every device stays connected.

| Install | Upgrade |
|---|---|
| Docker | Pull the new image with `docker pull`, then recreate the container with the same volume. |
| Docker Compose | `docker compose pull`, then `docker compose up -d`. |
| Kubernetes | `helm upgrade` with the new chart version. |
| Linux and macOS installer | Run the installer again. |
| Homebrew | `brew upgrade guidelane-library`, then restart the service. |
| Windows | Run `service install` from the new version. |

## Pin a version

To control when you upgrade, specify a version everywhere:

- Docker: `ghcr.io/guidelane-io/guidelane-library:1.0.1` instead of `latest`.
- Kubernetes: `helm install … --version 1.0.1`.
- The installer: `--version 1.0.1`.

The files for each release and their checksums are at
`https://downloads.guidelane.io/library/<version>/`. A published version is never changed. The
download server keeps the three most recent versions, so the installer can only install those.
Every version of the container image and the Helm chart stays available in the registry.

## Health check

`guidelane-library health` connects to the server's port and checks that the server responds
with its own key. It exits with 0 if it does, so you can use it with monitoring tools:

```sh
guidelane-library --config /var/lib/guidelane-library/library.toml health
```

The Docker image uses it as its health check, and the Helm chart uses it for its probes.

## Logs

The server writes one line per request to stderr, with the method, the route pattern, the status
and the duration, such as `PUT /v1/guides/{id} 201 38ms`. It never logs a guide's ID or title, a
device's token, or the contents of a file.

| Install | Log |
|---|---|
| Docker | `docker logs guidelane-library` |
| Kubernetes | `kubectl logs statefulset/<release>-guidelane-library` |
| Linux | `journalctl -u guidelane-library` |
| macOS installer | `/var/log/guidelane-library.log` |
| Homebrew | `$(brew --prefix)/var/log/guidelane-library.log` |
| Windows | `C:\ProgramData\Guidelane\Library\library.log` |

## Remove

| Install | Remove |
|---|---|
| Docker | `docker rm -f guidelane-library`, then `docker volume rm guidelane-library` to delete the guides. |
| Kubernetes | `helm uninstall <release>`. The volume stays until you delete its PersistentVolumeClaim. |
| Linux and macOS installer | Run the installer with `--uninstall`. Add `--purge` to delete the data folder. |
| Homebrew | `brew services stop`, `brew uninstall`, then delete the data folder. |
| Windows | `service uninstall`, then delete `C:\ProgramData\Guidelane\Library`. |
