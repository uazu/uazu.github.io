# Top-level actor template

The following template may be helpful for writing big top-level actors
that need to accept configuration and need to be connected up to other
actors through [`Fwd`] instances.

```rust,no_run,noplayground
/// `Widget` actor configuration.  Includes serde deserialization
/// support.
#[derive(Deserialize, Clone)]
#[serde(deny_unknown_fields)]
pub struct WidgetConf {
    // ... configuration values ...
}

/// `Widget` instance callbacks
pub struct WidgetFwds {
    // ... `Fwd` and `Share` values that the actor needs to talk to
    //   other actors and to access any shared resources ...
}

/// `Widget` actor
pub struct Widget {
    conf: WidgetConf,
    fwds: WidgetFwds,
    // ... actor state ...
}

impl Widget {
    /// Initialise the Widget actor
    pub fn init(cx: CX![], conf: WidgetConf, fwds: WidgetFwds) -> Option<Self> {
       // ...
       Some(Self {
           conf,
           fwds,
           // ...
       })
    }

    //... all other actor methods ...
}
```

[`Fwd`]: https://docs.rs/stakker/*/stakker/struct.Fwd.html
