{-# LANGUAGE CPP #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Miso qualified as M
import Miso (App, MisoString, CSS, Effect, JS, mount, scripts, styles, mountPoint, defaultEvents, CSS(Style))
import qualified Game as G
import System.Random qualified as MR
import View qualified as V
import Game.User(User(..))
import Game.Model (Model (..))
import Game.Model qualified as GM
import Styles qualified as S

default (MisoString)

#ifdef WASM
#ifndef INTERACTIVE
foreign export javascript "hs_start" main :: IO ()
foreign import javascript "document.getElementById('fe-game-root').innerHTML = ''" clearRootNode :: IO ()
#endif
#endif

-- INTERACTIVE is local development
main ∷ IO ()
main = do
    generator ← MR.newStdGen
    let model = GM.initModel (User {displayName = "aaa", email = Just "e@a.com"}) generator
#ifdef INTERACTIVE
    M.reload defaultEvents (M.component model G.update V.view) {styles = [Style S.styles]}
#else
    clearRootNode
    M.startApp defaultEvents (M.component model G.update V.view) {mountPoint = Just "fe-game-root"}
#endif


