---
layout: post
title: "Modellierung der Elm-Architektur"
---

Nachdem wir uns die Grundlagen erarbeitet haben, wollen wir ein paar Aspekte der Implementierung der Elm-Architektur näher betrachten.
Zuerst einmal wollen wir den Typ der Funktion `sandbox` diskutieren, die wir verwendet haben, um eine Elm-Anwendung zu erstellen.
Die Funktion hat die folgende Signatur.

```elm
sandbox :
    { init : model
    , view : model -> Html msg
    , update : msg -> model -> model
    }
    -> Program () model msg
```

Zuerst können wir feststellen, dass die Funktion einen Record als Argument erhält.
Dieser Record hat drei Einträge, die `init`, `view` und `update` heißen.
Die Funktion ist polymorph über zwei Typvariablen, nämlich `model` und `msg`.
Der Eintrag `init` ist vom Typ `model`.
Daher können wir die Funktion `sandbox` nicht nur mit einem festen Typ verwenden, sondern die Typen für das Modell und die Nachrichten wählen.
Wir müssen dabei nur beachten, dass wir gleiche Typvariablen durch den gleichen Typ ersetzen.

Die Typen der Einträge `view` und `update` unterscheiden sich von den Typen, die wir bisher in Records verwendet haben, da es sich um Funktionstypen handelt.
Im Kapitel [Funktionen höherer Ordnung](higher-order.md) haben wir bereits gesehen, dass wir in der Programmiersprache Elm Funktionen als Argumente übergeben können.
In einer Sprache, in der Funktionen *First-class Citizens* sind, können wir Funktionen aber nicht nur als Argument übergeben, wir können sie auch in Datenstrukturen ablegen.
Daher kann ein Record auch Funktionen enthalten, wie es im Argument von `sandbox` der Fall ist.
Das heißt, `sandbox` ist eine Funktion höherer Ordnung, die einen Record erhält.
Der Record enthält einen Wert und zwei Funktionen.

Das Ergebnis der Funktion `sandbox` ist ein dreistelliger Typkonstruktor.
Dieser erhält den Typ des Modells und den Typ der Nachrichten als Argumente.
Der Typ `()` wird als *Unit* bezeichnet und ist der Typ der nullstelligen Tupel.
Dieser Typ hat nur einen nullstelligen Konstruktor, nämlich `()`.
Der *Unit*-Typ wird ähnlich verwendet wie der Typ `void` in Java.
Das erste Argument von `Program` wird genutzt, wenn eine Anwendung mit Flags gestartet werden soll.
In diesem Fall können der JavaScript-Anwendung, die aus dem Elm-Code erzeugt wird, initial Informationen übergeben werden.
Das erste Argument von `Program` gibt den Typ dieser initialen Informationen an.
Da diese Funktionalität bei einer einfachen Elm-Anwendung nicht benötigt wird, wird dem Typkonstruktor `Program` der Typ `()` übergeben.
Das heißt, die Anwendung erhält beim Start ein Flag, das den Typ `()` hat.
Die Anwendung erhält initial dann einfach den Wert `()`, der aber keinerlei Information enthält.

An der Typsignatur von `sandbox` erkennt man auch, dass `Html` ein Typkonstruktor ist.
Man übergibt an den Typkonstruktor den Typ der Nachrichten.
Das heißt, wenn wir eine HTML-Struktur bauen, wissen wir, welchen Typ die Nachrichten haben, die in der Struktur verwendet werden.
Hierdurch können wir dafür sorgen, dass zum Beispiel in den `onClick`-*Handlern* der Struktur nur Werte des Typs `msg` verwendet werden.
Wir betrachten etwa das folgende Beispiel.

``` elm
module Counter exposing (main)

import Browser
import Html exposing (Html, text)


type alias Model =
    Int


init : Model
init =
    0


type Msg
    = Increase
    | Decrease


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increase ->
            model + 1

        Decrease ->
            model - 1


view : Model -> Html Msg
view model =
    div []
        [ text (String.fromInt model)
        , button [ onClick False ] [ text "+" ]
        , button [ onClick 23 ] [ text "-" ]
        ]


main : Program () Model Msg
main =
    Browser.sandbox { init = init, view = view, update = update }
```

Dieses Beispiel ist eine leichte Abwandlung unseres initialen Beispiels.
Dieses Programm kompiliert nicht, da die Funktion `view` eine HTML-Struktur vom Typ `Html Msg` erstellt, die `onClick`-*Handler*, die verwendet werden, aber Nachrichten vom Typ `Bool` und vom Typ `Int` versenden.

Um das Beispiel besser zu verstehen, werfen wir einen Blick auf die Signaturen der Funktionen `div` und `onClick`.

``` elm
div : List (Attribute msg) -> List (Html msg) -> Html msg

onClick : msg -> Attribute msg
```

Wir sehen, dass der Typ der Attribute ebenfalls ein Typkonstruktor ist, der den Typ der Nachrichten als Argument erhält.
Durch den Typ der Funktion `div` wird sichergestellt, dass die Attribute den gleichen Nachrichtentyp verwenden wie die Kinder des `div`.
Der Typ der Funktion `onClick` nimmt eine Nachricht und erzeugt ein Attribut, das Nachrichten vom gleichen Typ enthält.

Bei vielen Attributen und vielen HTML-Elementen spielt der Typ der Nachrichten keine Rolle.
Wir betrachten zum Beispiel die Signatur des Attributs `style`.

``` elm
style : String -> String -> Attribute msg
```

Diese Funktion ist polymorph über der Typvariable `msg` und die Variable wird nur ein einziges Mal verwendet.
Daher kann man mit einem Aufruf der Funktion `style` ein Attribut mit einem beliebigen Nachrichtentyp erzeugen.
Auf diese Weise ist es möglich, die `style`-Funktion für HTML-Strukturen mit beliebigen Nachrichtentypen zu verwenden.
Das heißt, Funktionen, für die der Typ der Nachrichten irrelevant ist, verwenden die Typvariable `msg` kein zweites Mal in ihrer Typsignatur.

Durch diese Modellierung kann gewährleistet werden, dass der Typ der Nachrichten, die an die Anwendung mithilfe von `onClick`-*Handlern* geschickt werden, auch von der Funktion `update` verarbeitet werden kann.
Das heißt, mithilfe des statischen Typsystems sorgen wir dafür, dass klar ist, welche Nachrichten unsere `update`-Funktion verarbeiten können muss.

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="recursion.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="subscriptions.html">weiter</a></li>
    </ul>
</div>