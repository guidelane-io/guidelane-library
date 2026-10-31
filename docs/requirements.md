# Requirements

## The server

Guidelane Library runs on any device in your network that stays switched on: a server, a virtual
machine, a NAS that runs containers, a Kubernetes cluster or a spare Mac.

| | Supported |
|---|---|
| Linux | x86_64 and arm64, any distribution. The binary is statically linked and needs no system libraries. The installer requires systemd. |
| macOS | Apple silicon and Intel. |
| Windows | x86_64, Windows and Windows Server. |
| Containers | `linux/amd64` and `linux/arm64` images, for Docker, Podman and Kubernetes. |

The server uses very few resources. When nobody is saving guides, it uses a few megabytes of
memory and no CPU, so one core and 512 MB of memory are enough. Memory use goes up while devices
upload guides: the server checks up to two uploads at a time and keeps each one in memory while
it checks it. Add enough memory for your two largest guides.

Plan disk space for your guides. Each step with its screenshot takes about 70 KB, so a guide with
20 steps takes about 1.5 MB.

## The network

| Port | Protocol | Used by |
|---|---|---|
| 7443 | TCP | Connected devices, and the admin page in a browser. |
| 5353 | UDP multicast | The server's mDNS announcement, which lets Guidelane Studio list the server on the local network. Optional. |

Devices connect to the server. The server never connects to them. The server doesn't need an
internet connection: it checks each device's license certificate with keys that are built into
the server.

Keep the server on your own network or behind your VPN. Never expose port 7443 to the internet:
the server has no user accounts, and every connected device can read and change every guide.

[Networking](networking.md) covers DNS names, firewalls, VPNs and networks that mDNS doesn't
reach.

## The devices

Each user needs Guidelane Studio on a Mac or a Windows PC, with a Business license or an active
trial. [Licenses](licenses.md) explains which licenses can use the server.
