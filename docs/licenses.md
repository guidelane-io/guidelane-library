# Licenses

The server itself doesn't need a license, but every device that uses it does. Guidelane Library
is part of the Guidelane Studio Business plan.

| License on the device | Can it use the server? |
|---|---|
| A Business license, from a seat or a deployment key | Yes. |
| An active trial | Yes. Every trial includes all features, including the server. |
| A Personal license | No. Guidelane Studio shows "Guidelane Library needs a Business license." and offers to buy one. |
| An expired trial, or an expired or revoked license | No. |

## How the server checks licenses

Each device sends the server its license certificate when it joins, whenever its license
changes, and every hour. The server verifies the certificate's signature with the same keys that
Guidelane Studio uses, and checks that the certificate was issued for that device. A device can't
claim a license it doesn't have. The server doesn't need an internet connection for this.

A device without a license that includes the server can't join. If a connected device loses its
license, for example when its trial expires, it stays on the Devices tab of the admin page. The
server refuses all requests from that device until it has a Business license again, and
Guidelane Studio hides the server's guides until then. Guides stored on the device itself stay
there. The user can still view them, export them, and back them up as .gdl files.

The Devices tab of the admin page shows who each device's license belongs to, or how many days
are left in its trial.

## Seats

Business licenses are sold per seat, in the license portal at
`https://studio.guidelane.io/license`. You can use a seat in two ways:

- **Assign it to a user**: on the portal's Users tab, enter the user's email address and choose
  "Give a seat". The user receives their own license key by email. The key works on up to 3 of
  their devices. Choose "Reassign…" to move the seat to another user, or "Remove…" to take it
  back. The key then stops working, and the user's devices lose the license the next time they
  go online.
- **Use a deployment key**: one key for all the devices you manage, which you add to their
  managed settings. Each device the key activates uses one seat. See
  [Rolling out to managed devices](managed-devices.md).

On the portal's Admins tab, you can add other users who manage the seats. On the Billing tab, you
can see your purchases and buy more seats.

## Devices without internet access

You can activate Guidelane Studio without a network connection. On the device, open Settings,
then License, and choose "Activate without a network". Guidelane Studio shows a request code.
Enter that code in the license portal on another device, then copy the certificate file the
portal gives you to the offline device.
