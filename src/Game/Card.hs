{-# LANGUAGE CPP #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

module Game.Card where

import Miso (MisoString)
#ifdef WASM
import GHC.Wasm.Prim
#endif
import Miso.JSON (FromJSON, (.:))
import Miso.JSON qualified as MJ

default (MisoString)

data Color
    = Red
    | Black
    | Blue
    | Green
    deriving (Show, Eq)

instance FromJSON Color where
    parseJSON =
        MJ.withNumber "Color" $
            pure . \case
                0.0 → Red
                1.0 → Black
                2.0 → Blue
                3.0 → Green
                _ → error "no matching color value"

data Target
    = Self
    | Opponent
    deriving (Show, Eq)

instance FromJSON Target where
    parseJSON =
        MJ.withNumber "Target" $
            pure . \case
                0.0 → Self
                1.0 → Opponent
                _ → error "no matching color value"

data CAction = CAction
    { target ∷ Target
    , value ∷ Int
    }
    deriving (Show, Eq)

instance FromJSON CAction where
    parseJSON = MJ.withObject "Action" $ \o → do
        target ← o .: "target"
        value ← o .: "value"
        pure CAction{target, value}

data Card = Card
    { idc ∷ Int
    , color ∷ Color
    , cost ∷ Int
    , energy ∷ Int
    , description ∷ MisoString
    , actions ∷ [CAction]
    }
    deriving (Show, Eq)

instance FromJSON Card where
    parseJSON = MJ.withObject "Card" $ \o → do
        idc ← o .: "idc"
        color ← o .: "color"
        cost ← o .: "cost"
        energy ← o .: "energy"
        description ← o .: "description"
        actions ← o .: "actions"
        pure Card{idc, color, cost, energy, description, actions}