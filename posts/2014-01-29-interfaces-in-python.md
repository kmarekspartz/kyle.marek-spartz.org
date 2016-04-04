---
title: Interfaces in Python
tags: python, interfaces, open-source
description: Implementing interfaces in Python
---

There's been a long history of proposals and disagreement over interfaces in Python. I'm going to ignore all of that and show one way to utilize interfaces.

An interface can be a class from which implementing classes inherit:

~~~ python
# interfaces.py:
class CountFishInterface(object):
    def one(self, *args, **kwargs):
        raise NotImplementedError
    def two(self, *args, **kwargs):
        raise NotImplementedError

class ColorFishInterface(object):
    def red(self, *args, **kwargs):
        raise NotImplementedError
    def blue(self, *args, **kwargs):
        raise NotImplementedError

# models.py:
from interfaces import CountFishInterface, ColorFishInterface

class OurFish(CountFishInterface, ColorFishInterface):
    pass
~~~

Now, `OurFish` doesn't yet implement the interface. Before we do that, let's add some tests. Note that since multiple classes may implement our interfaces, we make abstract tests for each interface.

~~~ python
# tests.py:
from unittest import TestCase
from interfaces import CountFishInterface, ColorFishInterface
from models import OurFish

class AbstractTestCountFishInterface(object):
    def test_one(self):
        try:
            self.obj.one()
        except NotImplementedError:
            self.fail(
                str(type(self.obj)) + 'does not implement one'
            )
    def test_two(self):
        try:
            self.obj.two()
        except NotImplementedError:
            self.fail(
                str(type(self.obj)) + 'does not implement two'
            )

class AbstractTestColorFishInterface(object):
    def test_red(self):
        try:
            self.obj.red()
        except NotImplementedError:
            self.fail(
                str(type(self.obj)) + 'does not implement red'
            )
    def test_blue(self):
        try:
            self.obj.blue()
        except NotImplementedError:
            self.fail(
                str(type(self.obj)) + 'does not implement blue'
            )

class TestOurFish(AbstractTestCountFishInterface,
                  AbstractTestColorFishInterface,
                  TestCase):
    def setUp(self):
        self.obj = OurFish()
~~~

Now our tests should fail! Let's implement the interface in OurFish:

~~~ python
# models.py:
from interfaces import CountFishInterface, ColorFishInterface

class OurFish(CountFishInterface, ColorFishInterface):
    def one(self):
        return 1
    def two(self):
        return 2
    def red(self):
        return '#FF0000'
    def blue(self):
        return '#0000FF'
~~~

Now our tests should pass!

Declaring new interfaces and writing the tests is quite verbose. Here's a simpler way of declaring new interfaces:

~~~ python
# interfaces.py
def Interface(interface_name, method_names):
    def interface_helper(*args, **kwargs):
        raise NotImplementedError
    methods = {method_name: interface_helper for method_name in method_names}
    return type(interface_name, (object,), methods)

ColorFishInterface = Interface('ColorFishInterface', [
    'red',
    'blue'
])
~~~

That's not that pythonic looking, but here's another way to do it:[^1]

~~~ python
# interfaces.py
interfaces = {
    'CountFishInterface': ['one', 'two'],
    'ColorFishInterface': ['red', 'blue']
}

for interface_name, methods in interfaces.iteritems():
    globals()[interface_name] = Interface(interface_name, methods)
~~~

Still messy, but it makes it easy to add more interfaces.

I'll leave refactoring the test cases as an [exercise](/posts/2014-01-30-testing-interfaces-in-python.html) to the reader. Beyond moving the try-block into a helper method, the best solution I can presently come up with is code-generation.

[^1]: *Update:* No one noticed, but I was originally missing the call to `iteritems`!
