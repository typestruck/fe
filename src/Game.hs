{-# LANGUAGE CPP #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings #-}

module Game where

import Data.Maybe qualified as DM
import Game.Action (Action (..))
import Game.Card (Card (..))
import Game.Model (Model (..))
import Game.Player (Player (..))
import Game.User (User (..))
import Miso (Effect, Response (body))
import Miso qualified as M
#ifdef WASM
import GHC.Wasm.Prim
#endif
import Data.Foldable qualified as DF
import Debug.Trace (trace, traceShow)
import Game.Events (Events (..))
import Game.Events qualified as GE
import Game.Move (Move (..), Step (Draw, Start))
import Game.Status (Status (..))
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
        JoinQueue → joinQueue
        StartTimer → startTimer
        HandleEvents events → handleEvents events
        DisplayError _ → pure ()

handleEvents ∷ Events → Effect parent Model Action
handleEvents events = DF.traverse_ go events.moves
  where
    go move = case move.step of
        Start → start
        Draw → draw move

    start = MS.modify' $ \model → model{status = Playing, deck = events.cards, players = events.players}

    draw move = MS.modify' $ \model →
        model
            { deck = drop (head move.values) model.deck
            , players = map (addToHand model.deck) model.players
            }
      where
        addToHand deck player
            | player.idp == move.by = player{hand = player.hand <> take (head move.values) deck}
            | otherwise = player

startTimer ∷ Effect parent Model Action
startTimer = MS.modify' $ \model → model{status = Waiting}

setUser ∷ User → Effect parent Model Action
setUser user = do
    MS.modify' $ \model → model{user = user, status = Playing}
    listenServerEvents

joinQueue ∷ Effect parent Model Action
joinQueue = MF.postJSON "/game/start" () [] (const StartTimer) notOk

listenServerEvents ∷ Effect parent Model Action
listenServerEvents = M.io_ $ GE.listenServerEvents "/game/events"

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
