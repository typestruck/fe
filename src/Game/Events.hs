{-# LANGUAGE CPP #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE MultilineStrings #-}
{-# LANGUAGE OverloadedStrings #-}

module Game.Events where

import Miso (MisoString)
#ifdef WASM
import GHC.Wasm.Prim
#endif
import Game.Card (Card (..))
import Game.Move (Move (..))
import Game.Player (Player (..))
import Miso.JSON (FromJSON, Parser, Value, (.:))
import Miso.JSON qualified as MJ

default (MisoString)

data Events = Events
    { cards ∷ [Card]
    , players ∷ [Player]
    , moves ∷ [Move]
    }
    deriving (Eq, Show)

parseEvents ∷ MisoString → Value → Parser Events
parseEvents name = MJ.withObject name $ \o → do
    cards ← o .: "cards"
    players ← o .: "players"
    moves ← o .: "moves"
    pure Events{cards, players, moves}

instance FromJSON Events where
    parseJSON = parseEvents "Events"

#ifdef WASM
foreign import javascript """
    window.listenServerEvents = function (url) {
        function raiseOpenEvent() { window.dispatchEvent(new CustomEvent('sse-open')); }

        if (window.events) {
            raiseOpenEvent();
            return;
        }

        window.events = new EventSource(url);
        window.events.onopen = _ => {
            raiseOpenEvent();
        };
        window.events.onmessage = (e) => {
            window.dispatchEvent(new CustomEvent('sse-message', { detail : {payload: e.data } }))
        };
    };

    return window.listenServerEvents($1);
    """  listenServerEvents :: MisoString -> IO ()
#else
listenServerEvents :: MisoString -> IO ()
listenServerEvents _ = pure ()
#endif