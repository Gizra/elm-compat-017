module TestRandom018 exposing (..)

import Random018
import Test exposing (..)
import Expect


-- Just verify that Random018 compiles


all : Test
all =
    describe "Random018"
        [ test "Compiles" <|
            \_ ->
                Expect.pass
        ]
