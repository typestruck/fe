{-# LANGUAGE CPP #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Game qualified as G
import Game.Model (Model (..))
import Game.Model qualified as GM
import Game.User (User (..))
import Miso (MisoString, defaultEvents, hydrateModel, subs)
import Miso qualified as M
import System.Random qualified as MR
import View qualified as V
import Game.Action (Action(JoinQueue))

default (MisoString)

#ifdef WASM
#ifndef INTERACTIVE
foreign export javascript "hs_start" main :: IO ()
#endif
#endif

-- INTERACTIVE is local development
main ∷ IO ()
main = do
    generator ← MR.newStdGen
    let model = GM.initModel (User{id = 0, name = "playa", email = Nothing}) generator
#ifdef INTERACTIVE
    M.reload defaultEvents (M.component model G.update V.view) {
        subs = ssrEventHandlers,
        styles = [Style S.styles]
    }
#else
    M.prerender defaultEvents (M.component model G.update V.view) {
        subs = ssrEventHandlers,
        hydrateModel = Just $ do
            user <- GM.loadFromPage
            pure model { user = user }
        }
#endif
    where
        --less painful than trying to make miso work with directly with server sent events
        ssrEventHandlers = [M.windowSub "sse-open" M.emptyDecoder (const JoinQueue)]