module HCat where

import qualified System.Environment as Env

runHCat :: IO ()
runHCat = Env.getArgs >>= print
