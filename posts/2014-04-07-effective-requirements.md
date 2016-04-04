---
title: Effective Requirements
tags: programming-philosophy
description: How to gather requirements
---

Requirements are a funny thing. They can be over- or underspecified, and it is often hard to know which is which.

Vagueness in the requirements can be bad or good. When requirements are vague, it is difficult to know what direction to go in, or whether the end result will be what the client is looking for. On the other hand, when the client can afford to experiment, vague requirements sometimes provide for novel solutions which the implementers would not have discovered had the requirements been more specific.

Programming in the requirements can also be bad or good. When non-programmers attempt pseudocode, it can lead to logically inconsistent requirements. Instead, when the client cannot afford to learn programming, the requirements should solely detail the needs of the client rather than the specific logic that needs implementing. On the other hand, providing pseudocode in the requirements makes implementation more straightforward, at least initially.

----------------

[John D. Cook](http://www.johndcook.com/) blogged about [patches and specs](http://www.johndcook.com/blog/2014/04/05/patches-and-specs/) today. I've not yet had time to view [the video](http://channel9.msdn.com/Events/Build/2014/3-642) he linked to, but here's the quote he selected:

> Every time code is patched, it becomes a little uglier, harder to understand, harder to maintain, bugs get introduced.
>
> If you don’t start with a spec, every piece of code you write is a patch.
>
> Which means the program starts out from Day One being ugly, hard to understand, and hard to maintain.
>
> – [Leslie Lamport](http://www.lamport.org/)
