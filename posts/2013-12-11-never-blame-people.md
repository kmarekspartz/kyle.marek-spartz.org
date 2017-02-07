---
title: Never Blame People
tags: ui, programming-philosophy
description: Computer programs should not blame people for their own failings
---

Many people don't like using computers because they internalize computer problems when things go wrong. People blame themselves when computers don't behave as expected.

One attempt to fix this would be to provide better error messages. Instead of 'Operation Failed', software should report why the operation failed. Was it a data problem? Network connectivity? A timeout for the server? Invalid response from the server? [^1] By telling people what is wrong, rather than telling them that something went wrong, software can empower people to adjust the necessary conditions to fix the problem.

Another current trend which people internalize is obfuscated UI. When people cannot find a menu because it is [hidden off the edge of the screen](https://www.microsoft.com/en-us/windows), or buttons are labeled with [abstract icons](http://gmail.com), they blame themselves.

Software needs to teach people not to blame themselves for things beyond their control.

[^1]: *Note:* this also makes things easier to debug!
