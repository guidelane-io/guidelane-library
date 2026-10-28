# Install with Docker

The image is `ghcr.io/guidelane-io/guidelane-library`, for `linux/amd64` and `linux/arm64`. Its
tags are `latest` and each version, such as `0.1.0`. It holds only the server, with no shell and
no package manager, and the server runs as the unprivileged user 65532.

The image keeps everything in `/data`. On its first start it sets the server up there: it
creates the config file, the data folder and the server's own certificate. Every later start
runs the server it set up.

## docker run

```sh
docker run -d --name guidelane-library --restart unless-stopped \
  -p 192.168.1.20:7443:7443 \
  -v guidelane-library:/data \
  ghcr.io/guidelane-io/guidelane-library
```

Publish the port on the host's address on your network, as above, rather than on every address
the host has. Then read the address of the admin page and its setup code:

```sh
docker logs guidelane-library
```

```text
The server is called Guidelane library.
Guidelane Library is listening on 0.0.0.0:7443.
The fingerprint of its key is F481 2213 002F 2AEA A38B 35C3 B55C E2C4 33DF 406C 2C18 C6F8 BA69 2857 CFD0 D283.
The admin page is at https://172.17.0.3:7443/admin.
Use this setup code to create the admin password: 7EN3-SKA9-NE3B
```

The address in the log is the container's own. Open the one you published instead, such as
`https://192.168.1.20:7443/admin`, and go on with [First start](first-start.md).

To give the server another name on its first start, add the start command and the name after
the image:

```sh
docker run -d --name guidelane-library --restart unless-stopped \
  -p 192.168.1.20:7443:7443 -v guidelane-library:/data \
  ghcr.io/guidelane-io/guidelane-library run --init --data . --name "Acme library"
```

You can change the name on the admin page at any time.

## Docker Compose

[`deploy/docker/compose.yaml`](../deploy/docker/compose.yaml) runs the server on Docker's own
network:

```sh
curl -fsSLO https://raw.githubusercontent.com/guidelane-io/guidelane-library/master/deploy/docker/compose.yaml
# Change 192.168.1.20 to your host's address, and the name if you like.
docker compose up -d
docker compose logs library
```

## Let Guidelane Studio find the server

A container on Docker's own network cannot announce itself over mDNS on your network, so
Guidelane Studio does not list the server on its Join page. Devices then join it by its address,
which works everywhere: see [Joining devices](joining-devices.md).

On Linux, the server can announce itself when the container uses the host's own network.
[`deploy/docker/compose.host-network.yaml`](../deploy/docker/compose.host-network.yaml) sets
that up. With `docker run`, use `--network host` in place of `-p`:

```sh
docker run -d --name guidelane-library --restart unless-stopped --network host \
  -v guidelane-library:/data ghcr.io/guidelane-io/guidelane-library
```

Docker Desktop on macOS and Windows has no host network to give the container, so on those
systems, devices join by address.

## Health

The image has a health check. Every 30 seconds, `guidelane-library health` connects to the
server's port and checks that the server answers with its own key. `docker ps` shows the
container as `healthy` once the server is up.

## A folder on the host instead of a volume

A named volume, as above, needs nothing more. To keep the data in a folder on the host instead,
the folder must belong to the image's user, 65532:

```sh
sudo mkdir -p /srv/guidelane-library
sudo chown 65532:65532 /srv/guidelane-library
sudo chmod 700 /srv/guidelane-library
docker run -d --name guidelane-library --restart unless-stopped \
  -p 192.168.1.20:7443:7443 -v /srv/guidelane-library:/data \
  ghcr.io/guidelane-io/guidelane-library
```

## Commands

Run the server's other commands in the running container:

```sh
docker exec guidelane-library guidelane-library --config /data/library.toml invite
docker exec guidelane-library guidelane-library --config /data/library.toml devices
```

[Configuration and commands](configuration.md) lists them all.

## Upgrade

Pull the new image and create the container again with the same volume. The data stays as it
is, and every device stays joined.

```sh
docker pull ghcr.io/guidelane-io/guidelane-library
docker rm -f guidelane-library
docker run -d --name guidelane-library --restart unless-stopped \
  -p 192.168.1.20:7443:7443 -v guidelane-library:/data ghcr.io/guidelane-io/guidelane-library
```

With Compose, run `docker compose pull` and then `docker compose up -d`.

To stay on one version, use its tag, such as `ghcr.io/guidelane-io/guidelane-library:0.1.0`, rather
than `latest`.
