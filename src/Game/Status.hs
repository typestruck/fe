module Game.Status where

data Status
    = NotPlaying
    | Waiting
    | Playing
    deriving (Eq, Show)