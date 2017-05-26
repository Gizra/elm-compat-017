module TestResult018 exposing (..)

import Result018 exposing (andThen)
import String
import Test exposing (..)
import Expect


isEven n =
    if n % 2 == 0 then
        Ok n
    else
        Err "number is odd"


all : Test
all =
    describe "Result018"
        [ describe "andThen Tests"
            [ test "andThen Ok" <| \() -> Expect.equal (Ok 42) ((String.toInt "42") |> andThen isEven)
            , test "andThen first Err" <|
                \() ->
                    Expect.equal
                        (Err "could not convert string '4.2' to an Int")
                        (String.toInt "4.2" |> andThen isEven)
            , test "andThen second Err" <|
                \() ->
                    Expect.equal
                        (Err "number is odd")
                        (String.toInt "41" |> andThen isEven)
            ]
        ]
