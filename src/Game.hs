module Game where

import Control.Concurrent qualified as CC
import Control.Monad qualified as CM
import Control.Monad.RWS (MonadState)
import Data.HashMap.Strict qualified as DM
import Game.User(User(..))
import Data.HashSet (HashSet)
import Data.HashSet qualified as DS
import Data.List qualified as DL
import Game.Action (Action (..))
import Game.Model (Model (..))
import Game.Model qualified as GM
import View qualified as V
import Miso qualified as M
import Miso (Effect)
import Miso.State qualified as MS
import Miso.String (MisoString)
import Miso.String qualified as MSS
import System.Random (StdGen)
import System.Random qualified as MR
import Prelude hiding (words)

update ∷ Action → Effect parent Model Action
update =
    \case
        _ -> pure ()

