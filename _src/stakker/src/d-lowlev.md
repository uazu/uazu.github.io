# *Low-level*, not medium- or high-level

The aim is that the cost of a deferred inter-actor call should be on
the order of a normal direct inter-object call.  Obviously we can
never as low as a direct call, but we want to get as close as
possible.  This means that **Stakker** is not aiming to replace
multi-threaded asynchronous runtimes, multi-threaded asynchronous
message systems, inter-thread channels, distributed systems, or
anything else like that.

Rather **Stakker**'s aim is to replace a mess of `Rc<RefCell<...>>`
and a tangle of direct and indirect inter-object calls (or any other
improvised collection of communicating components in the same thread)
with a nice ordered, well-behaved set of actors, easy to reason about
and maintain.

Higher-level inter-thread load balancing, work distribution and
message passing can be layered on top of **Stakker** as necessary.
