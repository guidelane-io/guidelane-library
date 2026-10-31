# Guidelane Library documentation

For a first install, read these pages in order. Afterwards, use them as a reference.

1. [Requirements](requirements.md): what the server, the network and the devices need.
2. Install the server on one of these platforms:
   - [Docker](install-docker.md), with `docker run` or Docker Compose
   - [Kubernetes](install-kubernetes.md), with the Helm chart
   - [Linux](install-linux.md), with the installer or manually
   - [macOS](install-macos.md), with the installer or Homebrew
   - [Windows](install-windows.md), as a Windows service
   - [Proxmox VE](install-proxmox.md), in a container
3. [First start](first-start.md): the admin page, the admin password, and the server's name and
   address.
4. [Joining devices](joining-devices.md): the five ways to connect a device, and how to
   disconnect one.
5. [Rolling out to managed devices](managed-devices.md): deployment keys, enrollment codes and
   configuration profiles for Jamf Pro, Intune, Kandji and Group Policy.

Reference:

- [Licenses](licenses.md): which licenses can use the server, seats and deployment keys.
- [Networking](networking.md): ports, mDNS, DNS names, load balancers and VPNs.
- [Certificates](certificates.md): the server's self-generated certificate, or your company's.
- [Configuration and commands](configuration.md): the config file, all commands, the
  installer's options and the data folder.
- [Backups, upgrades and removal](operations.md): backups, restores, upgrades, versions, health
  checks and logs.
- [Security](security.md): how the server protects guides, codes and passwords.
- [Troubleshooting](troubleshooting.md): what to do when something doesn't work.
