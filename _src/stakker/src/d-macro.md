# Design of macro argument structure

The design of the macro argument structure, e.g. for [`call!`] or
[`fwd_to!`] required several attempts before the syntax felt
comfortable.  One aim was for the syntax within the macro call to be
valid if interpreted as Rust syntax so that `rustfmt` would format it
automatically.  Another was for the structure to be reasonably
intuitive to understand without having to constantly refer back to
documentation.  It is much too easy to end up with a list of anonymous
fields to fill in, or confusing arguments that appear in some places
but not others.

So to give it more structure, the destination being addressed was put
in brackets, for example `[cx]` or `[self.other_actor]` or `[fwd]`,
and things were made to look like actual methods being called as far
as possible.

For [`fwd_to!`], it ends up looking something like currying, with the
constant arguments given first, and the variable argument types
following in a tuple after `as`, which is also valid Rust syntax to
introduce a type, encouraging IDEs to help with type completion if
they support that.

Another aspect of the macros is that a lot of tuning was done on the
order of evaluation of the arguments.  Whereas in plain Rust code,
you'd often get a borrow-checker error due to mentioning the same
variable more than once, in the macro you will often find that you can
get away with it due to the macro's internal order of evaluation.  All
arguments are evaluated in the caller's context before the call is
deferred, to keep the code intelligible.

[`call!`]: https://docs.rs/stakker/*/stakker/macro.call.html
[`fwd_to!`]: https://docs.rs/stakker/*/stakker/macro.fwd_to.html
