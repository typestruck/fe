{-# LANGUAGE CPP #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings #-}

module Game.Player where

import Miso (MisoString)
#ifdef WASM
import GHC.Wasm.Prim
#endif
import Miso.JSON (FromJSON, (.:))
import Miso.JSON qualified as MJ

default (MisoString)

data Player = Player
    { hp ∷ Int
    , name ∷ MisoString
    }
    deriving (Show, Eq)

instance FromJSON Player where
    parseJSON = MJ.withObject "Player" $ \o → do
        hp ← o .: "hp"
        name ← o .: "name"
        pure Player{hp, name}
