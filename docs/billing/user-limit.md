# What happens at the user limit

The Basic plan allows up to 10 users. Standard has no limit. [How users are counted](plans-and-seats.md#how-users-are-counted) covers what makes a user, including pending invites.

!!! note "Participants never count"
    Only team members and pending invites use up the limit. The number of participants you support has no effect on it.

## When you reach the limit

With 10 of 10 users on Basic:

- The **Invite** button in **Admin → Users** is unavailable and the portal says `Basic allows 10 users — upgrade to Standard`.
- **Reactivating** a suspended member is refused with the same message, because they would take a seat.
- Someone **accepting an invite you already sent** is never refused. Their invite already counts as a user, and accepting it turns that invite into the member without adding a second one.

## If you are over the limit

Your count can be above 10 if, for example, users were already in place when you moved to Basic. Nobody is suspended, signed out or made read-only. Every record stays exactly as it is, and only **adding users** is blocked until you are back under the limit.

## Making room

Pick whichever fits:

1. **Revoke pending invites** that are no longer needed in **Admin → Users**. A revoked invite stops counting straight away.
2. **Remove access for members** who no longer need it. See [Removing access](../admin/invite.md#removing-access).
3. **[Change to Standard](change-plan.md)** to remove the limit altogether.
