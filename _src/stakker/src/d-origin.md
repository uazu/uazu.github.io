# Origin

The **Stakker** crate didn't start out as an actor library.  Rather it
started out as an exploration of how to deliver events to the correct
contexts for them to be handled, and doing that in a way that is fully
compatible with "the Rust way", i.e. that takes full advantage of
Rust's approach to borrowing and ownership.

So effectively this is a low-level actor crate that evolved directly
and organically from Rust's fundamental principles, from the ground
up.
