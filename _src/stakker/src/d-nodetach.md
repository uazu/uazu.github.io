# Why not allow detached actors?

A detached actor would be one without any [`ActorOwn`] owner, which
stays alive only so long as another actor references it using
[`Actor`], or an outstanding [`Ret`] or [`Fwd`] callback is active.

<!--It is easy enough to implement -- just add a `detach()` call to
[`ActorOwn`] which reduces the strong count to zero without
terminating the actor, leaving only the weak [`Actor`] references
keeping the actor alive, and then add a Drop handler to catch the case
of the last weak reference being dropped.-->

The problem is that with only weak [`Actor`] references keeping it
alive, and no owner to enforce cleanup, it's too easy to create
reference cycles.  Maybe they can be avoided by awareness during
initial implementation, but it is too easy to add a few references or
callbacks after that during maintenance that create a reference cycle
meaning that the actor will never be cleaned up, even outliving the
**Stakker** runtime.

So it seems like a feature that would cause foot-guns down the line,
so unless a really strongly-motivating case comes along, for now
detached actors will not be allowed.

For some of the cases where you might want a detached actor, e.g. a
listener spawning child actors to handle incoming connections, this is
better handled using [`ActorOwnSlab`], which will handle cleanup
correctly when the parent actor terminates.

[`ActorOwnSlab`]: https://docs.rs/stakker/*/stakker/struct.ActorOwnSlab.html
[`ActorOwn`]: https://docs.rs/stakker/*/stakker/struct.ActorOwn.html
[`Actor`]: https://docs.rs/stakker/*/stakker/struct.Actor.html
[`Fwd`]: https://docs.rs/stakker/*/stakker/struct.Fwd.html
[`Ret`]: https://docs.rs/stakker/*/stakker/struct.Ret.html
