# Queue execution behaviour

The normal pattern is to introduce one or more events into the system
as actor calls pushed onto the main queue, and then to run the queue
to completion.  This means that the queue is run repeatedly until it
is empty.  You can imagine that a queued call to the actor may trigger
other calls as a consequence, and those might cause other calls, but
eventually all the necessary changes will finish propagating through
the system of actors, and then things will go quiet again.

**Stakker** always runs the main queue to completion before doing
anything else.  This means that if you wish to avoid saturating the
CPU, it's necessary to regulate fetching input data or accepting input
events.  Load regulation does not occur within the actor system.

To aid with this, two additional queues are provided:

- The first is the "lazy" queue.  This is run when the main queue is
  fully exhausted, but before checking for new I/O events.  As an
  example, it can be used to help batch output together into a single
  big flush.  For example when writing to TCP, executing the main
  queue might mean several chunks of data being written to a stream's
  output buffer.  Flushing after each write would be inefficient, and
  flushing after a delay would be too slow.  Instead an actor can put
  the flush call on the lazy queue, and do one big flush once the
  current batch of processing is complete.

- The second is the "idle" queue.  This is executed only when the
  thread becomes idle, i.e. the main and lazy queues are empty and
  there are no new external events that need handling.  This may be
  used to apply back-pressure on an incoming stream, by fetching more
  data only when there is nothing else to do.  When there are several
  items on the idle queue, they will execute in a round-robin fashion,
  assuming each call pushes a new call back onto the queue when it
  executes.
