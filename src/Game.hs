{-# LANGUAGE CPP #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings #-}

module Game where

import Data.Maybe qualified as DM
import Game.Action (Action (..))
import Game.Model (Model (..))
import Game.User (User (..))
import Miso (Effect, Response (body))
import Miso qualified as M
#ifdef WASM
import GHC.Wasm.Prim
#endif
import Debug.Trace (traceShow)
import Game.Events qualified as GE
import Miso.Fetch qualified as MF
import Miso.State qualified as MS
import Miso.String (MisoString)
import Game.Events(Events(..))
import Prelude hiding (words)
import Game.Move (Step(Start, Draw), Move(..))
import Game.Status (Status(Waiting, Playing))
import qualified Data.Foldable as DF

default (MisoString)

update ∷ Action → Effect parent Model Action
update =
    \case
        CheckUser → checkUser
        CreateUser possible → createUser possible
        SetUser user → setUser user
        JoinQueue → joinQueue
        StartTimer → startTimer
        HandleEvents events -> handleEvents events
        DisplayError _ → pure ()

handleEvents ∷ Events -> Effect parent Model Action
handleEvents events = DF.traverse_ go events.moves
    where go move = case move.step  of
            Start -> MS.modify' $ \model -> model { status = Playing, deck = events.cards, players = events.players }
            Draw -> pure ()

startTimer ∷ Effect parent Model Action
startTimer = MS.modify' $ \model → model{status = Waiting}

setUser ∷ User → Effect parent Model Action
setUser user = do
    MS.modify' $ \m → m{user = user}
    listenServerEvents

joinQueue ∷ Effect parent Model Action
joinQueue = MF.postJSON (baseUrl <> "game/start") () [] (const StartTimer) notOk

listenServerEvents ∷ Effect parent Model Action
listenServerEvents = M.io_ . GE.listenServerEvents $ baseUrl <> "game/events"

createUser ∷ Maybe User → Effect parent Model Action
createUser user = MF.postJSON' (baseUrl <> "user/create") user [] ok notOk
  where
    ok response = SetUser response.body

notOk ∷ Response (Maybe MisoString) → Action
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