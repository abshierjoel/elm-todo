port module Main exposing (..)

import Browser
import Char exposing (isDigit)
import FontAwesome.Attributes as Icon
import FontAwesome.Brands as Icon
import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Layering as Icon
import FontAwesome.Solid as Icon
import FontAwesome.Styles as Icon
import FontAwesome.Svg as SvgIcon
import FontAwesome.Transforms as Icon
import Html exposing (Html, a, button, div, h1, i, img, input, label, span, text)
import Html.Attributes exposing (checked, class, src, type_)
import Html.Events exposing (onClick)



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }


port setTheme : Bool -> Cmd msg



---- MODEL ----


type alias Model =
    { items : List String
    , isDark : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    { items = [ "Do Thing", "Make Work Happen", "Execute Action" ]
    , isDark = True
    }



---- UPDATE ----


type Msg
    = ClickedDarkMode


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedDarkMode ->
            ( { model | isDark = not model.isDark }, setTheme model.isDark )



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        colorTheme =
            if model.isDark == True then
                "theme--dark"

            else
                "theme--default"

        theme =
            "theme " ++ colorTheme
    in
    div [ class theme ]
        [ div [ class "main" ]
            [ h1 [ class "text-white text-shadow" ] [ text "Two Dew Elm" ]
            , div [ class "todo-list" ] (List.map viewItem model.items)
            , viewDarkModeToggle model.isDark
            , Icon.css
            ]
        ]


viewItem : String -> Html Msg
viewItem item =
    div [ class "list-item" ]
        [ span [ class "list-item-text" ] [ text item ]
        , span [ class "list-item-actions" ]
            [ button [ class "icon-button text-blue" ] [ Icon.viewStyled [] Icon.pencilAlt ]
            , button [ class "icon-button text-grey" ] [ Icon.viewStyled [] Icon.calendarAlt ]
            , button [ class "icon-button text-red" ] [ Icon.viewStyled [] Icon.trashAlt ]
            ]
        ]


viewDarkModeToggle : Bool -> Html Msg
viewDarkModeToggle isDark =
    div [ class "dark-mode" ]
        [ label [ class "toggle" ]
            [ input [ type_ "checkbox", checked isDark, onClick ClickedDarkMode ] []
            , span [ class "slider" ] []
            ]
        , text "Dark Mode"
        ]
