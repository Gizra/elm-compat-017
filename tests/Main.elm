port module Main exposing (..)

import Test exposing (..)
import Test.Runner.Node exposing (run)
import Json.Encode exposing (Value)
import TestBasics018
import TestBitwise018
import TestJsonDecode018
import TestList018
import TestMaybe018
import TestRandom018
import TestResult018
import TestTask018
import TestTuple018
import Doc.Basics019Spec
import Doc.Char019Spec
import Doc.Debug019Spec
import Doc.Json.Encode019Spec
import Doc.String019Spec
import Doc.Time019Spec
import Doc.Tuple019Spec


main : Program Value
main =
    run emit <|
        describe "All the tests"
            [ TestBasics018.all
            , TestBitwise018.all
            , TestJsonDecode018.all
            , TestList018.all
            , TestMaybe018.all
            , TestRandom018.all
            , TestResult018.all
            , TestTask018.all
            , TestTuple018.all
            , Doc.Basics019Spec.spec
            , Doc.Char019Spec.spec
            , Doc.Debug019Spec.spec
            , Doc.Json.Encode019Spec.spec
            , Doc.String019Spec.spec
            , Doc.Time019Spec.spec
            , Doc.Tuple019Spec.spec
            ]


port emit : ( String, Value ) -> Cmd msg
