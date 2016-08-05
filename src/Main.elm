port module Main exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, on)
import Html.Events.Extra
import Random
import Char
import Random.Array
import String
import Array exposing (Array)
import Json.Decode as Json
import List exposing (map)

main =
    Html.program
        { init = init, view = view, update = update, subscriptions = subscriptions }

port focus : String -> Cmd msg
port cryptoRandom : (Int, Int, Int, Int) -> Cmd msg

getRandomValues: Model -> Cmd msg
getRandomValues model =  cryptoRandom (model.lower, model.upper, model.digits, model.special)

-- MODEL

type alias RandomList = (List Float, List Float, List Float, List Float)

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
    model ! [ getRandomValues model ]

-- UPDATE

type Msg
    = Generate
    | SelectPassword
    | NewPassword String
    | Lower Int
    | Upper Int
    | Digits Int
    | Special Int
    | RandomValues RandomList

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Lower lower ->
            if lower == model.lower then model ! []
            else
                let model = { model | lower = lower } in
                model ! [ getRandomValues model ]

        Upper upper ->
            if upper == model.upper then model ! []
            else
                let model = { model | upper = upper } in
                model ! [ getRandomValues model ]

        Digits digits ->
            if digits == model.digits then model ! []
            else
                let model = { model | digits = digits } in
                model ! [ getRandomValues model ]

        Special special ->
            if special == model.special then model ! []
            else
                let model = { model | special = special } in
                model ! [ getRandomValues model ]

        Generate ->
            model ! [ getRandomValues model, focus ("#password") ]

        RandomValues list ->
            model ! [ randomPassword list ]

        SelectPassword ->
            model ! [ focus ("#password") ]

        NewPassword pass ->
            { model | password = pass } ! []


lowerCaseLetter : Float -> Char
lowerCaseLetter n = Char.fromCode (round (n * 25 + 97))

upperCaseLetter : Float -> Char
upperCaseLetter n = Char.fromCode (round (n * 25 + 65))

digit : Float -> Char
digit n = Char.fromCode (round (n * 9 + 48))

specialCharacter : Float -> Char
specialCharacter n = Char.fromCode (round (n * 13 + 33))

randomPassword : RandomList -> Cmd Msg
randomPassword list =
  let (lower, upper, digits, special) = list
      chars = (map lowerCaseLetter lower) ++
              (map upperCaseLetter upper) ++
              (map digit digits) ++
              (map specialCharacter special)
      shuffled = Random.Array.shuffle (Array.fromList chars)
  in
  Random.generate (Array.toList >> List.map String.fromChar >> String.join "" >> NewPassword) shuffled

-- SUBSCRIPTIONS

port randomValues : (RandomList -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
    randomValues RandomValues

onRange : (Int -> msg) -> Attribute msg
onRange message =
    on "input" (Json.map message Html.Events.Extra.targetValueInt)


view : Model -> Html Msg
view model =
    div []
        [
          h1 [] [ text "pwdgn" ],
          div [ class "control-container" ] [
            div [ class "controls" ] [
              input [ id "lower", type' "range", value (toString model.lower), Html.Attributes.min "0", Html.Attributes.max "20", onRange Lower ] [],
              input [ id "upper", type' "range", value (toString model.upper), Html.Attributes.min "0", Html.Attributes.max "20", onRange Upper ] [],
              input [ id "digits", type' "range", value (toString model.digits), Html.Attributes.min "0", Html.Attributes.max "20", onRange Digits ] [],
              input [ id "special", type' "range", value (toString model.special), Html.Attributes.min "0", Html.Attributes.max "10", onRange Special ] [],
              input [ class "invisible", type' "range" ] []
            ],
            div [ class "labels" ] [
              label [ for "lower" ] [ text (toString model.lower), text " lowercase letters." ],
              label [ for "upper" ] [ text (toString model.upper), text " uppercase letters." ],
              label [ for "digits" ] [ text (toString model.digits), text " digits." ],
              label [ for "special" ] [ text (toString model.special), text " special characters." ],
              label [ for "password" ] [ text (toString (String.length model.password)), text " total." ]
            ]
          ],
          div [ class "password-container" ] [
             input [ id "password", onClick SelectPassword, type' "text", readonly True, placeholder "Password", value model.password ] [],
             button [ class "generate-button", onClick Generate ] [ img [ src "loop.svg" ] [] ]
          ]
        ]
