module ClassNameExtractor.Cli where

import Prelude

import Effect (Effect)
import Options.Applicative (Parser, ParserInfo, argument, execParser, fullDesc, header, help, info, metavar, progDesc, str)

type Cli = {
  cssFilePath :: String,
  moduleName :: String
}

cliOptions :: Parser Cli
cliOptions = ado
  cssFilePath <- argument str
    ( metavar "<css-file-path>"
    <> help "Path to your CSS module file (e.g., src/components/Button/styles.module.css)"
    )
  moduleName <- argument str
    ( metavar "<purescript-module-name>"
    <> help "The PureScript module name where you want to use these styles (e.g., YourProject.Components.Button)"
    )
  in { cssFilePath, moduleName }

programInfo :: ParserInfo Cli
programInfo = info cliOptions
  ( fullDesc
  <> progDesc "Extract CSS class names from a CSS module file and generate PureScript types"
  <> header "class-name-extractor - CSS Module class name extractor for PureScript"
  )


parseOption :: Effect Cli
parseOption  = execParser programInfo
