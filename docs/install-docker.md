# Install with Docker

The image is `ghcr.io/guidelane-io/guidelane-library`, for `linux/amd64` and `linux/arm64`. It is
tagged `latest` and with each version number, such as `1.0.1`. The image contains only the
server, with no shell and no package manager, and the server runs as the unprivileged user 65532.

The image stores all data in `/data`. On first start, it sets up the server there: it creates the
config file, the data folder and the server's self-generated certificate. On every later start,
it runs the server it set up.

## docker run

```sh
docker run -d --name guidelane-library --restart unless-stopped \
  -p 192.168.1.20:7443:7443 \
  -v guidelane-library:/data \
  ghcr.io/guidelane-io/guidelane-library
```

Publish the port on the host's address in your network, as shown above, instead of on all of the
host's addresses. Then get the admin page's address and the setup code from the log:

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

The address in the log is the container's internal address. Open the address you published
instead, such as `https://192.168.1.20:7443/admin`, and continue with
[First start](first-start.md).

To give the server a different name on first start, add the start command and the name after the
image:

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
# Change 192.168.1.20 to your host's address, and change the name if you want.
docker compose up -d
docker compose logs library
```

## Let Guidelane Studio find the server

A container on Docker's own network can't announce itself over mDNS on your network, so
Guidelane Studio doesn't list the server on its Join page. Devices can join with the server's
address instead, which always works. See [Joining devices](joining-devices.md).

On Linux, the server can announce itself if the container uses the host's network.
[`deploy/docker/compose.host-network.yaml`](../deploy/docker/compose.host-network.yaml) sets this
up. With `docker run`, use `--network host` instead of `-p`:

```sh
docker run -d --name guidelane-library --restart unless-stopped --network host \
  -v guidelane-library:/data ghcr.io/guidelane-io/guidelane-library
```

Docker Desktop on macOS and Windows doesn't support host networking for containers, so devices
there join with the server's address.

## Health check

The image includes a health check. Every 30 seconds, `guidelane-library health` connects to the
server's port and checks that the server responds with its own key. Once the server is up,
`docker ps` shows the container as `healthy`.

## Use a folder on the host instead of a volume

A named volume, as shown above, needs no extra setup. To store the data in a folder on the host
instead, the folder must belong to the image's user, 65532:

```sh
sudo mkdir -p /srv/guidelane-library
sudo chown 65532:65532 /srv/guidelane-library
sudo chmod 700 /srv/guidelane-library
docker run -d --name guidelane-library --restart unless-stopped \
  -p 192.168.1.20:7443:7443 -v /srv/guidelane-library:/data \
  ghcr.io/guidelane-io/guidelane-library
```

## Commands

Run the server's other commands inside the running container:

```sh
docker exec guidelane-library guidelane-library --config /data/library.toml invite
docker exec guidelane-library guidelane-library --config /data/library.toml devices
```

[Configuration and commands](configuration.md) lists all commands.

## Upgrade

Pull the new image and recreate the container with the same volume. The data stays as it is, and
every device stays connected.

```sh
docker pull ghcr.io/guidelane-io/guidelane-library
docker rm -f guidelane-library
docker run -d --name guidelane-library --restart unless-stopped \
  -p 192.168.1.20:7443:7443 -v guidelane-library:/data ghcr.io/guidelane-io/guidelane-library
```

With Compose, run `docker compose pull` and then `docker compose up -d`.

To stay on one version, use its tag, such as `ghcr.io/guidelane-io/guidelane-library:1.0.1`,
instead of `latest`.
