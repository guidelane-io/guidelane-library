# Configuration and commands

## The config file

The server reads one config file, `library.toml`. Setting the server up creates it:

```toml
listen = "0.0.0.0:7443"
data = "."
certificate = "./tls/certificate.pem"
key = "./tls/key.pem"
```

| Setting | What it is |
|---|---|
| `listen` | The IP address and port the server listens on. `0.0.0.0` is every IPv4 address of the machine. |
| `data` | The data folder. |
| `certificate` | The server's certificate, as PEM, with its chain. |
| `key` | The certificate's private key, as PEM. |

A relative path is read from the config file's own folder. Restart the server after you change
the file.

Each kind of install keeps the config file in a different place:

| Install | Config file |
|---|---|
| Docker | `/data/library.toml` in the volume |
| Kubernetes | `/data/library.toml` on the volume, or the chart's own with `tls.secretName` |
| Linux and macOS installer | `/var/lib/guidelane-library/library.toml` |
| Homebrew | `$(brew --prefix)/var/guidelane-library/library.toml` |
| Windows service | `C:\ProgramData\Guidelane\Library\library.toml` |

The server's name, its address and the admin password are not in the file. You set them on the
admin page, and the server keeps them in `server.json` in the data folder.

## Commands

Every command takes `--config <file>` when the config file is not `library.toml` in the current
folder.

| Command | What it does |
|---|---|
| `init [--listen <address>] [--data <folder>] [--name <name>]` | Creates the config file, the data folder and the server's certificate. It replaces nothing, and stops if any of them exists. |
| `run` | Starts the server. It runs until it is stopped. |
| `run --init [--listen …] [--data …] [--name …]` | When there is no config file yet, sets the server up as `init` does, then starts it. With a config file, starts the server as it is. This is what the image, the chart and Homebrew run. |
| `health` | Checks that the server is running and answers with its own key. It exits with 0 when it does. |
| `invite` | Creates an invitation code for one device, good for 24 hours. |
| `devices` | Lists the devices that joined. |
| `revoke <name>` | Disconnects a device. Put the name in quotes if it has spaces. |
| `admin-reset` | Removes the admin password. The next start prints a new setup code. |
| `service install` | Windows only: installs the server as the service "Guidelane Library", or upgrades it. |
| `service uninstall` | Windows only: removes the service. |

Run commands as the server's own user, so that the server can still read the files they write.

## The installer's options

```sh
curl -fsSL https://downloads.guidelane.io/library/install.sh | sudo sh -s -- <options>
```

| Option | What it does |
|---|---|
| `--name <name>` | The server's name when it is first set up. |
| `--version <x.y.z>` | Installs that version rather than the latest. |
| `--dry-run` | Downloads and checks the server, and says what the installer would change, without changing anything. |
| `--uninstall` | Removes the service and the binary, and keeps the data folder. |
| `--purge` | With `--uninstall`, also removes the data folder and the server's user. |

Set `GUIDELANE_DOWNLOADS_URL` to make the installer download from another address, such as an
internal mirror that holds a copy of `https://downloads.guidelane.io/library/`.

## What the data folder holds

```text
guides/<id>.gdl     one file per guide, as the device saved it
index.json          the id, title, step count, time, etag and cover hash of each guide
devices.json        each device's name, when it joined, the SHA-256 of its token, and the
                    license certificate it last reported
pairing.json        the invitations and enrollment codes not used up yet, as hashes
server.json         the server's name, its address, and the hash of the admin password
staging/            uploads while they arrive and are checked
quarantine/         guide files that failed their checks when the index was rebuilt
tls/                the server's own certificate and its key
```

The server can always rebuild `index.json` from the guide files. It does this when it starts, if
the file is missing, unreadable, or disagrees with the `guides` folder.

Run one server per data folder.
