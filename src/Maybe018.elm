module Maybe018 exposing (andThen)

{-| Elm 0.18 flipped the arguments to `andThen`, for the sake of ease
of use in pipelines.

@docs andThen

-}


{-| Chain together many computations that may fail. It is helpful to see its
definition:

    andThen : (a -> Maybe b) -> Maybe a -> Maybe b
    andThen callback maybe =
        case maybe of
            Just value ->
                callback value

            Nothing ->
                Nothing

This means we only continue with the callback if things are going well. For
example, say you need to use (`head : List Int -> Maybe Int`) to get the
first month from a `List` and then make sure it is between 1 and 12:

    toValidMonth : Int -> Maybe Int
    toValidMonth month =
        if month >= 1 && month <= 12 then
            Just month
        else
            Nothing

    getFirstMonth : List Int -> Maybe Int
    getFirstMonth months =
        head months
            |> andThen toValidMonth

If `head` fails and results in `Nothing` (because the `List` was `empty`),
this entire chain of operations will short-circuit and result in `Nothing`.
If `toValidMonth` results in `Nothing`, again the chain of computations
will result in `Nothing`.

-}
andThen : (a -> Maybe b) -> Maybe a -> Maybe b
andThen =
    flip Maybe.andThen
