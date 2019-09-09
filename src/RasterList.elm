module RasterList exposing (Model, Msg, init, update, view)

import RasterTypes exposing(Raster)
import List
import Html exposing (Html, text, pre, br)

type alias Model = List Raster

type Msg = ReceivedRasters Model

init: () -> (Model, Cmd Msg)
init _ = ([], Cmd.none)

update: Msg -> Model -> (Model, Cmd Msg)
update msg model = 
  case msg of
    ReceivedRasters rasters ->
      ( List.concat [model, rasters] , Cmd.none)

view: Model -> Html Msg
view model = 
  Html.div 
    []
    (
      List.map 
      (\raster -> Html.div [] [Html.text raster.name])
      model
    )