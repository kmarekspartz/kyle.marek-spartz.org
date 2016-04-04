---
title: Setting Class Names Dynamically in Python
tags: python
description: Metaprogrammed named classes in Python
---

I'm finishing up my [QuickCheck](http://en.wikipedia.org/wiki/QuickCheck) implementation for Python. I'm writing generator combinators to make it easier to make new generators. Since the generators I'm using are just classes with a class method `arbitrary`, the combinators dynamically create classes:

~~~ python
def a_combinator(generator1, generator2):
    class a_combinator_class(...):
        @classmethod
        def arbitrary():
            ...
    return a_combinator_class
~~~

However, this leaves us with an issue. I would like to be able to display a name for the generator. For generators which aren't constructed with combinators, we can just call `generator.__name__`, but this doesn't work for generator combinators. With the above combinator, that would show `a_combinator_class` no matter what generators we pass into the combinator. It would be better if it showed `a_combinator(generator1, generator2)`. We can do this by setting `__name__` on `a_combinator_class`:

~~~ python
def a_combinator(generator1, generator2):
    class a_combinator_class(...):
        ...
    a_combinator_class.__name__ = ''.join([
        'a_combinator(',
        ', '.join([
            generator1.__name__,
            generator2.__name__
        ]),
        ')'
    ])
    return a_combinator_class
~~~
