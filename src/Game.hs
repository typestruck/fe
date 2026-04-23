{-# LANGUAGE CPP #-}
{-# LANGUAGE ExtendedDefaultRules #-}

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

import Game.View qualified as GV
import Miso (App, CSS, Effect, JS, mount, scripts, styles)
import Miso qualified as M
import Miso.State qualified as MS
import Miso.String (MisoString)
import Miso.String qualified as MSS
import System.Random (StdGen)
import System.Random qualified as MR
import Prelude hiding (words)

default (MisoString)

app ∷ [JS] → [CSS] → StdGen → App Model Action
app scripts styles generator = (M.component (GM.initModel (User {displayName = "aaa", email = Just "e@a.com"}) generator) update GV.view){scripts = scripts, styles = styles}

update ∷ Action → Effect parent Model Action
update =
    \case
        _ -> pure ()

