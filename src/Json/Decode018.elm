module Json.Decode018
    exposing
        ( andThen
        , field
        , index
        , lazy
        , map2
        , map3
        , map4
        , map5
        , map6
        , map7
        , map8
        , nullable
        )

{-| There were quite a few changes between Elm 0.17 and 0.18 in `Json.Decode`.
Here are some things from Elm 0.18 that you might want to use in Elm 0.17.

@docs andThen, field, index, lazy
@docs map2, map3, map4, map5, map6, map7, map8
@docs nullable

-}

import Json.Decode exposing (Decoder, (:=), succeed, oneOf, map, null)


{-| Create decoders that depend on previous results. If you are creating
versioned data, you might do something like this:

    info : Decoder Info
    info =
        field "version" int
            |> andThen infoHelp

    infoHelp : Int -> Decoder Info
    infoHelp version =
        case version of
            4 ->
                infoDecoder4

            3 ->
                infoDecoder3

            _ ->
                fail <|
                    "Trying to decode info, but version "
                        ++ toString version
                        ++ " is not supported."


    -- infoDecoder4 : Decoder Info
    -- infoDecoder3 : Decoder Info

-}
andThen : (a -> Decoder b) -> Decoder a -> Decoder b
andThen =
    flip Json.Decode.andThen


{-| Decode a JSON object, requiring a particular field.

    decodeString (field "x" int) "{ "x": 3 }" == Ok 3
    decodeString (field "x" int) "{ "x": 3, "y": 4 }" == Ok 3
    decodeString (field "x" int) "{ "x": true }" == Err ...
    decodeString (field "x" int) "{ "y": 4 }" == Err ...
    decodeString (field "name" string) "{ "name": "tom" }" == Ok "tom"

The object *can* have other fields. Lots of them! The only thing this decoder
cares about is if `x` is present and that the value there is an `Int`.
Check out [`map2`](#map2) to see how to decode multiple fields!

-}
field : String -> Decoder a -> Decoder a
field =
    (:=)


{-| Decode a JSON array, requiring a particular index.

    json = """[ "alice", "bob", "chuck" ]"""

    decodeString (index 0 string) json  == Ok "alice"
    decodeString (index 1 string) json  == Ok "bob"
    decodeString (index 2 string) json  == Ok "chuck"
    decodeString (index 3 string) json  == Err ...

-}
index : Int -> Decoder a -> Decoder a
index =
    toString >> field


{-| Sometimes you have JSON with recursive structure, like nested comments.
You can use `lazy` to make sure your decoder unrolls lazily.

    type alias Comment =
        { message : String
        , responses : Responses
        }

    type Responses
        = Responses (List Comment)

    comment : Decoder Comment
    comment =
        map2 Comment
            (field "message" string)
            (field "responses" (map Responses (list (lazy (\_ -> comment)))))

If we had said `list comment` instead, we would start expanding the value
infinitely. What is a `comment`? It is a decoder for objects where the
`responses` field contains comments. What is a `comment` though? Etc.

By using `list (lazy (\_ -> comment))` we make sure the decoder only expands
to be as deep as the JSON we are given. You can read more about recursive data
structures [here].
[here]: <https://github.com/elm-lang/elm-compiler/blob/master/hints/recursive-alias.md>

-}
lazy : (() -> Decoder a) -> Decoder a
lazy =
    Json.Decode.andThen (Json.Decode.succeed ())


{-| Try two decoders and then combine the result. We can use this to decode
objects with many fields:

    type alias Point =
        { x : Float, y : Float }

    point : Decoder Point
    point =
        map2 Point
            (field "x" float)
            (field "y" float)


    -- decodeString point """{ "x": 3, "y": 4 }""" == Ok { x = 3, y = 4 }

It tries each individual decoder and puts the result together with the `Point`
constructor.

-}
map2 : (a -> b -> value) -> Decoder a -> Decoder b -> Decoder value
map2 =
    Json.Decode.object2


{-| Try three decoders and then combine the result. We can use this to decode
objects with many fields:

    type alias Person =
        { name : String, age : Int, height : Float }

    person : Decoder Person
    person =
        map3 Person
            (at [ "name" ] string)
            (at [ "info", "age" ] int)
            (at [ "info", "height" ] float)


    -- json = """{ "name": "tom", "info": { "age": 42, "height": 1.8 } }"""
    -- decodeString person json == Ok { name = "tom", age = 42, height = 1.8 }

Like `map2` it tries each decoder in order and then give the results to the
`Person` constructor. That can be any function though!

-}
map3 : (a -> b -> c -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder value
map3 =
    Json.Decode.object3


{-| -}
map4 : (a -> b -> c -> d -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder value
map4 =
    Json.Decode.object4


{-| -}
map5 : (a -> b -> c -> d -> e -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder value
map5 =
    Json.Decode.object5


{-| -}
map6 : (a -> b -> c -> d -> e -> f -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder value
map6 =
    Json.Decode.object6


{-| -}
map7 : (a -> b -> c -> d -> e -> f -> g -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder value
map7 =
    Json.Decode.object7


{-| -}
map8 : (a -> b -> c -> d -> e -> f -> g -> h -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder h -> Decoder value
map8 =
    Json.Decode.object8


{-| Decode a nullable JSON value into an Elm value.

    decodeString (nullable int) "13"    == Ok (Just 13)
    decodeString (nullable int) "42"    == Ok (Just 42)
    decodeString (nullable int) "null"  == Ok Nothing
    decodeString (nullable int) "true"  == Err ..

-}
nullable : Decoder a -> Decoder (Maybe a)
nullable decoder =
    oneOf
        [ null Nothing
        , map Just decoder
        ]
