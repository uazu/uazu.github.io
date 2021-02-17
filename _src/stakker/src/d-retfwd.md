# Difference between `Ret` and `Fwd`

Both of these types allow specifying a callback or call-forward,
usually to an actor method but possibly to some other destination.
But there are some important differences:

- [`Ret`] can be called only once, and [`Fwd`] may be called many
  times
- [`Ret`] cannot be cloned, but [`Fwd`] has ref-counting and there may
  be many references to the same [`Fwd`] callback
- [`Ret`] can capture "move" types
- [`Ret`] is consumed when it is called
- [`Ret`] notifies the callback if it is dropped without being called

Whilst the names suggest uses of returning or forwarding data, there
are no restrictions about where the data is sent.  So a [`Ret`] may
'return' data back to some other actor than the caller if required.

[`Fwd`]: https://docs.rs/stakker/*/stakker/struct.Fwd.html
[`Ret`]: https://docs.rs/stakker/*/stakker/struct.Ret.html
