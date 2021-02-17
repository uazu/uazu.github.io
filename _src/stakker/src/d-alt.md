# Alternate approach

```rust
struct ActorBoxHead {
    weak_count: usize,
    strong_count_and_state: usize,
    ready_queue_chain_ptr: *mut Option<Box<QueueItem>>,
    lazy: Rc<LazyQueue>,  // Maybe optimise out to global or TLS
    ret: Option<Ret<StopCause>>,
}

struct QueueItem {
    next: Option<Box<QueueItem>>,
    @@@,
}

struct ActorBoxPrep {
    ready_queue: Option<Box<QueueItem>>,
    prep_queue: Option<Box<QueueItem>>,
    prep_queue_chain_ptr: *mut Option<Box<QueueItem>>,
}

struct ActorBoxReady<A> {
    actor: A,
}

struct Actor<A> {
    inner: *mut ActorBox<A>,
}

struct Prep<'a, A> {
    inner: *mut ActorBox<A>,
    core: &'a mut Core,
}

struct Be<'a, A> {
    inner: *mut ActorBox<A>,
    core: &'a mut Core,
}

impl Prep<'_, A> for Cat {  // Define prep-phase methods
    pub fn init(self) -> Some<Cat> {
        Some(Cat { ... })
    }
}

impl Be<'_, A> for Cat { // Define behaviours
    pub fn sound(self) {
        println!("Miaow");
    }
}
```

Both `Prep` and `Be` are only valid whilst there is a borrow on the
actor.  Before creating one, the borrow flag is set, and after they
are no longer in use, the borrow flag is cleared.

States:

- Prep
- PrepBorrow
- Ready
- ReadyBorrow
- ZombiePending: Still has state, cleanup queued on lazy queue, no
  calls allowed now
- Zombie: No state

On making a `Prep` call:

- Prep => the call goes ahead
- PrepBorrow => the call is queued using `ready_queue_chain_ptr`
- _ => the call is dropped

On making a `Ready` call:

- Prep* => the call is queued using `ready_queue`
- Ready => call goes ahead
- ReadyBorrow => the call is queued using `ready_queue_chain_ptr`
- Zombie* => the call is dropped

Executing a Ready call:

- State changes Ready -> ReadyBorrow
- Queue created, and `ready_queue_chain_ptr` set up to point to it
- `Be` instance created
- Call is made on the `Be` instance and returns
- While there are entries in the queue, the next entry is run
- State changes ReadyBorrow -> Ready

Queuing a ReadyBorrow call:

- Boxed closure is written to `ready_queue_chain_ptr`
- `ready_queue_chain_ptr` is set to point to the `next` member within
  the box

Handling switch from Prep to Ready:

- Drop all prep QueueItems
- Save the ready_queue
- Install the self value

Implementation of an actor:

```rust
struct Cat {}
impl Prep<Cat> {
    fn init(self) -> Option<Cat> {}
}
impl Be<Cat> {
    fn act(self) {}
}
```

`Be` auto-derefs to `Self`.  Also has `self.stop()`, `self.this()`,
`self.fail()`.

`Prep` doesn't have auto-deref.  Has `self.stop()`, `self.this()`,
`self.fail()`.  Also has `let be = self.start(Cat {})` which lets you
move to the Ready state, and returns a `Be` in case you want to make
calls on it immediately.

## Fwd and Ret

These have direct references to the actor, so can call the actor
directly, or queue to it if it is borrowed.  They need a Core
reference.

## Share

Share is implemented the same way as 0.1, with the same guarantees,
because we have Core to borrow on.  Probably easiest to use a QCell
because then we don't have to worry about

## Access to timers and lazy/idle queues

We have a Core reference in `self`

## Calling behaviours from a Prep handler

Often it's necessary to make initial calls on the object that has just
been created, before executing the ready queue.  HOW?

@@@

## Actor termination and drop handling

Cleanup of actor internals needs a Core ref.  Solution:

- When an actor is killed/stopped/failed, cleanup can occur
  immediately and the switch made immediately to Zombie, because the
  Core reference is present

- When an actor dies as a result of a drop (e.g. last ActorOwn
  dropped), then state changes to ZombiePending, and cleanup is
  deferred to the Lazy queue.  Then the cleanup is run with the Core
  reference

## Drop handler

Since a drop handler has no access to Core, if the actor needs to
clean up anything or forward anything then there are two options:

- Drop handler queues things to the lazy queue, via a reference kept
  in the actor, or else via a reference found via another actor
  reference.

- All actors must have a `drop` behaviour which is called by the actor
  cleanup code.

In the second case, the only difficulty is having to write an empty
drop handler trait for every actor:

```rust
impl ActorDrop for Be<Cat> {}
```

## Synchronous calls

Allow synchronous calls to behaviours from outside the runtime
(i.e. with a `&mut Stakker`).  These can return values.  They can also
start processes going through async calls to other actors.  However
they can't wait for other things to complete, so the returned values
can only come from their own state.

Maybe also allow synchronous calls that pass a `Ret` and if the `Ret`
is called back due to eager execution of other actors, return that
value.  Otherwise return None.  This is a bit more dodgy, since if any
actor changes to run stuff with a slight delay or over a link, then it
will break immediately.  So maybe not a good idea.

## Costs

Decrease:
- Borrowing check/inc/dec on call is faster than writing to and
  executing a queue
- Eager execution requires less queueing

Increase:
- Two sets of code need to be generated for every call due to having
  to handle the `borrowed` case.  Very hard for the compiler to
  eliminate the `borrowed` case code even when the borrow check always
  succeeds because the call never calls anything that might loop back.
