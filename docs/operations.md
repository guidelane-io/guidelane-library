# Backups, upgrades and removal

## Back up

Everything the server keeps is in its data folder: the guides, the devices that joined, the
enrollment codes, the server's name and the admin password. Back up that folder and you have
backed up the library.

The server replaces every file in it whole. It writes the new file beside the old one, flushes it
to the disk, then renames it over the old one. A copy taken while the server runs holds each file
as it was before or after a change, but never partway through one. For a backup that is
consistent across files, stop the server, copy the folder, and start it again, or take a
snapshot of the volume.

| Install | Data folder |
|---|---|
| Docker | the volume mounted at `/data` |
| Kubernetes | the `library` folder on the StatefulSet's volume |
| Linux and macOS installer | `/var/lib/guidelane-library` |
| Homebrew | `$(brew --prefix)/var/guidelane-library` |
| Windows service | `C:\ProgramData\Guidelane\Library` |
| Proxmox VE container | `/var/lib/guidelane-library` in the container, or the container's backup |

The `tls` folder holds the server's private key, so keep the backup as private as the server.

## Restore

Stop the server, put the data folder back, and start the server. A server restored with its own
key keeps every device that joined. A server with a new key needs every device to join again.

To move the server to another machine, install it there, stop it, replace its data folder with
the old one, and start it. If the new machine has another address, enter it on the Server tab
under "Address". Devices that reach the server by a DNS name keep working once the name points
to the new machine.

## Upgrade

Upgrading keeps the data folder, and every device stays joined.

| Install | Upgrade |
|---|---|
| Docker | `docker pull` the image, and create the container again with the same volume. |
| Docker Compose | `docker compose pull`, then `docker compose up -d`. |
| Kubernetes | `helm upgrade` with the new chart version. |
| Linux and macOS installer | Run the installer again. |
| Homebrew | `brew upgrade guidelane-library`, then restart the service. |
| Windows | Run the new version's `service install`. |

## Pin a version

To upgrade only when you choose, name a version everywhere:

- Docker: `ghcr.io/guidelane-io/guidelane-library:0.1.0` rather than `latest`.
- Kubernetes: `helm install … --version 0.1.0`.
- The installer: `--version 0.1.0`.

Each release's files and their checksums are at `https://downloads.guidelane.io/library/<version>/`.
A published version is never replaced.

## Check that it runs

`guidelane-library health` connects to the server's port and checks that the server answers
with its own key. It exits with 0 when it does, so monitoring tools can run it:

```sh
guidelane-library --config /var/lib/guidelane-library/library.toml health
```

The Docker image runs it as its health check, and the Helm chart runs it as its probes.

## Logs

The server writes one line for each request to stderr: the method, the route's pattern, the
status and the time it took, such as `PUT /v1/guides/{id} 201 38ms`. It never logs a guide's id
or title, a device's token or anything a file holds.

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
| Linux and macOS installer | The installer with `--uninstall`, and `--purge` to delete the data folder. |
| Homebrew | `brew services stop`, `brew uninstall`, then delete the data folder. |
| Windows | `service uninstall`, then delete `C:\ProgramData\Guidelane\Library`. |
