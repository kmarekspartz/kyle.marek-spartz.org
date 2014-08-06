---
title: Quantity and Quality
tags: beeminder, meta, philosophy, mindfeed
description: Adjusting my metrics to better reflect my goals.
---

*A case of accidental prioritization.*

In January, I started using [Beeminder](https://www.beeminder.com) to
track my blogging. For each post, I've been adding a data point with a
value of one, with a goal pace of about four posts per week.  However,
because each post had the same value, I had inadvertently set my
sights for quantity over quality. If it doesn't matter how well I
write, quality suffers at the expense of quantity[^2].

[^2]: Once I realized I was doing this, both quantity and quality
plummeted.

In order to get around this, I should change what is being
measured. Naively, I could change my goal to be *N* words per week
(where *N* is initially my historic rate), but this would result in a
different accidental prioritization of quantity over quality: I would
write longer posts, not necessarily better posts.

Instead, I'm developing a quality measurement using natural language
processing, and incorporating it into
[`mindfeed`](http://kyle.marek-spartz.org/posts/2014-05-29-mindfeed.html).
I'm unsure how exactly to calculate quality, so instead of guessing,
I'm developing a set of features each of which I'll mind[^1] with
Beeminder separately.  I'll then manually rate my previous posts and
develop a model which can assign a rating to a post using the
features. Eventually, I may ask some prototypical readers to rate my
posts. I could then develop a model for each set of ratings.

[^1]: *mind*, verb: to track data with Beeminder.

One feature will be length, thought as mentioned above, it cannot be
used on its own. I'll also look at vocabulary diversity using the
count of [types](https://en.wikipedia.org/wiki/Type-token_distinction)
as well as an information-theoretic approach. I will also be tracking
readability measures such as the [Flesch–Kincaid
index](https://en.wikipedia.org/wiki/Flesch%E2%80%93Kincaid_Readability_Test).
Another aspect to consider is uniqueness relative to previous
posts. This can be simple, such as how many new words were introduced
in this blog post, or more complex, such as
[vector-space](https://en.wikipedia.org/wiki/Vector_space_model)
[distance](https://en.wikipedia.org/wiki/Metric_%28mathematics%29).

Measurements are important, as they do change behavior, but what we
measure can sometimes have unintended consequences. Choose your
metrics carefully.
