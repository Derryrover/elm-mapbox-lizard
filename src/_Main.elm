port module Main exposing (Model, Msg(..), add1, init, main, toJs, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http exposing (Error(..))
import Json.Decode as Decode

-- own build elm
import MapBoxComponent
import ApiRequestExample
import ApiRaster
import RasterList
import RasterDataRouter
import TaskRun

-- libraries
import Mapbox.Element exposing (css)




-- ---------------------------
-- PORTS
-- ---------------------------


port toJs : String -> Cmd msg



-- ---------------------------
-- MODEL
-- ---------------------------


type alias Model =
    { counter : Int
    , serverMessage : String
    , mapBoxComponent : MapBoxComponent.Model
    , apiRequestExample : ApiRequestExample.Model
    , apiRasterModel: ApiRaster.Model
    , rasterListModel: RasterList.Model
    }


init : Int -> ( Model, Cmd Msg )
init flags = 
    let
        (mapBoxComponent, mapBoxCmd) = MapBoxComponent.init ()
        (apiRequestExampleModel, apiRequestExampleCmd) = ApiRequestExample.init ()
        (apiRasterModel, apiRasterCmd) = ApiRaster.init ()
        (rasterListModel, rasterListCmd) = RasterList.init ()
    in
        ( 
            { counter = flags
            , serverMessage = ""
            , mapBoxComponent =  mapBoxComponent 
            , apiRequestExample = apiRequestExampleModel
            , apiRasterModel = apiRasterModel
            , rasterListModel = rasterListModel
            }
        , Cmd.batch 
            [ Cmd.none
            , Cmd.map MapboxGLMsg mapBoxCmd
            , Cmd.map ApiRequestExampleMsg apiRequestExampleCmd
            , Cmd.map ApiRasterMsg apiRasterCmd
            , Cmd.map RasterListMsg rasterListCmd
            ] 
        )



-- ---------------------------
-- UPDATE
-- ---------------------------


type Msg
    = Inc
    | Set Int
    | TestServer
    | OnServerResponse (Result Http.Error String)
    | MapboxGLMsg MapBoxComponent.Msg
    | ApiRequestExampleMsg ApiRequestExample.Msg
    | ApiRasterMsg ApiRaster.Msg
    | RasterListMsg RasterList.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        ApiRequestExampleMsg apiRequestExampleMsg ->
            let
                (apiRequestExampleModel, apiRequestExampleCmd) = ApiRequestExample.update apiRequestExampleMsg model.apiRequestExample
            in
                ( { model | apiRequestExample = apiRequestExampleModel }, Cmd.map ApiRequestExampleMsg apiRequestExampleCmd )
        ApiRasterMsg apiRasterMsg ->
            let
                (apiRasterModel, apiRasterCmd) = ApiRaster.update apiRasterMsg model.apiRasterModel
                emittedList = RasterDataRouter.getRasterListFromEmit apiRasterMsg
            in
                ( { model | apiRasterModel = apiRasterModel }, Cmd.batch [Cmd.map RasterListMsg (TaskRun.run emittedList)  ,Cmd.map ApiRasterMsg apiRasterCmd] )
        RasterListMsg rasterListMsg ->
            let
                (rasterListModel, rasterListCmd) = RasterList.update rasterListMsg model.rasterListModel
            in
                ( { model | rasterListModel = rasterListModel }, Cmd.map RasterListMsg rasterListCmd )
        MapboxGLMsg mapboxGLMsg ->
            let
                (mapBoxComponent, mapBoxCmd) = MapBoxComponent.update mapboxGLMsg model.mapBoxComponent
            in
                ( { model | mapBoxComponent = mapBoxComponent }, Cmd.map MapboxGLMsg mapBoxCmd )
        Inc ->
            ( add1 model, toJs "Hello Js" )

        Set m ->
            ( { model | counter = m }, toJs "Hello Js" )

        TestServer ->
            let
                expect =
                    Http.expectJson OnServerResponse (Decode.field "result" Decode.string)
            in
            ( model
            , Http.get { url = "/test", expect = expect }
            )

        OnServerResponse res ->
            case res of
                Ok r ->
                    ( { model | serverMessage = r }, Cmd.none )

                Err err ->
                    ( { model | serverMessage = "Error: " ++ httpErrorToString err }, Cmd.none )


httpErrorToString : Http.Error -> String
httpErrorToString err =
    case err of
        BadUrl _ ->
            "BadUrl"

        Timeout ->
            "Timeout"

        NetworkError ->
            "NetworkError"

        BadStatus _ ->
            "BadStatus"

        BadBody s ->
            "BadBody: " ++ s


{-| increments the counter

    add1 5 --> 6

-}
add1 : Model -> Model
add1 model =
    { model | counter = model.counter + 1 }



-- ---------------------------
-- VIEW
-- ---------------------------


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ header []
            [ -- img [ src "/images/logo.png" ] []
            --   span [ class "logo" ] []
            -- , h1 [] [ text "Elm 0.19 Webpack Starter, with hot-reloading" ]
            ]
        , p [] [ text "Click on the button below to increment the state." ]
        , div [ class "pure-g" ]
            [ div [ class "pure-u-1-3" ]
                [ button
                    [ class "pure-button pure-button-primary"
                    , onClick Inc
                    ]
                    [ text "+ 1" ]
                , text <| String.fromInt model.counter
                ]
            , div [ class "pure-u-1-3" ] []
            , div [ class "pure-u-1-3" ]
                [ button
                    [ class "pure-button pure-button-primary"
                    , onClick TestServer
                    ]
                    [ text "ping dev server" ]
                , text model.serverMessage
                ]
            ]
        , p [] [ text "Then make a change to the source code and see how the state is retained after you recompile. Is it?" ]
        , p []
            [ text "And now don't forget to add a star to the Github repo "
            , a [ href "https://github.com/simonh1000/elm-webpack-starter" ] [ text "elm-webpack-starter" ]
            ]
        , Html.map MapboxGLMsg (MapBoxComponent.view model.mapBoxComponent)
        , Html.map ApiRequestExampleMsg (ApiRequestExample.view model.apiRequestExample)
        , Html.map ApiRasterMsg (ApiRaster.view model.apiRasterModel)
        , Html.map RasterListMsg (RasterList.view model.rasterListModel)
        ]



-- ---------------------------
-- MAIN
-- ---------------------------


main : Program Int Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view = 
            \m ->
                { title = "Elm 0.19 starter"
                , body = [ view m ]
                }
        , subscriptions = \_ -> Sub.none
        }

-- main =
--     Browser.document
--         { init = MapBoxComponent.init
--         , update = MapBoxComponent.update
--         -- , view =  Main2.view
--             -- \m ->
--             --     { title = "Elm 0.19 starter"
--             --     , body = [ view m ]
--             --     }
--         , view =  
--             \model ->
--                 { title = "Elm 0.19 starter"
--                 , body = [ css,  MapBoxComponent.view model ]
--                 }
--         , subscriptions = \_ -> Sub.none
--         }
