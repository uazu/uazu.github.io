# Event source independence

The core actor runtime crate of **Stakker** has no dependency on any
event system.  An interface to **mio** is provided as the
[**stakker_mio**] crate, but it should be possible to integrate
**Stakker** into any event system, even ones written in other
languages.

All that **Stakker** requires is that the external event system
provides it with one timeout (to wake it when the next **Stakker**
timer expires), and that it delivers events to it as calls pushed onto
the **Stakker** queue.

[**stakker_mio**]: https://crates.io/crates/stakker_mio
