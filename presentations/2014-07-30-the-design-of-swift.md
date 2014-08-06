% The design of Swift
% Kyle Marek-Spartz; <kyle.marek.spartz@gmail.com>; <http://kyle.marek-spartz.org>
% July 30, 2014

![Lightning Talk](/images/lightning.png)

# Who am I?

- Linguist
- Software developer
- Programming language enthusiast


# ***Warning:*** Bike-shedding


# Array[] → [Array]

- Early betas of Swift had an "unusual" syntax for array types.
- At the value level, the syntax is `[0,1,2]`, so why not at the type level?
- This has [already been addressed](https://developer.apple.com/swift/blog/?id=3).


# Exceptions

- Notably missing.


# Do we miss exceptions?

- The Go way?
    - Sentinel values.
    - A lot of redundant work.
    - Boilerplate: Why exceptions were invented.

- We use `enums` and generic types where we would otherwise have
  exceptions, such as `Optional`.
- Just the beginning...
    - Database queries.
    - HTTP requests.


# imports

Python

~~~ Python
from module import *
from module import a
~~~


# imports, Cont.

Swift

~~~ Python
import module
import var module.a
~~~


# imports, Cont.

More Python

~~~ Python
import module
from module import a, b, c
~~~


# Dual named parameters?

- Difference between the name outside and inside of a method.
- Compatibility with ObjC?


# Monkey patching

- The ability to extend the behavior of a class outside of where it
  was originally defined.
- Compatibility with ObjC? Categories?
- Leads to namespace issues...


# Type classes

- Haskell does something similar with type classes
- ... but it avoids the namespace issue.


# Significant whitespace

- Heartbleed, Apple's `goto` fail
- You keep your curly braces if I can keep my significant whitespace.
