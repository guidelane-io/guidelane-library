# First start

Once the server is running, you look after it from its admin page in a browser. Nothing after the
first start needs a terminal.

## Open the admin page

The server prints the address of its admin page and, while the page has no password yet, a
setup code:

```text
Guidelane Library is listening on 0.0.0.0:7443.
The fingerprint of its key is 21D2 D6D7 7436 B4D5 F712 F6CB D9A8 B4D2 150C CF93 573D 6940 7EBB D92F 7D58 6B8A.
The admin page is at https://192.168.1.20:7443/admin.
Use this setup code to create the admin password: EQ8H-2GA4-K7QX
```

The install guide for your platform says where to read these lines. The setup code changes each
time the server starts, until a password is set.

Open the address in a browser. The browser warns that the connection is not private, because
the server created its own certificate rather than getting one from an authority the browser
trusts. To check that you reached your server, compare the fingerprint it printed with the
SHA-256 fingerprint of the certificate's public key. In Chrome, the certificate viewer shows it
under "Public Key". Then go on to the page.

With a certificate from your company's certificate authority, the page opens with no warning. See
[Certificates](certificates.md).

## Create the admin password

The page asks for the setup code and a new password of at least 10 characters. From then on, it
asks for the password. A sign-in lasts 12 hours.

If you lose the password, stop the server, run `guidelane-library admin-reset` with the server's
config file, and start the server again. It prints a new setup code.

## Name the server and give it an address

On the Server tab:

- In "Name", enter the name people see in Guidelane Studio, such as "Acme library".
- In "Address", enter the host name or IP address devices use to reach the server. Leave it empty to
  use the IP address the server finds for itself. To use a name such as `library.example.com`,
  create its DNS record first. When you save, the server looks the name up and says whether it
  points to this server.

The server puts this address in every invitation and join link, and gives it to devices that
find the server on the network. That way, devices keep reaching the server if its IP address
changes. Set the address before devices join.

## The admin page

The page has three tabs:

- **Devices**: requests to join, each with a six-digit code, while devices wait for an answer.
  Below them, the tab lists every device that joined, with the license each one holds, when it
  last reached the server, and "Disconnect…".
- **Enrollment codes**: the codes that let many devices join without approval, how many joined
  with each one, when each one stops working, and "Revoke…".
- **Server**: the name and address, the port, whether devices on the network can find the
  server, its certificate and its key's fingerprint, the guides it keeps, and the admin password.

Choose "Invite a device" to create an invitation code and a join link for one device.

Next, [join the first device](joining-devices.md).
