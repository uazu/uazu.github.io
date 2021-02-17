# Time virtualization

Actors should use `cx.now()` to get the current `Instant`.  The
current time is provided to **Stakker** by the external code that is
running the event loop.

This has several consequences.  For one, a batch of processing will
all occur at the same logical time.  Another is that the overhead of
constantly calling `Instant::now()` throughout the code is avoided.
(`Instant::now()` uses a `Mutex` on some platforms.)  In addition,
when it's necessary to integrate **Stakker** into non-Rust code, the
current time from that code can be used instead of Rust's idea of
time.

However a more interesting aspect of this is that it allows time to be
virtualized.  So you can make time appear to go faster or slower than
realtime.  You can skip over long sleeps when testing your
application, or trigger timeouts when testing an individual actor,
without consuming real time to do so.  If you have a suitable external
tool communicating with your main loop, you can coordinate a group of
processes to skip over common sleeps to accelerate any testing that
isn't CPU-bound.  The **Stakker** runtime and the application won't
know the difference.
