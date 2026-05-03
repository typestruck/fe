module Game.Model where

import Game.User (User)
import System.Random (StdGen)

data Model = Model
    { user ∷ User
    , generator ∷ StdGen
    }

instance Eq Model where
    m == n = m.user == n.user

-- loadFromPage :: IO User
-- loadFromPage = do


initModel ∷ User → StdGen → Model
initModel user generator = Model{user = user, generator = generator}
