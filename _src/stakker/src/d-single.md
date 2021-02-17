# Maximised single-threaded performance

Each **Stakker** instance is oriented around running as fast as
possible within its own thread, avoiding any synchronization
completely unless specifically requested.  So a single **Stakker**
instance and all of its associated actors are intentionally limited to
running on a single thread.  Unless something uses a [`Waker`], there
should be no code in **Stakker** that will cause execution of any kind
of a CPU memory fence or other synchronization primitive.  So the CPU
core can run at full speed.

This means that inter-actor calls can be very fast.  With the default
features, making or executing an actor call does not require a memory
allocation.  A closure is added to the end of a queue stored in a flat
preallocated buffer, and is then later executed straight out of that
buffer.  The average call cost varies by load, but overall it is
roughly similar to calling things through `Rc<RefCell>`, once code has
been added to handle reentrant calls in a `Rc<RefCell>`-based
solution.

Some example deployment scenarios:

- When the workload can be comfortably handled by a single core,
  **Stakker** works more efficiently than a multi-threaded runtime
  because there are no synchronization costs.  This fits the
  traditional efficient "main thread" select/epoll non-blocking I/O
  model used by many internet servers and GUI applications.

- When the event-driven workload requires more than one core, several
  **Stakker** instances (each with their associated actors) may be
  run, on different cores and/or on different machines.  Workload must
  then be distributed between them at a higher level using sharding or
  some other form of load balancing.

- In both cases when there is heavy processing to do, then that
  processing could be offloaded to a threadpool.  In this case the
  synchronization costs are small compared to the saving in processing
  costs in the event-driven thread, and typically there will be no
  contention with other threads as the background processing runs.

Essentially if you're going to scale beyond one machine, you're going
to have to solve the problem of work distribution between processing
units anyway.  So you might as well make your processing units run as
fast as possible, which means running each of them on a single thread.
Using a certain amount of synchronization between a group of
independently-running threads is fine, for example to share common
immutable data, but it's best to think hard before introducing shared
mutable state between threads, or too much locking, or too much
inter-thread messaging.  By staying low-level, **Stakker** forces you
to think about that.  What is easy is fast, and what is slower takes
more effort.

**Stakker**'s approach won't suit all applications, but that is fine.
There are other crates to handle the other scenarios.  **Stakker**
concentrates on being efficient within its own niche.

[`Waker`]: https://docs.rs/stakker/*/stakker/struct.Waker.html
