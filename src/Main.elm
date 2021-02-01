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
import Html exposing (Html, a, button, div, form, h1, i, img, input, label, span, text)
import Html.Attributes exposing (checked, class, placeholder, src, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Encode as Encode exposing (Value)



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


init : ( Model, Cmd Msg )
init =
    ( initialModel, getItems )


initialModel : Model
initialModel =
    { items = []
    , isDark = True
    , alert = Nothing
    , newItem = ""
    }


type alias Model =
    { items : List String
    , isDark : Bool
    , alert : Maybe Alert
    , newItem : String
    }


type alias Alert =
    { alertText : String
    , alertType : String
    }



---- UPDATE ----


type Msg
    = ClickedDarkMode
    | GotListItems (Result Http.Error (List String))
    | ClickedAddItem
    | ClickedDeleteItem String
    | AddedItem (Result Http.Error ())
    | GotDeletedItem (Result Http.Error ())
    | UpdateNewItem String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedDarkMode ->
            ( { model | isDark = not model.isDark }, setTheme model.isDark )

        GotListItems (Ok items) ->
            ( { model | items = items }, Cmd.none )

        GotListItems (Err _) ->
            ( model, Cmd.none )

        ClickedAddItem ->
            ( model, addItem model.newItem )

        ClickedDeleteItem item ->
            ( model, deleteItem item )

        GotDeletedItem (Ok _) ->
            ( { model | alert = Just { alertType = "success", alertText = "Item successfully deleted!" } }, getItems )

        GotDeletedItem (Err _) ->
            ( { model | alert = Just { alertType = "warning", alertText = "An unkown error occoured!" } }, Cmd.none )

        AddedItem (Ok _) ->
            ( { model | newItem = "", alert = Just { alertType = "success", alertText = "Item Added!" } }, getItems )

        AddedItem (Err _) ->
            ( { model | alert = Just { alertType = "warning", alertText = "An unkown error occoured!" } }, Cmd.none )

        UpdateNewItem newItem ->
            ( { model | newItem = newItem }, Cmd.none )



---- DECODE ----


getItems : Cmd Msg
getItems =
    Http.get
        { url = "/api/items/joel"
        , expect = Http.expectJson GotListItems itemsDecoder
        }


addItem : String -> Cmd Msg
addItem item =
    Http.post
        { url = "/api/item/joel"
        , body = Http.jsonBody (itemEncoder item)
        , expect = Http.expectWhatever AddedItem
        }


deleteItem : String -> Cmd Msg
deleteItem item =
    Http.request
        { url = "/api/item/joel"
        , headers = []
        , body = Http.jsonBody (itemEncoder item)
        , expect = Http.expectWhatever GotDeletedItem
        , method = "DELETE"
        , timeout = Nothing
        , tracker = Nothing
        }


itemEncoder : String -> Encode.Value
itemEncoder item =
    Encode.object
        [ ( "item", Encode.string item ) ]


itemsDecoder : Decoder (List String)
itemsDecoder =
    list string



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

        items =
            if List.isEmpty model.items then
                viewAlert "The list is empty!" "info"

            else
                div [ class "todo-list" ] (List.map viewItem model.items)

        alertBox =
            case model.alert of
                Nothing ->
                    text ""

                Just a ->
                    viewAlert a.alertText a.alertType
    in
    div [ class theme ]
        [ div [ class "main" ]
            [ h1 [ class "text-white text-shadow" ] [ text "Two Dew Elm" ]
            , alertBox
            , items
            , viewAddForm model.newItem
            , viewDarkModeToggle model.isDark
            , Icon.css
            ]
        ]


viewAddForm : String -> Html Msg
viewAddForm newItem =
    form [ class "add-form", onSubmit ClickedAddItem ]
        [ input [ type_ "text", placeholder "New Item...", value newItem, onInput UpdateNewItem ] []
        , button []
            [ Icon.viewStyled [] Icon.plus
            , span [] [ text "Add" ]
            ]
        ]


viewItem : String -> Html Msg
viewItem item =
    div [ class "list-item" ]
        [ span [ class "list-item-text" ] [ text item ]
        , span [ class "list-item-actions" ]
            [ button [ class "icon-button text-blue" ] [ Icon.viewStyled [] Icon.pencilAlt ]
            , button [ class "icon-button text-grey" ] [ Icon.viewStyled [] Icon.calendarAlt ]
            , button [ class "icon-button text-red", onClick <| ClickedDeleteItem item ] [ Icon.viewStyled [] Icon.trashAlt ]
            ]
        ]


viewDarkModeToggle : Bool -> Html Msg
viewDarkModeToggle isDark =
    div [ class "dark-mode" ]
        [ label [ class "toggle" ]
            [ input [ type_ "checkbox", checked isDark, onClick ClickedDarkMode ] []
            , span [ class "slider" ] []
            ]
        , span [] [ text "Dark Mode" ]
        ]


viewAlert : String -> String -> Html msg
viewAlert msgText msgType =
    let
        classes =
            "alert " ++ msgType

        icon =
            if msgType == "warning" then
                Icon.skullCrossbones

            else if msgType == "success" then
                Icon.poo

            else
                Icon.exclamation
    in
    div [ class classes ]
        [ Icon.viewStyled [] icon
        , span [] [ text msgText ]
        ]
