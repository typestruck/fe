{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings #-}

module User.View where

import Miso (MisoString, View)
import Miso qualified as M
import Miso.Html.Element qualified as HE
import Miso.Html.Property qualified as HP
import Game.Model (Model)
import Game.Action (Action)

default (MisoString)

view :: Model -> View Model Action
view model = HE.div_ [HP.className "flex"] [M.text "My Account"]