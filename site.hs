--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
module Main where

import Control.Applicative ((<$>), Alternative (..))
import Data.Maybe          (fromMaybe)
import Data.Monoid         ((<>))
import Data.List           (isPrefixOf, isSuffixOf, sortBy, intercalate)
import Data.Time.Format    (parseTime)
import Data.Time.Clock     (UTCTime)
import System.FilePath     (takeFileName)
import System.Locale       (defaultTimeLocale)


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


postsGlob = "posts/*"

main :: IO ()
main = hakyllWith config $ do
    tags <- buildTags "posts/*" $ fromCapture "posts/tags/*.html"

    match staticContent $ idR copyFileCompiler

    -- match "css/*" $ idR compressCssCompiler

    match postsGlob $ do
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
    field "nextPost" nextPostUrl <>
    field "prevPost" prevPostUrl <>
    defaultContext

--------------------------------------------------------------------------------
-- Next and previous posts:
-- https://github.com/rgoulter/my-hakyll-blog/commit/a4dd0513553a77f3b819a392078e59f461d884f9

prevPostUrl :: Item String -> Compiler String
prevPostUrl post = do
  posts <- getMatches postsGlob
  let ident = itemIdentifier post
      sortedPosts = sortIdentifiersByDate posts
      ident' = itemBefore sortedPosts ident
  case ident' of
    Just i -> (fmap (maybe empty toUrl) . getRoute) i
    Nothing -> empty


nextPostUrl :: Item String -> Compiler String
nextPostUrl post = do
  posts <- getMatches postsGlob
  let ident = itemIdentifier post
      sortedPosts = sortIdentifiersByDate posts
      ident' = itemAfter sortedPosts ident
  case ident' of
    Just i -> (fmap (maybe empty toUrl) . getRoute) i
    Nothing -> empty


itemAfter :: Eq a => [a] -> a -> Maybe a
itemAfter xs x =
  lookup x $ zip xs (tail xs)


itemBefore :: Eq a => [a] -> a -> Maybe a
itemBefore xs x =
  lookup x $ zip (tail xs) xs


urlOfPost :: Item String -> Compiler String
urlOfPost =
  fmap (maybe empty toUrl) . getRoute . itemIdentifier

sortIdentifiersByDate :: [Identifier] -> [Identifier]
sortIdentifiersByDate =
    sortBy (flip byDate)
  where
    byDate id1 id2 =
      let fn1 = takeFileName $ toFilePath id1
          fn2 = takeFileName $ toFilePath id2
          parseTime' fn = parseTime defaultTimeLocale "%Y-%m-%d" $ intercalate "-" $ take 3 $ splitAll "-" fn
      in compare (parseTime' fn1 :: Maybe UTCTime) (parseTime' fn2 :: Maybe UTCTime)
--------------------------------------------------------------------------------

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
    , deployCommand = "./build_css.sh && pushd presentations && ./build.sh && popd && ./build_cv.sh && ./build_sitemap.sh && cp _site/blog.html _site/posts/index.html && pushd _site && widely push && popd"
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
