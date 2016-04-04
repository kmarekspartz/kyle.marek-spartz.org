---
title: Adding First-class Functions to Python
tags: python, programming-languages
description: Object and function duality
---

Let's pretend we are stuck in an alternate universe where first-class functions[^1] don't exist in Python. How could we add them back in using classes, without modifying the run-time?

Here's a square function:

~~~ python
class SquareFunc:
    def apply(x):
        return x * x

square = SquareFunc()
~~~


Okay, that wasn't very exciting. What about higher-order functions?

~~~ python
class MapFunc:
    def apply(f, list):
        new_list = []
        for element in list:
            new_list.append(f(element))
        return new_list

map = MapFunc()

map.apply(square, [1, 2, 3])  # [1, 4, 9]
~~~


And that's it!


[^1]: Or list comprehensions, as that would be cheating for this example. Also, I'm pretending `__call__` doesn't exist. Because.
