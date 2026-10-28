# Certificates

## The server's own certificate

When the server is first set up, it creates its own certificate and key, in the `tls` folder of
its data folder. This is the default, and it needs nothing from you.

Guidelane Studio trusts this certificate by its key. As a device joins, it checks the key with
the six-digit code, an invitation or an enrollment code, and keeps the key's fingerprint. From
then on, it accepts that key and no other, whatever name it uses to reach the server and whatever
dates the certificate has.

Browsers do not know this certificate, so they warn about it when you open the admin page.
Compare the fingerprint the server prints with the SHA-256 fingerprint of the certificate's
public key, then go on.

## A certificate from your company's authority

With a certificate from your company's certificate authority, the admin page opens with no
warning, and you can renew or replace the certificate like any other.

1. Have your authority issue a certificate for the server's name, such as
   `library.example.com`.
2. Save the certificate (with its chain) and its private key as PEM files where the server's
   user can read them.
3. Point `certificate` and `key` in the config file at them, and restart the server.

```toml
certificate = "/etc/guidelane-library/library.example.com.pem"
key = "/etc/guidelane-library/library.example.com-key.pem"
```

On Kubernetes, give the chart a TLS Secret instead: see [Kubernetes](install-kubernetes.md).

For macOS to trust the certificate, it must:

- list the server's name among its subject alternative names,
- include server authentication in its extended key usage,
- last no more than 825 days.

The computers that run Guidelane Studio must trust your authority, which company-managed
computers usually do already.
The Server tab shows the authority that issued the certificate and when it ends.

## What happens to devices that joined

When a device joins, its OS may already trust the server's certificate for the address the
device joins by. If it does, the device checks the certificate the way a browser does from then
on: its authority, its dates and its name. You can renew the certificate, or issue a new one
with a new key, and those devices keep working.

A device that joined while the server had its own certificate checks that certificate's key.
When you switch to a certificate from your company's authority:

- If the new certificate is for the same key, nothing changes for any device. Have your
  authority issue it for the key the server already has, `tls/key.pem` in its data folder.
- Otherwise, a device that trusts your authority switches to checking the new certificate the
  way a browser does, unless its managed settings pin the server's key with
  `LibraryFingerprint`.
- Any other device has to leave and join again.

## The key's fingerprint

The fingerprint is the SHA-256 of the certificate's public key (its SubjectPublicKeyInfo),
shown as sixteen groups of four characters. A certificate renewed with the same key keeps the
same fingerprint.
The Server tab shows it, and `init` and `run` print it.
