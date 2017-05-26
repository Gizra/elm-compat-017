module TestBitwise018 exposing (..)

import Bitwise018 as Bitwise
import Test exposing (..)
import Expect


all : Test
all =
    describe "Bitwises018"
        [ describe "shiftLeftBy"
            [ test "8 |> shiftLeftBy 1 == 16" <| \() -> Expect.equal 16 (8 |> Bitwise.shiftLeftBy 1)
            , test "8 |> shiftLeftby 2 == 32" <| \() -> Expect.equal 32 (8 |> Bitwise.shiftLeftBy 2)
            ]
        , describe "shiftRightBy"
            [ test "32 |> shiftRight 1 == 16" <| \() -> Expect.equal 16 (32 |> Bitwise.shiftRightBy 1)
            , test "32 |> shiftRight 2 == 8" <| \() -> Expect.equal 8 (32 |> Bitwise.shiftRightBy 2)
            , test "-32 |> shiftRight 1 == -16" <| \() -> Expect.equal -16 (-32 |> Bitwise.shiftRightBy 1)
            ]
        , describe "shiftRightZfBy"
            [ test "32 |> shiftRightZfBy 1 == 16" <| \() -> Expect.equal 16 (32 |> Bitwise.shiftRightZfBy 1)
            , test "32 |> shiftRightZfBy 2 == 8" <| \() -> Expect.equal 8 (32 |> Bitwise.shiftRightZfBy 2)
            , test "-32 |> shiftRightZfBy 1 == 2147483632" <| \() -> Expect.equal 2147483632 (-32 |> Bitwise.shiftRightZfBy 1)
            ]
        ]
