module TestJsonDecode018 exposing (..)

import Json.Decode exposing (int, string, decodeString)
import Json.Decode018 as Json018 exposing (field, index, nullable)
import Test exposing (..)
import Expect


expectErr result =
    case result of
        Ok _ ->
            Expect.fail "expected an error"

        Err _ ->
            Expect.pass


indexJson =
    """[ "alice", "bob", "chuck" ]"""


all : Test
all =
    describe "Json.Decode018"
        [ describe "field"
            [ test "case1" <|
                \_ ->
                    decodeString (field "x" int) """{ "x": 3 }"""
                        |> Expect.equal (Ok 3)
            , test "case2" <|
                \_ ->
                    decodeString (field "x" int) """{ "x": 3, "y": 4 }"""
                        |> Expect.equal (Ok 3)
            , test "case3" <|
                \_ ->
                    decodeString (field "x" int) """{ "x": true }"""
                        |> expectErr
            , test "case4" <|
                \_ ->
                    decodeString (field "x" int) """{ "y": 4 }"""
                        |> expectErr
            , test "case5" <|
                \_ ->
                    decodeString (field "name" string) """{ "name": "tom" }"""
                        |> Expect.equal (Ok "tom")
            ]
        , describe "index"
            [ test "alice" <|
                \_ ->
                    decodeString (index 0 string) indexJson
                        |> Expect.equal (Ok "alice")
            , test "bob" <|
                \_ ->
                    decodeString (index 1 string) indexJson
                        |> Expect.equal (Ok "bob")
            , test "chuck" <|
                \_ ->
                    decodeString (index 2 string) indexJson
                        |> Expect.equal (Ok "chuck")
            , test "fail" <|
                \_ ->
                    decodeString (index 3 string) indexJson
                        |> expectErr
            ]
        , describe "nullable"
            [ test "13" <|
                \_ ->
                    decodeString (nullable int) "13"
                        |> Expect.equal (Ok (Just 13))
            , test "42" <|
                \_ ->
                    decodeString (nullable int) "42"
                        |> Expect.equal (Ok (Just 42))
            , test "null" <|
                \_ ->
                    decodeString (nullable int) "null"
                        |> Expect.equal (Ok Nothing)
            , test "true" <|
                \_ ->
                    decodeString (nullable int) "true"
                        |> expectErr
            ]
        ]
