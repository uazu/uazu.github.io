# Data kept alongside the actor internal state

Due to the borrowing approach, the actor state is split into two parts.
The first part is outside the actor cell, and is accessible to any
runtime call that has an actor reference:

- Weak reference count
- Strong reference count
- Actor state: **Prep**, **Ready**, **Zombie**
- Termination notifier `Ret<StopCause>`
- A [`Deferrer`] instance

The [`Deferrer`] is required in order to support dropping the last
[`ActorOwn`].  It is also used for [`Fwd`] and [`Ret`] instances
calling the actor, and to support [`call!`] when only the actor is
mentioned.  It also means that any drop handler that has access to an
actor reference also has a [`Deferrer`] available.

Note that [`Rc`] is not used to handle the weak and strong references,
because we need to keep some data outside the cell that is accessible
to a weak reference even if the strong reference count has gone to
zero.  Also we need to be able to terminate the actor even when there
are still strong references.

The second part is inside the actor cell, and so is only accessible
when there is a `&mut Stakker` reference available.  So this is not
accessible within calls to other actors, where the `&mut Stakker`
reference is occupied by the borrow that enables access to the actor
cell for that call.  The actor cell contains:

- For **Prep**: [`FnOnce`] queue to store calls attempted before the actor
  is **Ready**
- For **Ready**: `Self` value for the actor

[`ActorOwn`]: https://docs.rs/stakker/*/stakker/struct.ActorOwn.html
[`Deferrer`]: https://docs.rs/stakker/*/stakker/struct.Deferrer.html
[`FnOnce`]: https://doc.rust-lang.org/stable/std/ops/trait.FnOnce.html
[`Fwd`]: https://docs.rs/stakker/*/stakker/struct.Fwd.html
[`Rc`]: https://doc.rust-lang.org/stable/std/rc/struct.Rc.html
[`Ret`]: https://docs.rs/stakker/*/stakker/struct.Ret.html
[`call!`]: https://docs.rs/stakker/*/stakker/macro.call.html
