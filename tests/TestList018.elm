module TestList018 exposing (..)

import List018 exposing (range, singleton)
import Test exposing (..)
import Expect


all : Test
all =
    describe "List018"
        [ describe "range"
            [ test "range 3 6" <|
                \_ ->
                    range 3 6
                        |> Expect.equal [ 3, 4, 5, 6 ]
            , test "range 3 3" <|
                \_ ->
                    range 3 3
                        |> Expect.equal [ 3 ]
            , test "range 6 3 " <|
                \_ ->
                    range 6 3
                        |> Expect.equal []
            ]
        , describe "singleton"
            [ test "singleton 1234" <|
                \_ ->
                    singleton 1234
                        |> Expect.equal [ 1234 ]
            ]
        ]
