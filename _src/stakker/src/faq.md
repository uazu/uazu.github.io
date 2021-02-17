# Stakker FAQ

To submit a question, please raise an issue on the [Stakker GitHub
page](https://github.com/uazu/stakker/issues).

## The cargo features seem confusing.  Which ones do I need?

Remember that changing the cargo features does not change the API of
the **Stakker** crate.  Rather the features change the implementations
that back the API, to support different ways of using **Stakker**.  If
you are only using a single **Stakker** instance in your app, the
default features will be fine.  If you plan to run more than one
instance, then check the features documentation on the front page of
the **Stakker** rustdoc on `docs.rs`, or else you'll get a panic.

## How can I create an `ActorOwn<dyn Trait>` and call it?

See the [`actor_of_trait!`] macro for details of the best current
solution, and the [Traits Design Notes](d-traits.html) for alternative
solutions and the reasons why `Actor<dyn Traits>` is not possible
right now.

[`actor_of_trait!`]: https://docs.rs/stakker/*/stakker/macro.actor_of_trait.html
