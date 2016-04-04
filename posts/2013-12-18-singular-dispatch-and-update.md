---
title: Singular Dispatch and Update
tags: python
description: Providing more implementations for a singular dispatch method
---

In my earlier [singular dispatch post](/posts/2013-12-12-pattern-matching-and-singular-dispatch-in-python.html), I suggested that the `update` method of the `singular_dispatch` class is quite useful. One place I'm using it is for an implementation of [QuickCheck](http://en.wikipedia.org/wiki/QuickCheck) in Python[^1].

[^1]: I'll be posting more on this as things get implemented.

An important aspect of QuickCheck is an `arbitrary` function which returns a random value of a specified type. Assuming we have a `random_int` function, we can create an initial `arbitrary` function which works for `int`:

~~~~ python
def random_int():
    return random.randint(-sys.maxint - 1, sys.maxint)

arbitrary = singular_dispatch({
    int: random_int,
})
~~~~

Now, when you want to extend this behavior to new types in Haskell, one would write something like:

~~~~ haskell
instance Arbitrary Bool where
  arbitrary = ...
  ...
~~~~

Back in Python land, we can add another instance to `arbitrary` using the `update` method:

~~~~ python
arbitrary.update({
    bool: lambda: arbitrary[int]() > 0
})
~~~~

Calling `arbitrary[cls]()` isn't very pythonic. The preferred notation would be `cls.arbitrary()`. This mixin provides that notation for classes which inherit from it[^2]:

[^2]: This mixin does not provide the object-oriented notation for primitive types.

~~~~ python
class ArbitraryMixin(object):
    @classmethod
    def arbitrary(cls):
        return arbitrary[cls]()


class Natural(int, ArbitraryMixin):
    ## Does not actually enforce self >= 0!
    pass

class NaturalPlus(int, ArbitraryMixin):
    ## Does not actually enforce self >= 1!
    pass


arbitrary.update({
    Natural: lambda: abs(arbitrary[int]())
    # Only arbitrary integers >= 0.
    NaturalPlus: lambda: Natural.arbitrary() + 1
    # Only arbitrary positive integers, and sys.maxint + 1.
})
~~~~

(*Note*: for simplicity, we're ignoring the sys.maxint + 1 case. It would not still be an `int` due to Python casting on overflow.)

This is reminiscent of `deriving` in Haskell, though nowhere near as powerful.

This even works for complex data structures such as Trees, as long as the structure is defined in arbitrary appropriately. To do so, we create a class combinator which returns a random arbitrary function:

~~~~ python
def or_(*args):
    return arbitrary[random.choice(args)]

class Tree(ArbitraryMixin):
    pass

class Leaf(Tree, ArbitraryMixin):
    def __init__(self, value):
        self.value = value

class Node(Tree, ArbitraryMixin):
    def __init__(self, left, right):
        self.left = left
        self.right = right

arbitrary.update({
    Tree: lambda: or_(Leaf, Node)(),
    Leaf: lambda: Leaf(Natural.arbitrary()),
    Node: lambda: Node(Tree.arbitrary(), Tree.arbitrary())
})
~~~~

One benefit of this is `Leaf.arbitrary()` is guaranteed to be a `Leaf` and `Node.arbitrary()` is guaranteed to be a `Node` but `Tree.arbitrary()` makes no such guarantees. This is a useful result of subtyping in Python.
