# Certificates

## The server's self-generated certificate

When the server is set up for the first time, it generates its own certificate and private key
and stores them in the `tls` folder inside its data folder. This is the default, and you don't
need to do anything.

Guidelane Studio trusts this certificate by its key. When a device joins, it verifies the key
with the six-digit code, an invitation code or an enrollment code, and stores the key's
fingerprint. After that, it only accepts that key, whatever name it uses to connect and whatever
dates the certificate has.

Browsers don't trust this certificate, so they show a warning when you open the admin page.
Compare the fingerprint the server prints with the SHA-256 fingerprint of the certificate's
public key, then continue.

## A certificate from your company's certificate authority

If you use a certificate from your company's certificate authority, the admin page opens without
a warning, and you can renew or replace the certificate like any other.

1. Have your certificate authority issue a certificate for the server's name, such as
   `library.example.com`.
2. Save the certificate (with its chain) and its private key as PEM files in a location the
   server's user can read.
3. Set `certificate` and `key` in the config file to these files, and restart the server.

```toml
certificate = "/etc/guidelane-library/library.example.com.pem"
key = "/etc/guidelane-library/library.example.com-key.pem"
```

On Kubernetes, give the chart a TLS Secret instead. See [Kubernetes](install-kubernetes.md).

For macOS to trust the certificate, it must:

- include the server's name in its subject alternative names
- include server authentication in its extended key usage
- be valid for no more than 825 days

The devices that run Guidelane Studio must trust your certificate authority. Company-managed
devices usually do already. The Server tab shows which certificate authority issued the
certificate and when it expires.

## What happens to connected devices

When a device joins, its OS may already trust the server's certificate for the address the
device uses. In that case, the device verifies the certificate the same way a browser does: its
certificate authority, its dates and its name. You can renew the certificate, or issue a new one
with a new key, and these devices keep working.

A device that joined while the server used its self-generated certificate verifies that
certificate's key. When you switch to a certificate from your company's certificate authority:

- If the new certificate uses the same key, nothing changes for any device. Have your
  certificate authority issue it for the key the server already has, `tls/key.pem` in its data
  folder.
- If it uses a new key, devices that trust your certificate authority switch to verifying the new
  certificate the same way a browser does, unless their managed settings pin the server's key
  with `LibraryFingerprint`.
- All other devices need to leave and join again.

## The key's fingerprint

The fingerprint is the SHA-256 hash of the certificate's public key (its SubjectPublicKeyInfo),
shown as sixteen groups of four characters. A certificate renewed with the same key keeps the
same fingerprint. The Server tab shows the fingerprint, and the `init` and `run` commands print
it.
