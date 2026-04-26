{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings #-}

module View where

import Data.List qualified as DL
import Game.Action (Action (..))
import Game.Model (Model (..))
import Miso (MisoString, View)
import Miso qualified as M
import Miso.Html.Element qualified as HE
import Miso.Html.Event qualified as HP
import Miso.Html.Property qualified as HP
import Miso.String qualified as MSS

default (MisoString)

view ∷ Model → View Model Action
view model =
    HE.main_ [HP.className "dark:bg-gray-800 dark:text-white min-h-full flex flex-col"] [M.text "oi"]
