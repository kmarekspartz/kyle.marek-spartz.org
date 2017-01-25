---
title: Widely and Hakyll
tags: hakyll, widely, haskell, meta, open-source
description: How I use Widely to deploy Hakyll sites
---

I've been using [widely](http://www.celador.mn/widely) and [Hakyll](http://jaspervdj.be/hakyll/) together for a little while now for a few different sites.

The quickest setup is to `cd` into `_site` and `widely sites:create <SITENAME>`. However this setup involves a lot of `cd`-ing for deployment. In order to minimize `cd`-ing, I added a `deployCommand` to my Hakyll configuration as follows:

``` haskell
config = defaultConfiguration
    { deployCommand = "pushd _site && widely push && popd"
    }
```

This makes building and deploying:

    ./site build && ./site deploy

However, widely creates a `.widely` file in its source directory, which in this case is Hakyll's `_site`, and I wouldn't store `_site` in a version control repository for the site. Ideally, the `.widely` file would be stored in the root of the repository. We can put the `.widely` there and have Hakyll move the `.widely` into `_site`.

To do this, I initially added `".widely*"` to the list of file identifiers going into the `idRoute` and the `copyFileCompiler`. This doesn't work, and for a few reasons.

First, the globs don't work the way I thought they do. I changed it to `(fromRegex "\\.widely.*"))` instead.

Second, Hakyll ignores dotfiles by default, so we need to change the `ignoreFile` function in the configuration:

``` haskell
config = defaultConfiguration
         { deployCommand = "pushd _site && widely push && popd"
         , ignoreFile = ignoreFile'
         }
  where
    ignoreFile' path
        | ".widely"    `isPrefixOf` fileName = False
        | "."    `isPrefixOf` fileName = True
        | "#"    `isPrefixOf` fileName = True
        | "~"    `isSuffixOf` fileName = True
        | ".swp" `isSuffixOf` fileName = True
        | otherwise                    = False
      where
        fileName = takeFileName path
```

I've been very happy with this setup, though there remains one issue: With the `.widely` file in multiple locations, occasionally I'll accidentally call `widely push` in the root of the repository. This isn't a huge issue as widely asks before making changes. When I make this mistake, widely detects quite a few files that shouldn't be included. I think it'll just take getting used to calling `./site deploy` instead.
