# Install on macOS

There are two ways to install the server on macOS. The installer sets the server up as a system
service that runs at boot under a user of its own. Homebrew is quicker to set up, and keeps the
server with your other Homebrew packages.

## With the installer

```sh
curl -fsSL https://downloads.guidelane.io/library/install.sh | sudo sh
```

The installer works as it does on Linux (see [Linux](install-linux.md)), with these differences:

- The server's user is `_guidelane`, a hidden system user.
- The service is the launchd daemon `/Library/LaunchDaemons/io.guidelane.library.plist`, which
  starts at boot, before anyone signs in.
- The log, with the setup code for the admin page, is `/var/log/guidelane-library.log`:

  ```sh
  sudo cat /var/log/guidelane-library.log
  ```

The same `--name`, `--version`, `--dry-run`, `--uninstall` and `--purge` options apply. Run the
server's other commands as its user:

```sh
sudo -u _guidelane guidelane-library --config /var/lib/guidelane-library/library.toml invite
```

## With Homebrew

```sh
brew install guidelane-io/tap/guidelane-library
sudo brew services start --sudo-service-user "$(whoami)" guidelane-library
```

With `sudo`, the server runs as a launchd daemon that starts at boot, and
`--sudo-service-user` keeps it running as your user rather than as root. Without `sudo`, it
runs as a launch agent, which runs only while you are signed in to the Mac.

The server keeps its data in `$(brew --prefix)/var/guidelane-library`. Its log, with the address
of the admin page and its setup code, is `$(brew --prefix)/var/log/guidelane-library.log`:

```sh
cat "$(brew --prefix)/var/log/guidelane-library.log"
```

Run the server's other commands with the same config file:

```sh
guidelane-library --config "$(brew --prefix)/var/guidelane-library/library.toml" invite
```

To upgrade, run `brew upgrade guidelane-library`, then `sudo brew services restart
guidelane-library`. To remove it, run `sudo brew services stop guidelane-library` and `brew
uninstall guidelane-library`. Homebrew leaves the data folder, so delete
`$(brew --prefix)/var/guidelane-library` too if you no longer need the guides.

## The Mac's firewall

If the Mac's firewall is on, allow the server through it:

```sh
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/local/bin/guidelane-library
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /usr/local/bin/guidelane-library
```

With Homebrew, the binary is at `$(brew --prefix)/opt/guidelane-library/bin/guidelane-library`.

## Keep the Mac awake

A Mac that sleeps stops answering devices. To keep it awake while it is plugged in, run:

```sh
sudo pmset -c sleep 0
```

Then go on with [First start](first-start.md).
