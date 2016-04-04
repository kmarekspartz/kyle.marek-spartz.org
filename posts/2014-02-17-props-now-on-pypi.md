---
title: Props Now On PyPI
tags: python, haskell, props, open-source
description: Releasing a property-based testing framework for Python
---

Props ([PyPI](https://pypi.python.org/pypi/props/), [GitHub](https://github.com/zeckalpha/props)) provides property-based testing for Python à la [QuickCheck](http://en.wikipedia.org/wiki/QuickCheck).

There are other QuickCheck-like libraries for Python:

- [factcheck](https://github.com/npryce/python-factcheck)
- [hypothesis](http://www.drmaciver.com/2013/03/quickcheck-style-testing-in-python-with-hypothesis/)
- [paycheck](https://github.com/markchadwick/paycheck)
- [pytest-quickcheck](https://pypi.python.org/pypi/pytest-quickcheck/)
- [qc.py](http://dan.bravender.us/2009/6/21/Simple_Quickcheck_implementation_for_Python.html)

However, I'm not sure how to add instances of Arbitrary (in the Haskell sense) for any of them! That's where Props comes in.

In Haskell's QuickCheck, Arbitrary is a typeclass:

~~~ Haskell
class Arbitrary a where
    arbitrary :: Gen a
~~~

Typeclasses are like interfaces, but for types instead of classes. The way to read this definition is "Any class `a` which implements the `Arbitrary` interface must provide a method `arbitrary` which returns a `Gen a`." Think of `Gen a` as a container which can be turned into random instances of `a`.[^1] To create new instance of `Arbitrary`[^2]:

~~~ Haskell
instance Arbitrary Bool where
    arbitrary = choose (False, True)
~~~

[^1]: I'll discuss the equivalent of `Gen a` being used in Props (closures! thunks!) in a later [post](/posts/2014-02-20-props-gen-a-thunks-and-closures.html).
[^2]: This specific instance is already provided for you, but it makes for a good example.


In Python, we define a class which provides `arbitrary` as a classmethod which raises `NotImplementedError` since we don't have [interfaces](/posts/2014-01-29-interfaces-in-python.html):

~~~ Python
class ArbitraryInterface(object):
    @classmethod
    def arbitrary(cls):
        raise NotImplementedError
~~~

To implement an instance:

~~~ Python
class bool(ArbitraryInterface):
    @classmethod
    def arbitrary():
        return random.choice([False, True])
~~~

However, in this case, `bool` is already defined, and we do not want to shadow that definition. Classmethods are just functions which dispatch on the type given, so we can define arbitrary somewhat like this[^3]:

~~~ Python
arbitrary_dict = {
    bool: lambda: random.choice([False, True]),
    ...
}

def arbitrary(cls):
    if issubclass(cls, ArbitraryInterface):
        return cls.arbitrary()
    return arbitrary_dict[bool]()
~~~

[^3]: `None` doesn't work in this case, so I handle it separately in Props.

This way we can provide implementations of arbitrary for already defined types (either in the standard library or in external libraries) in `arbitrary_dict`, and also handle instances of `ArbitraryInterface` for our own classes.
