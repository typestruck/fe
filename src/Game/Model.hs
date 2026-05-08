{-# LANGUAGE CPP #-}

module Game.Model where

import Game.User (User (..))
import System.Random (StdGen)
#ifdef WASM
import GHC.Wasm.Prim
#endif
import Miso (MisoString)
import Miso qualified as M
import Miso.JSON qualified as MJ
import Debug.Trace (traceShow)

data Model = Model
    { user ∷ User
    , generator ∷ StdGen
    }

instance Eq Model where
    m == n = m.user == n.user

#ifdef WASM
foreign import javascript "return document.getElementById('fe-model').innerHTML" extractModel :: IO JSString
#else
extractModel :: IO MisoString
extractModel = pure $ M.toMisoString ""
#endif

loadFromPage ∷ IO User
loadFromPage = do
    json ← extractModel
    case MJ.decode (traceShow json json) of
        Nothing → error "we must have a user"
        Just user → pure user

initModel ∷ User → StdGen → Model
initModel user generator = Model{user = user, generator = generator}
