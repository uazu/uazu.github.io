# Fast message execution

When an actor call is deferred to the [`FnOnce`] queue, for example
with the [`call!`] macro, the type and target method and any constant
arguments are fully known to the Rust compiler.  The only variables
are the target actor's address and the remaining arguments.  Rust can
inline and optimise this closure, effectively specializing it to the
type and method and the constant arguments provided.  So this means
that the closure might never even branch to the actor's code, since
that might all have been inlined and optimised down.  So the queue can
execute much faster than any kind of traditional actor messaging
system.  The call effectively bypasses all the message creation and
interpretation, and directly calls (or inlines) the actual actor code
that needs to be run.

Similarly, where an arbitrary callback is required (using [`Fwd`] or
[`Ret`]), for example where the type of the target actor is not known
to the calling actor, this is handled as two closures.  The first
closure accepts the arguments in the [`Fwd`] signature, and pushes the
second closure to the [`FnOnce`] queue.  The second closure is just
like a normal [`call!`], so can be fully optimised down to a specific
type and method.  The first closure is just some glue that assembles
the variable arguments ready for the second closure.  So again, this
is as direct as you can get, with no superfluous activity.

So again, aligning with Rust's strengths and making full use of Rust's
compile-time checks and compile-time knowledge pays off.

[`FnOnce`]: https://doc.rust-lang.org/stable/std/ops/trait.FnOnce.html
[`Fwd`]: https://docs.rs/stakker/*/stakker/struct.Fwd.html
[`Ret`]: https://docs.rs/stakker/*/stakker/struct.Ret.html
[`call!`]: https://docs.rs/stakker/*/stakker/macro.call.html
