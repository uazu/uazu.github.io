# About Stakker

**Stakker** is a lightweight low-level single-threaded actor runtime
for Rust.  Some features:

- It is designed to be layered on top of whatever event loop the user
  prefers to use, including ones from other languages.
- Asynchronous calls are addressed directly to individual methods
  within an actor, rather like Pony behaviours.
- All calls and argument types are known and statically checked at
  compile-time, which is very efficient and gives the optimiser a lot
  of scope.
- It provides a timer queue for timeouts or delayed calls, a lazy
  queue to allow batching recent operations, and an idle queue for
  running a call when nothing else is outstanding.
- Uses `unsafe` by default for added efficiency at runtime.  However,
  enabling the "no-unsafe" cargo feature switches to a fully safe
  implementation, and builds with `#[forbid(unsafe_code)]` to
  guarantee that no unsafe code is present.

**Resources:**

- [**Stakker** GitHub page](https://github.com/uazu/stakker)
- [Documentation on **docs.rs**](https://docs.rs/stakker)
- [Crate on **crates.io**](https://crates.io/crates/stakker)

Questions not covered in the FAQ can be asked in the [GitHub
discussion area](https://github.com/uazu/stakker/discussions).  Please
raise bugs and other issues on the [GitHub issues
page](https://github.com/uazu/stakker/issues).

In future if more people come to use **Stakker**, it would be good to
have some means of notifying those people if new features are being
considered, to include them in discussions.  This could be a
forever-open GitHub issue, or some other low-tech channel.  I'm open
to suggestions if someone has done this before.

**Related crates:**

- [**stakker_mio**]
- [**stakker_macros**]
- [**stakker_tui**]
- [**stakker_log**]
- [**qcell**]

Let me know if you have a crate you'd like added here.

[**qcell**]: https://crates.io/crates/qcell
[**stakker_log**]: https://crates.io/crates/stakker_log
[**stakker_macros**]: https://crates.io/crates/stakker_macros
[**stakker_mio**]: https://crates.io/crates/stakker_mio
[**stakker_tui**]: https://crates.io/crates/stakker_tui
