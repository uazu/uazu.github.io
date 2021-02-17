# Actor guarantees

**Stakker** is not a 100% strict actor system.  Due to Rust's interior
mutability (e.g. `Rc<Cell>`, `Rc<RefCell>`, `Arc<Mutex>`, etc), it is
hard to totally forbid shared mutable state between actors.  Also
there are cases when shared mutable state may be useful for
performance reasons.  So **Stakker** accepts the existence of shared
mutable state and also offers the [`Share`] type which provides
zero-cost compile-time-borrow-checked shared mutable data between
actors.

Sharing mutable state breaks the actor model and so must be used with
care (if used at all), as it might complicate the coder's ability to
reason cleanly about their code.  The danger is about the same as
using IPC shared memory between processes, or shared buffers between
threads.  However there are no locking concerns as Rust's borrow
checker ensures that the coder has exclusive access whilst they hold a
mutable reference to shared state.

The external interface of a group of actors bound together by shared
mutable data still follows the actor model.  So whilst the actor model
is broken within the group, the larger system is still easy to reason
about.  It's only necessary to take care about interactions within
that group.

So this means that it's possible to break up a single actor into many
smaller actors where it is cleaner in the code to receive events
directly to those actors, and yet they may still work together using
shared mutable state if necessary for efficiency reasons.

Remember that the purpose of actors in **Stakker** is only to provide
a context that is capable of receiving events.  You can create complex
trees and tables of logical components within a single actor, and that
is fine.  Not everything needs to be an actor.  However as soon as an
individual component needs to receive and handle events itself
(including timers), it's likely that the code will be simplified by
splitting it out as a separate actor.  The cost of doing so in
**Stakker** is small.

Making **Stakker** an actor system by default means that most of the
code is easy to reason about locally, but those parts that need some
extra performance through shared mutable state can still be written
efficiently.

So, in **Stakker**:

- Rust's guarantees *always* apply

- The actor-model guarantees *always* apply regarding forbidding
  access to another actor's state or methods.  (Not even interior
  mutability can break this.)

- But the actor-model assumption of no shared mutable state only
  applies by default, until the coder intentionally passes sharable
  data between two actors.

[`Share`]: https://docs.rs/stakker/*/stakker/struct.Share.html
