# Networking

## Ports

Devices reach the server on TCP port 7443, and so does a browser that opens the admin page.
Allow the port through the host's firewall, and through your VPN for people who work from home.
The Windows service adds its own firewall rule. On Linux and macOS, you add the rule.

To use another port, set `listen` in the config file, such as `listen = "0.0.0.0:8443"`, and
restart the server. See [Configuration and commands](configuration.md).

The server listens on every address of its machine unless the config file names one. To limit
the server to one network, give its address on that network, such as
`listen = "192.168.1.20:7443"`.

## Finding the server: mDNS

The server announces itself on its local network over mDNS (multicast DNS, UDP port 5353) as
`_guidelane-lib._tcp`, under its name. Guidelane Studio lists the servers it hears on its Join
page.

mDNS reaches only the local network segment. It does not cross:

- routers between subnets, unless they relay mDNS,
- a VPN,
- Docker's own networks, Docker Desktop on macOS and Windows, or a Kubernetes pod network.

That is fine: an announcement is only a convenience. Devices that do not hear it join the server
by its address, a join link or managed settings. The admin page's Server tab says whether the
announcement is working.

An announcement proves nothing about the server. A device checks the server when it joins.

## A host name

Devices reach the server at its IP address unless you give it a name. To use one, such as
`library.example.com`:

1. In your company's DNS, create a record for the name that points at the server's machine. On
   a single network, the machine's own `.local` name works too.
2. On the admin page's Server tab, enter the name under "Address" and save. The server looks the
   name up and says whether it points to this server.

A device may get different DNS answers than the server does, so the server saves the name even
when the check fails. The server puts the name in every invitation and join link, and gives it
to devices that find the server on the network.

The name needs no certificate. Guidelane Studio checks the server by its key, whatever name it
uses to reach the server. A certificate from your company's authority must include the name. See
[Certificates](certificates.md).

## Load balancers and proxies

The server serves TLS itself, and devices check its key. Anything in front of it must pass the
TLS connection through untouched: a plain TCP load balancer, port forwarding, or TLS passthrough.
A reverse proxy that ends TLS and opens a new connection to the server does not work, because
devices would see the proxy's key instead of the server's.

## The internet

Never expose the server to the internet. It has no user accounts: every device that joined can
read, replace and delete every guide. Keep it on your network, and let people who work from home
reach it through your VPN.
