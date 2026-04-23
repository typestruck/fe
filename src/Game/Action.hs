module Game.Action where


data Action
    = CheckAssets
    | ReplaceTiles
    | EndGame
    | CreateAccount
    deriving (Show, Eq)
