---
layout: post
title: "Strukturierung einer Anwendung"
---

In diesem Kapitel werden mehrere Aspekte der Strukturierung einer Elm-Anwendung diskutiert.
Die Struktur des Modells einer Anwendung geht dabei sehr stark mit einer guten Modularisierung der Anwendung einher.
Das heißt, ein gut strukturiertes Modell führt häufig zu einer guten Aufteilung der Anwendung in mehrere Module und ein schlecht strukturiertes Modell führt zu einer monolithischen Anwendung oder zu einer Aufteilung in Module, die schlecht wartbar ist.
In einer sehr einfachen Elm-Anwendung kann das Modell häufig mithilfe eines flachen Records dargestellt werden, also einem Record, der als Felder nur vordefinierte Datentypen verwendet.
Wenn die Anwendung komplexer wird, verhindert ein solcher flacher Record aber häufig eine gute Modularisierung.
Viele der Beispiele in diesem Kapitel sind durch den Vortrag [Scaling Elm Apps](https://www.youtube.com/watch?v=DoA4Txr4GUs) von Richard Feldman motiviert.


## Funktionen strukturieren

Als Beispiel für das Strukturieren von Funktionen betrachten wir die Funktion `view`.
Grundsätzlich kann jede Funktion durch die Einführung von Hilfsfunktionen besser strukturiert werden.
In einer Elm-Anwendung tendieren vor allem die Funktion `view` und `update` dazu lang bzw. unübersichtlich zu werden und bieten daher die häufigsten Ansatzpunkte für die Einführung von Hilfsfunktionen.
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

Wenn wir den Eindruck haben, dass die Funktion unübsichtlich wird, sollten wir versuchen, Teile der Funktion in Hilfsfunktionen auszulagern.
Das heißt, statt eine monolithische HTML-Struktur in der Funktion `view` zu erzeugen, identifizieren wir Teile, die wir in Funktionen auslagern können.
Es wäre zum Beispiel möglich, dass wir die Funktion wie folgt in Teile zerlegen. 
Wir gehen davon aus, dass wir ein Spiel implementieren, dessen visuelle Darstellung aus einem _Header_, einem _Footer_ und dem eigentlichen Spielbrett besteht.

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

Das heißt, wir nutzen logische Bestandteile der HTML-Seite, um Hilfsfunktionen zum Rendern dieser Teile zu idenfizieren.
Durch das Definieren von Hilfsfunktionen, haben wir nun statt einer großen Funktion, drei kleinere Funktionen.
Außerdem haben wir die Darstellung der HTML-Struktur in Teile zerlegt, die wir einzeln verstehen und verändern können.

Ein ähnliches Muster lässt sich auch auf die Funktion `update` anwenden.
Wenn die Funktion zu lang bzw. unübersichtlich wird, sollten wir die Funktion mithilfe von Hilfsfunktionen zerlegen.
Das heißt, statt alle Fälle explizt in der Funktion `update` zu behandeln, führen wir Hilfsfunktionen ein, die einen Teil der Logik übernehmen.

```elm
update : Msg -> Model -> Model
update msg model =
    case msg of
        ... ->
            updateUser msg model

        ...

        ... ->
            updateBoard msg model


updateUser : Msg -> Model -> Model
updateUser msg model =
    ...

updateBoard : Msg -> Model -> Model
updateBoard msg model =
    ...
```

## Modell strukturieren

In diesem Abschnitt wollen wir uns mit der Strukturierung von Modellen beschäftigen, da eine gute Struktur für eine Anwendung häufig mit einer guten Struktur für das Modell startet.
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
Außerdem hat der Spieler eine aktuelle Punktzahl und es gibt eine Highscore für das Spiel und den Vor- und Nachnamen der Spielerin mit dem Highscore.

Um die Wiederverwendbarkeit von Funktionen zu erhöhen, sollten sie nur die Informationen übergeben werden, die sie auch benötigen.
Das heißt, wenn die Funktionen `viewHeader`, `viewBoard` und `viewFooter` nur Teile des Modells benötigen, sollten auch nur diese Teile übergeben werden.
Da unser Modell flach ist, müssten wir die einzelnen Felder, die benötigt werden als einzelne Argumente an die Funktionen übergeben.
Stattdessen sollten wir an dieser Stelle die Gelegenheit nutzen, um zu identifizieren, ob unser Modell besser strukturiert werden kann.

Wir observieren zuerst, dass Vor- und Nachname zusammen einen Benutzer definieren.
Außerdem observieren wir, dass die Position des Spielers und die Positionen der Gegner das Spielbrett definieren.
Wir erhalten dadurch die folgende Struktur.

```elm
type User =
    { firstName : String
    , lastName : String
    }


type Board =
    { position : Int
    , enemies : List Point
    }


type Model =
    { user : User
    , points : Int
    , board : Board
    , highscoreUser : User
    , highscore : Int
    }
```

Welche Struktur am besten geeignet ist, hängt sehr davon ab, welche Daten wir zusammen verarbeiten wollen.
Wenn die Punktzahl zum Beispiel sehr eng an Nutzer\*innen gekoppelt ist, da in der Anwendung beide Informationen immer zusammen auftreten, könnte es sinnvoll sein, das Feld `points` ebenfalls zum Record `User` hinzuzufügen.

Mit der gewählten Strukturierung des Modells können wir die Typen der Funktionen `viewHeader`, `viewBoard` und `viewFooter` nun wie folgt spezialisieren.
Die Funktionen arbeiten nun nur noch auf einem Teil des Modells.

```elm
view : Model -> Html Msg
view model =
    div []
        [ viewHeader model.user model.points
        , viewBoard model.board
        , viewFooter model.highscoreUser model.highscore
        ]


viewHeader : User -> Int -> Html Msg
viewHeader user score =
    ...


viewBoard : Board -> Html Msg
viewBoard board =
    ...


viewFooter : User -> Int -> Html Msg
viewFooter user highscore =
    ...
```

Ähnlich wie bei der Funktion `view`, können wir auch die Hilfsfunktionen, die wir in `update` definiert haben, spezialisieren.


```elm
update : Msg -> Model -> Model
update msg model =
    case ... of
        ... ->
            let
                newUser =
                    setFirstName firstname model.user

                newBoard =
                    movePlayer newPoint model.board

            in
            { model | user = newUser, board = newBoard }

        ...


setFirstName : String -> User -> User
setFirstName firstName user =
    ...

movePlayer : Point -> Board -> Board
movePlayer msg model =
    ...
```

Da die Hilfsfunktionen jetzt nur noch auf einem Teil des Modells arbeiten, lassen sich die Funktionen noch besser modular verwenden.
Wir können jetzt zum Beispiel die Veränderung des Modells in mehrere unabhängige Veränderungen zerlegen.
Hierbei ist sehr wichtig, dass die Veränderungen unabhängig voneinander sind.
Wir können ein ähnliches Ergebnis auch erreichen, wenn wir zwei Funktionen nacheinander anwenden, die das komplette Modell als Argument erhalten.
Das heißt, wir könnten `update` zum Beispiel wie folgt definieren.

```elm
update : Msg -> Model -> Model
update msg model =
    case ... of
        ... ->
            updateUser msg (updateBoard msg model)

        ...
```

In dieser Implementierung haben wir aber keinerlei Garantie, dass die Änderungen unabhängig voneinander sein.
So kann `updateUser` zum Beispiel einen Wert überschreiben, der zuvor schon von `updateBoard` geändert wurde.
Auf diese Weise kann es zum Beispiel wichtig sein, dass diese Funktionen in der richtigen Reihenfolge ausgeführt werden.
All diese Eigenschaften führen mittel- oder langfristig häufig zu schlechtem Code.
Daher sollten unabhängige Änderungen nicht nacheinander durchgeführt werden.


## Nachrichten strukturieren

Wir wollen nur einen Blick darauf werfen, wie wir einen komplexen Nachrichtentyp strukturieren können.
Dazu betrachten wir das folgende Beispiel.

```elm
type Msg
    = SpaceKey
    | LeftKey
    | RightKey
    | UpKey
    | DownKey
    | FirstName String
    | LastName String
```

Die Anwendung kann verschiedene Tasten verarbeiten und es gibt die Möglichkeit den Vor- und den Nachnamen zu ãndern.

Auch in diesem Datentyp steckt eine geschachtelte Struktur, die sich auch schon etwas durch unsere Namensgebung ausdrückt.
Wir können diese Struktur wieder nutzen, um unsere Anwendung besser zu strukturieren.

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
    = Clicked Key
    | Changed Name
```

Die neue Struktur erlaubt es viel besser zu erkennen, dass die Anwendung zwei Arten von Interaktion erlaubt.
Außerdem können wir die Datentypen nutzen, um `update`-Funktionen, die auf unserem Modell arbeiten, zu spezialisieren.

```elm
update : Msg -> Model -> Model
update msg model =
    case msg of
        Clicked key ->
            { model | board = processKey key model.board }

        Changed name ->
            { model | user = changeName name model.user }


processKey : Key -> Board -> Board
processKey key board =
    ...


changeName : Name -> User -> User
changeName name user =
    ...
```

Diese Funktionen sind völlig unabhängig von unserem eigentlichen Modell.
Das heißt, wenn wir unserer Anwendung Änderungen vornehmen, die unabhängig von diesen Teilen der Anwendung sind, 

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="commands.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="abstractions.html">weiter</a></li>
    </ul>
</div>