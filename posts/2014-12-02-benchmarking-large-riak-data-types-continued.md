---
title: Benchmarking Large Riak Data Types, continued
tags: riak, databases, tools, ruby, web-ring
description: Some additional information about yesterdays post
---

[Yesterday's post](/posts/2014-12-01-benchmarking-large-riak-data-types.html) could have included a bit more information. Here's that information.

## My environment

I'm on Mac OS X 10.9.5, and I ran the benchmark against a single Riak 2.0.2 node
running locally, installed from [homebrew](https://brew.sh), which does
[a binary install](https://github.com/Homebrew/homebrew-core/blob/master/Formula/riak.rb).


## Other graphs

Some graphs I didn't include were a comparison of byte size and number of items, Set read times for both the key-value and data-type APIs, and Map read times for the key-value API. Here they are:

![Set byte size and number of items](/images/2014-12-01-riak-benchmark/set-size.png)

![Map byte size and number of items](/images/2014-12-01-riak-benchmark/map-size.png)

![Set reads (key-value API)](/images/2014-12-01-riak-benchmark/set-kv-reads.png)

![Set reads (data-type API)](/images/2014-12-01-riak-benchmark/set-dt-reads.png)

![Map reads (key-value API)](/images/2014-12-01-riak-benchmark/map-kv-reads.png)


## Raw data

[Here you go!](/files/riak-benchmark-results.tar.gz)


## A potential fix

[Russell Brown](https://github.com/russelldb) is working on a
feature branch
of [`riak_dt`](https://github.com/basho/riak_dt) which may have a fix for some
of this. I'm running the benchmark against a locally-compiled Riak right now,
and then I'll build it with his potential fix and compare the benchmark results.

**Update:** I ran the benchmark against the potential fix with
[good results](/posts/2014-12-03-benchmarking-large-riak-data-types-a-potential-fix.html).
