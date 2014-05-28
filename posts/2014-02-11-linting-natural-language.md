---
title: Linting Natural Language
tags: linguistics, meta
description: How I use GNU Style and Diction, and aspell.
---

For software, we have unit tests, linters, and type checkers. What do we have for natural language?

One tool that I use on occasion is [`diction`](https://www.gnu.org/software/diction/). I can never interpret its default output, so I tell it to make suggestions with `-s` and to warn me of beginner mistakes with `-b`:

~~~
diction -bs posts/2014-02-11-linting-natural-language.md
~~~

With most word processors and websites we have spell checkers. For plain-text, we can use [`aspell`](http://aspell.net/):

~~~
aspell -c posts/2014-02-11-linting-natural-language.md
~~~

Are there other tools you use for linting natural language?
