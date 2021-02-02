module Main exposing (..)

import Browser
import Browser.Dom as Dom exposing (focus)
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
import Html.Attributes exposing (checked, class, id, placeholder, src, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode as Decode exposing (Decoder, bool, list, string)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode exposing (Value)
import Task



---- PROGRAM ----


main : Program String Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }



---- MODEL ----


init : String -> ( Model, Cmd Msg )
init flags =
    ( { initialModel | listOwner = flags }, getList flags )


initialModel : Model
initialModel =
    { items = []
    , isDark = True
    , alert = Nothing
    , newItem = ""
    , listOwner = ""
    , listId = ""
    }


type alias Model =
    { items : List Item
    , isDark : Bool
    , alert : Maybe Alert
    , newItem : String
    , listOwner : String
    , listId : String
    }


type alias TodoList =
    { id : String
    , owner : String
    , isDark : Bool
    }


type alias Item =
    { id : String
    , task : String
    , isEditing : Bool
    , editingTask : String
    }


type alias Alert =
    { alertText : String
    , alertType : String
    }



---- UPDATE ----


type Msg
    = ClickedDarkMode
    | ClickedAddItem
    | ClickedDeleteItem String
    | ClickedEditItem String
    | ClickedUpdateItem String String
    | UpdateItemText String String
    | GotList (Result Http.Error TodoList)
    | GotListItems (Result Http.Error (List Item))
    | AddedItem (Result Http.Error ())
    | GotDeletedItem (Result Http.Error ())
    | GotUpdatedItem (Result Http.Error ())
    | UpdateNewItem String
    | FocusResult (Result Dom.Error ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedDarkMode ->
            ( { model | isDark = not model.isDark }, putDarkMode model.listId (not model.isDark) )

        ClickedAddItem ->
            ( model, addItem model.listId model.newItem )

        ClickedDeleteItem itemId ->
            ( model, deleteItem itemId )

        ClickedEditItem itemId ->
            ( { model | items = toggleOneEditState itemId model.items }, focusOn itemId )

        ClickedUpdateItem itemId newTask ->
            ( model, updateItem itemId newTask )

        UpdateItemText itemId newTask ->
            ( { model | items = updateItemTexts itemId newTask model.items }, Cmd.none )

        GotList (Ok todoList) ->
            ( { model | listId = todoList.id, isDark = todoList.isDark }, getItems todoList.id )

        GotList (Err _) ->
            ( { model | alert = Just { alertType = "warning", alertText = "Could not get list ID." } }, Cmd.none )

        GotListItems (Ok items) ->
            ( { model | items = items }, Cmd.none )

        GotListItems (Err _) ->
            ( model, Cmd.none )

        GotDeletedItem (Ok _) ->
            ( { model | alert = Just { alertType = "success", alertText = "Item successfully deleted!" } }, getItems model.listId )

        GotDeletedItem (Err _) ->
            ( { model | alert = Just { alertType = "warning", alertText = "An unkown error occoured!" } }, Cmd.none )

        GotUpdatedItem (Ok _) ->
            ( { model | alert = Just { alertType = "success", alertText = "Item successfully updated!" } }, getItems model.listId )

        GotUpdatedItem (Err _) ->
            ( { model | alert = Just { alertType = "warning", alertText = "An unkown error occoured!" } }, Cmd.none )

        AddedItem (Ok _) ->
            ( { model | newItem = "", alert = Just { alertType = "success", alertText = "Item Added!" } }, getItems model.listId )

        AddedItem (Err _) ->
            ( { model | alert = Just { alertType = "warning", alertText = "An unkown error occoured!" } }, Cmd.none )

        UpdateNewItem newItem ->
            ( { model | newItem = newItem }, Cmd.none )

        FocusResult result ->
            case result of
                _ ->
                    ( model, Cmd.none )


focusOn : String -> Cmd Msg
focusOn itemId =
    let
        domId =
            "input_" ++ itemId
    in
    Task.attempt FocusResult (focus domId)


toggleOneEditState : String -> List Item -> List Item
toggleOneEditState id items =
    let
        changeEdit : Item -> Item
        changeEdit item =
            if item.id == id then
                { item | isEditing = not item.isEditing }

            else
                item
    in
    List.map changeEdit items


updateItemTexts : String -> String -> List Item -> List Item
updateItemTexts id newTask items =
    let
        changeTask : Item -> Item
        changeTask item =
            if item.id == id then
                { item | editingTask = newTask }

            else
                item
    in
    List.map changeTask items



---- HTTP ----


getList : String -> Cmd Msg
getList owner =
    Http.get
        { url = "/api/list/" ++ owner
        , expect = Http.expectJson GotList listDecoder
        }


getItems : String -> Cmd Msg
getItems listId =
    Http.get
        { url = "/api/items/" ++ listId
        , expect = Http.expectJson GotListItems (list itemDecoder)
        }


addItem : String -> String -> Cmd Msg
addItem listId item =
    Http.post
        { url = "/api/item/" ++ listId
        , body = Http.jsonBody (itemEncoder item)
        , expect = Http.expectWhatever AddedItem
        }


updateItem : String -> String -> Cmd Msg
updateItem itemId newTask =
    Http.request
        { url = "api/item/" ++ itemId
        , method = "PUT"
        , headers = []
        , body = Http.jsonBody (itemEncoder newTask)
        , expect = Http.expectWhatever GotUpdatedItem
        , timeout = Nothing
        , tracker = Nothing
        }


putDarkMode : String -> Bool -> Cmd Msg
putDarkMode listId isDark =
    Http.request
        { url = "api/list/darkmode/" ++ listId
        , method = "PUT"
        , headers = []
        , body = Http.jsonBody (encodeIsDark isDark)
        , expect = Http.expectWhatever GotDeletedItem
        , timeout = Nothing
        , tracker = Nothing
        }



---- DECODE ----


encodeIsDark : Bool -> Encode.Value
encodeIsDark isDark =
    Encode.object
        [ ( "isDark", Encode.bool isDark ) ]


deleteItem : String -> Cmd Msg
deleteItem itemId =
    Http.request
        { url = "/api/item/" ++ itemId
        , method = "DELETE"
        , headers = []
        , body = Http.emptyBody
        , expect = Http.expectWhatever GotDeletedItem
        , timeout = Nothing
        , tracker = Nothing
        }


listDecoder : Decoder TodoList
listDecoder =
    Decode.succeed buildTodoList
        |> required "_id" string
        |> required "owner" string
        |> required "isDark" bool


buildTodoList : String -> String -> Bool -> TodoList
buildTodoList id owner isDark =
    { id = id, owner = owner, isDark = isDark }


itemEncoder : String -> Encode.Value
itemEncoder item =
    Encode.object
        [ ( "task", Encode.string item ) ]


itemDecoder : Decoder Item
itemDecoder =
    Decode.succeed buildItem
        |> required "_id" string
        |> required "task" string


buildItem : String -> String -> Item
buildItem id task =
    { id = id, task = task, isEditing = False, editingTask = task }



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


viewItem : Item -> Html Msg
viewItem item =
    let
        domId =
            "input_" ++ item.id

        titleArea =
            if item.isEditing then
                form [ onSubmit (ClickedUpdateItem item.id item.editingTask) ]
                    [ span [ class "list-item-text" ]
                        [ input [ type_ "text", id domId, value item.editingTask, onInput <| UpdateItemText item.id ] []
                        , button [ type_ "button" ] [ text "Update" ]
                        ]
                    ]

            else
                span [ class "list-item-text" ] [ text item.task ]
    in
    div [ class "list-item", id item.id ]
        [ titleArea
        , span [ class "list-item-actions" ]
            [ button [ class "icon-button text-blue", onClick <| ClickedEditItem item.id ] [ Icon.viewStyled [] Icon.pencilAlt ]
            , button [ class "icon-button text-grey" ] [ Icon.viewStyled [] Icon.calendarAlt ]
            , button [ class "icon-button text-red", onClick <| ClickedDeleteItem item.id ] [ Icon.viewStyled [] Icon.trashAlt ]
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
