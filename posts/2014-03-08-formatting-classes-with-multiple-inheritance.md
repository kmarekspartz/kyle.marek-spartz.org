---
title: Formatting Classes with Multiple Inheritance in
tags: python
description: Formatting rules for Python
---

[PEP 8](http://legacy.python.org/dev/peps/pep-0008/#maximum-line-length) says that line length should generally be fewer than 80 characters. It doesn't discuss formatting for classes with multiple inheritance, but we can infer a preferred style from the formatting for methods.

Consider this class with a long list of parent classes:

~~~ Python
class OurClass(AMixin, AnotherMixin, SomeParentClass, AnotherParent, ThisIsJustTooMany):
    pass
~~~

This could be formatted:

~~~ Python
class OurClass(
    AMixin,
    AnotherMixin,
    SomeParentClass,
    AnotherParent,
    ThisIsJustTooMany
):
    pass
~~~

Another formatting could be:

~~~ Python
class OurClass(AMixin,
               AnotherMixin,
               SomeParentClass,
               AnotherParent,
               ThisIsJustTooMany):
    pass
~~~

Due to the way methods are formatted in PEP 8, a better style might be:

~~~ Python
class OurClass(AMixin, AnotherMixin, SomeParentClass,
               AnotherParent, ThisIsJustTooMany):
    pass
~~~

I'm not sure here. I prefer the latter two. What would you prefer?
