{-# LANGUAGE CPP #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings #-}

module Game where

import Data.Maybe qualified as DM
import Game.Action (Action (..))
import Game.Model (Model (..))
import Game.User (User (..))
import Miso (Effect, Response(..))
import Miso qualified as M
#ifdef WASM
import GHC.Wasm.Prim
#endif
import Miso.Fetch qualified as MF
import Miso.State qualified as MS
import Miso.String (MisoString)
import Prelude hiding (words)

default (MisoString)

update ∷ Action → Effect parent Model Action
update =
    \case
        CheckUser → checkUser
        CreateUser possible → createUser possible
        SetUser user → setUser user
        JoinQueue -> joinQueue
        StartTimer -> startTimer
        DisplayError err → pure ()

startTimer  ∷  Effect parent Model Action
startTimer = MS.modify' $ \ model -> model { timer = True }

setUser ∷ User → Effect parent Model Action
setUser user = do
    MS.modify' $ \m → m{user = user}
    listenServerEvents

joinQueue ∷ Effect parent Model Action
joinQueue = MF.postJSON (baseUrl <> "game/start") () [] (const StartTimer) notOk

#ifdef WASM
--defined in index.js
foreign import javascript "return window.listenServerEvents($1)" lse :: MisoString -> IO ()
#else
lse :: MisoString -> IO ()
lse _ = pure ()
#endif

listenServerEvents :: Effect parent Model Action
listenServerEvents = M.io_ . lse $ baseUrl <> "game/events"

createUser ∷ Maybe User → Effect parent Model Action
createUser user = MF.postJSON' (baseUrl <> "user/create") user [] ok notOk
  where
    ok response = SetUser response.body


notOk :: Response (Maybe MisoString) -> Action
notOk response = DisplayError $ DM.fromMaybe "An error occured" response.body

-- if the user is not logged in automatically create a new account for their first game
checkUser ∷ Effect parent Model Action
checkUser = do
    model ← MS.get
    if model.user.id == 0 then
        createUser Nothing
    else
        listenServerEvents

baseUrl ∷ MisoString
#ifdef INTERACTIVE
baseUrl = "http://localhost:5234/"
#else
baseUrl = "/"
#endif