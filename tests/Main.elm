port module Main exposing (..)

import Test exposing (..)
import Test.Runner.Node exposing (run)
import Json.Encode exposing (Value)
import TestBasics018


main : Program Value
main =
    run emit <|
        describe "All the tests"
            [ TestBasics018.all
            ]


port emit : ( String, Value ) -> Cmd msg
