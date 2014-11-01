---
title: Uploading to PyPI
tags: python, teaching, tools, web-ring, open-source
description: Tom Christie gave a guide on uploading to PyPI
---

Yesterday, my co-worker, [Tom Christie](https://tom-christie.github.io/), posted a guide on [uploading Python modules to PyPI](https://tom-christie.github.io/articles/pypi/). I've done this a few times, but haven't had to deal with a package as complicated as the one he was uploading, since the packages I've uploaded are pure Python. His package compiles a C program which gets called by the Python library, and provides some [pickled](https://docs.python.org/2/library/pickle.html) data to minimize recomputation.

One thing I noticed was the suggestion to use [`twine`](https://pypi.python.org/pypi/twine/1.3.0) to minimize transmission of PyPI passwords in plaintext. I'm not sure why `pip` doesn't use HTTPS to interact with PyPI directly, but I suspect this to be fixed upstream before too long. For now, `twine` provides a workaround.
