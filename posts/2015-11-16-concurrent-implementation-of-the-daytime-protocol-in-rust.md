---
title: Concurrent implementation of the Daytime Protocol in Rust
tags: haskell, pymntos, python, web-ring, rust
description: A concurrent implementation Daytime protocol in Rust
---

When learning a language, I rewrite small programs I've previously written to
jumpstart my learning. Implementing a concurrent
[Daytime](https://en.wikipedia.org/wiki/Daytime_Protocol) server has proved
particularly useful because it uses both sockets and threads. If a language has
good socket and threading libraries, it is likely a good language.

Previously, I
[demonstrated](http://kyle.marek-spartz.org/posts/2014-08-26-concurrent-implementation-of-the-daytime-protocol-in-haskell.html)
a Haskell implementation. Here's an example in Rust:

```rust
extern crate time;

use std::time::Duration;
use std::io::Write;
use std::net::{TcpListener, TcpStream};
use std::thread;

fn handle_client(mut stream: TcpStream) {
    let date = time::strftime("%F %T\n", &time::now_utc()).unwrap().to_string();
    let _ = stream.write(date.as_bytes());
}

fn main() {
    let listener = TcpListener::bind("127.0.0.1:13").unwrap();

    for stream in listener.incoming() {
        match stream {
            Ok(stream) =>  {
                thread::spawn(move || {
                    // connection succeeded
                    thread::sleep(Duration::new(1,0));
                    handle_client(stream)
                });
            }
            Err(_) => { /* connection failed */ },
        }
    }

    drop(listener);
}
```
