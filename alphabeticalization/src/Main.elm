-- compile with hints at
-- https://github.com/elm/compiler/blob/master/hints/optimize.md
-- but really I was too lazy to use uglifier and just did
--
--   elm make src/Main.elm --optimize

module Main exposing (..)
import Browser
import Html exposing (Html, Attribute, h1, div, input, text)
import Html.Events exposing (onInput)
import Html.Attributes
import Char exposing (isAlpha, isUpper, toUpper, toLower)
import List exposing (sort, map, map2)

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
alphabeticalization = splitAtWordBoundaries >> map alphabeticalizeStringsStartingWithLetters >> String.concat

-- Eyeing the possibility of converting the primary word datatype from
-- String to List Char. I'm currently doing a lot of conversion
-- to/from List Char, and the only thing I think I'm getting is one
-- call to String.toLower, which could be map Char.toLower.

alphabeticalizeStringsStartingWithLetters : String -> String
alphabeticalizeStringsStartingWithLetters s =
    if stringStartsWithLetter s then scrambleWord s else s

scrambleWord : String -> String
scrambleWord word =
    let
        capsMask =
            capitalizationMask word
        lowerCaseScramble =
            word |> String.toLower |> sortLetters
    in applyCapitalizationMask capsMask lowerCaseScramble

capitalizationMask : String -> List Bool
capitalizationMask = String.toList >> map isUpper

applyCapitalizationMask : List Bool -> String -> String
applyCapitalizationMask mask string =
    map2 massageCharacterCase mask (String.toList string) |> String.fromList

massageCharacterCase : Bool -> Char -> Char
massageCharacterCase beUpper =
    if beUpper then toUpper else toLower

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
        Nothing -> newFinishedChunks () |> List.reverse
        Just (c, shortenedText) ->
            if inWordMode == isAlpha c
            then chunkRecursively finishedChunks inWordMode (String.cons c reversedCharsInChunk) shortenedText
            else chunkRecursively (newFinishedChunks ()) (not inWordMode) (String.fromChar c) shortenedText

stringStartsWithLetter : String -> Bool
stringStartsWithLetter str =
    case String.uncons str of
        Nothing -> False
        Just (c,_) -> isAlpha c
