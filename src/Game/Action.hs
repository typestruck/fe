module Game.Action where
import Game.User (User)
import Miso (MisoString)

data Action
    = CheckUser
    | CreateUser (Maybe User)
    | SetUser User
    | DisplayError MisoString
    deriving (Show, Eq)
