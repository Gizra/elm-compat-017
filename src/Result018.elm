module Result018 exposing (andThen, mapError)

{-| `formatError` was renamed to `mapError` in Elm 0.18, and
the parameters of `andThen` were flipped.

@docs andThen, mapError
-}

import Result


{-| Chain together a sequence of computations that may fail. It is helpful
to see its definition:

    andThen : (a -> Result e b) -> Result e a -> Result e b
    andThen callback result =
        case result of
          Ok value -> callback value
          Err msg -> Err msg

This means we only continue with the callback if things are going well. For
example, say you need to use (`toInt : String -> Result String Int`) to parse
a month and make sure it is between 1 and 12:

    toValidMonth : Int -> Result String Int
    toValidMonth month =
        if month >= 1 && month <= 12
            then Ok month
            else Err "months must be between 1 and 12"

    toMonth : String -> Result String Int
    toMonth rawString =
        toInt rawString
          |> andThen toValidMonth

    -- toMonth "4" == Ok 4
    -- toMonth "9" == Ok 9
    -- toMonth "a" == Err "cannot parse to an Int"
    -- toMonth "0" == Err "months must be between 1 and 12"

This allows us to come out of a chain of operations with quite a specific error
message. It is often best to create a custom type that explicitly represents
the exact ways your computation may fail. This way it is easy to handle in your
code.
-}
andThen : (a -> Result x b) -> Result x a -> Result x b
andThen =
    flip Result.andThen


{-| Transform an `Err` value. For example, say the errors we get have too much
information:

    parseInt : String -> Result ParseError Int

    type alias ParseError =
        { message : String
        , code : Int
        , position : (Int,Int)
        }

    mapError .message (parseInt "123") == Ok 123
    mapError .message (parseInt "abc") == Err "char 'a' is not a number"
-}
mapError : (x -> y) -> Result x a -> Result y a
mapError =
    Result.formatError
