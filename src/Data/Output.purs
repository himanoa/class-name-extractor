module ClassNameExtractor.Data.Output where

import Prelude

import ClassNameExtractor.CssParser (SelectorF)
import Data.Eq.Generic (genericEq)
import Data.Generic.Rep (class Generic)
import Data.List (List)
import Data.Maybe (Maybe(..))
import Data.Show.Generic (genericShow)
import Data.String (Pattern(..), Replacement(..), replace, toUpper)
import Data.String.CodeUnits (singleton, uncons)
import Node.Path (FilePath, basename, dirname, extname)
import Node.Path as Path

newtype FileBody = FileBody String
derive instance Generic FileBody _
instance Show FileBody where
  show (FileBody s) = s
instance Eq FileBody where
  eq = genericEq

newtype Namespace = Namespace String

derive instance Generic Namespace _
instance Show Namespace where
  show (Namespace s) = s
instance Eq Namespace where
  eq = genericEq


data Output
  = CssFile {
    namespace :: Namespace,
    body :: FileBody
  }
  | JsFile {
    path :: FilePath
  }
  | PursFile {
    namespace :: Namespace,
    path :: FilePath,
    classNames:: List SelectorF
  }

derive instance Generic Output _
instance Show Output where
  show = genericShow

instance Eq Output where
  eq = genericEq

-- | Replacement file extension
-- | ```purescript
-- | > replaceExt foo.js "css"
-- | foo.css
-- | ```
replaceExt :: String -> String -> String
replaceExt path newExt = 
  let
    dir = dirname path
    base = basename path
    ext = extname path
    baseWithoutExt = replace (Pattern ext) (Replacement "") base
    newBase = baseWithoutExt <> "." <> newExt
  in
    Path.concat [dir, newBase]

-- | Filename head to upper
-- | ```purescript
-- | > capitalizeFilename foo.js
-- | Foo.js
-- | ```
capitalizeFilename :: String -> String
capitalizeFilename path =
  let
    dir = dirname path
    base = basename path
    capitalized = case uncons base of
      Nothing -> base
      Just { head, tail } -> toUpper (singleton head) <> tail
  in
    Path.concat [dir, capitalized]

-- | Make a CSS file output
-- | ```purescript run
-- | > makeCssFile (Namespace "Data.Foo.Bar") ".foo { display: flex }"
-- | CssFile { namesapce: Namespace "Data.Foo.Bar", body: ".foo { display: flex }"  }
-- | ```
makeCssFile :: Namespace -> FileBody -> Output
makeCssFile ns fb =  CssFile { namespace: ns, body: fb }


-- | Make a Js file output
-- | ```purescript run
-- | > makeJsFile "./src/components/styles.css"
-- | JsFile { path ::  "./src/components/Styles.js" } 
-- | ```
makeJsFile :: FilePath -> Output
makeJsFile path = JsFile { path: capitalizeFilename $ replaceExt path "js"  }


-- | Make a Purs file output
-- | ```purescript run
-- | > makePursFile (Namespace "Data.Foo.Bar") "./src/components/styles.css" List.fromFoldable [Class "foo"]
-- | PursFile { path ::  "./src/components/Style.purs", namespace: (Namespace "Data.Foo.Bar"), classNames: [Class "foo"] } 
-- | ```
makePursFile :: Namespace -> FilePath -> List SelectorF  -> Output
makePursFile namespace path classNames =  PursFile { path: capitalizeFilename $ replaceExt path "purs", namespace, classNames }
