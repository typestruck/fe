{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings #-}

module Game.User where

import Miso (MisoString)
import Miso.JSON (FromJSON (..), ToJSON (..), (.:), (.=))
import Miso.JSON qualified as MJ
import Prelude hiding (id)

default (MisoString)

data User = User {id ∷ Int, name ∷ MisoString, email ∷ Maybe MisoString} deriving (Show, Eq)

instance ToJSON User where
    toJSON user = MJ.object ["Id" .= user.id, "Name" .= user.name, "Email" .= user.email]

instance FromJSON User where
    parseJSON = MJ.withObject "User" $ \v → do
        id ← v .: "Id"
        name ← v .: "Name"
        email ← v .: "Email"
        pure User{id, name, email}
