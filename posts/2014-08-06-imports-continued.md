---
title: Imports, continued
tags: python, haskell, haskell-mn, web-ring, imports, programming-languages, programming-philosophy, ui
description: I've been asked a follow up question about reexporting items.
---

I sent [yesterday's post about
imports](/posts/2014-08-05-imports.html) to [Danny
Gratzer](http://jozefg.bitbucket.org/). He had a follow-up question:

*"Is there a Python equivalent to the Haskell trick of doing the
 following which will then export all 3 modules?"*

~~~ Haskell
module Foo (module X) where
import Data.Text as X
import Data.ByteString as X
import Control.Lens as X
~~~

The following should accomplish the same result, though it isn't as
concise due to Python's lack of an embedded module language. Though
Haskell's module language is minimal[^1], it has one. In Python, file
structure
[determines](https://docs.python.org/2/tutorial/modules.html#packages)
modules (and packages).

[^1]: ... relative to languages such as ML. There is [ongoing
work](http://plv.mpi-sws.org/backpack/index.html) to improve Haskell's
module language.


~~~ Python
# foo/x.py:
from data.text import *
from data.byte_string import *
from control.lens import *

# foo/__init__.py:
import foo.x as x

# bar.py:
from foo import x
~~~

I wouldn't recommend these sorts of tricks as the import order affects
what is in scope, e.g. if `Data.Text` and `Data.ByteString` both defined
`baz`, which would be `X.baz`? Ideally import order should not matter
as it is an implementation detail that should be hidden by a module. A
language (or
[linter](https://en.wikipedia.org/wiki/Lint_%28software%29)) can
enforce that property by preventing imports with conflicting names in
general.
