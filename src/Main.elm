port module Main exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, on)
import Html.Events.Extra
import Random
import Random.Char
import Random.Array
import String
import Array exposing (Array)
import Json.Decode as Json

main =
    Html.program
        { init = init, view = view, update = update, subscriptions = subscriptions }

port focus : String -> Cmd msg

-- MODEL

type alias Model =
    { password : String
    , lower : Int
    , upper : Int
    , digits : Int
    , special : Int
    }


init : ( Model, Cmd Msg )
init =
    let model = { password = "", lower = 7, upper = 7, digits = 5, special = 2 } in
    ( model, randomPassword model.lower model.upper model.digits model.special )


-- UPDATE

type Msg
    = Generate
    | SelectPassword
    | NewPassword String
    | Lower Int
    | Upper Int
    | Digits Int
    | Special Int

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let password model = randomPassword model.lower model.upper model.digits model.special in
    case msg of
        Lower lower ->
            if lower == model.lower then model ! []
            else
                let model = { model | lower = lower } in
                model ! [ password model ]

        Upper upper ->
            if upper == model.upper then model ! []
            else
                let model = { model | upper = upper } in
                model ! [ password model ]

        Digits digits ->
            if digits == model.digits then model ! []
            else
                let model = { model | digits = digits } in
                model ! [ password model ]

        Special special ->
            if special == model.special then model ! []
            else
                let model = { model | special = special } in
                model ! [ password model ]

        Generate ->
            model ! [ password model ]

        SelectPassword ->
            model ! [ focus ("#password") ]

        NewPassword pass ->
            { model | password = pass } ! []


upperCaseLetter : Int -> Random.Generator (Array Char)
upperCaseLetter n =
    Random.Array.array n (Random.Char.char 65 90)


lowerCaseLetter : Int -> Random.Generator (Array Char)
lowerCaseLetter n =
    Random.Array.array n (Random.Char.char 97 122)


digit : Int -> Random.Generator (Array Char)
digit n =
    Random.Array.array n (Random.Char.char 48 57)


specialCharacter : Int -> Random.Generator (Array Char)
specialCharacter n =
    Random.Array.array n (Random.Char.char 33 46)


randomPassword : Int -> Int -> Int -> Int -> Cmd Msg
randomPassword lower upper digits special =
    let
        array = Random.map4 (\a b c d -> Array.append a (Array.append b (Array.append c d))) (lowerCaseLetter lower) (upperCaseLetter upper) (digit digits) (specialCharacter special)
        shuffled = array `Random.andThen` Random.Array.shuffle
    in
        Random.generate (Array.toList >> List.map String.fromChar >> String.join "" >> NewPassword) shuffled



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


onRange : (Int -> msg) -> Attribute msg
onRange message =
    on "input" (Json.map message Html.Events.Extra.targetValueInt)


view : Model -> Html Msg
view model =
    div []
        [
          h1 [] [ text "pwdgn" ],
          div []
            [ input [ type' "range", value (toString model.lower), Html.Attributes.min "0", Html.Attributes.max "20", onRange Lower ] []
            , label [] [ text (toString model.lower), text " lowercase letters." ]
            ]
        , div []
            [ input [ type' "range", value (toString model.upper), Html.Attributes.min "0", Html.Attributes.max "20", onRange Upper ] []
            , label [] [ text (toString model.upper), text " uppercase letters." ]
            ]
        , div []
            [ input [ type' "range", value (toString model.digits), Html.Attributes.min "0", Html.Attributes.max "20", onRange Digits ] []
            , label [] [ text (toString model.digits), text " digits." ]
            ]
        , div []
            [ input [ type' "range", value (toString model.special), Html.Attributes.min "0", Html.Attributes.max "10", onRange Special ] []
            , label [] [ text (toString model.special), text " special characters." ]
            ]
        , div []
            [ input [ id "password", onClick SelectPassword, type' "text", readonly True, placeholder "Password", value model.password ] []
            , label [] [ text (toString (String.length model.password)) ]
            ]
        , button [ onClick Generate ] [ text "Generate" ]
        ]
