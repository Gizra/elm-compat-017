port module Main exposing (..)

import Test exposing (..)
import Test.Runner.Node exposing (run)
import Json.Encode exposing (Value)
import TestBasics018
import TestBitwise018
import TestList018


main : Program Value
main =
    run emit <|
        describe "All the tests"
            [ TestBasics018.all
            , TestBitwise018.all
            , TestList018.all
            ]


port emit : ( String, Value ) -> Cmd msg
