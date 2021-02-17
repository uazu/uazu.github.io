# Timer queue

The timer queue contains a list of [`FnOnce`] calls to execute at
specific instants.  What we need from this queue is:

- To give us the next expiry time
- To execute items from the front of the queue when time advances
- To add and delete items

A [`BinaryHeap`] might be good for this queue, except for the problem
of deletions being O(N).  So instead for the moment a [`BTreeMap`] is
used.  The map is partitioned to split off the items to execute when
time advances.  This should scale much better than a binary heap,
especially considering deletions.  However a [`BTreeMap`] generates a
lot of code, so it is likely a combined N-ary heap tuned to cache line
size and `Vec` to support deletion might perform better.  So the
underlying implementation will probably change at some point, once
various scenarios have been benchmarked.

Apart from fixed timers, there are also "max" and "min" timers, that
can be adjusted very cheaply (just a memory write), without having to
add and delete timers from the timer queue most of the time.

For fixed timers, the [`BTreeMap`] maps a 64-bit key (32-bit wrapping
expiry time + 31-bit unique value) to a boxed [`FnOnce`].  For min/max
timers, the 64-bit key in the map consists of a 32-bit provisional
expiry time and a 31-bit slot number.  The actual current expiry time
which is updated by the calls is kept in a separate array.  When the
timer expires, the current expiry time is checked, and another timer
added back in if necessary.

[`BTreeMap`]: https://doc.rust-lang.org/stable/std/collections/struct.BTreeMap.html
[`BinaryHeap`]: https://doc.rust-lang.org/stable/std/collections/struct.BinaryHeap.html
[`FnOnce`]: https://doc.rust-lang.org/stable/std/ops/trait.FnOnce.html
