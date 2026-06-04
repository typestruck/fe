{-# LANGUAGE CPP #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings #-}

module Game.Move where

import Miso (MisoString)
#ifdef WASM
import GHC.Wasm.Prim
#endif
import Miso.JSON (FromJSON, (.:))
import Miso.JSON qualified as MJ

default (MisoString)

data Step
    = Start
    | Draw
    deriving (Show, Eq)

instance FromJSON Step where
    parseJSON =
        MJ.withNumber "Step" $
            pure . \case
                0.0 → Start
                1.0 → Draw
                _ → error "no matching color value"

data Move = Move
    { step ∷ Step
    , by ∷ Int
    , values ∷ [Int]
    }
    deriving (Show, Eq)

instance FromJSON Move where
    parseJSON = MJ.withObject "Move" $ \o → do
        step ← o .: "step"
        values ← o .: "values"
        by ← o .: "by"
        pure Move{step, by, values}