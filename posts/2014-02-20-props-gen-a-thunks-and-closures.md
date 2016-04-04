---
title: Props: Gen a, thunks, and closures
tags: python, props, haskell, programming-languages, open-source
description: Internals of Props
---

In my previous [post](/posts/2014-02-17-props-now-on-pypi.html) about [Props](https://pypi.python.org/pypi/props/), I said I would elaborate on its equivalent to `Gen a` from Haskell's [QuickCheck](https://en.wikipedia.org/wiki/QuickCheck).

In Haskell, consider the following implementation of a tree:

~~~ Haskell
data Tree a = Tree { value :: a
                   , children :: [Tree a]
                   } deriving (Eq, Show)
~~~

Let's make it an instance of `Arbitrary`[^1]:

~~~ Haskell
instance (Arbitrary a) => Arbitrary (Tree a) where
    arbitrary = do value <- arbitrary
                   children <- arbitrary
                   return Tree { value=value
                               , children=children
                               }
~~~

[^1]: This won't terminate as it would create an infinite Tree structure! But that's not important here. See [StackOverflow](http://stackoverflow.com/questions/15959357/quickcheck-arbitrary-instances-of-nested-data-structures-that-generate-balanced) if you want a version that would terminate.

Since Haskell can determine types at compile time, we don't need to put in any type annotations. In particular, we don't need to tell arbitrary what type we want it to return when making the arbitrary value and children.

In Python, the following class which implements `ArbitraryInterface`, would be approximately[^2] equivalent to the above Haskell type[^3]:

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

[^2]: The Python Tree class is just for `int`. This would be equivalent to the `Tree Int` type in Haskell. If we had generics in Python... something for a later post.

[^3]: This also won't terminate. I'll leave that as an exercise for the reader.

Ignoring some details[^4], we can think of Haskell's `Gen a` as representing something which can be turned into an `a`. How can we make something that can be turned into an `a`? We can use a thunk! A thunk is an object which represents a paused computation. Forcing a thunk causes the computation to occur. Since Haskell is lazy, everything is thunk by default. In Python, iterators can be thought of as lazy, but they usually represent collections of objects, rather than just a single object, so this would not be the best use of iterators.

[^4]: For example, Haskell's QuickCheck passes in a nonce to `Gen a` to make sure the generated `a` is unique. There's also the notion of `shrink` which Props does nothing with. Yet.

One simple way to implement a thunk is to make a closure which takes no arguments. For example:

~~~ Python
def setup_a_thunk(some, variables, _for, our, computation):
    def thunked_computation():
        // ...
        // Do a bunch of work
        // Using the variables passed in to setup_a_thunk
        return a_result
    return thunked_computation
~~~

We can then call `setup_a_thunk` a bunch of times, but it would not actually do the work until we force it, i.e. call the thunk with no arguments:

~~~ Python
a_thunk = setup_a_thunk(...)
another_thunk = setup_a_thunk(...)

one_result = a_thunk()  # This forces the thunk.
~~~

Since [objects are closures](http://c2.com/cgi/wiki?ClosuresAndObjectsAreEquivalent), we can view the class definition for `Tree` as setting up a closure, which we force when we call `arbitrary`.

So, there you have it. The equivalent of Haskell QuickCheck's `Gen a` in Props is a closure!
