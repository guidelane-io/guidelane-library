# Troubleshooting

## Guidelane Studio doesn't list the server

The server's mDNS announcement only reaches its own network segment. It doesn't pass through
routers, VPNs, Docker's own networks or Kubernetes pod networks. Join with the server's address
instead: on the Join page, choose "Other server…". [Networking](networking.md) explains where mDNS
works.

The Server tab of the admin page shows whether devices on the network can find the server. If
they can't, check that UDP port 5353 is allowed on the server's host.

## A device can't connect to the server

- Check that the server is running: `guidelane-library --config <config file> health`.
- Check that TCP port 7443 is open in the host's firewall and on the VPN.
- On the device, open `https://<address>:7443/admin` in a browser. If the page doesn't load, the
  problem is the network, not Guidelane Studio.
- If the server's address changed, enter the new one on the Server tab under "Address", or give
  the server a DNS name that always points to its current address.

## "Guidelane Library needs a Business license"

The device has a Personal license, or its trial or license has expired. The server refuses the
device until it has a Business license. See [Licenses](licenses.md).

## "Guidelane Studio can’t confirm this is the same server you joined"

The server presents a different key from the one the device stored when it joined. This happens
when the server was set up again with a new certificate, restored without its `tls` folder, or
given a new certificate with a new key. The user chooses "Leave" and then joins again. To avoid
this for everyone, keep the server's key. See [Certificates](certificates.md).

## The join request doesn't appear on the admin page

A request expires after 10 minutes, and the server discards all requests when it restarts. Ask
the user to choose "Ask to join" again. If the device connected to a different server at that
address, the six-digit codes won't match, so reject that request.

## "This Mac tried too many times" or "This PC tried too many times"

The server limits join and sign-in attempts per IP address. Wait a minute and try again. On
Kubernetes, keep `service.externalTrafficPolicy: Local` so that the server sees each device's own
IP address instead of the node's.

## The admin password is lost

Stop the server, run `guidelane-library --config <config file> admin-reset` as the server's user,
and start the server again. It prints a new setup code. Devices stay connected.

## The service doesn't start

Check its log (see [Backups, upgrades and removal](operations.md#logs)). These are the most
common causes:

- **"The config file at … could not be used"**: the file contains an error, or the server's user
  can't read it.
- **"Nothing was made, because the data folder could not be made (permission denied)"**: the
  server's user doesn't own the data folder. With Docker and a folder on the host, run
  `chown 65532:65532` on that folder.
- **Address already in use**: another program is using port 7443. Stop it, or set a different
  port with `listen` in the config file.
- **In a Proxmox VE container, systemd reports `status=226/NAMESPACE`**: turn on the container's
  "Nesting" feature under Options, then Features, and restart the container.

## Still having problems?

Open an issue in this repository with your platform, the server's version (shown under the
server's name on the admin page) and the log lines around the problem. Don't include codes, keys
or passwords.
