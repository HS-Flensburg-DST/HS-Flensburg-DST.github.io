---
layout: post
title: "Strukturierung einer Anwendung"
---

In diesem Kapitel werden mehrere Aspekte der Strukturierung einer Elm-Anwendung diskutiert.
Die Struktur des Modells einer Anwendung geht dabei sehr stark mit einer guten Modularisierung der Anwendung einher.
Das heißt, ein gut strukturiertes Modell führt häufig zu einer guten Aufteilung der Anwendung in mehrere Module und ein schlecht strukturiertes Modell führt zu einer monolithischen Anwendung oder zu einer Aufteilung in Module, die schlecht wartbar ist.
In einer sehr einfachen Elm-Anwendung kann das Modell häufig mithilfe eines flachen Records dargestellt werden, also einem Record, der als Felder nur vordefinierte Datentypen verwendet.
Wenn die Anwendung komplexer wird, verhindert ein solcher flacher Record aber häufig eine gute Modularisierung.
Viele der Beispiele in diesem Kapitel sind durch den Vortrag [Scaling Elm Apps](https://www.youtube.com/watch?v=DoA4Txr4GUs) von Richard Feldman inspiriert.


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
Durch das Definieren von Hilfsfunktionen, haben wir nun statt einer großen Funktion, drei kleinere Funktionen.
Außerdem haben wir die Darstellung der HTML-Struktur in Teile zerlegt, die wir einzeln verstehen und verändern können.

{% include callout-important.html content="
Funktionen wie `viewHeader`, `viewBoard` und `viewFooter` zu definieren, die nur einen Teil des Modells benötigen, aber das gesamte Modell erhalten, ist schlechter Stil.
" %}

Insbesondere verhindern wir auf diese Weise, dass wir die Funktionen wiederverwenden können.
Wir können die Funktionen aktuell nur aufrufen, wenn wir ein komplettes `Model` zur Verfügung haben.
Dadurch können wir die Funktionen aber nicht mehr Aufrufen, obwohl wir ggf. alle Informationen zur Verfügung haben, welche die Funktionen benötigen.
Wir werden später in diesem Kapitel illustrieren, wie wir diesen Aspekt der Modellierung verbessern können.

Wir können versuchen, ein ähnliches Muster auch auf die Funktion `update` anzuwenden.
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
Daher sollten Funktionen, die auf dem kompletten Modell arbeiten **nicht** nacheinander auf das Modell angewendet werden.
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
    | FirstName String
    | LastName String
```

Die Anwendung kann verschiedene Tasten verarbeiten und es gibt die Möglichkeit den Vor- und den Nachnamen zu ändern.

In diesem Datentyp steckt eine geschachtelte Struktur, die sich auch schon etwas durch unsere Namensgebung ausdrückt.
Wir können diese Struktur nutzen, um unsere Anwendung besser zu strukturieren.

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

Die neue Struktur erlaubt es viel besser zu erkennen, dass die Anwendung zwei Arten von Interaktionen ermöglicht.
Außerdem können wir die neuen Datentypen nutzen, um die `update`-Funktion durch Hilfsfunktionen zu strukturieren.

```elm
update : Msg -> Model -> Model
update msg model =
    case msg of
        Clicked key ->
            processKey key model

        Changed name ->
            changeName name model


processKey : Key -> Model -> Model
processKey key model =
    ...


changeName : Name -> Model -> Model
changeName name model =
    ...
```


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

Um die Wiederverwendbarkeit von Funktionen zu erhöhen, sollte man Funktionen nur die Informationen übergeben, die sie auch benötigen.
Das heißt, wenn die Funktionen `viewHeader`, `viewBoard` und `viewFooter` aus Abschnitt [Funktionen strukturieren](#funktionen-strukturieren) nur Teile des Modells benötigen, sollten auch nur diese Teile übergeben werden.
Da unser Modell flach ist, müssten wir die einzelnen Felder, die benötigt werden als einzelne Argumente an die Funktionen übergeben.
Stattdessen sollten wir an dieser Stelle die Gelegenheit nutzen, um zu überprüfen, ob unser Modell besser strukturiert werden kann.

Wir observieren zuerst, dass Vor- und Nachname zusammen Benutzer\*innen definieren.
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
Wir können an den Typen der Funktionen bereits identifizieren, dass der _Header_ den `User` und die Punktzahl anzeigt und der _Footer_ den _Highscore_ und den `User` mit dem _Highscore_.

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

Ähnlich wie bei der Funktion `view`, können wir durch die Strukturierung des Modells die `update`-Funktionen, die wir zuvor definieren haben, nun auf Teile des Modell spezialisieren.

```elm
update : Msg -> Model -> Model
update msg model =
    case msg of
        Click key ->
            { model | board = processKey key model.board }

        Change name ->
            { model | user = changeName name model.user }


processKey : Key -> Board -> Board
processKey key board =
    ...


changeName : Name -> User -> User
changeName name user =
    ...
```

Die Funktionen `processKey` und `changeName` arbeiten nun nur noch auf einem Teil des Modells.
Dieser Teil des Modells kann ggf. nun auch in ein eigenes Modul ausgelagert werden, da die Logik der Funktionen häufig unabhängig von der konkreten Anwendung sind.

Ein weiterer Vorteil dieser Art der Strukturierung ist, dass nun nicht nur Hilfsfunktionen für verschiedene Nachrichten einführen können.
Da die Hilfsfunktionen jetzt nur noch auf einem Teil des Modells arbeiten, können wir jetzt in einem Fall auch mehrere Hilfsfunktionen verwenden.
Wenn wir mehrere Änderungen am Modell vornehmen möchten, könnte unsere Anwendung zum Beispiel wie folgt aussehen.

```elm
update : Msg -> Model -> Model
update msg model =
    case ... of
        ... ->
            { model
                | user = changeName key model.user
                , board = processKey name model.board
            }

        ...


processKey : Key -> Board -> Board
processKey key board =
    ...


changeName : Name -> User -> User
changeName name user =
    ...
```

Im Unterschied zu Funktionen, die auf dem gesamten Modell arbeiten, sind die Funktionen `processKey` und `changeName` offensichtlich unabhängig voneinander, da sie auf disjunkten Teilen des Modells arbeiten.
Diese Form der Strukturierung mithilfe von Funktionen können wir nur erreichen, wenn wir den Modell-Datentyp strukturieren.


## Fehlerbehandlung

Am Ende dieses Kapitels wollen wir uns noch über ein wichtiges Thema in jeder Anwendung unterhalten, über die Behandlung von Fehlern.
An dieser Stelle wird ein _Code Smell_[^1] vorgestellt, der bei Anfänger\*innen in der funktionalen Programmierung häufig auftritt.
Wir haben im Kapitel [Polymorphismus](polymorphism.md) gelernt, dass man einen fehlenden Wert in der funktionalen Programmierung durch den Datentyp `Maybe` modellieren sollte.
Zum Beispiel könnte es sein, dass unser Modell einen Wert vom Typ `Maybe Int` enthält.
Wenn dieser Wert nun benötigt wird, tendieren viele Anfänger\*innen dazu, die Funktion `Maybe.withDefault` (oder eine entsprechende Logik mittels _Pattern Matching_) zu nutzen, um auf jeden Fall einen Wert zur Verfügung zu haben.
Einen fehlenden Wert durch einen _Default_-Wert zu ersetzen ist aber nur in wenigen Fällen sinnvoll.
Wir wollen an dieser Stelle ein paar Klassen von Fällen diskutieren, in denen wir ggf. mit einem `Maybe`-Datentyp arbeiten.

### Fehlerhafte Nutzereingabe

Es kann vorkommen, dass die Eingabe von Nutzer\*innen nicht den Erwartungen entspricht.
Dieser Fall tritt vor allem auf, wenn Eingaben über ein Textfeld getätigt werden können.
Falls die Eingabe nicht den Anforderungen entspricht, sollte ein erklärender Fehler angezeigt und zu einer erneuten Eingabe aufgefordert werden.
Das heißt, die Information, dass ein Wert nicht vorhanden ist, sollte bis zur Nutzerschnittstelle propagiert werden.
Somit sollte der `Maybe`-Wert nicht verworfen, sondern bis zur `view`-Funktion propagiert werden.

Der folgende Ausschnitt aus einer Elm-Anwendung illustriert noch einmal das Beispiel.

{% include callout-important.html content="
Dieses Beispiel illustriert einen _Code Smell_.
Die Funktion `Maybe.withDefault` sollte nicht auf diese Weise in einer Anwendung verwendet werden.
" %}

```elm
type alias Model =
    { choosenNumber : Float }


type Msg
    = UpdateInput String


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateInput input ->
            { model | choosenNumber = Maybe.withDefault 0.0 (String.toFloat input)
            }
```

Hier wird die Information, dass die Eingabe keine Zahl war einfach verworfen und durch einen _Default_-Wert ersetzt.
Daher kann diese Information auch niemals an die Nutzerschnittstelle gelangen.


### Fehlgeschlagene Anfrage

Die Anfrage an einer externe Ressource kann aus verschiedenen Gründen fehlschlagen.
Beispiele sind etwa, dass das Netz kurzzeitig nicht zur Verfügung steht oder dass es einen _Timeout_ bei einer Anfrage gab.
In diesem Fall sollte auf jeden Fall darauf hingewiesen werden, dass Informationen nicht angezeigt werden können.
Daher muss der `Maybe`-Wert hier ebenfalls bis zur `view`-Funktion propagiert werden.
Es muss unterschieden werden, ob die fehlenden Daten für die weitere Funktionalität der Anwendung wichtig sind.
Falls die Anwendung nicht sinnvoll fortgeführt werden kann, sollte es eine Möglichkeit geben, die Anfrage zu wiederholen.
Das heißt, es gibt zum Beispiel einen Knopf, der dafür sorgt, dass die Anfrage erneut durchgeführt wird.

Der folgende Ausschnitt aus einer Elm-Anwendung illustriert noch einmal das Beispiel.
Im Fall einer fehlgeschlagenen Anfrage wird in den meisten Fällen der Typ `Result` und nicht `Maybe` verwendet, da die `http`-Bibliothek diesen zur Verfügung stellt.

{% include callout-important.html content="
Dieses Beispiel illustriert einen _Code Smell_.
Die Funktion `Result.withDefault` sollte nicht auf diese Weise in einer Anwendung verwendet werden.
" %}

```elm
type alias Model =
    { number : Int
    , isEven : Bool
    }


type Msg
    = CheckNumber
    | Received (Result Http.Error Bool)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CheckNumber ->
            ( model
            , isEvenCmd model.number )

        Received result ->
            ( { model | isEven = Result.withDefault False result }
            , Cmd.none )
```

In diesem Beispiel wird die Information, dass Daten fehlen ebenfalls verworfen, bevor sie im Modell gespeichert werden.
Daher kann diese Information bei einer solchen Implementierung nicht angezeigt werden.


### Nicht-erfüllte Invarianten

In einer Anwendung gibt es häufig Invarianten, bei deren Nicht-Erfüllen die Anwendung nicht sinnvoll fortgeführt werden kann.
Dies kann zum Beispiel passieren, wenn in einer Liste ein Element mit einer bestimmten Eigenschaft gesucht, aber nicht gefunden wird.
Wenn eine solche Invariante nicht erfüllt ist, bedeutet das in den allermeisten Fällen, dass ein Bug in der Anwendung vorliegt.
Auch in diesem Fall sollte die Information, dass es einen internen Fehler gibt, an die Nutzerschnittstelle propagiert werden.
In einer produktiven Anwendung sollte die Information außerdem an einen Logging-Server weitergegeben werden, damit das Problem untersucht werden kann.

Der folgende Ausschnitt aus einer Elm-Anwendung illustriert noch einmal das Beispiel.

{% include callout-important.html content="
Dieses Beispiel illustriert einen _Code Smell_.
Die Funktion `Maybe.withDefault` sollte nicht auf diese Weise in einer Anwendung verwendet werden.
" %}

```elm
type alias User =
    { id : Int
    , name : String
    }


findNameById : Int -> List User -> String
findNameById targetId users =
    Maybe.withDefault "" (List.head (List.filter (\user -> user.id == targetId) users))
```

Hier wird die Information, dass der `User` nicht gefunden wurde, "weit unten" in der Anwendung verworfen.
Daher kann diese Information nie an die Nutzerschnittstelle gelangen.

Alle drei Beispiele haben gemeinsam, dass der `Nothing`-Fall verworfen wird, bevor er im Modell gespeichert wird.
In allen drei Fällen sollte diese Information aber zur `view`-Funktion gelangen.
Zur `view`-Funktion kann die Information aber nur gelangen, wenn sie in irgendeiner Form im Modell gespeichert wird.
Wir müssen die Information nicht notwendigerweise durch einen `Maybe`-Typ im Modell kodieren.
Zum Beispiel könnte das Modell einen eigenen Konstruktor haben, der kodiert, dass Informationen fehlen.
In allen drei Beispielen wird der `Nothing`-Fall aber auf einen ansonsten validen Wert abgebildet, nämlich auf `0.0`, `False` und `""`.
In diesen Fällen können wir also später auf jeden Fall nicht mehr unterscheiden, ob der Wert `False` durch `Just False` oder durch `Nothing` entstanden ist.
Das heißt, wir verwerfen in diesen Fällen Information.
Dies sollte nie geschehen.
Stattdessen sollte diese Information bis zur Nutzerschnittstelle, also bis zur `view`-Funktion erhalten bleiben.

<!-- ### Modellierung eines _Default_-Falles

Es gibt einen Fall, in dem es sinnvoll ist, einen `Maybe`-Wert durch eine Funktion wie `Maybe.withDefault` zu behandeln.
Diese ist der Fall, wenn der `Maybe`-Wert tatsächlich genutzt wird, um einen _Default_-Fall zu modellieren.
Zum Beispiel wäre es möglich, dass Nutzer\*innen auch die Option haben, keinen Wert auszuwählen.
Dies kann zum Beispiel bei _Dropdown_-Auswahlen der Fall sein.
In diesem Fall würde der Wert `Nothing` tatsächlich ausdrücken, dass ein _Default_-Wert verwendet werden soll und somit ist es natürlich auch sinnvoll, den `Nothing`-Fall mithilfe einer Funktion wie `Maybe.withDefault` zu behandeln.

```elm
type alias Model =
    { selectedOption : Maybe String }


type Msg
    = SelectOption String


init : Model
init =
    { selectedOption = Nothing }


update : Msg -> Model -> Model
update msg model =
    case msg of
        SelectOption newOption ->
            { model | selectedOption = Just newOption }


view : Model -> Html Msg
view model =
    div []
        [ select [ onInput SelectOption ] (options model.selectedOption)
        , text ("Ausgewählte Option: " ++ Maybe.withDefault "keine" model.selectedOption)
        ]
``` -->

[^1]: [Wikipedia-Artikel zum Thema _Code Smell_](https://de.wikipedia.org/wiki/Code-Smell)

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="commands.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="abstractions.html">weiter</a></li>
    </ul>
</div>
