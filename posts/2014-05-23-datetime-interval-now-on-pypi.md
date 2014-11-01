---
title: datetime-interval now on PyPI
tags: python, datetime-interval, props, open-source
description: Announcing datetime-interval, a Python package.
---

Python's builtin [`datetime`](https://docs.python.org/3/library/datetime.html) module provides useful representations of points in time (`date` and `datetime`) as well as durations of time (`timedelta`). However, it does not provide a representation of an interval of time, starting at a specific point and lasting for a duration. A representation such as this would be useful for representing calendar events. To fill this need, I've implemented `datetime-interval`.

`datetime-interval` provides two classes: `Interval` and `PeriodicInterval`. `Interval` provides a structure for keeping track of events with start and end times. `PeriodicInterval` provides a representation for recurring events, with a period and a count of occurrences.

I've not yet tested it or used it too extensively, so *caveat operator*. There are a few things that I'd like to add in before using it more:

- Interval should have an `isoformat` method which returns strings of the form "start/end".
    - This wouldn't work on PeriodicInterval, as recurring intervals have a
      different semantics in ISO 8601.
- Property-based testing with `props`.
- Add operators (in, +, -, *, [], etc.).
- How to account for recurrences such as every Tuesday and Thursday.
