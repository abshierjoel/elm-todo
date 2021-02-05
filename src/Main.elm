module Main exposing (..)

import Browser
import Browser.Dom as Dom exposing (focus)
import Char exposing (isDigit)
import FontAwesome.Attributes as Icon
import FontAwesome.Brands as Icon
import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Layering as Icon
import FontAwesome.Regular as IconFar
import FontAwesome.Solid as IconFas
import FontAwesome.Styles as Icon
import FontAwesome.Svg as SvgIcon
import FontAwesome.Transforms as Icon
import Html exposing (Html, a, button, div, form, h1, i, img, input, label, span, text, textarea)
import Html.Attributes as Attr exposing (checked, class, id, placeholder, src, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode as Decode exposing (Decoder, bool, list, string)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode exposing (Value)
import Task
import Tuple exposing (first, second)



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
    , newItem = { task = "", description = "" }
    , listOwner = ""
    , listId = ""
    }


type alias Model =
    { items : List Item
    , isDark : Bool
    , alert : Maybe Alert
    , newItem : NewItem
    , listOwner : String
    , listId : String
    }


type alias TodoList =
    { id : String
    , owner : String
    , isDark : Bool
    }


type alias NewItem =
    { task : String
    , description : String
    }


type alias Item =
    { id : String
    , task : String
    , description : String
    , isEditing : Bool
    , complete : Bool
    , editingTask : String
    , editingDesc : String
    }


type alias Alert =
    { alertText : String
    , alertType : String
    }



---- UPDATE ----


type Msg
    = ClickedDarkMode
    | ClickedAddItem
    | ClickedCompleteItem String Bool
    | ClickedDeleteItem String
    | ClickedEditItem String
    | ClickedUpdateItem String String String
    | UpdateItemTask String String
    | UpdateItemDesc String String
    | UpdateNewItemTask String
    | UpdateNewItemDesc String
    | GotList (Result Http.Error TodoList)
    | GotListItems (Result Http.Error (List Item))
    | AddedItem (Result Http.Error ())
    | GotDeletedItem (Result Http.Error ())
    | GotUpdatedItem (Result Http.Error ())
    | FocusResult (Result Dom.Error ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedDarkMode ->
            ( { model | isDark = not model.isDark }, putDarkMode model.listId (not model.isDark) )

        ClickedAddItem ->
            ( model, addItem model.listId model.newItem )

        ClickedCompleteItem itemId complete ->
            ( model, completeItem itemId complete )

        ClickedDeleteItem itemId ->
            ( model, deleteItem itemId )

        ClickedEditItem itemId ->
            ( { model | items = toggleOneEditState itemId model.items }, focusOn itemId )

        ClickedUpdateItem itemId newTask newDesc ->
            ( model, updateItem itemId ( newTask, newDesc ) )

        UpdateItemTask itemId newTask ->
            ( { model | items = updateItemTask itemId newTask model.items }, Cmd.none )

        UpdateItemDesc itemId newDesc ->
            ( { model | items = updateItemDesc itemId newDesc model.items }, Cmd.none )

        UpdateNewItemTask newTask ->
            ( { model | newItem = { task = newTask, description = model.newItem.description } }, Cmd.none )

        UpdateNewItemDesc newDesc ->
            ( { model | newItem = { task = model.newItem.task, description = newDesc } }, Cmd.none )

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
            ( { model | newItem = { task = "", description = "" }, alert = Just { alertType = "success", alertText = "Item Added!" } }, getItems model.listId )

        AddedItem (Err _) ->
            ( { model | alert = Just { alertType = "warning", alertText = "An unkown error occoured!" } }, Cmd.none )

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


updateItemTask : String -> String -> List Item -> List Item
updateItemTask id newTask items =
    let
        changeTask : Item -> Item
        changeTask item =
            if item.id == id then
                { item | editingTask = newTask }

            else
                item
    in
    List.map changeTask items


updateItemDesc : String -> String -> List Item -> List Item
updateItemDesc id newDesc items =
    let
        changeTask : Item -> Item
        changeTask item =
            if item.id == id then
                { item | editingDesc = newDesc }

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


addItem : String -> NewItem -> Cmd Msg
addItem listId item =
    Http.post
        { url = "/api/item/" ++ listId
        , body = Http.jsonBody (itemEncoder ( item.task, item.description ))
        , expect = Http.expectWhatever AddedItem
        }


updateItem : String -> ( String, String ) -> Cmd Msg
updateItem itemId item =
    Http.request
        { url = "api/item/" ++ itemId
        , method = "PUT"
        , headers = []
        , body = Http.jsonBody (itemEncoder item)
        , expect = Http.expectWhatever GotUpdatedItem
        , timeout = Nothing
        , tracker = Nothing
        }


completeItem : String -> Bool -> Cmd Msg
completeItem itemId complete =
    Http.request
        { url = "api/item/" ++ itemId
        , method = "PUT"
        , headers = []
        , body = Http.jsonBody (completeEncoder complete)
        , expect = Http.expectWhatever GotUpdatedItem
        , timeout = Nothing
        , tracker = Nothing
        }


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


listDecoder : Decoder TodoList
listDecoder =
    Decode.succeed buildTodoList
        |> required "_id" string
        |> required "owner" string
        |> required "isDark" bool


buildTodoList : String -> String -> Bool -> TodoList
buildTodoList id owner isDark =
    { id = id, owner = owner, isDark = isDark }


itemEncoder : ( String, String ) -> Encode.Value
itemEncoder item =
    Encode.object
        [ ( "task", Encode.string <| first item )
        , ( "description", Encode.string <| second item )
        ]


completeEncoder : Bool -> Encode.Value
completeEncoder complete =
    Encode.object
        [ ( "complete", Encode.bool complete ) ]


itemDecoder : Decoder Item
itemDecoder =
    Decode.succeed buildItem
        |> required "_id" string
        |> required "task" string
        |> required "description" string
        |> required "complete" bool


buildItem : String -> String -> String -> Bool -> Item
buildItem id task description complete =
    { id = id
    , task = task
    , description = description
    , complete = complete
    , isEditing = False
    , editingTask = task
    , editingDesc = description
    }



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
            , viewAddItem model.newItem
            , viewDarkModeToggle model.isDark
            , Icon.css
            ]
        ]


