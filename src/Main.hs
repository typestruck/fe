{-# LANGUAGE CPP #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Game qualified as G
import Game.Model (Model (..))
import Game.Model qualified as GM
import Game.User (User (..))
import Miso (MisoString, defaultEvents, subs, styles, CSS(..))
import Miso qualified as M
#ifdef INTERACTIVE
import qualified Styles as S
#else
import Miso (hydrateModel)
#endif
import System.Random qualified as MR
import Data.Functor((<&>))
import View qualified as V
import Game.Action (Action(..))
import qualified Miso.JSON as MJ
import Miso.JSON ((.:))
import Debug.Trace (traceShow)

default (MisoString)

#ifdef WASM
#ifndef INTERACTIVE
foreign export javascript "hs_start" main :: IO ()
#endif
#endif

newtype P = P { unP :: MisoString }

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
        ssrEventHandlers = [
            M.windowSub "sse-open" M.emptyDecoder (const JoinQueue),
            M.windowSub "sse-message" payloadDecoder (v HandleEvents)
            ]

        payloadDecoder = M.at ["detail"] . MJ.withObject "" $ \a -> a .: "payload" <&> P
        -- we need all this because it is not possible to decode a complex object from Decoder
        v f (P p) = case MJ.decode p of
                Just r -> f r
                Nothing -> error ("error decoding payload for events. payload was: " <> show p)
