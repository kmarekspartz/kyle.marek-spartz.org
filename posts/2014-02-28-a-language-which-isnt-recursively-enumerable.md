---
title: A Language which isn't Recursively Enumerable
tags: programming-languages, linguistics
description: A Language which isn't Recursively Enumerable
---

We've been working through the [Chomsky hierarchy](https://en.wikipedia.org/wiki/Chomsky_hierarchy) at the computational linguistics reading group. This past week, the existence of a language which wasn't recursively enumerable came up. Here's my attempt at a solution. Please let me know where my math and reasoning go off track.


By definition, a [recursively enumerable language](https://en.wikipedia.org/wiki/Recursively_enumerable_language) is a language for which there exists a Turing machine which must halt on all strings in the language, but may not necessarily halt on strings not in the language.

By definition, "a [universal Turing machine](https://en.wikipedia.org/wiki/Universal_Turing_machine) (UTM) is a Turing machine which can simulate an arbitrary Turing machine on arbitrary input".

The existence of a UTM requires a string-encoding of a Turing machine, that is, a string which can be interpreted by the UTM to simulate the described Turing machine.

Since languages are sets of strings, the set of strings which describe Turing machines that halt for all inputs is a language, *L*.

Due to the [halting problem](https://en.wikipedia.org/wiki/Halting_problem), there cannot exist a Turing machine which halts for all strings in *L*.

Since the definition of a recursively enumerable language requires the existence of such a Turing machine, the language *L* is not recursively enumerable.

While *L* is not recursively enumerable, supersets of *L* may be recursively enumerable. As an exercise for the reader, what is an example of a language which is a superset of *L*, but is recursively enumerable?
