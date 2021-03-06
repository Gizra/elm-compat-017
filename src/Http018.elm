module Http018 exposing
    ( Request, send, Error(..)
    , getString, get
    , post
    , request
    , Header, header
    , Body, emptyBody, jsonBody, stringBody, multipartBody, Part, stringPart
    , Expect, expectString, expectJson, expectStringResponse, Response
    , toTask
    )

{-| The API for this module had significant changes in Elm 0.18. This
represents a full implementation of the Elm 0.18 API.


# Send Requests

@docs Request, send, Error


# GET

@docs getString, get


# POST

@docs post


# Custom Requests

@docs request


## Headers

@docs Header, header


## Request Bodies

@docs Body, emptyBody, jsonBody, stringBody, multipartBody, Part, stringPart


## Responses

@docs Expect, expectString, expectJson, expectStringResponse, Response


# Low-Level

@docs toTask

-}

import Dict exposing (Dict)
import Http exposing (Data, RawError(..), empty, multipart, string, stringData)
import Json.Decode as Decode
import Json.Encode as Encode
import Task exposing (Task, fail, succeed)
import Task018 exposing (attempt)



-- REQUESTS


{-| Describes an HTTP request.
-}
type Request a
    = Request (RawRequest a)


type alias RawRequest a =
    { method : String
    , headers : List Header
    , url : String
    , body : Body
    , expect : Expect a
    , timeout : Maybe Float
    , withCredentials : Bool
    }


{-| Send a `Request`. We could get the text of “War and Peace” like this:

    import Http

    type Msg = Click | NewBook (Result Http.Error String)

    update : Msg -> Model -> ( Model, Cmd Msg )
    update msg model =
      case msg of
        Click ->
          ( model, getWarAndPeace )

        NewBook (Ok book) ->
          ...

        NewBook (Err _) ->
          ...

    getWarAndPeace : Cmd Msg
    getWarAndPeace =
      Http.send NewBook <|
        Http.getString "https://example.com/books/war-and-peace.md"

-}
send : (Result Error a -> msg) -> Request a -> Cmd msg
send resultToMessage request_ =
    attempt resultToMessage (toTask request_)


{-| Convert a `Request` into a `Task`. This is only really useful if you want
to chain together a bunch of requests (or any other tasks) in a single command.
-}
toTask : Request a -> Task Error a
toTask (Request r) =
    let
        headers =
            r.headers
                |> List.map (\(Header key value) -> ( key, value ))
                |> addContentType r.body

        req =
            { verb = r.method
            , headers = headers
            , url = r.url
            , body = downgradeBody r.body
            }

        settings =
            { timeout = Maybe.withDefault 0 r.timeout
            , onStart = Nothing
            , onProgress = Nothing
            , desiredResponseType = Nothing -- Possibly set based on expect?
            , withCredentials = r.withCredentials
            }
    in
    Http.send settings req
        |> Task.mapError promoteError
        |> Task.map promoteResponse
        |> Task018.andThen (applyExpect r.expect)


promoteError : RawError -> Error
promoteError err =
    case err of
        RawTimeout ->
            Timeout

        RawNetworkError ->
            NetworkError


promoteResponse : Http.Response -> Response String
promoteResponse r =
    let
        body =
            case r.value of
                Http.Text str ->
                    str

                Http.Blob blob ->
                    -- This can't happen, but we can't prove it to the
                    -- compiler.
                    ""
    in
    { url = r.url
    , status =
        { code = r.status
        , message = r.statusText
        }
    , headers = r.headers
    , body = body
    }


applyExpect : Expect a -> Response String -> Task Error a
applyExpect (ExpectString decode) response =
    if 200 <= response.status.code && response.status.code < 300 then
        case decode response of
            Ok value ->
                succeed value

            Err err ->
                fail (BadPayload err response)

    else
        fail (BadStatus response)


contentTypeKey : String
contentTypeKey =
    "Content-Type"


addContentType : Body -> List ( String, String ) -> List ( String, String )
addContentType body headers =
    let
        contentType =
            case body of
                EmptyBody ->
                    []

                StringBody mime _ ->
                    [ ( contentTypeKey, "application/json" ) ]

                MultipartBody _ ->
                    [ ( contentTypeKey, "multipart/form-data" ) ]
    in
    if List.any (\( key, _ ) -> key == contentTypeKey) headers then
        -- If there is an explicit content-type, don't change it
        headers

    else
        -- Otherwise, add a content type for our body
        List.append headers contentType


downgradeBody : Body -> Http.Body
downgradeBody b =
    case b of
        EmptyBody ->
            empty

        StringBody mime data ->
            string data

        MultipartBody parts ->
            multipart parts


{-| A `Request` can fail in a couple ways:

  - `BadUrl` means you did not provide a valid URL.
  - `Timeout` means it took too long to get a response.
  - `NetworkError` means the user turned off their wifi, went in a cave, etc.
  - `BadStatus` means you got a response back, but the [status code][sc]
    indicates failure.
  - `BadPayload` means you got a response back with a nice status code, but
    the body of the response was something unexpected. The `String` in this
    case is a debugging message that explains what went wrong with your JSON
    decoder or whatever.

[sc]: https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html

> Note that `BadUrl` is not actually used at the moment, because it is
> impractical to check the URL in Elm 0.17.

-}
type Error
    = BadUrl String
    | Timeout
    | NetworkError
    | BadStatus (Response String)
    | BadPayload String (Response String)



-- GET


