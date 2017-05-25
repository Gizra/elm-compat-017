module Basics018 exposing (never)

{-| The `never` function was new in Elm 0.18, so here it is.

@docs never

-}


{-| A function that can never be called. Seems extremely pointless, but it
*can* come in handy. Imagine you have some HTML that should never produce any
messages. And say you want to use it in some other HTML that *does* produce
messages. You could say:

    import Html exposing (..)

    embedHtml : Html Never -> Html msg
    embedHtml staticStuff =
        div []
            [ text "hello"
            , Html.map never staticStuff
            ]

So the `never` function is basically telling the type system, make sure no one
ever calls me!

-}
never : Never -> a
never n =
    never n
