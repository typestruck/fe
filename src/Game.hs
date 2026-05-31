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
import Debug.Trace (traceShow, trace)
import Game.Events qualified as GE
import Miso.Fetch qualified as MF
import Miso.State qualified as MS
import Miso.String (MisoString)
import Game.Events(Events(..))
import Prelude hiding (words)
import Game.Move (Step(Start, Draw), Move(..))
import Game.Status (Status(Waiting, Playing, NotPlaying))
import qualified Data.Foldable as DF
import Game.Card (Card(Card, color, cost, energy, actions), Color (Red))

default (MisoString)

update ∷ Action → Effect parent Model Action
update =
    \case
        CheckUser → checkUser
        CreateUser possible → createUser possible
        SetUser user → setUser user
        JoinQueue → joinQueue
        StartTimer → startTimer
        HandleEvents events → handleEvents events
        DisplayError _ → pure ()

handleEvents ∷ Events -> Effect parent Model Action
handleEvents events = do
    DF.traverse_ go events.moves
    where go move = case move.step of
            Start -> MS.modify' $ \model -> model { status = Playing, deck = events.cards, players = events.players }
            Draw -> pure ()

startTimer ∷ Effect parent Model Action
startTimer = MS.modify' $ \model → model{status = Waiting}

setUser ∷ User → Effect parent Model Action
setUser user = do
    MS.modify' $ \model → model{user = traceShow user user, status = traceShow Playing Playing}
    listenServerEvents

joinQueue ∷ Effect parent Model Action
joinQueue = MF.postJSON "/game/start" () [] (const StartTimer) notOk

listenServerEvents ∷ Effect parent Model Action
listenServerEvents = M.io_ $ GE.listenServerEvents  "/game/events"

createUser ∷ Maybe User → Effect parent Model Action
createUser user = MF.postJSON' "/user/create" user [] ok notOk
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
