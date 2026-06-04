{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings #-}

module Game.View where

import Debug.Trace
import Game.Action (Action (..))
import Game.Card (Card (..))
import Game.Model (Model (..))
import Game.Player (Player (..))
import Game.Status (Status (..))
import Miso (MisoString, View)
import Miso qualified as M
import Miso.Html qualified as HP
import Miso.Html.Element qualified as HE
import Miso.Html.Property qualified as HP

default (MisoString)

view ∷ Model → View Model Action
view model =
    HE.div_
        [HP.className "flex justify-center grow mt-10"]
        $ case model.status of
            Playing → playing model
            _ → notPlaying model

notPlaying ∷ Model → [View Model Action]
notPlaying model =
    [ HE.button_
        [HP.className "dark:bg-green-500 font-bold text-xl rounded-sm p-10", HP.onClick CheckUser]
        -- https://chenhuijing.com/blog/can-you-make-a-countdown-timer-in-pure-css/
        [ M.text $ if model.status == Waiting then "Waiting for game start...." else "New game vs"
        ]
    ]

playing ∷ Model → [View Model Action]
playing model =
    [ HE.div_
        [HP.className "flex"]
        [ HE.div_
            [HP.className "flex flex-col p-30"]
            [ HE.div_ [HP.className "p-20 flex"] . concatMap (showHand . hand) $ take half model.players
            , HE.div_ [HP.className "p-20"] [M.text "FIELD"]
            , HE.div_ [HP.className "p-20 flex"] . concatMap (showHand . hand) $ drop half model.players
            ]
        , HE.div_ [HP.className "flex items-center"] [M.text "DECK"]
        ]
    ]
  where
    half = length model.players `div` 2

    showHand = map showCard
    showCard card =
        HE.div_
            [HP.className "border solid border-gray p-10 w-100 m-10"]
            [ M.text card.description
            ]