{-| Create a `GET` request and interpret the response body as a `String`.

    import Http

    getWarAndPeace : Http.Request String
    getWarAndPeace =
        Http.getString "https://example.com/books/war-and-peace"

-}
getString : String -> Request String
getString url =
    request
        { method = "GET"
        , headers = []
        , url = url
        , body = emptyBody
        , expect = expectString
        , timeout = Nothing
        , withCredentials = False
        }


{-| Create a `GET` request and try to decode the response body from JSON to
some Elm value.

    import Http
    import Json.Decode exposing (list, string)

    getBooks : Http.Request (List String)
    getBooks =
        Http.get "https://example.com/books" (list string)

You can learn more about how JSON decoders work [here] in the guide.

[here]: https://guide.elm-lang.org/interop/json.html

-}
get : String -> Decode.Decoder a -> Request a
get url decoder =
    request
        { method = "GET"
        , headers = []
        , url = url
        , body = emptyBody
        , expect = expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }



-- POST


{-| Create a `POST` request and try to decode the response body from JSON to
an Elm value. For example, if we want to send a POST without any data in the
request body, it would be like this:

    import Http
    import Json.Decode exposing (list, string)

    postBooks : Http.Request (List String)
    postBooks =
        Http.post "https://example.com/books" Http.emptyBody (list string)

See [`jsonBody`](#jsonBody) to learn how to have a more interesting request
body. And check out [this section][here] of the guide to learn more about
JSON decoders.

[here]: https://guide.elm-lang.org/interop/json.html

-}
post : String -> Body -> Decode.Decoder a -> Request a
post url body decoder =
    request
        { method = "POST"
        , headers = []
        , url = url
        , body = body
        , expect = expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }



-- CUSTOM REQUESTS


{-| Create a custom request. For example, a custom PUT request would look like
this:

    put : String -> Body -> Request ()
    put url body =
        request
            { method = "PUT"
            , headers = []
            , url = url
            , body = body
            , expect = expectStringResponse (\_ -> Ok ())
            , timeout = Nothing
            , withCredentials = False
            }

The `timeout` is the number of milliseconds you are willing to wait before
giving up.

-}
request :
    { method : String
    , headers : List Header
    , url : String
    , body : Body
    , expect : Expect a
    , timeout : Maybe Float
    , withCredentials : Bool
    }
    -> Request a
request =
    Request



-- HEADERS


{-| An HTTP header for configuring requests. See a bunch of common headers
[here].

[here]: https://en.wikipedia.org/wiki/List_of_HTTP_header_fields

-}
type Header
    = Header String String


{-| Create a `Header`.

    header "If-Modified-Since" "Sat 29 Oct 1994 19:43:31 GMT"

    header "Max-Forwards" "10"

    header "X-Requested-With" "XMLHttpRequest"

**Note:** In the future, we may split this out into an `Http.Headers` module
and provide helpers for cases that are common on the client-side. If this
sounds nice to you, open an issue [here] describing the helper you want and
why you need it.

[here]: https://github.com/elm/http/issues

-}
header : String -> String -> Header
header =
    Header



-- BODY


{-| Represents the body of a `Request`.
-}
type Body
    = EmptyBody
    | StringBody String String
    | MultipartBody (List Data)


{-| Create an empty body for your `Request`. This is useful for GET requests
and POST requests where you are not sending any data.
-}
emptyBody : Body
emptyBody =
    EmptyBody


{-| Put some JSON value in the body of your `Request`. This will automatically
add the `Content-Type: application/json` header.
-}
jsonBody : Encode.Value -> Body
jsonBody value =
    StringBody "application/json" (Encode.encode 0 value)


{-| Put some string in the body of your `Request`. Defining `jsonBody` looks
like this:

    import Json.Encode as Encode

    jsonBody : Encode.Value -> Body
    jsonBody value =
        stringBody "application/json" (Encode.encode 0 value)

Notice that the first argument is a [MIME type][mime] so we know to add
`Content-Type: application/json` to our request headers. Make sure your
MIME type matches your data. Some servers are strict about this!

[mime]: https://en.wikipedia.org/wiki/Media_type

-}
stringBody : String -> String -> Body
stringBody =
    StringBody


{-| Create multi-part bodies for your `Request`, automatically adding the
`Content-Type: multipart/form-data` header.
-}
multipartBody : List Part -> Body
multipartBody =
    MultipartBody


{-| Contents of a multi-part body. Right now it only supports strings, but we
will support blobs and files when we get an API for them in Elm.
-}
type alias Part =
    Data


{-| A named chunk of string data.

    body =
        multipartBody
            [ stringPart "user" "tom"
            , stringPart "payload" "42"
            ]

-}
stringPart : String -> String -> Part
stringPart =
    stringData



-- RESPONSES


{-| Logic for interpreting a response body.
-}
type Expect a
    = ExpectString (Response String -> Result String a)


{-| Expect the response body to be a `String`.
-}
expectString : Expect String
expectString =
    ExpectString
        (Ok << .body)


{-| Expect the response body to be JSON. You provide a `Decoder` to turn that
JSON into an Elm value. If the body cannot be parsed as JSON or if the JSON
does not match the decoder, the request will resolve to a `BadPayload` error.
-}
expectJson : Decode.Decoder a -> Expect a
expectJson decoder =
    ExpectString
        (Decode.decodeString decoder << .body)


{-| Maybe you want the whole `Response`: status code, headers, body, etc. This
lets you get all of that information. From there you can use functions like
`Json.Decode.decodeString` to interpret it as JSON or whatever else you want.
-}
expectStringResponse : (Response String -> Result String a) -> Expect a
expectStringResponse =
    ExpectString


{-| The response from a `Request`.
-}
type alias Response body =
    { url : String
    , status : { code : Int, message : String }
    , headers : Dict String String
    , body : body
    }
