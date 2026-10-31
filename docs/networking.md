# Networking

## Ports

Devices and the admin page connect to the server on TCP port 7443. Allow this port through the
host's firewall, and through your VPN for users who work remotely. The Windows service adds its
own firewall rule. On Linux and macOS, you need to add the rule yourself.

To use a different port, set `listen` in the config file, such as `listen = "0.0.0.0:8443"`, and
restart the server. See [Configuration and commands](configuration.md).

By default, the server listens on all of the host's network addresses. To limit it to one
network, set its address on that network, such as `listen = "192.168.1.20:7443"`.

## Finding the server with mDNS

The server announces itself on the local network over mDNS (multicast DNS, UDP port 5353) as
`_guidelane-lib._tcp`, under its name. Guidelane Studio lists the servers it finds on its Join
page.

mDNS only works within a local network segment. It doesn't pass through:

- routers between subnets, unless they relay mDNS
- a VPN
- Docker's own networks, Docker Desktop on macOS and Windows, or a Kubernetes pod network

This is not a problem, because the announcement is only a convenience. Devices that don't see it
can join with the server's address, a join link or managed settings. The Server tab of the admin
page shows whether the announcement is working.

Devices don't trust a server because of its announcement. A device verifies the server when it
joins.

## Host name

Devices connect to the server by its IP address unless you give the server a host name. To use a
name such as `library.example.com`:

1. In your company's DNS, create a record for the name that points to the server's host. On a
   single network, the host's `.local` name also works.
2. On the Server tab of the admin page, enter the name under "Address" and save. The server looks
   up the name and tells you whether it points to this server.

Devices can get different DNS results than the server, so the server saves the name even if the
check fails. The server includes the name in every invitation and join link, and sends it to
devices that find the server on the network.

The name doesn't need a certificate. Guidelane Studio verifies the server by its key, whatever
name it uses to connect. If you use a certificate from your company's certificate authority, it
must include the name. See [Certificates](certificates.md).

## Load balancers and proxies

The server handles TLS itself, and devices verify its key. Anything in front of the server must
pass the TLS connection through unchanged: a plain TCP load balancer, port forwarding or TLS
passthrough. A reverse proxy that terminates TLS and opens a new connection to the server
doesn't work, because devices would see the proxy's key instead of the server's.

## The internet

Never expose the server to the internet. The server has no user accounts, and every connected
device can read, replace and delete every guide. Keep it on your network, and give remote users
access through your VPN.
