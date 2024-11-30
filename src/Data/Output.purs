module ClassNameExtractor.Data.Output where

import Prelude

import ClassNameExtractor.CssParser (SelectorF)
import Data.Eq.Generic (genericEq)
import Data.Generic.Rep (class Generic)
import Data.List (List)
import Data.Show.Generic (genericShow)
import Node.Path (FilePath)

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

-- | Make a CSS file output
-- | ```purescript run
-- | > makeCssFile (Namespace "Data.Foo.Bar") ".foo { display: flex }"
-- | CssFile { namesapce: Namespace "Data.Foo.Bar", body: ".foo { display: flex }"  }
-- | ```
makeCssFile :: Namespace -> FileBody -> Output
makeCssFile ns fb =  CssFile { namespace: ns, body: fb }


-- | Make a Js file output
-- | ```purescript run
-- | > makeJsFile "./src/components/styles.js"
-- | JsFile { path ::  "./src/components/styles.js" } 
-- | ```
makeJsFile :: FilePath -> Output
makeJsFile path =  JsFile { path }


-- | Make a Purs file output
-- | ```purescript run
-- | > makePursFile (Namespace "Data.Foo.Bar") "./src/components/styles.js" List.fromFoldable [Class "foo"]
-- | PursFile { path ::  "./src/components/Style.purs", namespace: (Namespace "Data.Foo.Bar"), classNames: [Class "foo"] } 
-- | ```
makePursFile :: Namespace -> FilePath -> List SelectorF  -> Output
makePursFile namespace path classNames =  PursFile { path, namespace, classNames }
