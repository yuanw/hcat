{-# LANGUAGE LambdaCase #-}
module HCat where

import qualified System.Environment as Env
import qualified Control.Exception as Exception
import qualified System.IO.Error as IOError

handleArgs :: IO (Either String FilePath)
handleArgs =
  parseArgs <$> Env.getArgs
  where parseArgs args =
          case args of
            [fileName] -> Right fileName
            [] -> Left "Empty args"
            _ -> Left "mutiple args"

runHCat :: IO ()
runHCat = Exception.catch
  (handleArgs
   >>= \case
      Left err -> putStrLn $ "Error processing: " <> err
      Right fname -> readFile fname >>= putStrLn)
  handleErr
  where
    handleErr :: IOError -> IO ()
    handleErr e = putStrLn "I ran into an error" >> print e
