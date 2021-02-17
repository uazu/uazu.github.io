# Alternatives to the actor method signature

An actor method in **Stakker** has this signature:

```rust,no_run,noplayground
fn method(&mut self, cx: CX![], ...args...) {...}
```

There are four things that need to be passed into an actor method:

- A `&mut self` reference, to allow direct access to the actor's state
- A context to allow stopping and failing the actor and getting an
  `Actor<Self>` reference
- A reference to the runtime to allow adding timers, deferring calls
  and to support borrowing `Share` instances and so on
- The arguments to the call

So this is handled as `(&mut self, cx: CX![], ...args...)`, where `cx`
gives access to both the actor's specific context [`Cx`] and by
auto-deref to the runtime [`Core`].  Note that `cx: CX![]` is used to
avoid boilerplate and expands to `cx: &mut Cx<'_, Self>`.

However, some alternative approaches were considered:

- Pass just `(&mut self, ...args...)` and include `cx` in `Self` as
  `self.cx`.  This means storing an extra 8 bytes in every actor
  struct, wasting memory and forcing a write to memory just for the
  short time that `Cx` is required during a call.  This seems like a
  bad idea.

- Require the coder to put actor methods into separate `impl
  Prep<MyActor> {...}` and `impl Ready<MyActor> {...}` sections, where
  the `Ready` wrapper is effectively `(&mut MyActor, &mut
  Cx<MyActor>)`.  If the method self argument is `mut self` or `&mut
  self` then it can be made to auto-deref to `&mut MyActor` so that
  the actor state is directly accessible through `self` as normal, and
  also offer access to the other functions of `Cx` through for example
  `self.stop()` or `self.core`.

  The most immediate problem with this is that Rust currently does not
  permit that `impl` when `Ready` and `MyActor` are in different
  crates, with the error "cannot define inherent `impl` for a type
  outside of the crate where the type is defined".  I could find no
  workaround for this that didn't bring along its own issues.

  This approach gives shorter argument lists and conveniently
  separates *Prep*, *Ready*, and instance methods (making the actor
  API clearer), at the cost of having two `impl` sections, and a
  possible additional overhead for accessing actor state.  Also it is
  less obvious what is happening behind the scenes, since `self` is
  overloaded for two (or three) different purposes.

- Using procedural macros, it would be possible to write the calls any
  way we want, and transform them into the right form for the
  compiler.  However **Stakker** intentionally avoids this kind of
  thing because it is not transparent, i.e. the coder can't see what
  is going on.  Procedural macros in general can generate a huge
  amount of code behind the scenes without the coder realizing.
  Really you're no longer writing Rust in this case.  So the
  preference is to keep things explicit and transparent, and use
  macros only for small regions, where they are necessary to keep
  things clear, and not to wrap large regions of code.

So, the `cx: CX![]` approach is kept because it is more explicit,
low-level and unabstracted.  Everything is exactly what you see:
`Self` access is direct, and `self` and `cx` can be used independently
as necessary.  It's more Rust's style to make things explicit in the
code.

[`Core`]: https://docs.rs/stakker/*/stakker/struct.Core.html
[`Cx`]: https://docs.rs/stakker/*/stakker/struct.Cx.html
