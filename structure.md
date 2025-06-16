---
layout: post
title: "Strukturierung einer Anwendung"
---

In diesem Kapitel werden mehrere Aspekte der Strukturierung einer Elm-Anwendung diskutiert.
Die Struktur des Modells einer Anwendung geht dabei sehr stark mit einer guten Modularisierung der Anwendung einher.

{% include callout-important.html content="
Das heißt, ein gut strukturiertes Modell führt häufig zu einer guten Aufteilung der Anwendung in mehrere Module und ein schlecht strukturiertes Modell führt zu einer monolithischen Anwendung oder zu einer Aufteilung in Module, die schlecht wartbar ist.
" %}

In einer sehr einfachen Elm-Anwendung kann das Modell häufig mithilfe eines flachen Records dargestellt werden, also einem Record, der als Felder nur vordefinierte Datentypen verwendet.
Wenn die Anwendung komplexer wird, verhindert ein solcher flacher Record aber häufig eine gute Modularisierung.
Viele der Beispiele in diesem Kapitel sind durch den Vortrag [Scaling Elm Apps](https://www.youtube.com/watch?v=DoA4Txr4GUs) von Richard Feldman inspiriert.

Eine weitere motivierende Kraft für die Strukturierung einer Anwendung ist das **_Domain-driven Design_ (DDD)**.
Beim _Domain-driven Design_ teilen die Domänenexperten, also in den meisten Fällen die Auftraggeber einer Anwendung, und die Entwickler\*innen ein gemeinsames mentales Modell.
Ein gemeinsames mentales Modell ist sehr wichtig, um die Anforderungen einer Anwendung optimal umzusetzen.
Beim _Domain-driven Design_ soll zusätzlich der Quelltext der Anwendung dieses Modell ebenfalls widerspiegeln.
Wenn der Quelltext das mentale Modell möglichst gut widerspiegelt, kann das mentale Modell auf diese Weise an andere Entwickler\*innen weitergegeben werden.
Die Ideen zur Anwendung von _Domain-driven Design_ in diesem Kapitel sind zum Teil durch das Buch [Domain Modeling Made Functional](https://pragprog.com/titles/swdddf/domain-modeling-made-functional/) inspiriert.

In diesem Abschnitt werden wir die Strukturierung verschiedener Komponenten einer Anwendung betrachten.
Die Komponenten werden in diesem Kapitel einzeln betrachtet, um die Inhalte aufzuteilen.
Die einzelnen Komponenten sind aber sehr stark miteinander verwoben und lassen sich häufig nur in einem Zug verbessern.


## Funktionen strukturieren

Als Beispiel für das Strukturieren von Funktionen betrachten wir die Funktion `view`.
Grundsätzlich kann jede Funktion durch die Einführung von Hilfsfunktionen besser strukturiert werden.
In einer Elm-Anwendung tendieren vor allem die Funktionen `view` und `update` dazu, lang bzw. unübersichtlich zu werden und bieten daher die häufigsten Ansatzpunkte für die Einführung von Hilfsfunktionen.
Wir betrachten die folgende `view`-Funktion.

```elm
view : Model -> Html Msg
view model =
    div []
        [ ...
        , ...
        , ...
        ]
```

Wenn wir den Eindruck haben, dass die Funktion unübersichtlich wird, sollten wir versuchen, Teile der Funktion in Hilfsfunktionen auszulagern.
Das heißt, statt eine monolithische HTML-Struktur in der Funktion `view` zu erzeugen, identifizieren wir Teile, die wir in Funktionen auslagern können.
Wir gehen in diesem Beispiel davon aus, dass wir ein Spiel implementieren, dessen visuelle Darstellung aus einem _Header_, einem _Footer_ und dem eigentlichen Spielbrett besteht.
Es wäre zum Beispiel möglich, dass wir die Funktion wie folgt in Teile zerlegen.

```elm
view : Model -> Html Msg
view model =
    div []
        [ viewHeader model
        , viewBoard model
        , viewFooter model
        ]


viewHeader : Model -> Html Msg
viewHeader model =
    ...


viewBoard : Model -> Html Msg
viewBoard model =
    ...


viewFooter : Model -> Html Msg
viewFooter model =
    ...
```

Das heißt, wir nutzen logische Bestandteile der HTML-Seite, um Hilfsfunktionen zum Rendern dieser Teile zu identifizieren.
Durch das Definieren von Hilfsfunktionen haben wir nun statt einer großen Funktion, drei kleinere Funktionen.
Außerdem haben wir die Darstellung der HTML-Struktur in Teile zerlegt, die wir einzeln verstehen und verändern können.

{% include callout-important.html content="
Funktionen wie `viewHeader`, `viewBoard` und `viewFooter` zu definieren, die nur einen Teil des Modells benötigen, aber das gesamte Modell erhalten, ist schlechter Stil.
" %}

Insbesondere verhindern wir auf diese Weise, dass wir die Funktionen wiederverwenden können.
Wir können die Funktionen aktuell nur aufrufen, wenn wir ein komplettes `Model` zur Verfügung haben.
Dadurch können wir die Funktionen aber unter Umständen nicht mehr aufrufen, obwohl wir ggf. alle Informationen zur Verfügung haben, welche die Funktionen benötigen.
Wir werden später in diesem Kapitel illustrieren, wie wir diesen Aspekt der Modellierung verbessern können.

Wir haben gesehen, wie wir die Funktion `view` mithilfe von Hilfsfunktionen in kleinere Einheiten zerlegen können.
Wir wollen nun versuchen, ein ähnliches Muster auch auf die Funktion `update` anzuwenden.
Das heißt, wir könnten `update` zum Beispiel wie folgt definieren.

```elm
update : Msg -> Model -> Model
update msg model =
    case ... of
        ... ->
            updateUser msg (updateBoard msg model)

        ...
```

In dieser Implementierung haben wir aber keinerlei Garantie, dass die Änderungen unabhängig voneinander sind.
So kann `updateUser` zum Beispiel einen Wert überschreiben, der zuvor schon von `updateBoard` geändert wurde.
Auf diese Weise kann es zum Beispiel wichtig sein, dass diese Funktionen in der richtigen Reihenfolge ausgeführt werden.
All diese Eigenschaften führen mittel- oder langfristig häufig zu schlechtem Code.

{% include callout-important.html content="
Daher sollten Funktionen, die auf dem kompletten Modell arbeiten, **nicht** nacheinander auf das Modell angewendet werden.
" %}

Um die Funktion `update` besser zu strukturieren, müssen wir die Nachrichten, die an unsere Anwendung geschickt werden, strukturieren.
Im folgenden Abschnitt sehen wir ein Beispiel für diese Form der Strukturierung.


## Nachrichten strukturieren

Wir wollen nun einen Blick darauf werfen, wie wir einen komplexen Nachrichtentyp strukturieren können.
Dazu betrachten wir das folgende Beispiel.

```elm
type Msg
    = SpaceKey
    | LeftKey
    | RightKey
    | UpKey
    | DownKey
    | ChangeFirstName String
    | ChangeLastName String
```

Die Anwendung kann verschiedene Tasten verarbeiten und es gibt die Möglichkeit den Vor- und den Nachnamen zu ändern.

In diesem Datentyp steckt eine geschachtelte Struktur, die sich auch schon etwas durch unsere Namensgebung ausdrückt.
Wir können diese Struktur nutzen, um unsere Anwendung besser zu strukturieren.
Die folgenden Datentypen machen die Struktur, die sich in unseren Nachrichten befindet, sichtbar.

```elm
type Key
    = Space
    | Left
    | Right
    | Up
    | Down


type Name
    = FirstName String
    | LastName String


type Msg
    = Pressed Key
    | Change Name
```

Die neue Struktur erlaubt es viel besser zu erkennen, dass die Anwendung zwei Arten von Interaktionen ermöglicht.
Außerdem bilden diese neuen Datentypen die Domäne der Anwendung viel besser ab.
In unserer ursprünglichen Modellierung gab es nur Nachrichten.
Das Konzept einer Nachricht ist aber kein Domänen-Konzept, sondern ein Konzept der _Model_-_View_-_Update_-Architektur.
In der neuen Modellierung gibt es die Konzepte `Taste` und `Name`, bei denen es sich um Begriffe der Domäne handelt.

Durch die bessere Struktur im Datentyp `Msg` können wir nun die `update`-Funktion durch Hilfsfunktionen strukturieren.

```elm
update : Msg -> Model -> Model
update msg model =
    case msg of
        Pressed key ->
            moveCharacter key model

        Change name ->
            changeUserName name model


moveCharacter : Key -> Model -> Model
moveCharacter key model =
    ...


changeUserName : Name -> Model -> Model
changeUserName name model =
    ...
```

Die Semantik der Funktion `update` ist "Verarbeite die Nachricht".
Das heißt, durch eine Funktion wie `update` lernen wir im Grunde nichts über die Struktur der Anwendung.
Eine Funktion wie `changeUserName` hat aber eine viel spezifischere Semantik.
Auch hier arbeiten wir wieder auf der Ebene der Domäne.
Das heißt, durch die Zerlegung der Funktion haben wir auch erreicht, dass Leser\*innen des Codes direkt sehen, dass in der Anwendung ein Name geändert werden kann.


## Modell strukturieren

In diesem Abschnitt wollen wir uns mit der Strukturierung von Modellen beschäftigen, da eine gute Struktur des Modells häufig elementar für eine gute Struktur der Anwendung ist.
Wir betrachten das folgende Beispiel-Modell.

```elm
type Model =
    { firstName : String
    , lastName : String
    , points : Int
    , position : Point
    , enemies : List Point
    , highscoreFirstName : String
    , highscoreLastName : String
    , highscore : Int
    }
```

Das Modell modelliert ein Spiel, bei dem man seinen Namen in Form von Vor- und Nachname angibt.
Außerdem hat der Spieler eine aktuelle Punktzahl und es gibt einen Highscore für das Spiel.
Zuletzt ist noch angegeben, wer aktuell den Highscore hält.

{% include callout-important.html content="
Um die Wiederverwendbarkeit von Funktionen zu erhöhen, sollte man Funktionen nur die Informationen übergeben, die sie auch benötigen.
" %}

Das heißt, wenn die Funktionen `viewHeader`, `viewBoard` und `viewFooter` aus Abschnitt [Funktionen strukturieren](#funktionen-strukturieren) nur Teile des Modells benötigen, sollten auch nur diese Teile übergeben werden.
Da unser Modell flach ist, müssten wir die einzelnen Felder, die benötigt werden, als einzelne Argumente an die Funktionen übergeben.
Stattdessen sollten wir an dieser Stelle die Gelegenheit nutzen, um zu überprüfen, ob unser Modell besser strukturiert werden kann.

Wir observieren zuerst, dass Vor- und Nachname zusammen Benutzer\*innen definieren.
Außerdem observieren wir, dass die Position des Spielers und die Positionen der Gegner das Spielbrett definieren.
Wir erhalten dadurch die folgende Struktur.

```elm
type User =
    { firstName : String
    , lastName : String
    , score : Score
    }


type Board =
    { position : Point
    , enemies : List Point
    }


type Score =
    Score Int


type Model =
    { user : User
    , board : Board
    , highscoreUser : User
    }
```

{% include callout-important.html content="
Zur Strukturierung der Datentypen sollten wir wieder Prinzipien aus dem Ansatz _Domain-driven Design_ anwenden.
" %}

Das heißt, wir fassen Daten zusammen, die in der Domäne der Anwendung auch zusammen auftreten.
Wenn die Punktzahl zum Beispiel nie zusammen mit dem `User` verwendet wird, ist es vermutlich sinnvoll, den `score` aus dem `User` zu entfernen.
Im Grunde sollten wir uns fragen, ob wir unseren Datentyp einer Person erklären können, welche die Domäne kennt, aber keine Programmierkenntnisse hat.

Mit der gewählten Strukturierung des Modells können wir die Typen der Funktionen `viewHeader`, `viewBoard` und `viewFooter` nun wie folgt spezialisieren.
Die Funktionen arbeiten nun nur noch auf einem Teil des Modells.
Wir können an den Typen der Funktionen bereits identifizieren, dass der _Header_ und _Footer_ jeweils einen `User` anzeigen.

```elm
view : Model -> Html Msg
view model =
    div []
        [ viewHeader model.user
        , viewBoard model.board
        , viewFooter model.highscoreUser
        ]


viewHeader : User -> Html Msg
viewHeader user =
    ...


viewBoard : Board -> Html Msg
viewBoard board =
    ...


viewFooter : User -> Html Msg
viewFooter highscoreUser =
    ...
```

Ähnlich wie bei der Funktion `view`, können wir durch die Strukturierung des Modells die `update`-Funktion, die wir zuvor definiert haben, nun auf Teile des Modells spezialisieren.

```elm
update : Msg -> Model -> Model
update msg model =
    case msg of
        HandleKey key ->
            { model | board = moveCharacter key model.board }

        ChangeName name ->
            { model | user = changeUserName name model.user }


moveCharacter : Key -> Board -> Board
moveCharacter key board =
    ...


changeUserName : Name -> User -> User
changeUserName name user =
    ...
```

Während die Funktionen `moveCharacter` und `changeUserName` zuvor als Argument einen Wert vom Typ `Modell` erhalten haben, arbeiten sie nun nur noch auf einem Teil des Modells.
Der Typ der Funktion liefert nun zusätzliche Dokumentation dazu, welches Verhalten die Funktion hat.
Dieser Teil des Modells kann ggf. nun auch in ein eigenes Modul ausgelagert werden, da die Logik der Funktionen häufig unabhängig von der konkreten Anwendung sind.
Das heißt, wir können zum Beispiel die Verwaltung von Nutzer\*innen in ein Modul `User` auslagern.

{% include callout-important.html content="
Diese Überlegung folgt dem folgenden wichtigen Ansatz in der Software-Architektur.

> Code that changes together belongs together.
"%}

Das heißt, Funktionen, die auf einem Datentyp arbeiten, sollten in der Nähe (in einem eigenen Modul oder vor bzw. nach dem Datentyp) definiert sein.
Man sollte sich dabei aber immer überlegen, ob der Code sich tatsächlich zusammen ändert.
Die `view`-Funktionen sollten zum Beispiel häufig nicht in dem Modul definiert sein, in dem der entsprechende Datentyp definiert ist.
Auf der einen Seite müssen wir den Code der `view`-Funktionen ändern, wenn der Datentyp sich ändert.
In vielen Fällen ändern wir den Code der `view`-Funktionen aber eher, weil sich das Design unserer Anwendung ändert.
Zum Beispiel, wenn sich die HTML-Struktur ändert.
In diesem Fall wollen wir lieber alle Funktionen, die zur grundsätzlichen Struktur der HTML-Seite gehören, zusammen haben, da diese sich häufig zusammen ändern werden.

Ein weiterer Vorteil des nicht-flachen Modells ist, dass wir nun nicht nur Hilfsfunktionen für verschiedene Nachrichten einführen können.
Da die Hilfsfunktionen jetzt nur noch auf einem Teil des Modells arbeiten, können wir jetzt in einem Fall auch mehrere Hilfsfunktionen verwenden.
Wenn wir mehrere Änderungen am Modell vornehmen möchten, könnte unsere Anwendung zum Beispiel wie folgt aussehen.

```elm
update : Msg -> Model -> Model
update msg model =
    case ... of
        ... ->
            { model
                | user = changeUserName key model.user
                , board = moveCharacter name model.board
            }

        ...


moveCharacter : Key -> Board -> Board
moveCharacter key board =
    ...


changeUserName : Name -> User -> User
changeUserName name user =
    ...
```

Im Unterschied zu Funktionen, die auf dem gesamten Modell arbeiten, sind die Funktionen `moveCharacter` und `changeUserName` offensichtlich unabhängig voneinander, da sie auf disjunkten Teilen des Modells arbeiten.
Diese Form der Strukturierung mithilfe von Funktionen können wir nur erreichen, wenn wir den Modell-Datentyp strukturieren.


## Mögliche Effekte einschränken

Im Kapitel [Modellierung der Elm-Architektur](architecture.md) haben wir gelernt, dass die verschiedenen Komponenten der Elm-Architektur Typkonstruktoren bzw. polymorphe Datentypen nutzen, um zu kodieren, welche Arten von Nachrichten an die Anwendung geschickt werden können.
Zum Beispiel drückt der Typ `Html Msg` aus, dass aus der entsprechenden HTML-Struktur Nachrichten vom Typ `Msg` verschickt werden können.
Grundsätzlich können wir, wie im vorherigen Abschnitt gesehen, für jede `view`-Funktion, die wir definieren, den Ergebnistyp `Html Msg` verwenden.
Es ist aber besser, den Typ stärker einzuschränken und damit Leser\*innen zu kommunizieren, welche Arten von Nachrichten überhaupt aus der Struktur heraus verschickt werden können.
Wir nehmen zum Beispiel einmal an, dass _Header_ und _Board_ keine Art von Interaktion erlauben.
In diesem Fall sollten die entsprechenden `view`-Funktionen polymorph im Typ der Nachrichten sein.

```elm
viewHeader : Model -> Html msg
viewHeader model =
    ...


viewBoard : Model -> Html msg
viewBoard model =
    ...
```

Im _Footer_ befinden sich Eingabefelder, um den Vor- und Nachnamen zu ändern.
Wir könnten für die Funktion `viewFooter` nun den Ergebnistyp `Html Msg` verwenden.
Wir würden damit aber nicht ausdrücken, dass nur Nachrichten vom Typ `Name` verschickt werden können.
Stattdessen können wir auch eine Definition der folgenden Form verwenden.
Diese Funktion liefert eine HTML-Struktur vom Typ `Html Name`, da alle Nachrichten, die wir aus der HTML-Struktur verschicken, vom Typ `Name` sind.

```elm
viewFooter : Model -> Html Name
viewFooter model =
    div []
        [ input
            [ placeholder "Vorname"
            , value model.textInput
            , onInput FirstName
            ]
            []
        , input
            [ placeholder "Nachname"
            , value model.textInput
            , onInput LastName
            ]
            []
        ]
```

Da `viewHeader` und `viewBoard` jeweils polymorph in der HTML-Struktur sind, können wir nun die folgende Funktion definieren.

```elm
view : Model -> Html Name
view model =
    div []
        [ viewHeader model
        , viewBoard model
        , viewFooter model
        ]
```

Die folgende Definition erzeugt nun allerdings einen Typfehler.
Wir gehen im folgenden davon aus, dass die Konstante `keyDecoder` den Typ `Decoder Key` hat.
<!-- Im Kapitel [Abonnements](subscriptions.md) werden wir genauer lernen, wofür der Eintrag `subscriptions` genutzt wird.
An dieser Stelle müssen wir nur wissen, dass der Ausdruck `onKeyDown keyDecoder` den Typ `Sub Key` hat und dieser Typ kodiert, dass durch diese Komponente Nachrichten vom Typ `Key` an die Anwendung geschickt werden können. -->

``` elm
main : Program () Model Msg
main =
    Browser.element
        { init = init
        , subscriptions = \_ -> onKeyDown keyDecoder
        , view = view
        , update = update
        }
```

Die Funktion `view` liefert Nachrichten vom Typ `Name`, während `onKeyDown keyDecoder` Nachrichten vom Typ `Key` liefert.
Außerdem behauptet der Typ `Program () Model Msg`, dass die gesamte Anwendung Nachrichten vom Typ `Msg` liefert.
Für Typkonstruktoren wie `Html` und `Sub` können wir `map`-Funktionen definieren.
<!-- Im Kapitel [Funktoren](abstractions.md#funktoren) werden wir noch einmal ausführlicher diskutieren, was diese `map`-Funktionen gemeinsam haben. -->
Wir können diese `map`-Funktionen nutzen, um die Nachrichten, die die verschiedenen Strukturen verschicken können, in eine gemeinsame Datenstruktur einzupacken.
Wir erhalten zum Beispiel wie folgt eine typkorrekte Definition.

``` elm
main : Program () Model Msg
main =
    Browser.element
        { init = init
        , subscriptions = \_ -> Sub.map HandleKey (onKeyDown keyDecoder)
        , view = \model -> Html.map ChangeName (view model)
        , update = update
        }
```

In dieser Definition von `main` können wir ganz explizit sehen, dass die HTML-Struktur Nachrichten der Form `ChangeName` verschickt, während wir durch ein Abonnement Nachrichten der Form `HandleKey` erhalten.

Man sollte diese Technik mit Bedacht einsetzen.
Falls man den Typ einer Funktion einschränken kann, sollte man den Typ einschränken, um Leser\*innen zu kommunizieren, welche Aktionen aus dem Code heraus ausgelöst werden können.

{% include callout-important.html content="
Man sollte die Struktur des Typs für Nachrichten aber nicht ändern, nur um die Typen der `view`-Funktionen einschränken zu können.
" %}

In diesem Fall würde man die Struktur des Datentyps an die Struktur des UI binden.
Die Tatsache, dass der Name aus dem _Footer_ heraus geändert wird, ist aber vermutlich eine kurzlebige Eigenschaft, die sich ggf. schnell ändert.

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="commands.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="error-handling.html">weiter</a></li>
    </ul>
</div>
