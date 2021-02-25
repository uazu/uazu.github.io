# `Actor<dyn Trait>`

If you need to have a group of different actors that all implement the
same interface and that can be used interchangeably behind that
standard interface, there are several options available.  However
`Actor<dyn Trait>` is not one of them, for reasons that will be
explained below!

## Use a trait on the actor side: `Actor<Box<dyn Trait>>`

There is a macro [`actor_of_trait!`] to support this.  This all looks
clean and minimal in the source.  On the caller side, all they see is
a standard-looking actor interface.  However compared to a non-trait
actor, this adds an extra indirection to all calls due to the `Box`.
Here's an example:

```rust,no_run,noplayground
use stakker::*;
use std::time::Instant;

// Trait definition
type Animal = Box<dyn AnimalTrait>;
trait AnimalTrait {
    fn sound(&mut self, cx: CX![Animal]);
}

struct Cat;
impl Cat {
    fn init(_: CX![Animal]) -> Option<Animal> {
        Some(Box::new(Cat))
    }
}
impl AnimalTrait for Cat {
    fn sound(&self, _: CX![Animal]) {
        println!("Miaow");
    }
}

struct Dog;
impl Dog {
    fn init(_: CX![Animal]) -> Option<Animal> {
        Some(Box::new(Dog))
    }
}
impl AnimalTrait for Dog {
    fn sound(&mut self, _: CX![Animal]) {
        println!("Woof");
    }
}

pub fn main() {
    let mut stakker = Stakker::new(Instant::now());
    let s = &mut stakker;

    let animal1 = actor_of_trait!(s, Animal, Cat::init(), ret_nop!());
    let animal2 = actor_of_trait!(s, Animal, Dog::init(), ret_nop!());

    let mut list: Vec<Actor<Animal>> = Vec::new();
    list.push(animal1.clone());
    list.push(animal2.clone());

    for a in list {
        call!([a], sound());
    }
    s.run(Instant::now(), false);
}
```

## Use a trait on the caller side: `Box<dyn Trait>`

This involves wrapping the actors in a trait that forwards calls, and
then boxing it to make it dynamic.  So this also adds an indirection,
but on the caller side.  This is more verbose than doing it on the
actor side, and the calls don't look like other actor calls.  Here's
an example:

```rust,no_run,noplayground
use stakker::*;
use std::time::Instant;

// External interface of all Animals
trait Animal {
    fn sound(&self);
}

// A particular animal, wraps any actor that implements AnimalActor
struct AnAnimal<T: AnimalActor + 'static>(ActorOwn<T>);
impl<T: AnimalActor + 'static> Animal for AnAnimal<T> {
    fn sound(&self) {
        call!([self.0], sound());
    }
}

// Internal interface of animal actors
trait AnimalActor: Sized {
    fn sound(&self, cx: CX![]);
}

struct Cat;
impl Cat {
    fn init(_: CX![]) -> Option<Self> {
        Some(Self)
    }
}
impl AnimalActor for Cat {
    fn sound(&self, _: CX![]) {
        println!("Miaow");
    }
}

struct Dog;
impl Dog {
    fn init(_: CX![]) -> Option<Self> {
        Some(Self)
    }
}
impl AnimalActor for Dog {
    fn sound(&self, _: CX![]) {
        println!("Woof");
    }
}

fn main() {
    let mut stakker = Stakker::new(Instant::now());
    let s = &mut stakker;

    let animal1 = AnAnimal(actor!(s, Dog::init(), ret_nop!()));
    let animal2 = AnAnimal(actor!(s, Cat::init(), ret_nop!()));

    let mut list: Vec<Box<dyn Animal>> = Vec::new();
    list.push(Box::new(animal1)); // <- dyn coercion occurs here
    list.push(Box::new(animal2)); // <- dyn coercion occurs here

    for a in list {
        a.sound();
    }
    s.run(Instant::now(), false);
}
```


## Use [`Fwd`] and [`ActorOwnAnon`]

Instead of using a trait, it's also possible to use [`Fwd`] to capture
the entry point of an arbitrary actor, and to pass that to other
actors that only care about the forwarding interface.  The extra
indirection is also present in this solution, since the call must pass
via the [`Fwd`] handler.  However this is a lot more flexible than
traits.

Where you want another actor to not only have a [`Fwd`] instance but
also to hold the owning reference to the actor, then you can use
[`ActorOwnAnon`].  That way if that actor dies, the referenced actor
dies too.  This allows owning the actor without being exposed to the
type.  So you can keep a `Vec<ActorOwnAnon>` pointing to different
kinds of actors for example.


## Why `Actor<dyn Trait>` can't be supported

`Rc<dyn Trait>` can be done, so why isn't `Actor<dyn Trait>` possible?

To enable `dyn Trait` requires the actor runtime to be changed to use
`A: ?Sized`, where `A` is the actor's `Self` type.  Unfortunately Rust
does not support `?Sized` values inside an `enum`, apparently due to
it inhibiting layout optimisations, and **Stakker** requires an enum
to enable switching between the three actor states (**Prep**,
**Ready** and **Zombie**).  Maybe Rust could have a
`#[repr(unsizable)]` for enums to support this one day, but it doesn't
right now.

In addition `CoerceUnsized` is still unstable at the time of writing.
This is the approved way to do the "dyn coercion" which converts an
`Rc<impl Trait>` to an `Rc<dyn Trait>`.  However that can be worked
around, I believe.  So that isn't the blocker.

Looking at alternative approaches, it seemed like implementing a
custom `enum` in unsafe code might be possible using `union`, but that
is also a dead end due to `union` only supporting `Copy` types on
stable at present.  I have an [**unsized_enum**] crate which I believe
is sound and could be the basis for `Actor<dyn Trait>` in **Stakker**,
but I don't want to force it on all **Stakker** users.  I'd like to be
able to offer a safe alternative as well.  (Update: As of Feb-2021
'union' supports `ManuallyDrop` which allows `?Sized`, so that might
offer a better way, although it still requires `unsafe`.)

So unfortunately it's not possible to do `Actor<dyn Trait>` right now,
and one of the alternatives must be used instead.

[**unsized_enum**]: https://crates.io/crates/unsized_enum
[`ActorOwnAnon`]: https://docs.rs/stakker/*/stakker/struct.ActorOwnAnon.html
[`Fwd`]: https://docs.rs/stakker/*/stakker/struct.Fwd.html
[`actor_of_trait!`]: https://docs.rs/stakker/*/stakker/macro.actor_of_trait.html
