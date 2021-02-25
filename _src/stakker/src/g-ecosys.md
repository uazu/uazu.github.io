# Finding **Stakker**-compatible crates

Here are some considerations to help decide whether a crate is usable
with **Stakker**:

- **Non-blocking:** If it is going to be called directly from an
  actor, the crate must never block or sleep, because that would hold
  up all the work of the whole thread.

- **Data processing only:** If it just does data processing when
  called, and doesn't require any I/O or timers or anything, then that
  would be straightforward to use.  (For example [**regex**] crate.)

- **Event-loop independent:** If it requires I/O but says it can run
  on top of any event loop, then that is a very good sign.  Even
  crates that may appear dependent on a particular I/O system (`mio`,
  Tokio, etc) might still be usable if the protocol handling can be
  called independently.  (For example [**tungstenite**])

- **Event-loop providers:** If a crate provides an event loop (or the
  basis for an event loop), for example SDL or `mio`, then **Stakker**
  can almost certainly be run on top of it, so long as the underlying
  crate can guarantee that **Stakker** is always called from the same
  thread.

Where a required crate can't be run on top of **Stakker**, for example
a crate that depends on Tokio, then you can still run it in the same
process by running Tokio in another thread and communicating with the
**Stakker** thread via channels.

A possible future extension to **Stakker** would be to add a simple
async/await executor, one that allows a subset of async/await crates
to run, for example ones that can process futures or streams passed
from the actor runtime, and that don't require direct I/O themselves.

[**regex**]: https://crates.io/crates/regex
[**tungstenite**]: https://crates.io/crates/tungstenite
