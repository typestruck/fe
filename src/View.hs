{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE OverloadedStrings #-}

module View where

import Game.Action (Action (..))
import Game.Model (Model (..))
import Game.User(User(..))
import Game.View qualified as GV
import Miso (MisoString, View)
import Miso.Html.Element qualified as HE
import Miso.Html.Property qualified as HP
import User.View qualified as UV
import qualified Miso as M

default (MisoString)

view ∷ Model → View Model Action
view model =
    HE.main_
        [HP.className "dark:bg-gray-800 dark:text-white min-h-full flex flex-col md:flex-row md:items-start"]
        [ UV.view model
        , GV.view model
        ]
