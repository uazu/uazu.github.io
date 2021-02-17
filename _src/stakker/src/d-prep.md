# Actor **Prep** state

An actor may be in one of three states: **Prep**, **Ready** and
**Zombie**.  The purpose of the **Prep** state is to allow time for an
actor to set itself up before accepting calls.  Actors are created
instantaneously, but the initialisation call is made asynchronously,
so for even the simplest actor, there will be some time where the
actor is in the **Prep** state.

Since actor initialisation is asynchronous and has no time bound, the
actor may do quite complex operations in the **Prep** state, for
example attempting to make a connection to a remote server, or calling
and receiving responses back from other actors.  In this case
remaining in the **Prep** state means that the actor is signalling to
the runtime that it is "not yet ready" to accept normal actor calls.

Any actor calls made to it are queued until it enters the **Ready**
state.  This simplifies the logic of actors since otherwise the actor
would be forced to do its own queuing of requests if it was not yet
ready to service them.

To support doing asynchronous calls to other actors in the **Prep**
state, it's possible to create [`Ret`] and [`Fwd`] instances that call
back to **Prep** state methods instead of normal actor methods.

[`Fwd`]: https://docs.rs/stakker/*/stakker/struct.Fwd.html
[`Ret`]: https://docs.rs/stakker/*/stakker/struct.Ret.html
