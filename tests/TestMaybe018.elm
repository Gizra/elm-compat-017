module TestMaybe018 exposing (..)

import Maybe018 exposing (andThen)
import Test exposing (..)
import Expect


all : Test
all =
    describe "Maybe018"
        [ describe "andThen Tests"
            [ test "succeeding chain" <|
                \() ->
                    Expect.equal
                        (Just 1)
                        (andThen (\a -> Just a) (Just 1))
            , test "failing chain (original Maybe failed)" <|
                \() ->
                    Expect.equal
                        Nothing
                        (andThen (\a -> Just a) Nothing)
            , test "failing chain (chained function failed)" <|
                \() ->
                    Expect.equal
                        Nothing
                        (andThen (\a -> Nothing) (Just 1))
            ]
        ]
