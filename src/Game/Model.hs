module Game.Model where

import Game.User (User)
import System.Random (StdGen)

data Model = Model
    {
     user ∷ User
    , generator ∷ StdGen
    , assetsLoaded ∷ Bool
    }

instance Eq Model where
    m == n = m.assetsLoaded == n.assetsLoaded && m.user == n.user

initModel ∷ User → StdGen → Model
initModel user generator = Model{user = user, assetsLoaded = False, generator = generator}
