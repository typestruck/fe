{-# LANGUAGE CPP #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings #-}

module Game.Player where

import Miso (MisoString)
#ifdef WASM
import GHC.Wasm.Prim
#endif
import Game.Card (Card)
import Miso.JSON (FromJSON, (.:))
import Miso.JSON qualified as MJ

default (MisoString)

data Player = Player
    { idp ∷ Int
    , hp ∷ Int
    , name ∷ MisoString
    , hand ∷ [Card]
    }
    deriving (Show, Eq)

instance FromJSON Player where
    parseJSON = MJ.withObject "Player" $ \o → do
        idp ← o .: "idp"
        hp ← o .: "hp"
        name ← o .: "name"
        hand ← o .: "hand"
        pure Player{idp, hp, name, hand}
