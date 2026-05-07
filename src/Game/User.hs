{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings #-}

module Game.User where

import Miso (MisoString)
import Miso.JSON (FromJSON (..), (.:))
import Miso.JSON qualified as MJ
import Prelude hiding (id)

default (MisoString)

data User = User {id ∷ Int, name ∷ MisoString, email ∷ Maybe MisoString} deriving (Show, Eq)

instance FromJSON User where
    parseJSON = MJ.withObject "User" $ \v → do
        id ← v .: "Id"
        name ← v .: "Name"
        email ← v .: "Email"
        pure User{id, name, email}
