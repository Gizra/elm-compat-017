module TestBasics018 exposing (..)

import Basics018
import Test exposing (..)
import Expect


-- Just verify that Basics018 compiles


all : Test
all =
    describe "Basics018"
        [ test "Compiles" <|
            \_ ->
                Expect.pass
        ]
