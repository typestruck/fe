{-# LANGUAGE CPP #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings #-}

module Game where

import Control.Concurrent qualified as CC
import Control.Monad qualified as CM
import Control.Monad.RWS (MonadState)
import Data.HashMap.Strict qualified as DM
import Data.HashSet (HashSet)
import Data.HashSet qualified as DS
import Data.List qualified as DL
import Data.Maybe qualified as DM
import Game.Action (Action (..))
import Game.Model (Model (..))
import Game.Model qualified as GM
import Game.User (User (..))
import Miso (Effect)
import Miso qualified as M
import Miso.Fetch qualified as MF
import Miso.State qualified as MS
import Miso.String (MisoString)
import Miso.String qualified as MSS
import System.Random (StdGen)
import System.Random qualified as MR
import View qualified as V
import Prelude hiding (words)

default (MisoString)

update ∷ Action → Effect parent Model Action
update =
    \case
        CheckUser → checkUser
        CreateUser possible → createUser possible
        SetUser user → setUser user
        DisplayError err → pure ()

setUser ∷ User → Effect parent Model Action
setUser user = do
    MS.modify' $ \m → m{user = user}
    joinQueue

joinQueue ∷ Effect parent Model Action
joinQueue = do
    pure ()

createUser ∷ Maybe User → Effect parent Model Action
createUser user = MF.postJSON' (baseUrl <> "user/create") user [] ok notOk
  where
    ok response = SetUser response.body
    notOk response = DisplayError $ DM.fromMaybe "An error occured" response.body

-- if the user is not logged in automatically create a new account for their first game
checkUser ∷ Effect parent Model Action
checkUser = do
    model ← MS.get
    if model.user.id == 0 then
        createUser Nothing
    else
        joinQueue

baseUrl ∷ MisoString
#ifdef INTERACTIVE
baseUrl = "http://localhost:5234/"
#else
baseUrl = "/"
#endif