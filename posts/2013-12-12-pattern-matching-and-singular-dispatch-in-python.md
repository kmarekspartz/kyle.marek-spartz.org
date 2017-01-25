---
title: Pattern Matching and Singular Dispatch in Python
tags: python
description: Implementing pattern matching and singular dispatch in Python
---

[Pattern matching](https://en.wikipedia.org/wiki/Pattern_matching) and [singular dispatch](https://en.wikipedia.org/wiki/Dynamic_dispatch) are useful tools not readily usable in Python. There is [PEP 443](http://www.python.org/dev/peps/pep-0443/), but I'm not a fan for how verbose that is.

We can use dictionaries to do basic pattern matching. Here's an absolute value function:

~~~~ python
def abs(x):
    abs_dict = {
        True: lambda x: x,
        False: lambda x: -x
    }
    return abs_dict[x >= 0](x)
~~~~

We can use any expression to dispatch the `abs_dict`. This allows for more complex patterns than just `True` and `False`. This function takes an `int` or a `string` and returns more:

~~~~ python
def more(x):
    more_dict = {
        int: lambda x: x + 1,
        str: lambda x: x + 's'
    }
    return more_dict[type(x)](x)

more(1) == 2
more('noun') == 'nouns'
~~~~

This used singular dispatch to choose which implementation to use. I’ve been using the following:


~~~~ python
from collections import OrderedDict

class singular_dispatch(OrderedDict):   
    def __call__(self, *args, **kwargs):
        return self[type(args[0])](*args, **kwargs)

~~~~

Pretend `OrderedDict` is a normal `dict` for now. By inheriting from `dict`, our singular_dispatch objects can function like any other dictionary, and has all of its methods.[^1] We want singular dispatch objects to also function as a function, so we add a `__call__` method. The call method uses the type of its first argument (other than `self`) to dispatch which function within `self` to use. This assumes that the values in `self` are functions which operate on the type for their keys.

This simplifies the definition of `more`:

~~~~ python
more = singular_dispatch({
    int: lambda x: x + 1,
    str: lambda x: x + 's'
})

more(1) == 2
more('noun') == 'nouns'
~~~~

`singular_dispatch` objects also allow us to specify an instance to use instead of the type of the first argument. In this case, that would raise a `TypeError`:

~~~~ python
more[int](1) == 2
# more[str](1) raises TypeError
# more[int]('noun') raises TypeError
~~~~

Inheriting from [OrderedDict](http://docs.python.org/2/library/collections.html#collections.OrderedDict) isn’t strictly necessary in this case, but it is useful for the `singular_dispatch` class since it remembers the order in which keys are added.

[^1]: Including `update`. More on that in a different post.
