module TestTuple018 exposing (..)

import Tuple018 exposing (first, second, mapFirst, mapSecond)
import Test exposing (..)
import Expect
import String


all : Test
all =
    describe "Tuple018"
        [ test "first (1, 2)" <| \() -> Expect.equal 1 (first ( 1, 2 ))
        , test "second (1, 2)" <| \() -> Expect.equal 2 (second ( 1, 2 ))
        , test "mapFirst" <| \() -> mapFirst String.length ( "stressed", 16 ) |> Expect.equal ( 8, 16 )
        , test "mapSecond" <| \() -> mapSecond sqrt ( "stressed", 16 ) |> Expect.equal ( "stressed", 4 )
        ]
