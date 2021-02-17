# Roadmap

Currently **Stakker** is performing well for the applications it is
being used in, so there is no urgent need for new features.  However
that does not mean it is "done".  Things will be added gradually as
new requirements are discovered and refined.

Here are some near-term plans (6 months):

- More fully test running on top of a C++ language event loop within
  another application, e.g. using **Stakker** in a library with a C++
  interface

- Benchmark timer-queue performance, and then optimise, e.g. changing
  to an N-ary heap

Waiting for new Rust language features:

- If Rust one day supports enums or unions containing a DST on one
  variant (like an `Option<dyn Trait>` or a `MaybeUninit<dyn Trait>`),
  then it would be possible to do `Actor<dyn Trait>` instead of
  `Actor<Box<dyn Trait>>` as at present (see [`actor_of_trait!`]).

- If Rust had better support for working with VTables and fat
  pointers, then a lot of unsafe code could be eliminated from the
  flat FnOnceQueue.  See: https://github.com/rust-lang/rfcs/pull/2580

- If Rust supported passing borrows and lifetimes into the generator
  resume function, and generators were stabilized, then they could be
  used to implement actor coroutines.  See:
  https://github.com/rust-lang/rust/issues/68923

Further ahead:

- Write more varied applications with **Stakker**, and see if that
  suggests any more features that need adding.  If other people start
  using **Stakker**, that may also suggest more features.

- Maybe switch all macros over to procedural macros to allow `cx` to
  be picked up automatically from the context, to make code more
  concise.  (`macro_rules!` hygiene normally forbids this, but
  procedural macros have different rules.)

- Look at ways to proxy calls between actors on different threads or
  different machines, i.e. where a local actor acts as a proxy for a
  remote actor and forwards calls and responses

- Investigate writing crates to allow Stakker to be layered on top of
  other runtimes, e.g. **tokio** or **async_std**.

- Investigate writing a simple async executor on top of **Stakker** to
  interface directly to async/await style code in the same thread.
  However if this is to be done at all it needs to be very low-level
  and efficient, ideally avoiding any synchronisation, memory fences,
  atomic operations, mutexes and so on.  Otherwise it might be better
  to run one of the existing executors in another thread instead, and
  communicate data with channels to keep the **Stakker** thread lean.

- Possibly look at making use of generators or async/await to allow
  writing sequential-style actor coroutines within an actor.  This
  would allow making a call to another actor and receiving the `Ret`
  directly in the code.  The main difficulty is passing the `Cx` (with
  its lifetime) up into the coroutine at each resume, and having it
  drop at each yield.  Because of the low-level nature of **Stakker**,
  this needs to be efficient to be a good fit.  This will probably
  require a good deal of experimentation and tweaking to find the
  right ergonomics, and the best low-level fit.  There's no sense in
  rushing it.

- Support off-loading CPU-intensive or I/O work to a threadpool.  If
  actor coroutines are implemented, then we could simply mark a block
  of code as `offload!` to move it to a threadpool, which would be
  very convenient.

[`actor_of_trait!`]: https://docs.rs/stakker/*/stakker/macro.actor_of_trait.html
