module ApiRequestExample exposing( Model, Msg, init, update, view)

-- Make a GET request to load a book called "Public Opinion"
--
-- Read how it works:
--   https://guide.elm-lang.org/effects/http.html
--

import Browser
import Html exposing (Html, text, pre)
import Http
import Json.Decode
import List



-- MAIN


-- main =
--   Browser.element
--     { init = init
--     , update = update
--     , subscriptions = subscriptions
--     , view = view
--     }



-- MODEL


type Model
  = Failure
  | Loading
  | Success String

-- type alias Raster = 
--   { url: String
--   , uuid: String 
--   , name: String 
--   }



init : () -> (Model, Cmd Msg)
init _ =
  ( Loading
  , Http.get
      -- { url = "https://elm-lang.org/assets/public-opinion.txt"
      -- , expect = Http.expectString GotText
      -- }
      { url = "/api/v3/rasters/"
      , expect = Http.expectJson GotText rasterJsonDecoded
      }
  )

rasterJsonDecoded : Json.Decode.Decoder String
rasterJsonDecoded =
  -- Json.Decode.field "data" (Json.Decode.field "image_url" Json.Decode.string)
  Json.Decode.field "next" Json.Decode.string

-- rasterDecoder: Json.Decode.Decoder Raster
-- rasterDecoder =
--   Json.Decode.map3 Raster
--     (Json.Decode.field "url" Json.Decode.string)
--     (Json.Decode.field "uuid" Json.Decode.string)
--     (Json.Decode.field "name" Json.Decode.string)

-- rasterListDecoder: Json.Decode.Decoder (List Raster)
-- rasterListDecoder =
--   Json.Decode.list rasterDecoder



-- UPDATE


type Msg
  = GotText (Result Http.Error String)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GotText result ->
      case result of
        Ok fullText ->
          (Success fullText, Cmd.none)

        Err _ ->
          (Failure, Cmd.none)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Html Msg
view model =
  case model of
    Failure ->
      text "I was unable to load your book."

    Loading ->
      text "Loading..."

    Success fullText ->
      pre [] [ text fullText ]