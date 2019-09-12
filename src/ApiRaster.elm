module ApiRaster exposing( Model, Msg(..), init, update, view, ApiRasterResult)

import Html exposing (Html, text, pre, br)
import Http
import Json.Decode
import List
import Maybe
import String

import RasterTypes exposing(Raster)



-- MODEL

type alias ApiRasterResult = 
  { count: Int
  , previous: Maybe String
  , next: Maybe String
  , results: List Raster
  }

type Model
  = Failure
  | Loading
  | Success ApiRasterResult





init : () -> (Model, Cmd Msg)
init _ =
  ( Loading
  , Http.get
      { url = "/api/v3/rasters/"
      , expect = Http.expectJson ParsedJson rasterResultDecoder
      }
  )

rasterDecoder: Json.Decode.Decoder Raster
rasterDecoder =
  Json.Decode.map3 Raster
    (Json.Decode.field "url" Json.Decode.string)
    (Json.Decode.field "uuid" Json.Decode.string)
    (Json.Decode.field "name" Json.Decode.string)

rasterListDecoder: Json.Decode.Decoder (List Raster)
rasterListDecoder =
  Json.Decode.list rasterDecoder

rasterResultDecoder: Json.Decode.Decoder ApiRasterResult
rasterResultDecoder = 
  Json.Decode.map4 ApiRasterResult
    (Json.Decode.field "count" Json.Decode.int)
    (Json.Decode.maybe (Json.Decode.field "previous" Json.Decode.string))
    (Json.Decode.maybe (Json.Decode.field "next" Json.Decode.string))
    (Json.Decode.field "results" rasterListDecoder)



-- UPDATE


type Msg
  = ParsedJson (Result Http.Error ApiRasterResult) | Emit ApiRasterResult


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ParsedJson result ->
      case result of
        Ok parsedJson ->
          (Success parsedJson, Cmd.map (always (Emit parsedJson)) Cmd.none )--Cmd.none)

        Err _ ->
          (Failure, Cmd.none)
    Emit apiRasterResult ->
      (model, Cmd.none)



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

    Success parsedJson ->
      let
         next = 
          case parsedJson.next of
            Nothing -> ""
            Just str -> str
         previous = 
          case parsedJson.previous of
            Nothing -> "bla"
            Just str -> str 
      in
      
        pre 
          [] 
          [ text (String.fromInt (parsedJson.count)) 
          , br [] []
          , text next
          , br [] []
          , text previous
          ]