% Interfaces
% Kyle Marek-Spartz; <kyle.marek.spartz@gmail.com>; <http://kyle.marek-spartz.org>
% February 13, 2014

# Interfaces

- Interfaces verify that a class implements certain methods.
- In some languages this is done statically, e.g. Java.


# Interfaces in Java

~~~~ Java
public interface CountFishInterface {
    public void one();
    public void two();
}

public class OurFish implements CountFishInterface {
    public void one() { ... }
    public void two() { ... }
}
~~~~

- `javac` should complain if the interface is not satisfied.


# Interfaces in Python
- In Python, this verification can't be done statically, due to the ability to add methods at runtime.
- <http://www.python.org/dev/peps/pep-0245/>
- <https://pypi.python.org/pypi/zope.interface/4.1.0>
- <http://ref.readthedocs.org/en/latest/understanding_python/interfaces/index.html>
- <http://nedbatchelder.com/text/pythonic-interfaces.html>
- <http://dirtsimple.org/2004/12/python-interfaces-are-not-java.html>


# `NotImplementedError`

~~~~ python
class CountFishInterface(object):
    def one(self, *args, **kwargs):
        raise NotImplementedError
    def two(self, *args, **kwargs):
        raise NotImplementedError
~~~~


# `NotImplementedError`, cont.

~~~~ python
class OurFish(CountFishInterface):
    def one(self):
        return 1
    def two(self):
        return 2
~~~~   

- Classes that are expected to implement these methods can inherit from the interface.
- If a method is called that is expected to be there but isn't, it would raise `NotImplementedError`.


# A sidenote on composition over inheritance

- Multiple inheritance both enables this ability, but it also makes adds a small difficulty:
    - If the methods specified in the interface are provided for using mixins or parent classes, then choosing the order of the inheritance is important.
    - Interfaces should appear in an appropriate place in the inheritance specification, i.e. near the end.
    - For help with this, see the documentation on [multiple inheritance](http://docs.python.org/3/tutorial/classes.html#multiple-inheritance).


# Testing against an interface

~~~~ python
class OurFishImplementsCountFishInterface(TestCase):
    def setUp(self):
        self.obj = OurFish()
    def test_one(self):
        try:
            self.obj.one()
        except NotImplementedError:
            self.fail(
                'OurFish does not implement one'
            )
    ...
~~~~


# Testing against an interface, cont.

~~~~ python
class AbstractTestCountFishInterface(object):
    def test_one(self):
        try:
            self.obj.one()
        except NotImplementedError:
            self.fail(
                str(type(self.obj)) + 'does not implement one'
            )
    ...

class TestOurFish(AbstractTestCountFishInterface, ..., TestCase):
    def setUp(self):
        self.obj = OurFish()
~~~~


# `AttributeError`

- Calls to methods on classes that don't provide them would normally raise an `AttributeError`, so why bother?
- Documenting the interface in the code is useful.
- If we generate these Interfaces automatically, we can also generate test cases automatically.


# Defining classes at run time

This:

~~~~ python
class A(B, C):
    an_attribute = 1
    def a_method():
        return 2
~~~~

is approximately equivalent to:

~~~~ python
A = type('A', (B, C), {
    'an_attribute': 1,
    'a_method': lambda: 2
})
~~~~


# Defining interfaces at run time

~~~~ python
def Interface(interface_name, method_names):
    def interface_helper(*args, **kwargs):
        raise NotImplementedError
    methods = {
        method_name: interface_helper
        for method_name
        in method_names
    }
    return type(interface_name, (object,), methods)
~~~~


# Defining interface tests at run time

~~~~ python
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
~~~~


# Defining multiple interfaces (and abstract tests) at run time

~~~~ python
interfaces = {
    'CountFish': ['one', 'two'],
    'ColorFish': ['red', 'blue']
}

for interface_name, methods in interfaces.iteritems():
    interface_name += 'Interface'
    globals()[interface_name] = Interface(interface_name, methods)
    test_name = 'AbstractTest' + interface_name
    globals()[test_name] = AbstractInterfaceTest(test_name, methods)
~~~~


# To do:

- Accounting for classmethods
- Specifying the signature of the methods


# `interface-mixins`

- <https://pypi.python.org/pypi/interface-mixins>
- <https://github.com/zeckalpha/interface-mixins>
- <http://kyle.marek-spartz.org>
