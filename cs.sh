
old=`cat ./public/index.css`

npx @tailwindcss/cli -i ./src/index.css -o ./public/index.css

new=`cat ./public/index.css`

if [[ "$old" == "$new" ]]; then
    exit 0
fi

cat > src/Styles.hs <<- EOM
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE MultilineStrings #-}
{-# LANGUAGE OverloadedStrings #-}

module Styles where

import Miso(MisoString)

default (MisoString)

styles :: MisoString
styles = """
`sed -e 's:\\\:\\\\\\\:g' public/index.css`
"""
EOM


