---
title: Compiler Optimizations and Optimality Theory
tags: linguistics, programming-languages
description: Compiler optimizations and optimality theory
---

Yesterday, I read a [post](http://gus-massa.blogspot.com/2014/04/removing-strange-t-and-f-of-ifs-in.html) on bytecode optimizations in Racket. The post discusses a number of optimizations (both proposed and implemented) for `if`-expressions in the Racket compiler.

Of particular interest is optimization *h*, which despite optimizing many redundant `if`-expressions, introduces a few trivially redundant expressions, such as `(if #t a b)`, which should just be `a`. The solution proposed introduces three more optimizations *i, j, k* to account for these cases.

Another observation from the Racket post was that there are cases where bytecode could have improvements and regressions with the optimizations ordered one way, and have different improvements and regressions with the optimizations ordered a different way.

This is similar to a problem that phonology faced when using a similar rule-based approach. [Optimality Theory](https://en.wikipedia.org/wiki/Optimality_theory) (OT) was created to account for this. It eschews the rule-based approach for a constraint and search approach, so that rules can apply in different orders in different cases.

In OT, there is a universal set of constraints, *CON*, which, given a language, has an ordering. Given a underlying representation, *GEN* generates an infinite list of all possible outputs. *EVAL* then considers each candidate against the ordered constraints for the language.

By analogy, a graph search algorithm could be used to evaluate bytecode according to a specific set of ordered constraints. Instead of applying rules in a linear order, each transformation rule would provide a new node in the graph. Ordered constraints would then be used as a heuristic.
