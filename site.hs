--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
module Main where

import Control.Applicative ((<$>))
import Data.Monoid         ((<>))
import Data.List           (isPrefixOf, isSuffixOf)
import System.FilePath     (takeFileName)

import Text.Pandoc.Options ( WriterOptions
                           , writerHTMLMathMethod
                           , HTMLMathMethod(MathJax)
                           , writerHtml5
                           )
import Hakyll


staticContent :: Pattern
staticContent = "favicon.ico"
           .||. "404.html"
           .||. "images/**"
           .||. "robots.txt"
           .||. "sitemap.txt"
           .||. "presentations/*"
           .||. "publications/*"
           .||. "files/*"
           .||. "*.pdf"
           .||. fromRegex "\\.widely.*"


-- | "Lift" a compiler into an idRoute compiler.
-- idR :: ... => Compiler (Item String) -> Rules ()
idR compiler = do
    route idRoute
    compile compiler


main :: IO ()
main = hakyllWith config $ do
    tags <- buildTags "posts/*" $ fromCapture "posts/tags/*.html"

    match staticContent $ idR copyFileCompiler

    -- match "css/*" $ idR compressCssCompiler

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ postCompiler tags

    match "*.md" $ do
        route $ setExtension "html"
        compile defaultCompiler

    tagsRules tags $ \tag pattern -> idR $ tagCompiler tags tag pattern

    create ["posts/tags/index.html"] $ idR $ tagsCompiler tags

    create ["blog.html"] $ idR $ postsCompiler tags

    create ["index.html"] $ idR $ homeCompiler tags

    create ["atom.xml"] $ idR $ feedCompiler tags

    create ["atom-all.xml"] $ idR $ largeFeedCompiler tags

    match "templates/*" $ compile templateCompiler

    match "css/combined.css" $ compile cssTemplateCompiler

-------------------------------------------------------------------------------

-- | "Lifts" a template name and a context into a compiler.
defaultTemplateWith :: Identifier -> Context String -> Compiler (Item String)
defaultTemplateWith template ctx =
    makeItem ""
        >>= loadAndApplyTemplate template ctx
        >>= loadAndApplyTemplate "templates/default.html" ctx
        >>= relativizeUrls

cssTemplateCompiler :: Compiler (Item Template)
cssTemplateCompiler = cached "Hakyll.Web.Template.cssTemplateCompiler" $
    fmap (readTemplate . compressCss) <$> getResourceString

tagCompiler :: Tags -> String -> Pattern -> Compiler (Item String)
tagCompiler tags tag pattern = do
    posts <- recentFirst =<< loadAll pattern
    defaultTemplateWith "templates/tag.html" $ tagCtx tags posts tag


tagsCompiler :: Tags -> Compiler (Item String)
tagsCompiler tags =
    defaultTemplateWith "templates/tags.html" $ tagsCtx tags


homeCompiler :: Tags -> Compiler (Item String)
homeCompiler tags =
    defaultTemplateWith "templates/index.html" $ homeCtx tags



postsCompiler :: Tags -> Compiler (Item String)
postsCompiler tags = do
    posts <- recentFirst =<< loadAll "posts/*"
    defaultTemplateWith "templates/blog.html" $ postsCtx tags posts


postCompiler :: Tags -> Compiler (Item String)
postCompiler tags =
    pandocCompilerWith defaultHakyllReaderOptions writerOptions
        >>= saveSnapshot "content"
        >>= loadAndApplyTemplate "templates/post.html"    ctx
        >>= loadAndApplyTemplate "templates/default.html" ctx
        >>= relativizeUrls
      where ctx = postCtx tags

defaultCompiler :: Compiler (Item String)
defaultCompiler =
    pandocCompilerWith defaultHakyllReaderOptions writerOptions
        >>= loadAndApplyTemplate "templates/default.html" defaultContext
        >>= relativizeUrls


feedCompilerHelper :: (Compiler [Item String] -> Compiler [Item String]) -> Tags -> Compiler (Item String)
feedCompilerHelper f tags = do
    let ctx = feedCtx tags
    posts <- f . recentFirst =<<  -- Any reason to just take the most recent 10?
        loadAllSnapshots "posts/*" "content"
    renderAtom myFeedConfiguration ctx posts


feedCompiler :: Tags -> Compiler (Item String)
feedCompiler = feedCompilerHelper $ fmap (take 10)


largeFeedCompiler :: Tags -> Compiler (Item String)
largeFeedCompiler = feedCompilerHelper id


feedCtx :: Tags -> Context String
feedCtx tags = bodyField "description" <> postCtx tags


postCtx :: Tags -> Context String
postCtx tags =
    dateField "date" "%B %e, %Y" <>
    tagsField "tags" tags        <>
    defaultContext


postsCtx :: Tags -> [Item String] -> Context String
postsCtx tags posts =
    listField "posts" (postCtx tags) (return posts) <>
    constField "title" "Blog"                       <>
    field "tags" (\_ -> renderTagList tags)         <>
    defaultContext


tagCtx :: Tags -> [Item String] -> String -> Context String
tagCtx tags posts tag =
    constField "title" ("Posts tagged &quot;" ++ tag ++ "&quot;") <>
    listField "posts" (postCtx tags) (return posts)       <>
    defaultContext


tagsCtx :: Tags -> Context String
tagsCtx tags =
    constField "title" "Tags"               <>
    field "tags" (\_ -> renderTagList tags) <>
    defaultContext


homeCtx :: Tags -> Context String
homeCtx tags =
    constField "title" "Home"               <>
    field "tags" (\_ -> renderTagList tags) <>
    defaultContext


writerOptions :: WriterOptions
writerOptions = defaultHakyllWriterOptions
    { writerHTMLMathMethod = MathJax "http://cdn.mathjax.org/mathjax/latest/MathJax.js"
    , writerHtml5          = True
    }


config :: Configuration
config = defaultConfiguration
    { ignoreFile    = ignoreFile'
    , deployCommand = "./build_css.sh && pushd presentations && ./build.sh && popd && ./build_cv.sh && ./build_sitemap.sh && pushd _site && widely push && popd"
    }
  where
    ignoreFile' path
        | ".widely" `isPrefixOf` fileName = False
        | "."       `isPrefixOf` fileName = True
        | "#"       `isPrefixOf` fileName = True
        | "~"       `isSuffixOf` fileName = True
        | ".swp"    `isSuffixOf` fileName = True
        | ".sh"     `isSuffixOf` fileName = True
        | otherwise                       = False
      where
        fileName = takeFileName path


myFeedConfiguration :: FeedConfiguration
myFeedConfiguration = FeedConfiguration
    { feedTitle       = "kms"
    , feedDescription = ""
    , feedAuthorName  = "Kyle Marek-Spartz"
    , feedAuthorEmail = "kyle.marek.spartz@gmail.com"
    , feedRoot        = "http://kyle.marek-spartz.org"
    }
