# Troubleshooting

## Guidelane Studio does not list the server

The server's mDNS announcement reaches only its own network segment. It does not cross routers,
VPNs, Docker's own networks or Kubernetes pod networks. Join by the server's address instead:
on the Join page, choose "Other server…". [Networking](networking.md) explains where mDNS
reaches.

The admin page's Server tab says whether devices on the network can find the server. If it says
they cannot, check that UDP port 5353 is allowed on the server's machine.

## A device cannot reach the server

- Check that the server is running: `guidelane-library --config <config file> health`.
- Check that TCP port 7443 is open on the machine's firewall, and on the VPN.
- From the device, open `https://<address>:7443/admin` in a browser. If the browser cannot open
  it, the problem is the network, not Guidelane Studio.
- If the server's address changed, enter the new one on the Server tab under "Address", or give
  the server a DNS name that you keep pointed at its address.

## "Guidelane Library needs a Business license"

The device has a Personal license, or its trial or license ended. The server refuses the device
until the device holds a Business license. See [Licenses](licenses.md).

## "Guidelane Studio can’t confirm this is the same server you joined"

The server shows a different key than the one the device kept when it joined. This happens when
the server was set up again with a new certificate, restored without its `tls` folder, or given
a new certificate for a new key. The person chooses "Leave", then joins again. To avoid it for
everyone, keep the server's key: see [Certificates](certificates.md).

## The join request does not appear on the admin page

A request waits 10 minutes for an answer, and the server forgets requests when it restarts. Ask
the person to choose "Ask to join" again. If the device reached another server at that address,
the six-digit codes do not match: reject that request.

## "This computer tried too many times"

The server limits join and sign-in attempts for each address. Wait a minute and try again. In
Kubernetes, keep `service.externalTrafficPolicy: Local` so that the server sees each device's own
address rather than the node's.

## The admin password is lost

Stop the server, run `guidelane-library --config <config file> admin-reset` as the server's
user, and start the server again. It prints a new setup code. Devices stay joined.

## The service does not start

Read its log (see [Backups, upgrades and removal](operations.md#logs)). These are the usual
causes:

- **"The config file at … could not be used"**: the file has a mistake, or the server's user
  cannot read it.
- **"Nothing was made, because the data folder could not be made (permission denied)"**: the
  server's user does not own the data folder. With Docker and a folder on the host, run
  `chown 65532:65532` on that folder.
- **Address already in use**: another program listens on port 7443. Stop it, or set another
  port with `listen` in the config file.
- **In a Proxmox VE container, systemd reports `status=226/NAMESPACE`**: turn on the container's
  "Nesting" feature under Options, then Features, and restart the container.

## Still stuck

Open an issue in this repository with the platform, the server's version (the admin page shows
it under the server's name) and the log lines around the problem. Leave out codes, keys and
passwords.
