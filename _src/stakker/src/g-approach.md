# Getting used to the actor way of thinking

If you're accustomed to sequential-style coding, e.g.  **async/await**
or **Go**, maybe the switch to actor-based coding will seem very
strange.  Despite its simplicity it may take some getting used to.

Remember that in an actor system there are only two principal things
to consider:

- The actor's own state (i.e. the contents of its `struct` and any
  other data it has synchronous access to)
- The incoming messages (aka "events" or "incoming calls")

When you write a behaviour for an actor, i.e. an actor method that
handles an incoming "message" or "call", then your focus is very
narrow.  You consider how the actor should react to the incoming
event, *considering only the current state of the actor.*

Then your reaction to the event will likely be one or more of the
following:

- Update the actor's state
- Send one or more messages to other actors
- Set or update timers
- Call methods outside of the actor system (e.g. send I/O)

Once you have completed your handling of that event, the job is done
and you return.  Anything that you need to remember to do later will
either have been encoded into the state of the actor, or else already
put in motion as a timer or an actor call.

This is in some ways similar to some approaches to personal
time-management.  By keeping the focus narrow, it makes it easier to
reason about the problem, one small step at a time.

So this is the essence of how an actor works within an actor system:
It simply makes a sequence of small decisions as events come in, one
small step at a time.  However this is a surprisingly powerful way of
handling complexity.

When events may be coming in from various directions, and when using a
sequential model of thinking that focuses on the "happy path", it is
hard to be sure that all the combinations of asynchronous error
conditions and event orderings have been handled correctly.  However
in the actor model, each event is evaluated in the context of the
actor state as it exists at the moment of the event's arrival.  The
"happy state" for that event has equal weight to all the "error
states" in the consideration of the coder.

The other thing that an actor system allows you to do is to have
multiple requests active (i.e. "in flight" or "in progress") with
various other actors at the same time, if that is required.  Those
responses might come back quickly or slowly, and will be dealt with
one by one as they arrive.  Maybe other operations will be triggered
as some of them come back, and complete before or after the other
responses arrive.  All this complexity is handled easily by just
considering each incoming message one at a time in the context of the
actor state.  To do something similar in async/await-style code would
be impossibly complicated.  That level of asynchronicity is just not
easy to handle in a sequential model, but it comes completely
naturally in the actor model.

This is not to say that there is no value in sequential coding styles.
There are "painfully sequential" problems which can't be broken down
into concurrent operations, which can be written very naturally and
simply in the sequential style.  But when the asynchronous complexity
rises, the actor model scales much better to handle it.  It is no
accident that many low-level network protocols are specified as state
machines, and that's essentially what an actor is: The concrete
implementation of a state machine.
