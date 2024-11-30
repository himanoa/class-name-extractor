module ClassNameExtractor.FS where

import Prelude

import ClassNameExtractor.Data.Output (FileBody, coerceFileBody)
import ClassNameExtractor.RIO (RIO)
import Data.Maybe (maybe)
import Effect.Aff.Class (liftAff)
import Node.Encoding (Encoding(..))
import Node.FS.Aff as FS
import Node.Path (FilePath)

class Monad m <= MonadFS m where
  readFile :: FilePath -> m String
  writeFile :: FilePath -> FileBody -> m Unit
  isExists :: FilePath -> m Boolean

instance monadFSRIO :: MonadFS RIO where
  readFile path = do
    liftAff $ FS.readTextFile UTF8 path
  writeFile path body = do
    liftAff $ FS.writeTextFile UTF8 path (coerceFileBody body)
  isExists path = do
    maybeErr <- liftAff $ FS.access path
    pure $ maybe false (const true) maybeErr 
