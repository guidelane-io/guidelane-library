# Install on Linux

## With the installer

On a Linux host with systemd, run:

```sh
curl -fsSL https://downloads.guidelane.io/library/install.sh | sudo sh
```

To set the server's name, or to install a specific version:

```sh
curl -fsSL https://downloads.guidelane.io/library/install.sh | sudo sh -s -- --name "Acme library"
curl -fsSL https://downloads.guidelane.io/library/install.sh | sudo sh -s -- --version 1.0.1
```

The installer:

1. Downloads the server for your host's architecture and verifies its SHA-256 checksum against
   the published one. Without `--version`, it installs the latest release.
2. Installs the binary to `/usr/local/bin/guidelane-library`.
3. Creates the system user `guidelane` and the data folder `/var/lib/guidelane-library`, which
   only that user can open.
4. Sets up the server in the data folder, if it isn't set up yet.
5. Writes the systemd unit `guidelane-library.service`, which starts the server at boot, and
   starts the service.
6. Prints the address of the admin page.

The setup code for the admin page is in the server's log:

```sh
sudo journalctl -u guidelane-library
```

Then continue with [First start](first-start.md).

To review the installer before you run it, download it first. It is also in this repository as
[`install.sh`](../install.sh).

```sh
curl -fsSLO https://downloads.guidelane.io/library/install.sh
less install.sh
sudo sh install.sh --dry-run
```

With `--dry-run`, the installer downloads and verifies the server and lists every change it would
make, without changing anything.

### Run the server's commands

Run commands as the server's user, so that the server can still read the files they create:

```sh
sudo -u guidelane guidelane-library --config /var/lib/guidelane-library/library.toml invite
sudo -u guidelane guidelane-library --config /var/lib/guidelane-library/library.toml devices
```

### Upgrade

Run the installer again. It replaces the binary, restarts the service, and doesn't change the
data folder.

### Remove

```sh
curl -fsSL https://downloads.guidelane.io/library/install.sh | sudo sh -s -- --uninstall
```

This stops and removes the service and the binary, and keeps the data folder. Add `--purge` to
also remove the data folder and the `guidelane` user. This deletes all guides.

## Manual install

Download the package for your architecture from `https://downloads.guidelane.io/library/<version>/`
and verify it against the `SHA256SUMS` file in the same folder:

```sh
version=1.0.1
target=x86_64-unknown-linux-musl   # or aarch64-unknown-linux-musl
curl -fsSLO "https://downloads.guidelane.io/library/$version/guidelane-library-$version-$target.tar.gz"
curl -fsSLO "https://downloads.guidelane.io/library/$version/SHA256SUMS"
sha256sum --check --ignore-missing SHA256SUMS
tar -xzf "guidelane-library-$version-$target.tar.gz"
sudo install -m 0755 "guidelane-library-$version-$target/guidelane-library" /usr/local/bin/
```

Create a user and a data folder for the server:

```sh
sudo useradd --system --user-group --home-dir /var/lib/guidelane-library --no-create-home \
  --shell /usr/sbin/nologin guidelane
sudo install -d -m 0700 -o guidelane -g guidelane /var/lib/guidelane-library
```

Save this unit as `/etc/systemd/system/guidelane-library.service`:

```ini
[Unit]
Description=Guidelane Library
After=network-online.target
Wants=network-online.target

[Service]
User=guidelane
Group=guidelane
ExecStart=/usr/local/bin/guidelane-library --config /var/lib/guidelane-library/library.toml run --init --data .
Restart=on-failure
NoNewPrivileges=yes
ProtectSystem=strict
ProtectHome=yes
PrivateTmp=yes
ReadWritePaths=/var/lib/guidelane-library

[Install]
WantedBy=multi-user.target
```

`run --init` sets up the server on first start and runs the existing setup on every later
start. Then start the service:

```sh
sudo systemctl daemon-reload
sudo systemctl enable --now guidelane-library
sudo journalctl -u guidelane-library
```

## Without systemd

On a host without systemd, such as Alpine Linux with OpenRC, run the same command from your
service manager, as the server's user:

```sh
guidelane-library --config /var/lib/guidelane-library/library.toml run --init --data .
```

The server writes its log to stderr and runs in the foreground until it is stopped.

## Firewall

Allow TCP port 7443 from the networks your devices are on. With `ufw`:

```sh
sudo ufw allow from 192.168.1.0/24 to any port 7443 proto tcp
```

With `firewalld`:

```sh
sudo firewall-cmd --permanent --add-port=7443/tcp && sudo firewall-cmd --reload
```

For the server's mDNS announcement, also allow UDP port 5353 (`firewall-cmd --add-service=mdns`).
