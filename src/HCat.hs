module HCat where

import qualified System.Environment as Env

handleArgs :: IO (Either String FilePath)
handleArgs =
  parseArgs <$> Env.getArgs
  where parseArgs args =
          case args of
            [fileName] -> Right fileName
            [] -> Left "Empty args"
            _ -> Left "mutiple args"

runHCat :: IO ()
runHCat =
  handleArgs >>= displayMessage
  where
    displayMessage parsedArgument =
      case parsedArgument of
        Left errMessage -> putStrLn $ "Error: " <> errMessage
        Right fileName -> putStrLn $ "Opening file: " <> fileName
