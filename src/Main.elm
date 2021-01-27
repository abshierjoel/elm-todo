module Main exposing (..)

import Browser
import Html exposing (Html, a, button, div, h1, i, img, span, text)
import Html.Attributes exposing (class, src)



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }



---- MODEL ----


type alias Model =
    { items : List String }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    { items = [ "Do Thing", "Make Work Happen", "Execute Action" ] }



---- UPDATE ----


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div [ class "main" ]
        [ h1 [] [ text "Two Dew Elm" ]
        , div [ class "todo-list" ] (List.map viewItem model.items)
        ]


viewItem : String -> Html Msg
viewItem item =
    div [ class "list-item" ]
        [ span [ class "list-item-text" ] [ text item ]
        , span [ class "list-item-actions" ]
            [ button [ class "icon-button" ] [ i [ class "fas fa-pencil-alt" ] [] ] ]
        ]
