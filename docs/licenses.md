# Licenses

The server itself needs no license. Each device that uses it does: Guidelane Library is part of
the Guidelane Studio Business plan.

| On the device | Can it use the server? |
|---|---|
| A Business license, from a seat or a deployment key | Yes. |
| A trial with days left | Yes. Every trial includes everything, the server too. |
| A Personal license | No. Guidelane Studio says "Guidelane Library needs a Business license." and offers to buy one. |
| A trial that has ended, or a license that ended or was revoked | No. |

## What the server checks

Each device sends the server its license certificate when it joins, whenever its license
changes, and every hour. The server checks the certificate's signature with the same keys that
Guidelane Studio uses to check it, and checks that the certificate was issued for that device.
A device therefore cannot claim a license it does not hold. The server needs no internet
connection for this.

A device without a license that includes the server cannot join. A device that joined and then
lost its license, for example when its trial ended, stays on the admin page's Devices tab. The
server refuses every request from that device until the device holds a Business license again,
and Guidelane Studio hides the server's guides in the meantime. Guides on the device itself
stay there, and the person can still view them, and export or back them up as .gdl files.

The admin page's Devices tab shows who each device's license belongs to, or how many days its
trial has left.

## Seats

Business licenses are sold by the seat, in the license portal at
`https://studio.guidelane.io/license`. A seat is used in one of two ways:

- **A seat given to a person**: in the portal's Users tab, enter their email address and choose
  "Give a seat". They receive their own key by email. The key works on up to 3 of their
  computers. Choose "Reassign…" to move the seat to someone else, or "Remove…" to take it back.
  Their key then stops working, and their computers lose the license the next time they are online.
- **A deployment key**: one key for the computers you manage, which you put in their managed
  settings. Each computer it activates uses one seat. See
  [Rolling out to managed devices](managed-devices.md).

On the portal's Admins tab, you can add other people who manage the seats. On its Billing tab,
you can see the purchases and buy more seats.

## A computer that is never online

You can activate Guidelane Studio without a network. On the computer, open Settings, then
License, and choose "Activate without a network". Guidelane Studio shows a request code. Enter
the code in the license portal on another device, and take the certificate file the portal gives
you back to the computer.
