module String019 exposing
    ( replace, fromInt, fromFloat
    , toInt, toFloat
    )

{-| Elm 0.19 added several new functions, and changed the
signature for `toInt` and `toFloat`.

@docs replace, fromInt, fromFloat
@docs toInt, toFloat

-}

import Result exposing (toMaybe)
import String exposing (join, split)


{-| Replace all occurrences of some substring.

    replace "." "-" "Json.Decode.succeed" --> "Json-Decode-succeed"

    replace "," "/" "a,b,c,d,e" --> "a/b/c/d/e"

**Note:** If you need more advanced replacements, check out the
[`elm/parser`][parser] or [`elm/regex`][regex] package.

[parser]: /packages/elm/parser/latest
[regex]: /packages/elm/regex/latest

-}
replace : String -> String -> String -> String
replace before after string =
    join after (split before string)


{-| Convert an `Int` to a `String`.

    fromInt 123 --> "123"

    fromInt -42 --> "-42"

Check out [`Debug.toString`](Debug#toString) to convert _any_ value to a string
for debugging purposes.

-}
fromInt : Int -> String
fromInt =
    toString


{-| Try to convert a string into an int, failing on improperly formatted strings.

    String019.toInt "123" --> Just 123

    String019.toInt "-42" --> Just -42

    String019.toInt "3.1" --> Nothing

    String019.toInt "31a" --> Nothing

If you are extracting a number from some raw user input, you will typically
want to use [`Maybe.withDefault`](Maybe#withDefault) to handle bad data:

    Maybe.withDefault 0 (String019.toInt "42") --> 42

    Maybe.withDefault 0 (String019.toInt "ab") --> 0

-}
toInt : String -> Maybe Int
toInt =
    String.toInt >> toMaybe


{-| Convert a `Float` to a `String`.

    fromFloat 123 --> "123"

    fromFloat -42 --> "-42"

    fromFloat 3.9 --> "3.9"

Check out [`Debug.toString`](Debug#toString) to convert _any_ value to a string
for debugging purposes.

-}
fromFloat : Float -> String
fromFloat =
    toString


{-| Try to convert a string into a float, failing on improperly formatted strings.

    String019.toFloat "123" --> Just 123.0

    String019.toFloat "-42" --> Just -42.0

    String019.toFloat "3.1" --> Just 3.1

    String019.toFloat "31a" --> Nothing

If you are extracting a number from some raw user input, you will typically
want to use [`Maybe.withDefault`](Maybe#withDefault) to handle bad data:

    Maybe.withDefault 0 (String019.toFloat "42.5") --> 42.5

    Maybe.withDefault 0 (String019.toFloat "cats") --> 0

-}
toFloat : String -> Maybe Float
toFloat =
    String.toFloat >> toMaybe
