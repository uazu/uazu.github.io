# Why use actors?

If you find that your code has to accept events from more than one
direction, and has to react correctly to each event based on the
current state, and has to deal with a lot more variations than a
"happy path, or fail", then actors provide a convenient way to manage
that complexity.  There is a reason why a lot of networking is based
around state machines!  An actor is essentially the implementation of
a state machine and the transitions between those states in response
to events.

In addition, dividing a larger problem into a set of asynchronously
interacting actors means that each small part of the problem can be
analysed and understood clearly in isolation, and tested
asynchronously independently of the rest of the system.

Also, the abstraction provided by actors naturally allows interacting
actors to be separated and run remotely if necessary.  Since
inter-actor calls are asynchronous, no actor can depend on synchronous
responses, so distributed and remote operation comes naturally.  The
only thing required is some glue to pass the inter-actor calls over a
protocol.

However for a long sequence of asynchronous operations that either
advance to the next or fail, a sequential "actor coroutine" style
might make the code clearer than an event-driven actor style.  So
adding async/await or generators on top of the actors, to provide
something like a coroutine that can be driven forward by actor events
is a possible future direction for **Stakker**, if it can be made
efficient.
