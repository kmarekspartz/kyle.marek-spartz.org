---
title: Testing Interfaces in Python
tags: python, interfaces, open-source
description: Generating tests for interfaces in Python
---

In yesterday's [post](/posts/2014-01-29-interfaces-in-python.html), I proposed a way to write and test interfaces in Python. Testing these interfaces was quite verbose. I left refactoring that testing as an exercise to the reader. Then I decided to do that exercise. Here's a neat way to generate interfaces and abstract tests given a dictionary mapping interface names to a list of method names:

~~~ python
# interfaces.py
def Interface(interface_name, method_names):
    def interface_helper(*args, **kwargs):
        raise NotImplementedError
    methods = {method_name: interface_helper for method_name in method_names}
    return type(interface_name, (object,), methods)

def AbstractInterfaceTest(test_name, method_names):
    def abstract_interface_test_helper(method_name):
        def test_method(self):
            try:
                getattr(self.obj, method_name)()
            except NotImplementedError:
                self.fail(
                    type(self.obj).__name__ +
                    ' does not implement ' +
                    method_name
                )
        return test_method
    methods = {
        'test_' + method_name: abstract_interface_test_helper(method_name)
        for method_name
        in method_names
    }
    return type(test_name, (object,), methods)

interfaces = {
    'CountFish': ['one', 'two'],
    'ColorFish': ['red', 'blue']
}

for interface_name, methods in interfaces.iteritems():
    interface_name += 'Interface'
    globals()[interface_name] = Interface(interface_name, methods)
    test_name = 'AbstractTest' + interface_name
    globals()[test_name] = AbstractInterfaceTest(test_name, methods)
~~~

In order to use this with the other code from yesterday, we'd have to update `tests.py` as well:

~~~ python
# tests.py
from unittest import TestCase, main
from interfaces import CountFishInterface, ColorFishInterface,\
    AbstractTestColorFishInterface, AbstractTestCountFishInterface
from models import OurFish

class TestOurFish(AbstractTestCountFishInterface,
                  AbstractTestColorFishInterface,
                  TestCase):
    def setUp(self):
        self.obj = OurFish()

if __name__ == '__main__':
    main()
~~~
