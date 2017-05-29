---
title: Moving to monorepos without losing history
tags: programming-philosophy,tools
description: No need to start from scratch; you can merge your repos and preserve history.
---

If you'd like to merge two (or more) git repositories together and preserve
the commit histories of both, here's the script for you:

~~~ bash
cd some-repo

git remote add other-repo git@other-repo.com:other-repo/other-repo.git
git fetch other-repo
git checkout other-repo/master

git checkout -b merge-other-repo
mkdir other-repo

for f in *; do
  git mv $f other-repo
done

# If you're making a merge request:

git merge master --allow-unrelated-histories

git push origin merge-other-repo

# Then make a merge request

# If you're pushing directly to master:

git checkout master

git merge merge-other-repo

git push origin master
~~~
