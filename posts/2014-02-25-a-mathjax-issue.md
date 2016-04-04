---
title: A MathJax Issue
mathjax: true
tags: meta
description: Test page for a MathJax issue
---

I'm having a small issue with [MathJax](http://www.mathjax.org/). I wanted to
use it in yesterday's post, but it wasn't working so I used
[LaTeXiT](http://pierre.chachatelier.fr/latexit/latexit-home.php?lang=en) to
generate a PNG.

Here's the PNG:

![](/images/factorial.png)

Here's the MathJax version:

$$factorial = \lambda n . \left\lbrace
\begin{array}{c c}
n & \textrm{if $n = 1$} \\
n * self (n-1) & \textrm{if $n > 1$}
\end{array}\right.
$$

The MathJax version generates fine on the MathJax website, so I suspect it has
something to do with my configuration (the default
[Hakyll](http://jaspervdj.be/hakyll/) MathJax config). Can anyone help? Feel
free to browse the source.

*Update:* Thanks to [Daniil Frumin](http://covariant.me/) for the [fix](https://groups.google.com/forum/#!topic/hakyll/Fob_YFFh7kU)! It all seems to be working now.
