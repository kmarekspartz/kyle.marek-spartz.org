% Property-based Testing
% Kyle Marek-Spartz; <kyle.marek.spartz@gmail.com>; <http://kyle.marek-spartz.org>
% April 10, 2014

# Unit testing

- Specific data
- Test specific properties on the specific data


# Property-based testing

- Started with QuickCheck, a Haskell library
- Define "generators" for each type/model:
    - Generate random (ideally pathological) data
    - (Not the same word as what we usually think of as generators in Python)
- Define properties that each type should have
- Test properties against generated data
- Props ([PyPI](https://pypi.python.org/pypi/props/), [GitHub](https://github.com/zeckalpha/props)) provides property-based testing for Python à la [QuickCheck](http://en.wikipedia.org/wiki/QuickCheck).


# Properties

- A property is just a function which takes an object or objects and:
    - returns `True` on success
    - returns `False` or raises `AssertionError` on failure


# ∀

- `for_all` takes a list of "generators" and a property. It then tests the property for arbitrary (random) values of the "generators".


# Commutativity

Commutative properties of `int`s:

~~~ Python
for_all(int, int)(lambda a, b: a + b == b + a)
for_all(int, int)(lambda a, b: a * b == b * a)
~~~


# Associativity

More complicated properties:

~~~ Python
def prop_associative(a, b, c):
    assert a * (b * c) == (a * b) * c
    return a + (b + c) == (a + b) + c
    
for_all(int, int, int)(prop_associative)
for_all(float, float, float)(prop_associative)
~~~


# "Generators"

A "generator" is a specification of a set of possible Python objects. A
"generator" is either:

- One of the following built-in types:
    - `None`, `bool`, `int`, `float`, `long`, `complex`, `str`, `tuple`,
      `set`, `list`, or `dict`
- A class that implements `ArbitraryInterface`
- Or constructed using the generator combinators.


# `ArbitraryInterface`

~~~ Python
class ArbitraryInterface(object):
    @classmethod
    def arbitrary(cls):
        raise NotImplementedError
~~~


# `arbitrary`

~~~ Python
class Tree(ArbitraryInterface):
    value = None
    children = []

    def __init__(self, value, children):
        self.value = value
        self.children = children

    @classmethod
    def arbitrary(cls):
        return cls(
            arbitrary(int),           # Value
            arbitrary(list_of(Tree))  # Children
        )
~~~


# "Generator" combinators

- `maybe_a(float)`
- `maybe_an(int)`
- `one_of(float, int)`
- `tuple_of(float, int)`
- `set_of(int)`
- `list_of(bool)`
- `dict_of(a=bool, b=int, c=float)`


# To Do

- all built in types: http://docs.python.org/2/library/stdtypes.html
- ranges
- import some `faker` generators for more semantic random values
    - e.g. email addresses, names


# Other QuickCheck-like libraries for Python

- [factcheck](https://github.com/npryce/python-factcheck)
- [hypothesis](http://www.drmaciver.com/2013/03/quickcheck-style-testing-in-python-with-hypothesis/) 
- [paycheck](https://github.com/markchadwick/paycheck)
- [pytest-quickcheck](https://pypi.python.org/pypi/pytest-quickcheck/) 
- [qc.py](http://dan.bravender.us/2009/6/21/Simple_Quickcheck_implementation_for_Python.html)
