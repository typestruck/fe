{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings #-}

module Game.View where

import Game.Action (Action (..))
import Game.Model (Model)
import Miso (MisoString, View)
import Miso qualified as M
import Miso.Html.Element qualified as HE
import Miso.Html.Property qualified as HP
import qualified Miso.Html as HP

default (MisoString)

view ∷ Model -> View Model Action
view model =
    HE.div_
        [HP.className "flex justify-center grow mt-10"]
        [ HE.button_ [HP.className "dark:bg-green-500 font-bold text-xl rounded-sm p-10", HP.onClick CheckUser] [M.text "New game vs"]
        ]