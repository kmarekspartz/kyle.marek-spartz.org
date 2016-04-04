---
title: Sacrificing Safety for Flexibility
tags: programming-philosophy, programming-languages
description: An analogy between type systems and databases 
---

There are tradeoffs with almost any technology choice. Often, a choice's strength is also its weakness.

When choosing a programming language, should it use static or dynamic typing? There are arguments to be made on each side. For static, we get a reasonable amount of assurance that certain classes of bugs cannot occur. However, with dynamic, we can be more flexible about our structure and design. Many people have argued for the inverse: languages with static type systems are inflexible and languages with dynamic type systems are unsafe.

In databases, one ongoing trend is the popularity of NoSQL systems, particularly key-value stores. One argument for key-value stores is their flexibility. However, just as before, we lose the guarantees that a static type system (i.e. SQL) provides. This is just a tradeoff that has to be considered when choosing a database.

The main argument for flexibility in both dynamic languages and key-value stores is how fast a prototype can be made since there is little need to account for changes in schema or typing. However, when these systems need to be made robust later on, developers end up making code to account for the schema or typing in their system. This code would be redundant and automatic in a static type system.

It is perhaps even worse when dynamism is forced into static systems. In C, we could just put all of our data into an [untagged union](http://en.wikipedia.org/wiki/Union_type#Untagged_unions). This would allow us to pass anything into anywhere. We lose the safety of a (weak) static type system for a small gain in flexibility. In SQL databases, we can denormalize and put everything in one table, and use nullable strings for every column type. But again, we lose safety for flexibility.[^1]

[^1]: Interestingly, both forcing static types into a dynamic system and forcing dynamism into a static system decreases maintainability.
