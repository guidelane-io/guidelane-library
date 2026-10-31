# Install on macOS

You can install the server on macOS in two ways. The installer sets up the server as a system
service that starts at boot and runs under its own user. Homebrew is quicker to set up and
manages the server together with your other Homebrew packages.

## With the installer

```sh
curl -fsSL https://downloads.guidelane.io/library/install.sh | sudo sh
```

The installer works the same way as on Linux (see [Linux](install-linux.md)), with these
differences:

- The server's user is `_guidelane`, a hidden system user.
- The service is the launchd daemon `/Library/LaunchDaemons/io.guidelane.library.plist`, which
  starts at boot, before any user signs in.
- The log, which contains the setup code for the admin page, is `/var/log/guidelane-library.log`:

  ```sh
  sudo cat /var/log/guidelane-library.log
  ```

The `--name`, `--version`, `--dry-run`, `--uninstall` and `--purge` options work the same way.
Run the server's other commands as its user:

```sh
sudo -u _guidelane guidelane-library --config /var/lib/guidelane-library/library.toml invite
```

## With Homebrew

```sh
brew install guidelane-io/tap/guidelane-library
sudo brew services start --sudo-service-user "$(whoami)" guidelane-library
```

With `sudo`, the server runs as a launchd daemon that starts at boot, and `--sudo-service-user`
runs it as your user instead of root. Without `sudo`, it runs as a launch agent, which only runs
while you are signed in to the Mac.

The server stores its data in `$(brew --prefix)/var/guidelane-library`. Its log, which contains
the admin page's address and the setup code, is `$(brew --prefix)/var/log/guidelane-library.log`:

```sh
cat "$(brew --prefix)/var/log/guidelane-library.log"
```

Run the server's other commands with the same config file:

```sh
guidelane-library --config "$(brew --prefix)/var/guidelane-library/library.toml" invite
```

To upgrade, run `brew upgrade guidelane-library`, then `sudo brew services restart
guidelane-library`. To remove the server, run `sudo brew services stop guidelane-library` and
`brew uninstall guidelane-library`. Homebrew doesn't delete the data folder, so also delete
`$(brew --prefix)/var/guidelane-library` if you no longer need the guides.

## macOS firewall

If the macOS firewall is turned on, allow the server through it:

```sh
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/local/bin/guidelane-library
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /usr/local/bin/guidelane-library
```

With Homebrew, the binary is at `$(brew --prefix)/opt/guidelane-library/bin/guidelane-library`.

## Keep the Mac awake

When the Mac goes to sleep, devices can't connect to the server. To keep the Mac awake while it's
plugged in, run:

```sh
sudo pmset -c sleep 0
```

Then continue with [First start](first-start.md).
