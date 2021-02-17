# Delivering events

The next problem is how to deliver events.  One approach is to deliver
an event to the destination as soon as it occurs, as a direct method
call.  However this results in nested callbacks on the stack, i.e. one
event causes an event handler to be called on another object, which in
responding to that event causes other events to be generated, calling
event handlers in other objects, all before the original event handler
has completed.  The main problem with this approach is that it can
lead to re-entrant calls to the same object, which in other languages
can result in very hard to understand bugs.

However in Rust there is a bigger problem, because a re-entrant call
will require borrowing the same object twice.  If we use [`RefCell`],
we'll only discover this bug if we're lucky enough to come across it
in testing.  However if we use [**qcell**] instead, there is
absolutely no way to construct a program that will execute a
re-entrant call on an object.  So letting Rust do compile-time
borrowing checks on data behind [`Rc`] pays off, because it forces us
to adopt a design that has none of the problems that are easy to
produce in other languages accidentally.

So to avoid borrowing problems and re-entrant calls, event sending and
event delivery must be separated, which means that a queue is
necessary.  The most fundamental queue would be one that stores a list
of [`FnOnce`] closures to execute later.  It's possible to make this
efficient by storing the closures in a flat `Vec<u8>`, which means
that no allocations are required to send a message, so long as the
queue buffer has grown big enough.

This also demonstrates another pattern in Rust, that Rust's rules seem
to lead to shallow call-stacks.  This is because when a borrow is
active, that often restricts access to other things.  To get access to
those things again means dropping back down the stack again.  Also
when borrows are passed deeper and deeper into the code, they seem to
become more and more invasive and restrictive, as you end up having to
annotate more and more functions and structures with lifetimes.

Using a [`FnOnce`] queue to defer operations untangles all of this and
means that each operation is run directly from the main loop with the
minimum restrictions from the borrow checker.

[**qcell**]: https://crates.io/crates/qcell
[`FnOnce`]: https://doc.rust-lang.org/stable/std/ops/trait.FnOnce.html
[`Rc`]: https://doc.rust-lang.org/stable/std/rc/struct.Rc.html
[`RefCell`]: https://doc.rust-lang.org/stable/std/cell/struct.RefCell.html
