---
title: Top-down Programming
tags: programming-philosophy
description: Why I prefer top-down to bottom-up programming
---

> Think about the ideal way to write a web app. Write the code to make it happen.
>
> [Aaron Swartz](http://www.aaronsw.com/) (from [web.py](http://webpy.org/philosophy))

If we write the code that we think we will need, before we actually need it, we likely are writing code we don't need. Instead, use [lazy evaluation](http://en.wikipedia.org/wiki/Lazy_evaluation) to implement only the code that you need as you need it! This prevents the creation of [spaghetti code](http://en.wikipedia.org/wiki/Spaghetti_code). Not only does this keep our implementation simple, but this also allows us to program in the problem domain, which makes it easier to find problems later.

I've been using [readme driven development](http://tom.preston-werner.com/2010/08/23/readme-driven-development.html) to implement my port of [QuickCheck](https://en.wikipedia.org/wiki/QuickCheck) to Python. It seems to be working well so far. All I have left is to add some tests, and name it! Any ideas for the name? There's already [quite](https://github.com/markchadwick/paycheck) [a](http://dan.bravender.us/2009/6/21/Simple_Quickcheck_implementation_for_Python.html) [few](https://pypi.python.org/pypi/pytest-quickcheck/) [other](http://www.drmaciver.com/2013/03/quickcheck-style-testing-in-python-with-hypothesis/) [libraries](https://github.com/npryce/python-factcheck) that have taken the good names.
