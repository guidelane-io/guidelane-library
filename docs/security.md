# Security

## What to know first

- Keep the server on your own network, behind your router or firewall, and reach it from home
  through your VPN. Never expose it to the internet.
- The server has no user accounts and no roles. Every device that joined can read, replace and
  delete every guide. Control who joins.
- The server stores guides as they are, without encrypting them. Keep the data folder on an
  encrypted disk.

## Connections

- Connections use only TLS 1.3.
- A device checks the server by the fingerprint of its key, which the device keeps when it
  joins. If the server has a certificate from an authority the OS trusts, the device checks the
  certificate against the authorities the OS trusts instead. See [Certificates](certificates.md).
- A device asking to join commits to a random value before it hears the server's, and the server
  picks its own before it hears the device's. The six-digit code comes from both. For each
  request, anything between them with another certificate has only a one-in-a-million chance of
  making the codes match, so you would reject it.
- Before a device sends an invitation or enrollment code, the server proves that it holds that
  code, with a proof tied to its own key, so nothing else on the network can collect codes.

## Codes and tokens

- A device's token is 256 random bits, given to it once. The server keeps only its SHA-256 and
  compares hashes in constant time. Invitation and enrollment codes are kept and compared the
  same way.
- An enrollment code has about 78 bits of randomness. It lets in only as many devices as you
  allowed, until the day you chose. Pairing attempts are limited for each address.
- The admin password is kept as a PBKDF2-HMAC-SHA256 hash with its own salt, and sign-ins are
  limited for each address. A sign-in lasts 12 hours.
- The admin page runs no script except its own, and refuses a change that did not come from the
  page itself.

## Licenses

The server checks each device's license certificate offline, with the same public keys
Guidelane Studio uses, and checks that the certificate was issued for that device. The server
never contacts the license service, and the license service never learns about your server.

## Files

- On Linux and macOS, only the server's user can open the data folder and the folders in it
  (`0700`) or read its files (`0600`).
- On Windows, `service install` makes the data folder readable only by the service,
  administrators and the system.
- The server writes no log line with a guide's id or title, a token or anything a file holds.

## Downloads

Each release's packages are listed with their SHA-256 in
`https://downloads.guidelane.io/library/<version>/SHA256SUMS` and in
`https://downloads.guidelane.io/library/latest.json`. The installer checks the download against
them before it installs anything. To check a package yourself:

```sh
sha256sum --check --ignore-missing SHA256SUMS
```

The image's digest for each version is shown on its page on GitHub Container Registry.

## Reporting a problem

Report a security problem to support@guidelane.io rather than in a public issue.
