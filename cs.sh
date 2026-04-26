
old=`cat ./public/static/styles.css`

npx @tailwindcss/cli -i ./src/styles.css -o ./public/static/styles.css

new=`cat ./public/static/styles.css`

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
`sed -e 's:\\\:\\\\\\\:g' public/static/styles.css`
"""
EOM


