# Privilege levels

Another way of looking at the statically-checked cell borrowing
approach used by **Stakker** (i.e. [**qcell**]-based borrowing) is to
consider all the code associated with the actor system as belonging to
one of three privilege levels.

**Level 0**: Code in the highest level of privilege has access to a
`&mut Stakker`.  This is the code outside of the actor system (the
main loop and any associated external code that the actor system
interfaces to) and the code called by the main loop that handles a
queue-deferred action (actor call, return, forward, etc).  In terms of
statically-checked borrowing, both the [`Actor`]-owner and
[`Share`]-owner are available.

**Level 1**: Actor methods all run in this level.  They have a `&mut
Core` (maybe via a `&mut Cx`), but have no access to [`Stakker`]
methods.  In terms of statically-checked borrowing, the
[`Actor`]-owner is unavailable (because it was used to get access to
the actor state), but the [`Share`]-owner is still free.

**Level 2**: Methods called on [`Share`] objects run in this level, as
well as `Drop` handlers.  In fact any code which doesn't accept a
`&mut Core` or `&mut Cx` argument runs in this level.  Neither of the
cell owners are available.  In the case of a method call on a
[`Share`] object (e.g. `share.rw(cx).method(args)`), the `&mut Core`
isn't available because it was used to get access to the share.

If you take a snapshot of the callstack at any point in time you'd
find code running in one or more of these levels.  At the base of the
stack would be the main loop code, in level 0.  If an actor method is
running then this would be code in level 1.  If the actor is calling
out to [`Share`] code or arbitrary external libraries, this would be
code in level 2.  The levels form bands on the callstack.

Here are some examples of different things you can do at different
levels:

| Level: | 0: main loop | 1: actor methods | 2: share methods,<br/>drop handlers |
| - | :-: | :-: | :-: |
| Available borrow: | `&mut Stakker` | `&mut Core` or<br/>`&mut Cx` | none |
| Run the queues | Yes | - | - |
| Run an actor call | Yes | - | - |
| [`query!`] an actor | Yes | - | - |
| [`lazy!`], [`idle!`] | Yes | Yes | - |
| [`after!`], [`at!`], etc | Yes | Yes | - |
| Access a [`Share`] | Yes | Yes | - |
| [`ret!`] data to [`Ret`] | Yes | Yes | Yes |
| [`fwd!`] data to [`Fwd`] | Yes | Yes | Yes |
| [`call!`] an actor | Yes | Yes | Yes |
| defer using [`Deferrer`] | Yes | Yes | Yes |

Remember that these levels are statically enforced by the compiler
(without any runtime overhead), so there is no way around it in safe
code.  However note that even in level 2, you can defer an operation,
or forward data elsewhere.  So the system of "privileges" only stops
you doing things *right now*.  It doesn't stop you doing them a little
bit later.  So it blocks synchronous operations when those could
potentially cause issues, but doesn't stop you doing those same things
asynchronously.

Also note that even in the internal code of **Stakker** it's
impossible to break these rules.  The rules are enforced by the Rust
compiler and a tiny bit of code in [**qcell**].  If a borrow is
performed to get access to an actor's state, then the `&mut Stakker`
borrow is locked up until that actor borrow is released.  Similarly a
share borrow locks up the `&mut Cx` or `&mut Core`.  See [**qcell**]
documentation for more details.  So this provides a very strong
guarantee of correctness.

[**qcell**]: https://crates.io/crates/qcell
[`Actor`]: https://docs.rs/stakker/*/stakker/struct.Actor.html
[`Deferrer`]: https://docs.rs/stakker/*/stakker/struct.Deferrer.html
[`Fwd`]: https://docs.rs/stakker/*/stakker/struct.Fwd.html
[`Ret`]: https://docs.rs/stakker/*/stakker/struct.Ret.html
[`Share`]: https://docs.rs/stakker/*/stakker/struct.Share.html
[`Stakker`]: https://docs.rs/stakker/*/stakker/struct.Stakker.html
[`after!`]: https://docs.rs/stakker/*/stakker/macro.after.html
[`at!`]: https://docs.rs/stakker/*/stakker/macro.at.html
[`call!`]: https://docs.rs/stakker/*/stakker/macro.call.html
[`fwd!`]: https://docs.rs/stakker/*/stakker/macro.fwd.html
[`idle!`]: https://docs.rs/stakker/*/stakker/macro.idle.html
[`lazy!`]: https://docs.rs/stakker/*/stakker/macro.lazy.html
[`query!`]: https://docs.rs/stakker/*/stakker/macro.query.html
[`ret!`]: https://docs.rs/stakker/*/stakker/macro.ret.html
