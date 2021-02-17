# Benchmarking **Stakker** against other solutions

Benchmarks were run to compare different approaches to implementing a
ring of actors, each receiving a message containing a value, doing
some work on that value and then passing it onto the next actor.
Through test parameters, the work can be tuned to modify more or less
memory or consume more or less CPU time.  This also corresponds to
stressing data or instruction use in the CPU cache.

The solutions tested were as follows:

- **Flat**: Flat code, doing the same work but completely inline,
  without any actors.  This is the baseline.

- **Rc/RefCell**: Using `Rc<RefCell>` to refer to and call other
  actors, and when borrowing doesn't permit a call to be made (due to
  the actor already running higher up the stack), stash the call and
  return back down the stack, picking up and running the call when
  we've unwound enough.

- **Stakker**: Using **Stakker** with default features

- **Stakker no-unsafe**: Using **Stakker** with `no-unsafe` feature
  (using all safe code, and allocations when queuing calls)

- **Arc/Mutex**: Using `Arc<Mutex>` instead of `Rc<RefCell>` to refer
  to other actors, but running uncontended on a single thread.  So
  this shows the overhead of whatever atomic operations or memory
  fences `Mutex` uses when uncontended.

- **crossbeam**: Using **crossbeam** channels to pass the message
  between actors running on different threads, and thus parallelize
  the work at the cost of thread synchronization.

The parameters to the test are as follows:

- **actors**: Number of actors
- **split**: How many simultaneous messages "in flight" to allow
- **data**: How many `u64` values to touch in memory each iteration
- **cpu**: How many calculations to perform on each iteration

The tests were run under Linux.  The CPU is an Intel i5-6200U 2.3GHz
(max 2.8GHz) CPU from 2016.  This has 2 cores, exposed as 4 logical
cores with hyper-threading.

@@@

Having more messages in flight is advantageous to both **Stakker** and
**crossbeam**.  For **Stakker**, it helps due to filling the queue
more and batching call execution.  For **crossbeam** it allows true
parallel operation and saturation of all cores with work.
