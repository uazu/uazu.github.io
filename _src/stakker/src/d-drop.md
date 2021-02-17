# Dropping things to clean up

**Stakker** maintains the Rust convention of easy clean-up by simply
dropping things.  If dropping something in the **Stakker** API doesn't
clean things up correctly, then that is probably a bug.

So for example if you drop the last [`ActorOwn`] referring to an
actor, then the actor will be terminated and the actor's drop handler
called.  Or if you drop a [`Ret`] instance, then `None` is sent back,
which indicates that the message containing the [`Ret`] wasn't replied
to.  Or if you drop a [`Waker`] in another thread, the wake handler is
informed and the slot released.

The intention is that if you keep to certain simple conventions, then
you can rely on drop-based cleanup to take care of all problem
situations.  For example if you use [`ActorOwn`] links in a DAG
(e.g. a tree of actors with parents and children), then when one actor
fails, the whole tree of actors that it owns will also be cleaned up
correctly.  This also means that if anything goes wrong in an actor,
then calling [`fail`] or [`fail_str`] should always be a safe way to
bail out.  The actor and all its children will clean up, and the parent
actor will be informed of the failure.

However, if you decide to try and implement some more complicated form
of inter-actor ownership that isn't a DAG, perhaps with [`ActorOwn`]
loops and manual [`kill`] calls to do cleanup, then it's your
responsibility to make sure that clean-up occurs correctly in all
failure modes.

Another issue occurs when your actor allocates internal resources to
service another actor's request, and you wish to know if that actor
fails in order to release those resources.  This can be solved by
creating a droppable "guard" object which is passed to the associated
actor for it to store.  If the actor dies, then the drop handler of
your guard runs, which can send a message back to your actor to clean
up, via an [`Actor`] reference to your actor that it holds.

[`ActorOwn`]: https://docs.rs/stakker/*/stakker/struct.ActorOwn.html
[`Actor`]: https://docs.rs/stakker/*/stakker/struct.Actor.html
[`Ret`]: https://docs.rs/stakker/*/stakker/struct.Ret.html
[`Waker`]: https://docs.rs/stakker/*/stakker/struct.Waker.html
[`fail_str`]: https://docs.rs/stakker/*/stakker/struct.Cx.html#method.fail_str
[`fail`]: https://docs.rs/stakker/*/stakker/struct.Cx.html#method.fail
[`kill`]: https://docs.rs/stakker/*/stakker/struct.Actor.html#method.kill
