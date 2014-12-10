---
title: Hakyll CSS Template Compiler
tags: meta, hakyll, open-source
description: To appease Google, I inlined CSS in my Hakyll pages.
---

Google wasn't happy with how many render-blocking resources I was loading from
pages on this site. It suggested that I inline render-blocking CSS.

I'm not sold that this is ideal. Previously, if a client requested a resource
they already had, they wouldn't necessarily need to re-download the resource.
The CSS being used across pages could be cached, so each request would only get
the necessary unique data. Other than the initial fetch which would get all
the resources, the amount of information exchanged is minimal.

With the CSS inline, this content cannot be cached (across pages), and therefore
it is downloaded for each page. While there are fewer requests needed to get a
single page, there is redundant information being included in each request.

Anyway, I thought I'd try it out. [Hakyll](http://jaspervdj.be/hakyll/) provides
a
[CSS compiler](https://github.com/jaspervdj/hakyll/blob/59b6f01218eb2fbd36cb9fec6a3413093171ccda/src/Hakyll/Web/CompressCss.hs#L24)
which compresses CSS by removing whitespace, comments, and redundant
punctuation. It also provides a
[template compiler](https://github.com/jaspervdj/hakyll/blob/59b6f01218eb2fbd36cb9fec6a3413093171ccda/src/Hakyll/Web/Template.hs#L147),
which allows variable substitution and nesting of templates. However, it doesn't
provide a way to compress CSS inside a template. I took the definition of it's
template compiler and its CSS compiler and combined them:

``` Haskell
cssTemplateCompiler :: Compiler (Item Template)
cssTemplateCompiler = cached "Hakyll.Web.Template.cssTemplateCompiler" $
    fmap (readTemplate . compressCss) <$> getResourceString
```

I made a
[few other changes](https://github.com/zeckalpha/kyle.marek-spartz.org/commit/802be82df158a17e4e68615af661e89c4d4829ed)
in order to make this work. I needed to
[combine my CSS files](https://github.com/zeckalpha/kyle.marek-spartz.org/commit/802be82df158a17e4e68615af661e89c4d4829ed#diff-65cfe7d4cb9e2a84b335aee2b8c9fd61R1),
and then
[include](https://github.com/zeckalpha/kyle.marek-spartz.org/commit/802be82df158a17e4e68615af661e89c4d4829ed#diff-456a69052615a663e52659628e6583a8R10)
the combined CSS as a partial template in my default template.

I did have one CSS file that I couldn't inline like this, since it specifies
additional resources to fetch (fonts), but this is a Google hosted file, so
hopefully they won't hold it against me. Google suggested that I create a link
to this file after rendering, using JavaScript, so [that](https://github.com/zeckalpha/kyle.marek-spartz.org/commit/802be82df158a17e4e68615af661e89c4d4829ed#diff-456a69052615a663e52659628e6583a8R52)'s
in my changes, too.
