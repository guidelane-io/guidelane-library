# Joining devices

Devices join the server from Guidelane Studio, under Settings, then Library. There are five ways
to join, and you can use any combination of them. To connect many company devices at once, see
[Rolling out to managed devices](managed-devices.md).

Every device needs a Business license or an active trial to join. See [Licenses](licenses.md).

## Find the server on the network

This is the most common way on an office network.

1. In Guidelane Studio, open Settings, then Library, and choose "Join…" next to "Guidelane
   Library". Guidelane Studio lists the servers on the network by name.
2. Choose the server, check the device's name, and choose "Ask to join". Guidelane Studio shows a
   six-digit code.
3. On the admin page, the request appears under "Join requests" on the Devices tab, with a code.
   If the code matches the one on the device, choose "Accept". If it doesn't, choose "Reject".

Matching codes confirm that the device and the admin page show the same request, and that no
other device on the network answered in the server's place. A request expires after 10 minutes.

## Enter the server's address

If the server's announcement doesn't reach the device, for example over a VPN or when the server
runs in a container, enter the server's address instead. On the Join page, choose "Other
server…" and enter the address under "Server address", such as `192.168.1.20` or
`library.example.com`. The rest of the process is the same as above.

## Use an invitation code

On the admin page, choose "Invite a device" to create a 12-character code, such as
`K7QX-2M9P-CS3N`. You can also create one on a device that has already joined, by choosing
"Invite…" next to the server in Settings. On the new device, choose "Join…", choose the server
or enter its address, enter the code under "Invitation code", and choose "Join". The device joins
immediately, without a join request.

An invitation code works for one device, once, within 24 hours. Before the device sends the
code, the server proves that it created the invitation, so no other device on the network can
pretend to be the server.

You can also create an invitation code from the command line:

```sh
guidelane-library --config <config file> invite
```

## Send a join link

Next to each invitation code, the admin page and Guidelane Studio offer a link such as
`guidelane-studio://join?address=library.example.com%3A7443&code=K7QX-2M9P-CS3N`. Send it by
email or in a chat message. When the user opens the link, Guidelane Studio opens its Join page
with the address and the code filled in, and the user chooses "Join". A device never joins just
because a link was opened.

## Use an enrollment code

On the Enrollment codes tab, choose "New enrollment code…" to create a 16-character code, such as
`K7QX-2M9P-CS3N-H4TR`. You choose how many devices can join with it and the day it expires.
These devices join without your approval. Enter the code the same way as an invitation code, or
add it to managed settings. The page shows the code only once, so copy it right away.

To stop more devices from joining with a code, choose "Revoke…". Devices that already joined
with it stay connected.

## Disconnect a device

On the Devices tab, choose "Disconnect…" next to the device. The device can no longer connect to
the server. Users can also disconnect their own device by choosing "Leave" next to the server in
Settings.

From the command line, you can list the devices and disconnect one:

```sh
guidelane-library --config <config file> devices
guidelane-library --config <config file> revoke "Anna's MacBook Pro"
```
