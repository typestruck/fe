module Game.User where

data User = User {displayName ∷ String, email ∷ Maybe String} deriving (Show, Eq)
