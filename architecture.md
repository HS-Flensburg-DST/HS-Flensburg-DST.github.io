---
layout: post
title: "Die Elm-Architektur"
---

Nachdem wir uns die Grundlagen erarbeitet haben, wollen wir ein paar Aspekte der Implementierung der Elm-Architektur näher betrachten.


## Grundlagen

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
Wir haben die Idee, einen Record an eine Funktion zu übergeben, um die Argumente zu benennen, bereits im Abschnitt [Records](basics.md#records) kennengelernt.
Der Record, der an `sandbox` übergeben wird, hat drei Einträge, die `init`, `view` und `update` heißen.
Die Funktion ist polymorph über zwei Typvariablen, nämlich `model` und `msg`.
Der Eintrag `init` ist vom Typ `model`.
Daher können wir die Funktion `sandbox` nicht nur mit einem festen Typ verwenden, sondern die Typen für das Modell und die Nachrichten wählen.
Wir müssen dabei nur beachten, dass wir alle Vorkommen einer Typvariable durch den gleichen Typ ersetzen.

Die Typen der Einträge `view` und `update` unterscheiden sich von den Typen, die wir bisher in Records verwendet haben, da es sich um Funktionstypen handelt.
In einer Programmiersprache wie Elm, in der Funktionen _First-class Citizens_ sind, können wir Funktionen nicht nur als Argument übergeben, wir können sie auch in Datenstrukturen ablegen.
Daher kann ein Record auch Funktionen enthalten, wie es im Argument von `sandbox` der Fall ist.
Das heißt, `sandbox` ist eine Funktion höherer Ordnung, die einen Record erhält.
Der Record enthält einen Wert und zwei Funktionen.

Das Ergebnis der Funktion `sandbox` ist ein dreistelliger Typkonstruktor.
Dieser erhält den Typ des Modells und den Typ der Nachrichten als Argumente.

{% include callout-important.html content="
Der Typ `()` wird als *Unit* bezeichnet und ist der Typ der nullstelligen Tupel.
Dieser Typ hat nur einen nullstelligen Konstruktor, nämlich `()`.
Der *Unit*-Typ wird ähnlich verwendet wie der Typ `void` in Java.
" %}

Das erste Argument von `Program` wird genutzt, wenn eine Anwendung mit _Flags_ gestartet werden soll.
In diesem Fall können der JavaScript-Anwendung, die aus dem Elm-Code erzeugt wird, initial Informationen übergeben werden.
Das erste Argument von `Program` gibt den Typ dieser initialen Informationen an.
Da diese Funktionalität bei einer einfachen Elm-Anwendung nicht benötigt wird, wird dem Typkonstruktor `Program` der Typ `()` übergeben.
Das heißt, die Anwendung erhält beim Start ein _Flag_, das den Typ `()` hat.
Die Anwendung erhält initial dann einfach immer den Wert `()`, der aber keinerlei Information enthält.


## Typsicherheit

An der Typsignatur von `sandbox` erkennt man auch, dass `Html` ein Typkonstruktor ist.
Man übergibt an den Typkonstruktor den Typ der Nachrichten.
Das heißt, wenn wir eine HTML-Struktur bauen, wissen wir, welchen Typ die Nachrichten haben, die in der Struktur verwendet werden.
Hierdurch können wir dafür sorgen, dass zum Beispiel in den `onClick`-_Handlern_ der Struktur nur Werte des Typs `msg` verwendet werden.
Wir betrachten etwa das folgende Beispiel.

```elm
module Counter exposing (main)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)


type alias Model =
    Int


init : Model
init =
    0


type Msg
    = IncreaseCounter
    | DecreaseCounter


update : Msg -> Model -> Model
update msg model =
    case msg of
        IncreaseCounter ->
            model + 1

        DecreaseCounter ->
            model - 1


view : Model -> Html Msg
view model =
    div []
        [ text (String.fromInt model)
        , button [ onClick False ] [ text "+" ]
        , button [ onClick 23.5 ] [ text "-" ]
        ]


main : Program () Model Msg
main =
    Browser.sandbox { init = init, view = view, update = update }
```

Dieses Beispiel ist eine leichte Abwandlung unseres initialen Beispiels aus dem Kapitel [Eine erste Elm-Anwendung](first-application.md).
Dieses Programm kompiliert nicht, da die Funktion `view` eine HTML-Struktur vom Typ `Html Msg` erstellt, die `onClick`-_Handler_, die verwendet werden, aber Nachrichten vom Typ `Bool` und vom Typ `Int` versenden.

Um das Beispiel besser zu verstehen, werfen wir einen Blick auf die Signaturen der Funktionen `div` und `onClick`.

```elm
div : List (Attribute msg) -> List (Html msg) -> Html msg

onClick : msg -> Attribute msg
```

Wir sehen, dass der Typ der Attribute ebenfalls ein Typkonstruktor ist, der den Typ der Nachrichten als Argument erhält.
Durch den Typ der Funktion `div` wird sichergestellt, dass die Attribute den gleichen Nachrichtentyp verwenden wie die Kinder des `div`.
Der Typ der Funktion `onClick` nimmt eine Nachricht und erzeugt ein Attribut, das Nachrichten vom gleichen Typ enthält.

Bei vielen Attributen und vielen HTML-Elementen spielt der Typ der Nachrichten keine Rolle.
Wir betrachten zum Beispiel die Signatur des Attributs `style`.

```elm
style : String -> String -> Attribute msg
```

Diese Funktion ist polymorph über der Typvariable `msg` und die Variable wird nur ein einziges Mal verwendet.
Daher kann man mit einem Aufruf der Funktion `style` ein Attribut mit einem beliebigen Nachrichtentyp erzeugen.
Auf diese Weise ist es möglich, die `style`-Funktion für HTML-Strukturen mit beliebigen Nachrichtentypen zu verwenden.
Das heißt, Funktionen, für die der Typ der Nachrichten irrelevant ist, verwenden die Typvariable `msg` kein zweites Mal in ihrer Typsignatur.

Durch diese Modellierung kann gewährleistet werden, dass der Typ der Nachrichten, die an die Anwendung mithilfe von `onClick`-_Handlern_ geschickt werden, auch von der Funktion `update` verarbeitet werden kann.
Das heißt, mithilfe des statischen Typsystems sorgen wir dafür, dass klar ist, welche Nachrichten unsere `update`-Funktion verarbeiten können muss.
Da wir in Elm in einem `case`-Ausdruck immer alle möglichen Werte eines Typs verarbeiten müssen, kann es somit nie vorkommen, dass in der Funktion `update` ein Laufzeitfehler auftritt, da eine Nachricht an die Funktion gesendet wird, die diese nicht verarbeiten kann.

Dadurch, dass der Typ der Nachrichten im HTML-Typ kodiert ist, kann es natürlich vorkommen, dass wir zwei HTML-Strukturen nicht kombinieren können.
Wir betrachten zum Beispiel folgendes Beispiel.

```elm
type alias Model =
    Int


type Msg
    = IncreaseCounter
    | DecreaseCounter


viewText : Model -> Html ()
viewText model =
    text (String.fromInt model)


viewButtons : Html Msg
viewButtons =
    div []
        [ button [ onClick IncreaseCounter ] [ text "+" ]
        , button [ onClick DecreaseCounter ] [ text "-" ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ viewText model
        , viewButtons
        ]
```

Dieses Programm kompiliert nicht, da wir versuchen eine HTML-Struktur vom Typ `Html ()` mit einer HTML-Struktur vom Typ `Html Msg` zu kombinieren.

{% include callout-important.html content="
Um solche Fälle zu vermeiden, sollten wir einer HTML-Struktur, die gar keine Nachrichten versendet immer einen polymorphen Typ geben.
" %}

Das heißt, wir sollten die folgende Definition verwenden.

```elm
viewText : Model -> Html msg
viewText model =
    text (String.fromInt model)
```


## Unnötige Abhängigkeiten

Dadurch, dass die HTML-Struktur angibt, welche Nachrichten in ihr verschickt werden können, können Abhängigkeiten entstehen, die vermieden werden sollten.
Wir nehmen einmal an, dass unsere Anwendung einen _Footer_ hat, in dem man seinen Namen in ein `<input>`-Element eingeben kann.
Dazu erweitern wir die Datentypen für das Modell und die Nachrichten wie folgt.

```elm
type Msg
    = IncreaseCounter
    | DecreaseCounter
    | UpdateName String
```

```elm
type alias Model =
    { counter : Int
    , name : String
    }
```

Wir definieren außerdem die folgende Funktion, welche die HTML-Struktur des _Footers_ erzeugt.

```elm
viewFooter : Model -> Html Msg
viewFooter model =
    div []
        [ input
            [ placeholder "Name"
            , value model.name
            , onInput UpdateName
            ]
        ]
```

Durch Vorerfahrungen mit React.js haben Studierende die Tendenz, eine solche Funktion in ein eigenes Modul zu schreiben.
Die Funktion `viewFooter` in ein eigenes Modul zu verschieben würde aber dem folgenden Grundsatz in der Software-Architektur widersprechen.

{% include callout-important.html content="
> Code that changes together belongs together.
"%}

Die Funktion `viewFooter` ist sehr stark an die konkrete Anwendung gebunden.
Es ist sehr unwahrscheinlich, dass wir einen identischen Footer in einer anderen Anwendung benötigen.
Es wäre aber durchaus denkbar, dass wir eine Hilfsfunktion definieren wollen, die ein Eingabefeld für einen Namen anzeigt.
Zum Beispiel könnte es sein, dass wir Eingabefelder dieser Art auf mehreren Seiten unserer Anwendung benötigen.
Es könnte sogar sein, dass wir diese Funktion so stark verallgemeinern, dass sie auch für andere Projekte nützlich ist.
Wir könnten also zum Beispiel die folgende Funktion in einem Modul `NameInput` definieren.

```elm
view : Model -> Html Msg
view model =
    input
        [ placeholder "Name"
        , value model.name
        , onInput UpdateName
        ]
```

Die Funktion `view` nutzt aber sowohl den Typ `Model` als auch den Typ `Msg`.
Häufig sind diese Datentypen in einem `Main`-Modul definiert.
Wir können im Modul `NameInput` das Modul `Main` nicht importieren, da das `Main`-Modul auch das Modul `NameInput` importieren muss, um die Funktion `view` zu nutzen.
In Studierendenprojekten wird dieses Problem manchmal gelöst, indem ein eigenes Modul angelegt wird, in dem nur die Datentypen `Model` und `Msg` definiert sind.
Dadurch brechen wir aber mit dem Grundsatz _Code that changes together belongs together._
Wir müssen bei diesem Ansatz in verschiedensten Modulen Code ändern, wenn wir an einem der Datentypen etwas ändern.
Aus eigener Erfahrung kann ich auch sagen, dass es sehr sehr mühsam ist, sich in Code einzuarbeiten, der diese Form der Strukturierung nutzt.
So muss man ununterbrochen zwischen Modulen springen, um ein mentales Modell für die grundlegenden Datentypen und Funktionen wie `update` und `view` zu erhalten.

Wir wollen uns hier bessere Lösungen für diese unnötigen Abhängigkeiten anschauen.
Zuerst können wir observieren, dass die Funktion `view` gar nicht das vollständige Modell als Argument benötigt.

{% include callout-important.html content="
Wenn eine Funktion nur einen Teil eines Records benötigt, sollten wir darüber nachdenken, ob wir den gesamten Record an die Funktion übergeben müssen.
"%}

Dies verringert die Kopplung (_Cohesion_) des Codes, also die Abhängigkeiten zwischen Modulen.
Auch bei der Funktion `viewFooter` sollten wir uns überlegen, ob wir überhaupt ein Argument vom Typ `Model` übergeben.
Bei diesem Argument wird zum Beispiel gar nicht offensichtlich, welche Informationen die Funktion `viewFooter` tatsächlich benötigt.

Auch wenn wir die Abhängigkeit vom Datentyp `Model` einfach entfernen können, besteht weiterhin eine Abhängigkeit zum Datentyp `Msg`.
Auch diese Abhängigkeit können wir entfernen.
Der Ergebnistyp der Funktion `view` spiegelt gar nicht genau das Verhalten dieser Funktion wider.
Laut Ergebnistyp kann die HTML-Struktur, die von `view` geliefert wird, beliebige Nachrichten vom Typ `Msg` liefern.
Das ist aber gar nicht der Fall.
Wir wissen statisch, dass die Funktion `view` immer nur Nachrichten der Form `UpdateName string` liefert.
Um genauer auszudrücken, was die Funktion zurückliefert, können wir den Ergebnistyp von `view` zu `Html String` abändern.
In diesem Fall ist klar, dass die Funktion immer einen `String` liefert.

Wir können die Funktion `viewFooter` nun wie folgt definieren.

```elm
viewFooter : String -> Html String
viewFooter name =
    div [] [ NameInput.view name ]
```

Wenn wir nun die Funktion `viewFooter` wie folgt nutzen, erhalten wir allerdings einen Typfehler.

```elm
view : Model -> Html Msg
view model =
    div []
        [ viewText model.counter
        , viewButtons
        , viewFooter model.name
        ]
```

Das Problem besteht darin, dass die Konstante `viewButtons` den Typ `Html Msg` hat, während die Funktion `viewFooter` einen Wert vom Typ `Html String` liefert.
Um dieses Problem zu beheben, können wir die folgende Funktion aus dem Modul `Html` nutzen.

```elm
map : (a -> b) -> Html a -> Html b
```

Wir können diese `map`-Funktion nutzen, um die Nachrichten, die die verschiedenen Strukturen verschicken können, in eine gemeinsame Datenstruktur einzupacken.
Wir erhalten zum Beispiel wie folgt eine typkorrekte Definition.

```elm
view : Model -> Html Msg
view model =
    div []
        [ viewText model.counter
        , viewButtons
        , Html.map UpdateName (viewFooter model.name)
        ]
```

In dieser Definition von `main` können wir ganz explizit sehen, dass die HTML-Struktur Nachrichten der Form `UpdateName` verschickt.
Man sollte diese Technik aber mit Bedacht einsetzen.
Falls man den Typ einer Funktion einschränken kann, sollte man den Typ einschränken, um Leser\*innen zu kommunizieren, welche Aktionen aus dem Code heraus ausgelöst werden können.

{% include callout-important.html content="
Man sollte die Struktur des Typs für Nachrichten aber nicht ändern, nur um die Typen der `view`-Funktionen einschränken zu können.
" %}

In diesem Fall würde man die Struktur des Datentyps an die Struktur des UI binden.
Die Tatsache, dass der Name aus dem _Footer_ heraus geändert wird, ist aber vermutlich eine kurzlebige Eigenschaft, die sich ggf. schnell ändert.

{% include bottom-nav.html previous="first-application.html" %}
