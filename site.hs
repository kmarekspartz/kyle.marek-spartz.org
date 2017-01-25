--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
module Main where

import Control.Applicative ((<$>), Alternative (..))
import Data.Maybe          (fromMaybe)
import Data.Monoid         ((<>))
import Data.List           (isPrefixOf, isSuffixOf, sortBy, intercalate)
import Data.Time.Format    (parseTimeM, defaultTimeLocale)
import Data.Time.Clock     (UTCTime)
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
           .||. "*.txt"
           .||. "presentations/*"
           .||. "publications/*"
           .||. "salem/*"
           .||. "files/*"
           .||. "*.pdf"
           .||. fromRegex "\\.widely.*"


-- | "Lift" a compiler into an idRoute compiler.
-- idR :: ... => Compiler (Item String) -> Rules ()
idR compiler = do
    route idRoute
    compile compiler


postsGlob = "posts/*.md"

main :: IO ()
main = hakyllWith config $ do
    match staticContent $ idR copyFileCompiler

    match postsGlob $ do
        route $ setExtension "html"
        compile $ postCompiler

    match "*.md" $ do
        route $ setExtension "html"
        compile defaultCompiler

    create ["blog.html"] $ idR $ postsCompiler

    create ["atom.xml"] $ idR $ feedCompiler

    create ["atom-all.xml"] $ idR $ largeFeedCompiler

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

postsCompiler :: Compiler (Item String)
postsCompiler = do
    posts <- recentFirst =<< loadAll postsGlob
    defaultTemplateWith "templates/blog.html" $ postsCtx posts


postCompiler :: Compiler (Item String)
postCompiler =
    pandocCompilerWith defaultHakyllReaderOptions writerOptions
        >>= saveSnapshot "content"
        >>= loadAndApplyTemplate "templates/post.html"    postCtx
        >>= loadAndApplyTemplate "templates/default.html" postCtx
        >>= relativizeUrls

defaultCompiler :: Compiler (Item String)
defaultCompiler =
    pandocCompilerWith defaultHakyllReaderOptions writerOptions
        >>= loadAndApplyTemplate "templates/default.html" defaultContext
        >>= relativizeUrls


feedCompilerHelper :: (Compiler [Item String] -> Compiler [Item String]) -> Compiler (Item String)
feedCompilerHelper f = do
    posts <- f . recentFirst =<<  -- Any reason to just take the most recent 10?
        loadAllSnapshots postsGlob "content"
    renderAtom myFeedConfiguration feedCtx posts


feedCompiler :: Compiler (Item String)
feedCompiler = feedCompilerHelper $ fmap (take 10)


largeFeedCompiler :: Compiler (Item String)
largeFeedCompiler = feedCompilerHelper id


feedCtx :: Context String
feedCtx = bodyField "description" <> postCtx


postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" <>
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
    sortBy byDate
  where
    byDate id1 id2 =
      let fn1 = takeFileName $ toFilePath id1
          fn2 = takeFileName $ toFilePath id2
          parseTime' fn = parseTimeM True defaultTimeLocale "%Y-%m-%d" $ intercalate "-" $ take 3 $ splitAll "-" fn
      in compare (parseTime' fn1 :: Maybe UTCTime) (parseTime' fn2 :: Maybe UTCTime)
--------------------------------------------------------------------------------

postsCtx :: [Item String] -> Context String
postsCtx posts =
    listField "posts" postCtx (return posts) <>
    constField "description" "Writings"      <>
    constField "title" "Blog"                <>
    defaultContext

homeCtx :: Context String
homeCtx =
    constField "description" "Writings"     <>
    constField "title" "Home"               <>
    defaultContext


writerOptions :: WriterOptions
writerOptions = defaultHakyllWriterOptions
    { writerHTMLMathMethod = MathJax "http://cdn.mathjax.org/mathjax/latest/MathJax.js"
    , writerHtml5          = True
    }

config :: Configuration
config = defaultConfiguration
    { ignoreFile    = ignoreFile'
    , deployCommand = "./bin/deploy.sh"
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
