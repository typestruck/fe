{-# LANGUAGE CPP #-}

module Main where

import Miso qualified as M
import Miso.String qualified as MS
import qualified App as A
import System.Random qualified as MR
import Styles(styles)
import Miso (defaultEvents,  CSS(Style))

#ifdef WASM
#ifndef INTERACTIVE
foreign export javascript "hs_start" main :: IO ()
#endif
#endif

main ∷ IO ()
#ifdef INTERACTIVE
main = do
    generator ← MR.newStdGen
    M.reload defaultEvents $ A.app [] [Style styles] generator
#else
main = do
    generator ← MR.newStdGen
    M.prerender defaultEvents $ A.app [] [] generator
#endif


