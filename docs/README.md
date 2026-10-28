# Guidelane Library documentation

Read these in order for a first install, then come back to the ones you need.

1. [Requirements](requirements.md): the machine, the network and the devices.
2. Install the server on one of these:
   - [Docker](install-docker.md), with `docker run` or Docker Compose
   - [Kubernetes](install-kubernetes.md), with the Helm chart
   - [Linux](install-linux.md), with the installer or by hand
   - [macOS](install-macos.md), with the installer or Homebrew
   - [Windows](install-windows.md), as a Windows service
   - [Proxmox VE](install-proxmox.md), in a container
3. [First start](first-start.md): the admin page, its password, the server's name and address.
4. [Joining devices](joining-devices.md): the five ways a device joins, and disconnecting one.
5. [Rolling out to managed devices](managed-devices.md): deployment keys, enrollment codes and
   configuration profiles for Jamf Pro, Intune, Kandji and Group Policy.

Reference:

- [Licenses](licenses.md): which licenses can use the server, seats and deployment keys.
- [Networking](networking.md): ports, mDNS, DNS names, load balancers and VPNs.
- [Certificates](certificates.md): the server's own certificate, or your company's.
- [Configuration and commands](configuration.md): the config file, every command, the
  installer's options and the data folder.
- [Backups, upgrades and removal](operations.md): backups, restores, upgrades, versions, health
  checks and logs.
- [Security](security.md): how the server protects guides, codes and passwords.
- [Troubleshooting](troubleshooting.md): what to do when something does not work.
