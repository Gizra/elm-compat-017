module Task018 exposing (attempt, andThen, onError, perform)

{-| Elm 0.18 flipped parameters for `andThen` and `onError`,
added `attempt` and altered `perform`.

@docs attempt, andThen, onError, perform
-}

import Basics018 exposing (never)
import Task exposing (Task)


{-| Command the Elm runtime to attempt a task that might fail!
-}
attempt : (Result x a -> msg) -> Task x a -> Cmd msg
attempt func =
    Task.perform (func << Err) (func << Ok)


{-| Chain together a task and a callback. The first task will run, and if it is
successful, you give the result to the callback resulting in another task. This
task then gets run.

    succeed 2
      |> andThen (\n -> succeed (n + 2))
      -- succeed 4

This is useful for chaining tasks together. Maybe you need to get a user from
your servers *and then* lookup their picture once you know their name.
-}
andThen : (a -> Task x b) -> Task x a -> Task x b
andThen =
    flip Task.andThen


{-| Recover from a failure in a task. If the given task fails, we use the
callback to recover.

    fail "file not found"
      |> onError (\msg -> succeed 42)
      -- succeed 42

    succeed 9
      |> onError (\msg -> succeed 42)
      -- succeed 9
-}
onError : (x -> Task y a) -> Task x a -> Task y a
onError =
    flip Task.onError


{-| The only way to *do* things in Elm is to give commands to the Elm runtime.
So we describe some complex behavior with a `Task` and then command the runtime
to `perform` that task. For example, getting the current time looks like this:

    import Task
    import Time exposing (Time)

    type Msg = Click | NewTime Time

    update : Msg -> Model -> ( Model, Cmd Msg )
    update msg model =
      case msg of
        Click ->
          ( model, Task.perform NewTime Time.now )

        NewTime time ->
          ...
-}
perform : (a -> msg) -> Task Never a -> Cmd msg
perform =
    Task.perform never
