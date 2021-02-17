# Signatures of actor methods

Methods that handle calls made to an actor in the **Ready** state have
the following signature, where "...args..." indicates 0 or
more additional arguments:

```rust,no_run,noplayground
fn method(&mut self, cx: CX![], ...args...) {...}
```

A `&mut self` or `&self` argument gives access to the actor state, and
`cx` gives access to the runtime via the [`Cx`] type.  Methods that
handle calls in the **Prep** state use the following signature:

```rust,no_run,noplayground
fn method(cx: CX![], ...args...) -> Option<Self> {...}
```

These do not have a `self` argument because in the **Prep** state the
actor does not yet have a `Self` value as it is not yet initialised.
If the **Prep** method is ready to put the actor into the **Ready**
state and start handling normal actor calls, it should return a `Self`
value as `Some(...)`.  If it is not yet ready then it should return
`None` and make sure that some external callback or timer is active
that will guarantee that another **Prep** method will run in due
course, to continue with the preparation of the actor, or to
initialise it, or to terminate it with a failure.

Note that methods with any other signature to the ones above are not
callable through the actor system.  Normal Rust visibility rules apply
to the methods, so if these calls need to be accessed outside of the
module, they should be marked as `pub`, `pub(super)`, etc as
necessary.

[`Cx`]: https://docs.rs/stakker/*/stakker/struct.Cx.html
