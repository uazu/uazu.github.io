# Cargo features and safety

By default **Stakker** uses some `unsafe` for efficiency.  This means
it uses implementations that require less memory or less CPU time.
However, if you wish, you can enable the "no-unsafe" Cargo feature,
and the whole crate will be compiled with `#[forbid(unsafe_code)]`,
and fully safe implementations are used instead.  You lose some
efficiency, but for many applications that would make little
difference, so use this if minimising `unsafe` is important for your
project.

There are other cargo features that switch in and out different
underlying implementations to optimise for different cases.  However
the external API of the crate does not change when features are
changed.  The API should operate identically.

Note that since Cargo features are additive, it's necessary that when
more than one crate in a build uses **Stakker**, the **Stakker** build
should be compatible with all of them, i.e. provide the lowest common
denominator.  So this typically means using the less optimal
implementation.

Note that crates should not enable **Stakker** cargo features unless
they really need them.  It should be up to the top-level application
to add features as required.  Note that even if the top-level
application does not use **Stakker** directly, it is still possible to
list the crate as a dependency in order to select cargo features.
