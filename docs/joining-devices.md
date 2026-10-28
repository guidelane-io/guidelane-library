# Joining devices

A device joins the server from Guidelane Studio, under Settings, then Library. There are five
ways to join, and you can mix them. For many company devices at once, see
[Rolling out to managed devices](managed-devices.md).

Each way needs the device to have a Business license or a trial that has not ended. See
[Licenses](licenses.md).

## Found on the network

This is the usual way on an office network.

1. In Guidelane Studio, open Settings, then Library, and choose "Join…" beside "Guidelane
   Library". Guidelane Studio lists the servers on its network by name.
2. Choose the server, check the device's name, and choose "Ask to join". Guidelane Studio shows
   a six-digit code.
3. On the admin page, the request is under "Join requests" on the Devices tab, with a code.
   Choose "Accept" when the code matches the one on the device, and "Reject" when it does not.

The code proves that the device and the admin page are looking at the same request, and that
nothing between them answered in the server's place. A request waits 10 minutes for an answer.

## By the server's address

When the network does not carry the server's announcement, for example over a VPN or when the
server runs in a container, enter its address instead. On the Join page, choose "Other server…"
and enter the address under "Server address", such as `192.168.1.20` or `library.example.com`.
The request then goes on as above.

## With an invitation code

On the admin page, choose "Invite a device" to create a code of twelve characters, such as
`K7QX-2M9P-CS3N`. You can also create one on a device that joined, by choosing "Invite…" beside
the server in Settings. On the new device, choose "Join…", choose the server or enter its
address, enter the code under "Invitation code", and choose "Join". The device joins at once,
without a request.

An invitation lets one device join, once, within 24 hours. Before the device sends the code,
the server proves that it created the invitation, so nothing else on the network can pose as
the server.

You can also create one from the command line:

```sh
guidelane-library --config <config file> invite
```

## With a join link

Beside each invitation code, the admin page and Guidelane Studio offer a link such as
`guidelane-studio://join?address=library.example.com%3A7443&code=K7QX-2M9P-CS3N`. Send it in an
email or a chat message. When the person opens the link, Guidelane Studio shows its Join page
with the address and the code filled in, and the person then chooses "Join". A device never
joins from the link alone.

## With an enrollment code

On the Enrollment codes tab, choose "New enrollment code…" to create a code of sixteen
characters, such as `K7QX-2M9P-CS3N-H4TR`. You choose how many devices can join with it, and
until which day. Those devices join without your approval. Enter the code like an invitation
code, or put it in managed settings. The page shows the code once, so copy it then.

Choose "Revoke…" to stop a code from letting more devices join. Devices that joined with it stay
joined.

## Disconnect a device

On the Devices tab, choose "Disconnect…" beside the device. The device can no longer reach the
server. The person can also leave from their side by choosing "Leave" beside the server in
Settings.

From the command line, you can list the devices and disconnect one:

```sh
guidelane-library --config <config file> devices
guidelane-library --config <config file> revoke "Anna's MacBook Pro"
```
