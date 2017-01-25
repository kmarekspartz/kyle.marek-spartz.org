---
title: Concurrent implementation of the Daytime Protocol in Haskell
tags: haskell, pymntos, python, web-ring
description: I demonstrate a concurrent implementation of the Daytime Protocol in Haskell
---

One example from [*Parallel and Concurrent Programming in
Haskell*](http://chimera.labs.oreilly.com/books/1230000000929/index.html)
is a [concurrent network
server](http://chimera.labs.oreilly.com/books/1230000000929/ch12.html#sec_server-trivial).
The server given in the book implements an informally specified
doubling protocol, where each submitted line gets parsed as an Integer
and returns the double of the input.

Back in May, [Andrew Clarkson](https://github.com/bitborn) gave
a talk at the PyMNtos meeting about [Asynchronous
IO](https://docs.python.org/3.4/library/asyncio.html) in Python. As an
example, he included an asynchronous version of a
[Daytime](https://en.wikipedia.org/wiki/Daytime_Protocol) server.

Let's take the Haskell doubling server, and make it a (TCP) Daytime
server.

... but first, some imports.

> import Control.Monad (forever)

`forever` is useful for making loops out of void functions (`IO ()`).

> import Text.Printf (printf)

`printf` behaves similarly to how it does in other languages: it takes
a format string and items to interpolate into the format
string.

> import Data.Time (getCurrentTime, formatTime)
> import System.Locale (defaultTimeLocale)

These are used to get the current time, and format it with the default locale.

> import System.IO (
>     Handle

A handle is a place for IO to stream data.

>   , stdout

`stdout` is the default handle used for things like
`putStrLn`.

>   , hPutStrLn

This is the handle equivalents of `putStrLn`. Rather
than assuming the standard handle, the handle is passed in
explicitly. One can define `putStrLn` (in [point-free
style](https://en.wikipedia.org/wiki/Tacit_programming)) as `putStrLn
= hPutStrLn stdout`.

>   , hClose

Handles need to be closed when you are done with them.

>   )

> import Network (
>     withSocketsDo

This is
[needed](http://hackage.haskell.org/package/network-2.6.0.1/docs/Network-Socket-Internal.html#v:withSocketsDo)
on Windows to initialize the networking subsystem. It is here for
portability reasons.

>   , listenOn

This opens a [socket](https://en.wikipedia.org/wiki/Network_socket) on
a specified
[port](https://en.wikipedia.org/wiki/Port_%28computer_networking%29).

>   , PortID(PortNumber)

To specify the port, we'll pass in a `PortNumber`.

>   , accept

`accept` takes a socket and returns a tuple of a Handle, a
[host](https://en.wikipedia.org/wiki/Host_%28network%29), and the
port.

>   )

> import Control.Concurrent (
>     forkFinally

`forkFinally` creates a new (light-weight)
[thread](https://en.wikipedia.org/wiki/Thread_%28computing%29) to run
a specified process and when it completes, it "finally" runs another
command. You'll see when we get there.

>   , threadDelay

It turns out our single-threaded implementation is quite efficient,
so we'll add a slight delay to make clear how concurrency affects the
server.

>   )

This program has four different main functions. The fourth one is the
concurrent Daytime server, so we'll use that implementation as our
main `main`:

> main = main4

First, lets write a non-server version of what a Daytime server
does. According to the
[specification](https://tools.ietf.org/html/rfc867):

*"Once a connection is established the current date and time is sent
out the connection as a ascii character string (and any data received
is thrown away).  The service closes the connection after sending the
quote."*


A non-server of this would just be a simple version of [`date`](http://linux.die.net/man/1/date)

> main1 :: IO ()
> main1 = do
>   ct <- getCurrentTime
>   let time = formatTime defaultTimeLocale "%F %T" ct
>   putStrLn time

This outputs the time, and halts.

In order to work with sockets, however, we'll need to use the Handle
equivalent program. We'll also adding a slight delay to make the
benefits of concurrency clear later.

To convert `main1` to use handles explicitly, we'll pass an output
handle in, and use `hPutStrLn` instead of `putStrLn`:

> mainWith :: Handle -> IO ()
> mainWith outH = do
>   threadDelay (10^6) -- to simulate "real" work.
>   ct <- getCurrentTime
>   let time = formatTime defaultTimeLocale "%F %T" ct
>   hPutStrLn outH time

Ignoring the `threadDelay`, the equivalent program to `main1` would be:

> main2 :: IO ()
> main2 = mainWith stdout

Now we can get on with implementing the server. The specification
establishes port 13 for the Daytime protocol.[^2]

[^2]: You may need root access in order to run this program. If you do
not have root acces, change the port to 1313 or some other number
above 1024. Socket numbers below 1024 are generally protected on
modern computers.

> port :: Int
> port = 13


Let's start out with the server implementation from the book:

> main3 :: IO ()
> main3 = withSocketsDo $ do
>   sock <- listenOn (PortNumber (fromIntegral port))
>   printf "Listening on port %d\n" port
>   forever $ do
>     (handle, host, port) <- accept sock
>     printf "Accepted connection from %s: %s\n" host (show port)

Here's where things diverge. We use our `mainWith` in place of
`talk`. Since we can pass handles into `mainWith`, we can pass handles
returned by `accept` into `mainWith`:

>     mainWith handle

Don't forget to close the handle after the connection has been handled
(as specified)!

>     hClose handle

This handles each connection in sequence. Since handling the
connection takes over a second of work (due to the thread delay), it
can only respond to one connection per second.

Let's add some concurrency! This first part is the same:

> main4 :: IO ()
> main4 = withSocketsDo $ do
>   sock <- listenOn (PortNumber (fromIntegral port))
>   printf "Listening on port %d\n" port
>   forever $ do
>     (handle, host, port) <- accept sock
>     printf "Accepted connection from %s: %s\n" host (show port)

Here's where `forkFinally` comes in. Instead of calling `mainWith
handle`, we fork a new thread to call it. When the thread completes,
we (finally) close the handle.

>     forkFinally (mainWith handle)
>                 (\_ -> hClose handle)

Since a new thread is created for each connection, we are no longer
limited to one connection per second.

To run [this file](/files/daytime.lhs)[^3]:

`runhaskell daytime.lhs`

[^3]: Again, you may need root access.

To test the concurrency[^4]:

`yes "nc localhost 13" | parallel -j 32`

[^4]: You'll need [GNU
`parallel`](https://www.gnu.org/software/parallel/) installed, if you
don't have it.

This streams commands to connect to localhost on port 13, and uses
`parallel` to have 32 worker threads running those commands. With
`main3`, you should see one response per second, whereas with
`main4`, you should see 32 responses per second.
