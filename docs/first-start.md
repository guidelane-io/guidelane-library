# First start

Once the server is running, you manage it from its admin page in a browser. After the first
start, you don't need a terminal.

## Open the admin page

When the server starts, it prints the address of its admin page. Until an admin password is set,
it also prints a setup code:

```text
Guidelane Library is listening on 0.0.0.0:7443.
The fingerprint of its key is 21D2 D6D7 7436 B4D5 F712 F6CB D9A8 B4D2 150C CF93 573D 6940 7EBB D92F 7D58 6B8A.
The admin page is at https://192.168.1.20:7443/admin.
Use this setup code to create the admin password: EQ8H-2GA4-K7QX
```

The install guide for your platform explains where to find this output. Until a password is set,
the setup code changes every time the server starts.

Open the address in a browser. The browser warns that the connection is not private, because the
server uses a self-generated certificate that the browser doesn't trust. To make sure you reached
your own server, compare the fingerprint in the output with the SHA-256 fingerprint of the
certificate's public key. In Chrome, the certificate viewer shows it under "Public Key". Then
continue to the page.

If the server uses a certificate from your company's certificate authority, the page opens
without a warning. See [Certificates](certificates.md).

## Create the admin password

Enter the setup code and a new password of at least 10 characters. After that, the page asks for
the password. A sign-in lasts 12 hours.

If you lose the password, stop the server, run `guidelane-library admin-reset` with the server's
config file, and start the server again. The server then prints a new setup code.

## Name the server and set its address

On the Server tab:

- In "Name", enter the name users see in Guidelane Studio, such as "Acme library".
- In "Address", enter the host name or IP address that devices use to connect to the server.
  Leave it empty to use the IP address the server detects. To use a name such as
  `library.example.com`, create its DNS record first. When you save, the server looks up the name
  and tells you whether it points to this server.

The server includes this address in every invitation and join link, and sends it to devices that
find the server on the network. This way, devices can still connect if the server's IP address
changes. Set the address before any devices join.

## The admin page

The page has three tabs:

- **Devices**: pending join requests, each with a six-digit code. Below them is a list of every
  connected device, with its license, the last time it connected, and "Disconnect…".
- **Enrollment codes**: the codes that let many devices join without approval, how many devices
  joined with each code, when each code expires, and "Revoke…".
- **Server**: the name and address, the port, whether devices on the network can find the
  server, its certificate and key fingerprint, the stored guides, and the admin password.

Choose "Invite a device" to create an invitation code and a join link for one device.

Next, [connect the first device](joining-devices.md).
