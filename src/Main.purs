module Main where

import Prelude

import ClassNameExtractor.Cli (parseOption)
import ClassNameExtractor.Data.Output (Namespace(..))
import ClassNameExtractor.Execute (execute)
import ClassNameExtractor.RIO (runRIO)
import Effect (Effect)
import Effect.Aff (launchAff_)

main :: Effect Unit

main = do
  { cssFilePath, moduleName } <- parseOption
  launchAff_ $ runRIO {} $ execute cssFilePath (Namespace moduleName)

