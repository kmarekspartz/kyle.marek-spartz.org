---
title: Reusing Generators in Python
tags: python
description: (On not) reusing generators in Python
---

A friend of mine had an issue recently with a generator in Python. Here's the code:

~~~ Python
def our_generator(input):
    while input:
        do(something, on, input)
        yield something

print(list(our_generator(input)))

for i in our_generator(input):
    do(something, else, with, i)
~~~

See the bug?

There was an issue with the `for`-loop, so the print statement was added in, but this changed the behavior of the program. Once the generator has expired, it can't be reused, so it never entered the `for`-loop. Since the generator would be exhausted anyway, we can get the expected behavior without additional cost by doing the following:

~~~ Python
output = list(our_generator(input))

print(output)

for i in output:
    do(something, else, with, i)
~~~
