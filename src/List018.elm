module List018 exposing (range, singleton)

{-| Elm 0.18 added a couple of functions to `List`. Enjoy!

@docs range, singleton

-}


{-| Create a list of numbers, every element increasing by one.
You give the lowest and highest number that should be in the list.

    range 3 6 == [3, 4, 5, 6]
    range 3 3 == [3]
    range 6 3 == []

-}
range : Int -> Int -> List Int
range lo hi =
    [lo..hi]


{-| Create a list with only one element:

    singleton 1234 == [1234]
    singleton "hi" == ["hi"]

-}
singleton : a -> List a
singleton value =
    [ value ]
