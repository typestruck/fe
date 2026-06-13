{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings #-}

module Game.View where

import Debug.Trace
import Game.Action (Action (..))
import Game.Card (Card (..), Color (..), Target (Opponent, Self))
import Game.Model (Model (..))
import Game.Player (Player (..))
import Game.User(User(..))
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
            [ HE.div_ [] $ map showPlayer otherPlayers
            , HE.div_ [HP.className "p-20 flex"] $ concatMap showHand otherPlayers
            , HE.div_ [HP.className "p-20"] [HE.button_ endTurnProps [M.text "End turn"]]
            , HE.div_ [HP.className "p-20 flex"] $ concatMap showHand loggedPlayers
            , HE.div_ [] $ map showPlayer loggedPlayers
            ]
        , HE.div_ [HP.className "flex items-center"] [M.text "DECK"]
        ]
    ]
  where
    otherPlayers = filter (\p -> p.idp /=  model.user.id) model.players
    loggedPlayers = filter (\p -> p.idp ==  model.user.id) model.players

    showPlayer player =
        HE.div_
            []
            [ M.text (player.name <> (M.toMisoString $ show player.idp))
            , M.text . M.toMisoString $ " " <> show player.hp
            ]

    endTurnProps
        | traceShow model.turn model.turn == Just (traceShow model.user.id model.user.id) = []
        | otherwise = [HP.disabled_]

    showHand player = map (showCard player.idp) player.hand
    showCard playerId card =
        HE.div_
            ([HP.className $ "flex flex-col border solid border-gray p-10 w-200 h-300 m-10 " <> colorName <> extra] <> props)
            [ HE.div_
                [HP.className "flex pb-10 justify-between"]
                [ HE.div_ [] [M.text . M.toMisoString $ show card.energy]
                , HE.div_ [] [M.text . M.toMisoString $ show card.cost]
                ]
            , HE.div_ [] [M.text card.description]
            ]
      where
        canPlay = playerId == model.user.id && model.turn == Just model.user.id

        props
            | canPlay = []
            | otherwise = [HP.disabled_]

        colorName =
            case card.color of
                Red → "bg-red-500"
                Blue → "bg-blue-500"
                Black → "bg-black-500"
                Green → "bg-green-500"

        extra
            | canPlay = " cursor-pointer"
            | otherwise = ""