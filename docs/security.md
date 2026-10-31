# Security

## Before you start

- Keep the server on your own network, behind your router or firewall, and give remote users
  access through your VPN. Never expose it to the internet.
- The server has no user accounts and no roles. Every connected device can read, replace and
  delete every guide, so control which devices join.
- The server stores guides unencrypted. Keep the data folder on an encrypted disk.

## Connections

- Connections use TLS 1.3 only.
- A device verifies the server by its key's fingerprint, which the device stores when it joins.
  If the server has a certificate from a certificate authority the OS trusts, the device verifies
  the certificate against the OS's trusted certificate authorities instead. See
  [Certificates](certificates.md).
- When a device asks to join, it commits to a random value before it receives the server's, and
  the server chooses its own value before it receives the device's. The six-digit code is derived
  from both values. An attacker in between with a different certificate has a one-in-a-million
  chance per request of producing matching codes, so you would reject the request.
- Before a device sends an invitation or enrollment code, the server proves that it knows the
  code, with a proof tied to its own key. This way, no other device on the network can collect
  codes.

## Codes and tokens

- Each device receives a token of 256 random bits, once. The server stores only its SHA-256 hash
  and compares hashes in constant time. Invitation and enrollment codes are stored and compared
  the same way.
- An enrollment code has about 78 bits of randomness. It only lets in as many devices as you
  allowed, until the day you chose. Join attempts are rate-limited per IP address.
- The admin password is stored as a PBKDF2-HMAC-SHA256 hash with its own salt, and sign-in
  attempts are rate-limited per IP address. A sign-in lasts 12 hours.
- The admin page only runs its own scripts, and it refuses changes that don't come from the page
  itself.

## Licenses

The server checks each device's license certificate offline, with the same public keys that
Guidelane Studio uses, and checks that the certificate was issued for that device. The server
never contacts the license service, and the license service doesn't know your server exists.

## Files

- On Linux and macOS, only the server's user can open the data folder and its subfolders
  (`0700`) or read its files (`0600`).
- On Windows, `service install` restricts the data folder to the service, administrators and the
  SYSTEM account.
- The server never logs a guide's ID or title, a token, or the contents of a file.

## Downloads

The SHA-256 checksum of each release package is listed in
`https://downloads.guidelane.io/library/<version>/SHA256SUMS` and in
`https://downloads.guidelane.io/library/latest.json`. The installer verifies the download against
them before it installs anything. To verify a package yourself:

```sh
sha256sum --check --ignore-missing SHA256SUMS
```

The image digest for each version is shown on the image's page in the GitHub Container Registry.

## Reporting a vulnerability

Report security problems to support@guidelane.io, not in a public issue.
