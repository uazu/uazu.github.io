# Overhead of an actor

With default features on a 64-bit platform, an actor requires one
allocation of 48 + `Self` bytes for the actor, and a second allocation
of 8 bytes for the termination notifier.  The details follow:

The table below shows the sizes requested from `malloc`, so include
the internal data used by the reference-counting implementation.

Features | 1000-byte actor | Overhead | Notifier | 0-byte actor
:---: | :---: | :---: | :---: | :---:
default | 1048 | 48 | 8 | 72
no-unsafe | 1056 | 56 | 8 | 80
all features | 1080 | 80 | 8 | 104

The Overhead column shows the bytes used above the actor's own
`Self` instance size.

The Notifier column shows the bytes required for a simple [`Ret`]
instance created using [`ret_to!`] to notify a parent of the
termination of this actor.  This is a separate allocation because it
is variable-sized in general.  Note that the Notifier overhead is
optional, as you can use [`ret_nop!`] which avoids that allocation,
but normally it will be required.

Regarding the 0-byte actor column: The actor's `Self` structure is in
a union with a [`FnOnce`] queue, so `Self` structures smaller than 24
bytes still consume the minimum 24 bytes.

[`FnOnce`]: https://doc.rust-lang.org/stable/std/ops/trait.FnOnce.html
[`Ret`]: https://docs.rs/stakker/*/stakker/struct.Ret.html
[`ret_nop!`]: https://docs.rs/stakker/*/stakker/macro.ret_nop.html
[`ret_to!`]: https://docs.rs/stakker/*/stakker/macro.ret_to.html
