module TestTask018 exposing (..)

import Task018
import Test exposing (..)
import Expect


-- Just verify that Task018 compiles


all : Test
all =
    describe "Task018"
        [ test "Compiles" <|
            \_ ->
                Expect.pass
        ]
