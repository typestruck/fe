{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings #-}

module Game.View where

import Game.Action (Action)
import Game.Model (Model)
import Miso (MisoString, View)
import Miso qualified as M
import Miso.Html.Element qualified as HE
import Miso.Html.Property qualified as HP

default (MisoString)

view ∷ View Model Action
view =
    HE.div_
        [HP.className "flex justify-center grow mt-10"]
        [ HE.button_ [HP.className "dark:bg-green-500 font-bold text-xl rounded-sm p-10"] [M.text "New game vs"]
        ]