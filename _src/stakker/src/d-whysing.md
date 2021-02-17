# Why single-threaded?

Consider the levels of locality that different actor systems operate
over, along with the different restrictions on message contents for
each.  (Note that if actors are intended to migrate, then the
restrictions apply to actor state as well.)

Here are some levels with example types to illustrate this:

Locality | Message | Actor ref | Pass data by ref | Share mutably
:--- | :--- | :--- | :--- | :---
Thread | `'static` | `Rc` | `Box` or `Vec` | `Rc<Cell>` or [`Share`]
Process | `Send` | `Arc` | `Box` or `Vec` + `Send` | `Arc<Mutex>`
Distributed | serializable | ID | n/a | n/a

(Note that `'static` means "no active borrows to stuff that might go
away", which is just Rust's borrow checker making sure you don't crash
your process.)

If your whole actor system is going to have a uniform interface, you
need to pick your level, commit to it and optimise for it.  Doing half
of one and half of another might give some of the benefits of both,
but it also brings the restrictions of both.  This results in
implementations having to take "opinionated" positions.

For a multi-threaded actor runtime, you pay the cost of
synchronization and then must hope that maxing out as many cores as
possible makes up for those costs in the application area of interest.
For a distributed actor runtime, you accept the limitations and costs
of everything being serializable in order to gain the benefit of
distributed execution.  However if we choose to limit ourselves to a
single thread, then we can avoid those restrictions entirely and stay
low-level and fast, free to use non-`Send` types and so on.

**Stakker**'s design decisions means it naturally fits the
fully-committed single-thread approach, which it takes full advantage
of.  Allowing seamless migration of actors between threads and
redirection of queued calls to other threads would mean abandoning a
lot of the single-thread performance and distinctive features of
**Stakker**.  So for now **Stakker** concentrates on the low-level
goal of fast operation within a single thread.

Maybe in the future it might be possible to add some kind of a
distributed or inter-thread message-passing layer above existing
**Stakker** actors.  There are some questions, though:

- What kind of application scenario are we targetting?
- Should we enable actors to migrate?  To other threads?  To other
  machines?
- Should there be proxy actors to redirect calls, or some kind of
  direct message-sending mechanism?
- How can we protect local same-thread calls from these overheads?
- How should we represent references to actors that are on another
  thread or another machine?  With the existing actor-reference types
  and proxies, or with new types?

There's not just the question of whether it can be done (which
obviously it can), but whether it can be done efficiently, and whether
the ergonomics can be made natural and comfortable for the coder.

This might be an interesting thing to investigate at some point.

[`Share`]: https://docs.rs/stakker/*/stakker/struct.Share.html
