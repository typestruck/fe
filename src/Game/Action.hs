module Game.Action where
import Game.User (User)
import Miso (MisoString)
import Game.Events (Events(..))

data Action
    = CheckUser
    | CreateUser (Maybe User)
    | SetUser User
    | JoinQueue
    | HandleEvents Events
    | StartTimer
    | DisplayError MisoString
    deriving (Show, Eq)
