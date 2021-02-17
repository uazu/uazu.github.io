# Detecting delivery failure using `Ret`

A [`Ret`] callback is guaranteed to always be called eventually, even if
it is lost and dropped.  So this means that if a call is made to an
actor that terminates before the call is serviced, any [`Ret`] included
in the arguments to that call will be dropped and a `None` response
will be sent back.

So this means that any call where there needs to be an action if the
message cannot be handled needs to include a [`Ret`] in its arguments,
even if it is just a `Ret<()>` which is called with no arguments on
successfully processing the call.  The [`ret_to!`] macro supports this
scenario.

However where it is not important to handle the case where the call is
lost, the [`ret_some_to!`] macro unwraps the value and ignores the
`None` (dropped) case.

[`Ret`]: https://docs.rs/stakker/*/stakker/struct.Ret.html
[`ret_some_to!`]: https://docs.rs/stakker/*/stakker/macro.ret_some_to.html
[`ret_to!`]: https://docs.rs/stakker/*/stakker/macro.ret_to.html
