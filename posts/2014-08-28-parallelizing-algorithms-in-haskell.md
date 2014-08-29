---
title: Parallelizing algorithms in Haskell
tags: haskell
description: I demonstrate parallelizing existing code in Haskell
---

I've been working through [*Parallel and Concurrent Programming in
Haskell*](http://chimera.labs.oreilly.com/books/1230000000929/index.html).
In my [last
post](/posts/2014-08-26-concurrent-implementation-of-the-daytime-protocol-in-haskell.html),
I demonstrated the facilities Haskell provides for lightweight
concurrency. In this post, let's take a look at Haskell facilities for
parallelism.

As a brief example, let's parallelize
[Quicksort](https://en.wikipedia.org/wiki/Quicksort)[^1].

``` {.sourceCode .literate .haskell}
import Control.Parallel.Strategies
```

[Strategies](http://hackage.haskell.org/package/parallel-3.2.0.4/docs/Control-Parallel-Strategies.html)
provide a means to tell the run-time system how to evaluate objects.
We'll be using `rseq` is the sequential evaluation strategy, and
`parList` takes a strategy for list items, and uses that strategy for
each list element in parallel.

Here's our non-parallelized Quicksort implementation:

``` {.sourceCode .literate .haskell}
quicksort :: Ord a => [a] -> [a]
quicksort [] = []
quicksort (x:xs) =
  let leftPartition = [y | y <- xs, y < x]
      rightPartition = [y | y <- xs, y >= x]
      left = quicksort leftPartition
      right = quicksort rightPartition
  in left ++ [x] ++ right
```

Quicksort partitions a list around a pivot, sorts each partition, and
then combines the partitions and the pivot.

Our parallelized version is almost the same:

``` {.sourceCode .literate .haskell}
parallelsort :: Ord a => [a] -> [a]
parallelsort [] = []
parallelsort (x:xs) =
    let leftPartition = [y | y <- xs, y < x] `using` parList rseq
        rightPartition = [y | y <- xs, y >= x] `using` parList rseq
        left = parallelsort leftPartition
        right = parallelsort rightPartition
    in left ++ [x] ++ right
```

We simply tell the run-time system what strategy to use for the list
comprehensions.

This doesn't really improve much in this case, but when used
judiciously, extending your existing code with parallelism is
straight-forward in Haskell.

This post is also [available](/files/parallelsort.lhs) as a [literate
Haskell](http://www.haskell.org/haskellwiki/Literate_programming) file.

[^1]: This isn't the best algorithm to parallelize, nor is this an
    efficient implementation, but it shows how to add parallelism to
    your code.
