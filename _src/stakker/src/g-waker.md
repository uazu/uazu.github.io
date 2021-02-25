# Inter-thread communication with Waker

The foundation for inter-thread communication in **Stakker** is the
[`Waker`] mechanism.  This uses an atomic bitmap-tree, which means
that many wakeup events from other threads will be accumulated into a
single I/O event on the **Stakker** thread, using only a small number
of atomic operations to recover them, keeping the load on the
**Stakker** thread low.

A [`Waker`] will normally be paired with a channel or some other
shared mutable state, e.g. data within a `Mutex`.  So the [`Waker`] is
used to notify a handler in the **Stakker** thread that it needs to
examine the shared state and respond to whatever it finds there.

[`PipedThread`] is an example of this, combining a thread, two message
pipes and a [`Waker`].  This provides a convenient way to handle some
very simple scenarios for running heavy or blocking calls in another
thread.  However it should be straightforward to build other
inter-thread communication methods on top of [`Waker`].

One thing to note is that when using channels such as `crossbeam`,
ideally we'd want to only notify the [`Waker`] when the channel is
empty at the instant that the message is added.  However the channel
APIs typically don't give us a way to detect this condition.  (Perhaps
it's not even possible to detect this in some cases due to how the
channel is implemented.)  Attempting to detect it with an `is_empty()`
call on the channel before adding the message is doomed to
intermittent failure due to races.  So this means that another thread
adding something to a channel for the **Stakker** thread to pick up
must notify the [`Waker`] on every message sent.  So [`Waker`] is
designed to make this as cheap as possible.  After the first time, it
will take only one atomic operation.

[`PipedThread`]:  https://docs.rs/stakker/*/stakker/struct.PipedThread.html
[`Waker`]: https://docs.rs/stakker/*/stakker/struct.Waker.html
