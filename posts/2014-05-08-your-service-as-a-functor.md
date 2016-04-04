---
title: Your Service as a Functor
tags: programming-languages
description: Applying category theory to servers and services
---

[Marius Eriksen](http://monkey.org/~marius/)'s [*Your Server as a Function*](http://monkey.org/~marius/funsrv.pdf) proposes a useful model for the development and reasoning of distributed systems with a [service-oriented architecture](https://en.wikipedia.org/wiki/Service-oriented_architecture). Most of the discussion regarding this paper seems focused on *futures*, but I've been thinking a lot about *services* and *filters*. The following discussion is not dependent on an understanding of futures.

A service takes a request and returns a response:

```Haskell
type Service :: Request -> Response
```

Services can be parameterized by other services:[^1]

```Haskell
authorizedWwwService :: Service -> Service -> Service
authorizedWwwService authService wwwService request
    | authService `authorizes` request = wwwService request
    | otherwise = unauthorizedMessage authService
```

[^1]: Type classes should specify the interface of the parameterized services to improve type safety, but that's beyond the scope of this post.

Filters, as defined in the paper, take a request and a service, and return a response:

```Haskell
type Filter'' :: (Request, Service) -> Response
```

However, if we curry the arguments, and swap the order of the `Request` and the `Service`, we get the following:

```Haskell
type Filter' :: Service -> Request -> Response
```

Noting that the return type of `Filter'` is `Request -> Response`, which is just `Service`. We can thus simplify:

```Haskell
type Filter :: Service -> Service
```

`Filter` is just a higher-order service![^2]

[^2]: Another approach would be to make `Service` an instance of `Functor`, which is more-or-less done in the paper using the filter combinators (specifically `andThen`).

We can parameterize filters, too:

```Haskell
timeoutFilter :: TimeDuration -> Filter
cachingFilter :: Service -> Filter
loggingFilter :: Service -> Filter
statusFilter :: Service -> Filter
authenticationFilter :: Service -> Filter
```

If we add a `Filter2`, this would allow for things like load balancers:

```Haskell
type Filter2 :: Service -> Service -> Service

loadbalancerFilter2 :: LoadBalancerSettings -> Filter2

```

Decomposing redundant work in this manner allows a distributed system to be developed declaratively and safely.
