# Handling expected and unexpected actor termination

There are four ways that an actor can terminate.  These are
enumerated by the [`StopCause`] enum:

- `Stopped`: Successful termination
- `Failed`: Actor terminated itself due to some problem
- `Killed`: Actor was killed by another entity
- `Dropped`: The last [`ActorOwn`] referencing this actor was dropped

Both `Failed` and `Killed` have an associated boxed [`Error`].  When
an actor is created, a notification handler `Ret<StopCause>` is
normally provided.  This receives the reason for the actor's
termination when it terminates.  So usually a parent actor will keep a
hold of the [`ActorOwn`] for the child actor within its own state, and
will receive the termination notification.  However other patterns are
also possible.

On receiving a termination notification, the parent actor might choose
to restart the child, or terminate itself, or take some other action.
The parent actor has a free choice on how to handle it.  It is
possible to downcast the [`Error`] to take a different action
depending on the type of failure if necessary.

[`ActorOwn`]: https://docs.rs/stakker/*/stakker/struct.ActorOwn.html
[`Error`]: https://doc.rust-lang.org/stable/std/error/trait.Error.html
[`StopCause`]: https://docs.rs/stakker/*/stakker/enum.StopCause.html
