{-# LANGUAGE CPP #-}

module Game.Model where

import Game.User (User (..))
import System.Random (StdGen)
#ifdef WASM
import GHC.Wasm.Prim
import Miso qualified as M
#else
import Miso qualified as M
import Miso (MisoString)
#endif
import Game.Card ( Card(..) )
import Miso.JSON qualified as MJ
import Game.Status(Status(..))
import Game.Player (Player(..))
import Debug.Trace (traceShow)

data Model = Model
    { user ∷ User
    , generator ∷ StdGen
    , status ∷ Status
    , turn :: Maybe Int
    , deck :: [Card]
    , players :: [Player]
    } deriving (Eq, Show)

#ifdef WASM
foreign import javascript "return document.getElementById('fe-model').innerHTML" extractModel :: IO JSString
#else
extractModel :: IO MisoString
extractModel = pure $ M.toMisoString ""
#endif

loadFromPage ∷ IO User
loadFromPage = do
    json ← extractModel
    case MJ.decode json of
        Nothing → error "we must have a user"
        Just user → pure user

initModel ∷ User → StdGen → Model
initModel user generator = Model{user, generator, status = NotPlaying, deck = [], players = [], turn = Nothing}