viewAddItem : NewItem -> Html Msg
viewAddItem newItem =
    form [ class "add-form", onSubmit ClickedAddItem ]
        [ input [ type_ "text", placeholder "New Item...", value newItem.task, Attr.required True, onInput UpdateNewItemTask ] []
        , textarea [ value newItem.description, placeholder "Description...", onInput UpdateNewItemDesc ] []
        , button []
            [ Icon.viewStyled [] IconFas.plus
            , span [] [ text "Add" ]
            ]
        ]


viewItem : Item -> Html Msg
viewItem item =
    let
        complete =
            if item.complete then
                "text-dashed"

            else
                ""

        titleArea =
            if item.isEditing then
                viewEditItem item

            else
                span [ class "list-item-text" ]
                    [ span [ class <| "list-item-title " ++ complete ] [ text item.task ]
                    , span [ class "list-item-description" ] [ text item.description ]
                    ]

        completeColor =
            if item.complete then
                "text-green"

            else
                "text-grey"

        completeIcon =
            if item.complete then
                IconFas.checkCircle

            else
                IconFar.checkCircle
    in
    div [ class "list-item", id item.id ]
        [ titleArea
        , span [ class "list-item-actions" ]
            [ button [ class <| "icon-button " ++ completeColor, onClick <| ClickedCompleteItem item.id (not item.complete) ] [ Icon.viewStyled [] completeIcon ]
            , button [ class "icon-button text-blue", onClick <| ClickedEditItem item.id ] [ Icon.viewStyled [] IconFas.pencilAlt ]
            , button [ class "icon-button text-red", onClick <| ClickedDeleteItem item.id ] [ Icon.viewStyled [] IconFas.trashAlt ]
            ]
        ]


viewEditItem : Item -> Html Msg
viewEditItem item =
    let
        domId =
            "input_" ++ item.id
    in
    form [ onSubmit (ClickedUpdateItem item.id item.editingTask item.editingDesc) ]
        [ span [ class "list-item-text" ]
            [ input [ type_ "text", id domId, value item.editingTask, onInput <| UpdateItemTask item.id ] []
            , textarea [ value item.editingDesc, onInput <| UpdateItemDesc item.id ] []
            , button [ type_ "submit" ] [ text "Update" ]
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
                IconFas.skullCrossbones

            else if msgType == "success" then
                IconFas.poo

            else
                IconFas.exclamation
    in
    div [ class classes ]
        [ Icon.viewStyled [] icon
        , span [] [ text msgText ]
        ]
