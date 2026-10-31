# Install on Kubernetes

The Helm chart runs the server as a StatefulSet with one replica and a persistent volume, and
exposes it through a Service. The chart is published as an OCI chart, which requires Helm 3.8 or
later.

```sh
helm install library oci://ghcr.io/guidelane-io/charts/guidelane-library \
  --namespace guidelane --create-namespace \
  --set library.name="Acme library"
```

Each chart version has the same version number as the server it runs. To install a specific
version, add `--version 1.0.1`.

## Make the server reachable from your network

Devices connect from outside the cluster, so the server needs an address on your network. By
default, the chart creates a Service of type `LoadBalancer`. On a cluster running on your own
hardware, a load balancer such as MetalLB assigns the address:

```sh
helm install library oci://ghcr.io/guidelane-io/charts/guidelane-library \
  --namespace guidelane --create-namespace \
  --set service.loadBalancerIP=192.168.1.40
```

If you don't have a load balancer, use a NodePort. Devices then connect to the server on that
port at a node's address:

```sh
helm install library oci://ghcr.io/guidelane-io/charts/guidelane-library \
  --namespace guidelane --create-namespace \
  --set service.type=NodePort --set service.nodePort=30743
```

The server handles TLS itself, and devices verify its key, so nothing in front of the server may
terminate the TLS connection. An Ingress that terminates TLS doesn't work. A plain TCP load
balancer, a NodePort, or a Gateway API `TLSRoute` with TLS passthrough works.

## First start

```sh
kubectl get service --namespace guidelane
kubectl logs statefulset/library-guidelane-library --namespace guidelane
```

The log shows the setup code for the admin page. Open `https://<address>:7443/admin` and
continue with [First start](first-start.md). On the Server tab of the admin page, enter the
address that devices use under "Address". This can be the load balancer's address or a DNS name
that points to it.

## mDNS in a cluster

The pod network doesn't pass the server's mDNS announcement to your network, so Guidelane Studio
doesn't list the server on its Join page. Devices join with the server's address, an invitation
link or managed settings, which is how most companies roll it out anyway.

To announce the server on a node's network, run the pod on the node's network:

```sh
--set hostNetwork=true
```

The pod then uses port 7443 on its node, and devices can connect to it at the node's address.

## Use your company's certificate

By default, the server generates its own certificate on first start and stores it on its volume.
To use a certificate from your company's certificate authority, store it as a TLS Secret and pass
its name to the chart:

```sh
kubectl create secret tls library-tls --namespace guidelane \
  --cert=library.example.com.pem --key=library.example.com-key.pem
helm upgrade library oci://ghcr.io/guidelane-io/charts/guidelane-library \
  --namespace guidelane --reuse-values --set tls.secretName=library-tls
```

With `tls.secretName`, the chart gives the server a config file that points to the Secret. Read
[Certificates](certificates.md) before you change a certificate that devices already trust.

## Values

| Value | Default | Description |
|---|---|---|
| `library.name` | `Guidelane library` | The server's name, used when the server is first set up. |
| `image.repository` | `ghcr.io/guidelane-io/guidelane-library` | The image. |
| `image.tag` | the chart's version | The image tag. |
| `service.type` | `LoadBalancer` | `LoadBalancer`, `NodePort` or `ClusterIP`. |
| `service.port` | `7443` | The Service port. |
| `service.loadBalancerIP` | empty | A fixed address from your load balancer. |
| `service.nodePort` | empty | The node port, with `service.type=NodePort`. |
| `service.externalTrafficPolicy` | `Local` | Preserves each device's own IP address, which the server uses to rate-limit join and sign-in attempts. |
| `service.annotations` | `{}` | Annotations for your load balancer, such as MetalLB's address pool. |
| `hostNetwork` | `false` | Runs the pod on its node's network, so the server can announce itself over mDNS. |
| `tls.secretName` | empty | A Secret of type `kubernetes.io/tls` with your company's certificate. |
| `persistence.size` | `5Gi` | The size of the volume for the guides. |
| `persistence.storageClass` | the cluster's default | The storage class of the volume. |
| `resources` | 128 Mi requested, 1 Gi limit | Memory and CPU. The server keeps up to two uploads in memory while it checks them. |
| `nodeSelector`, `tolerations`, `affinity` | empty | Where the pod runs. |

## Without Helm

To apply plain manifests, render them from the chart and keep them in your own repository:

```sh
helm template library oci://ghcr.io/guidelane-io/charts/guidelane-library \
  --namespace guidelane --set service.type=NodePort > guidelane-library.yaml
kubectl apply --namespace guidelane -f guidelane-library.yaml
```

## Backups and upgrades

The server stores all of its data on its volume, in the `library` folder. Back up the volume with
your usual tool, such as Velero or your storage's snapshots. To upgrade, run `helm upgrade` with
the new chart version. The StatefulSet replaces the pod, the volume stays, and devices stay
connected. See [Backups, upgrades and removal](operations.md) for more.

Keep the replica count at one. Two servers using the same data folder would write to the same
files.
