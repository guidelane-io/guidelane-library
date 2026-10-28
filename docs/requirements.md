# Requirements

## The machine

Guidelane Library runs on any machine that stays on inside your network: a server, a virtual
machine, a NAS that runs containers, a Kubernetes cluster or a spare Mac.

| | Supported |
|---|---|
| Linux | x86_64 and arm64, any distribution. The binary is static, so it needs no system libraries. The installer needs systemd. |
| macOS | Apple silicon and Intel. |
| Windows | x86_64, Windows and Windows Server. |
| Containers | `linux/amd64` and `linux/arm64` images, for Docker, Podman and Kubernetes. |

The server is light. While no one is saving, it uses a few megabytes of memory and no CPU, so
one core and 512 MB are plenty. Memory goes up while devices save: the server checks at most two
uploads at once, and holds each one in memory while it checks it. Give it memory for two of your
largest guides on top of that.

Plan disk space for your guides. Each step with its screenshot takes roughly 70 KB, so a guide
of 20 steps takes about 1.5 MB.

## The network

| Port | Protocol | What uses it |
|---|---|---|
| 7443 | TCP | Every device that joined, and the admin page in a browser. |
| 5353 | UDP multicast | The server's announcement over mDNS, so Guidelane Studio lists it on the local network. Optional. |

Devices connect to the server, and the server never connects to them. The server needs no
internet connection. It checks each device's license certificate with keys that are built into
the server.

Keep the server on your own network, or behind your VPN. Never expose port 7443 to the internet:
the server has no user accounts, and every device that joined can read and change every guide.

[Networking](networking.md) covers DNS names, firewalls, VPNs and where mDNS does not reach.

## The devices

Each person needs Guidelane Studio on a Mac or a Windows PC, with a Business license or a trial
that has not ended. [Licenses](licenses.md) explains which licenses can use the server.
