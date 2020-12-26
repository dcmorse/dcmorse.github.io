module Main exposing (..)
import Browser
import Html exposing (Html, Attribute, h1, div, input, text)
import Html.Events exposing (onInput)
import Html.Attributes
import Char exposing (isAlpha)
import List exposing (sort, map)

-- MAIN


main =
  Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
  { content : String
  }


init : Model
init =
  { content = "" }



-- UPDATE


type Msg
  = Change String


update : Msg -> Model -> Model
update msg model =
  case msg of
    Change newContent ->
      { model | content = newContent }



-- VIEW


view : Model -> Html Msg
view model =
  div [ Html.Attributes.style "margin" "5%" ]
    [ h1 [] [ text "Alphabeticalization" ]
    , input
          [ Html.Attributes.placeholder "type some words to translate"
          , Html.Attributes.value model.content
          , Html.Attributes.style "box-sizing" "border-box"
          , Html.Attributes.style "width" "33em"
          , Html.Attributes.style "margin-bottom" "20px"
          , onInput Change ]
          []
    , div [] [ text <| alphabeticalization model.content ]
    ]


-- ALPHABETICALIZATION

alphabeticalization : String -> String
alphabeticalization = splitAtWordBoundaries >> mapIf stringStartsWithLetter sortLetters >> String.concat

mapIf : (x -> Bool) -> (x -> x) -> List x -> List x
mapIf testFn fn =
    map (\x -> if testFn x then fn x else x)

sortLetters : String -> String
sortLetters =
    String.toList >> sort >> String.fromList

splitAtWordBoundaries : String -> List String
splitAtWordBoundaries =
    chunkRecursively [] True ""

chunkRecursively : List String -> Bool -> String -> String -> List String
chunkRecursively finishedChunks inWordMode reversedCharsInChunk text =
    let
        newFinishedChunks () =
            String.reverse reversedCharsInChunk :: finishedChunks
    in case String.uncons text of
        Nothing -> List.reverse <| newFinishedChunks ()
        Just (c, shortenedText) ->
            if inWordMode == isAlpha c
            then chunkRecursively finishedChunks inWordMode (String.cons c reversedCharsInChunk) shortenedText
            else chunkRecursively (newFinishedChunks ()) (not inWordMode) (String.fromChar c) shortenedText

reverseIfLetters : String -> String
reverseIfLetters str =
    if stringStartsWithLetter str
    then String.reverse str
    else str

stringStartsWithLetter : String -> Bool
stringStartsWithLetter str =
    case String.uncons str of
        Nothing -> False
        Just (c,_) -> isAlpha c
