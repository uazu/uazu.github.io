# Deferrer

A [`Deferrer`] is an object that allows a call to be submitted to the
main queue.  Mostly the coder does not need to worry about this,
because there are ways to submit a call from almost everywhere:

- In all actor calls, there is the `cx` context available, which
  allows calls to be submitted directly to the runtime

- Each actor reference has access to a [`Deferrer`] kept in the
  actor's external data, which means that it is always possible to
  submit a call if you have an [`Actor`] or [`ActorOwn`] reference.

However in the case that you need to submit a call from a drop
handler, and that drop handler does not have any actor references
available, you may need to obtain a [`Deferrer`] and store it in the
struct that will be dropped.

Note that a [`Deferrer`] takes zero bytes unless either the crate
feature "multi-stakker" or "inline-deferrer" is enabled.  This is
because if there is only ever a single [`Stakker`] instance running in
the whole process (or thread), we can optimise a [`Deferrer`] to use a
global variable (or thread-local).  Only in the case of needing
multiple [`Stakker`] instances in a single thread (a much rarer case)
does the [`Deferrer`] need to be a direct reference, in which case it
consumes one `usize`.  So you don't pay the cost unless you need it.

[`ActorOwn`]: https://docs.rs/stakker/*/stakker/struct.ActorOwn.html
[`Actor`]: https://docs.rs/stakker/*/stakker/struct.Actor.html
[`Deferrer`]: https://docs.rs/stakker/*/stakker/struct.Deferrer.html
[`Stakker`]: https://docs.rs/stakker/*/stakker/struct.Stakker.html
