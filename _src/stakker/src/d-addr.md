# Addressing events to objects

The most natural way to organize objects or components in core Rust is
in tree-like graphs with single ownership and no cross-references or
back-references within the tree.  However to manage an event system,
events must be delivered to specific objects or components.  So some
form of references to those objects are required to support the event
system.

In Rust's standard library, multiple ownership or long-lived direct
references within a heterogeneous set of objects means using [`Rc`].
However this also means giving up compile-time borrowing checks and
reverting to [`RefCell`], which does run-time checks instead.
Immediately we've lost one of Rust's most important compile-time
checks.  Investigating how to regain this compile-time check resulted
in the [**qcell**] crate, which re-enables zero-cost compile-time
checks of ownership behind [`Rc`] references.

So this means that we can now have both [`Rc`] references and safe
mutable access to the [`Rc`] contents without any run-time checks or
run-time cost.

[**qcell**]: https://crates.io/crates/qcell
[`Rc`]: https://doc.rust-lang.org/stable/std/rc/struct.Rc.html
[`RefCell`]: https://doc.rust-lang.org/stable/std/cell/struct.RefCell.html
