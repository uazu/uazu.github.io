# Becoming an actor system

So at this point we have:

- Components which can be addressed from anywhere, with ref-counting
  references to them

- No access to component state and no possibility to make direct calls
  to a component from another component, all guaranteed by the borrow
  checker

- A queue that allows calls to methods on other components to be
  deferred to run later

This is so close to an actor system, that we might as well formalize
it as one to make it easier to reason about.

However, compared to other actor systems, there are no per-actor
message queues, and the 'messages' are actually [`FnOnce`] closures
which call a method directly on the actor, rather than some arbitrary
message structure that needs to be interpreted.  So it is much closer
to actors as provided by the Pony language, rather than some classical
actor system where all the messages are visible and dealt with by
hand.

Effectively each actor method on a **Stakker** actor takes the role of
a message type, and the arguments of that method take the role of the
data of that message.

[`FnOnce`]: https://doc.rust-lang.org/stable/std/ops/trait.FnOnce.html
