---
title: Benchmarking Large Riak Data Types: A Potential Fix
tags: riak, databases, tools, ruby, web-ring
description: Russell Brown has a potential fix for the Data Type growth
---

## A potential fix

As I mentioned in my
[last post](/posts/2014-12-02-benchmarking-large-riak-data-types-continued.html),
[Russell Brown](https://github.com/russelldb) is working on a
feature branch
of [`riak_dt`](https://github.com/basho/riak_dt) which may have a fix for some
of this. Today, I ran
[my benchmark](/posts/2014-12-01-benchmarking-large-riak-data-types.html) against a
locally-compiled Riak, and then I built it with the potential fix.


## My environment

I'm on Mac OS X 10.9.5, and I ran the benchmark against a single Riak 2.0.2 node
running locally, installed from source. I have OTP R17, and therefore had to make a few changes in the Riak build system:

- [Allow 17 in the accepted versions regex](https://github.com/basho/riak_kv/issues/919)
- Disable `warnings_as_errors` in a few of the dependencies as needed
- [Exclude rabbit_common due to conflicting modules](http://lists.basho.com/pipermail/riak-users_lists.basho.com/2011-July/004996.html)

To include the patched version, I changed the riak_dt branch that riak_kv depends on to `bug/rdb/faster-merge-orswot`.


## Results

Map writes has improved significantly. Not only does it no longer seem exponential, but it is much faster! Notice the time scales:

![Unpatched Map writes (data-type API)](/images/2014-12-01-riak-benchmark/unpatched-map-dt-writes.png)

![Patched Map writes (data-type API)](/images/2014-12-01-riak-benchmark/patched-map-dt-writes.png)

The same applies for Map reads:


![Unpatched Map reads (data-type API)](/images/2014-12-01-riak-benchmark/unpatched-map-dt-reads.png)

![Patched Map reads (data-type API)](/images/2014-12-01-riak-benchmark/patched-map-dt-reads.png)

The stripes in the Patched Map reads chart is likely due to the precision the
benchmark uses when printing the time. They can be ignored.

However, there was a regression (tradeoff) with regards to size. It appears
that the patched version grows at a faster rate, though it is still linear.

![Unpatched Map byte size and number of items](/images/2014-12-01-riak-benchmark/unpatched-map-size.png)

![Patched Map byte size and number of items](/images/2014-12-01-riak-benchmark/patched-map-size.png)

The blip around 1,000 items may be due to the change in the size of the elements
from 3 to 4 bytes.

There are no visually significant changes for Map reads using the key-value API.

![Unpatched Map reads (key-value API)](/images/2014-12-01-riak-benchmark/unpatched-map-kv-reads.png)

![Patched Map reads (key-value API)](/images/2014-12-01-riak-benchmark/patched-map-kv-reads.png)



## 20k Elements

Testing the unpatched version with 20,000 elements would be unbearable, but did
test the patched version to give a better idea of how it would behave at that
size. It's not quite what I was expecting, but it is still much faster than the unpatched version with 3,000 elements.

![Patched Map writes (20k elements) (data-type API)](/images/2014-12-01-riak-benchmark/patched-map-dt-writes-20k.png)

![Patched Map reads (20k elements) (data-type API)](/images/2014-12-01-riak-benchmark/patched-map-dt-reads-20k.png)


## Raw data

[Here you go!](/files/riak-benchmark-results.tar.gz)


## Future work

- Test the patched Set implementation.
- Test against an actual cluster rather than a single local node.
- Make a [`basho_bench`](https://github.com/basho/basho_bench) version of the
  benchmark.

Once again, big thanks to Russell Brown for the quick turn-around on this! We're looking
forward to using this change once it is officially released. We are also
eagerly anticipating [delta-mutation](http://arxiv.org/abs/1410.2803), which
should bring the linear growth (for writes) down to amortized constant time,
if I'm understanding the change correctly.
