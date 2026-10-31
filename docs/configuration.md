# Configuration and commands

## The config file

The server reads one config file, `library.toml`, which is created during setup:

```toml
listen = "0.0.0.0:7443"
data = "."
certificate = "./tls/certificate.pem"
key = "./tls/key.pem"
```

| Setting | Description |
|---|---|
| `listen` | The IP address and port the server listens on. `0.0.0.0` means all of the host's IPv4 addresses. |
| `data` | The data folder. |
| `certificate` | The server's certificate in PEM format, with its chain. |
| `key` | The certificate's private key in PEM format. |

Relative paths are resolved from the folder that contains the config file. Restart the server
after you change the file.

The location of the config file depends on how you installed the server:

| Install | Config file |
|---|---|
| Docker | `/data/library.toml` in the volume |
| Kubernetes | `/data/library.toml` on the volume, or the chart's own file when you set `tls.secretName` |
| Linux and macOS installer | `/var/lib/guidelane-library/library.toml` |
| Homebrew | `$(brew --prefix)/var/guidelane-library/library.toml` |
| Windows service | `C:\ProgramData\Guidelane\Library\library.toml` |

The server's name, its address and the admin password are not in the config file. You set them
on the admin page, and the server stores them in `server.json` in the data folder.

## Commands

If the config file is not `library.toml` in the current folder, pass `--config <file>` to every
command.

| Command | Description |
|---|---|
| `init [--listen <address>] [--data <folder>] [--name <name>]` | Creates the config file, the data folder and the server's certificate. It never overwrites anything, and stops if any of them already exists. |
| `run` | Starts the server. It keeps running until it is stopped. |
| `run --init [--listen …] [--data …] [--name …]` | If there is no config file yet, sets up the server like `init` and then starts it. If there is one, starts the server with it. The image, the chart and Homebrew use this command. |
| `health` | Checks that the server is running and responds with its own key. Exits with 0 if it does. |
| `invite` | Creates an invitation code for one device, valid for 24 hours. |
| `devices` | Lists the connected devices. |
| `revoke <name>` | Disconnects a device. Put the name in quotes if it contains spaces. |
| `admin-reset` | Removes the admin password. The server prints a new setup code the next time it starts. |
| `service install` | Windows only: installs or upgrades the server as the "Guidelane Library" service. |
| `service uninstall` | Windows only: removes the service. |

Run commands as the server's user, so that the server can still read the files they create.

## Installer options

```sh
curl -fsSL https://downloads.guidelane.io/library/install.sh | sudo sh -s -- <options>
```

| Option | Description |
|---|---|
| `--name <name>` | The server's name, used when the server is first set up. |
| `--version <x.y.z>` | Installs this version instead of the latest one. |
| `--dry-run` | Downloads and verifies the server and shows what the installer would change, without changing anything. |
| `--uninstall` | Removes the service and the binary, and keeps the data folder. |
| `--purge` | With `--uninstall`, also removes the data folder and the server's user. |

To download from a different location, such as an internal mirror of
`https://downloads.guidelane.io/library/`, set `GUIDELANE_DOWNLOADS_URL`.

## Contents of the data folder

```text
guides/<id>.gdl     one file per guide, as the device uploaded it
index.json          the ID, title, step count, time, ETag and cover hash of each guide
devices.json        each device's name, when it joined, the SHA-256 hash of its token, and
                    the license certificate it last reported
pairing.json        the unused invitation and enrollment codes, as hashes
server.json         the server's name, its address, and the hash of the admin password
staging/            uploads that are still arriving or being checked
quarantine/         guide files that failed their checks when the index was rebuilt
tls/                the server's self-generated certificate and its private key
```

The server can always rebuild `index.json` from the guide files. It does this at startup if the
file is missing, can't be read, or doesn't match the `guides` folder.

Only run one server per data folder.
