---
layout: post
title: "Programmierregeln"
---

Wenn Sie die Laboraufgabe bearbeiten, erhalten Sie automatisiert Feedback zum Programmierstil.
Auf dieser Seite werden einige der Programmierregeln erläutert, die durch den Linter angemerkt werden.


1. [Name einer Regel](#name-einer-regel)

2. [Regeln](#regeln)

    1. [NoForbiddenFeatures](#noforbiddenfeatures)

    2. [NoMinimalUnderscorePattern](#nominimalunderscorepattern)

    3. [UseRecordUpdate](#userecordupdate)

    4. [RemoveCodeDuplication](#removecodeduplication)

    5. [NoUnnecessaryReconstruction](#nounnecessaryreconstruction)

<br/>

## Name einer Regel

Die Stil-Anmerkungen des Linters beinhalten neben der kurzen Beschreibung auch Informationen darüber, in welcher Datei der Verstoß gefunden wurde, und vor allem, gegen welche Regel verstoßen wurde.
Im Folgenden Bild ist zu sehen, wo man den Namen der Regel findet.
![Namen finden](assets/images/check-name.png) 


## Regeln

Bei Programmierregeln gibt es keine Kategorien wie richtig und falsch.
Man kann auch gute Programme schreiben, die sich nicht an die folgenden Regeln halten.
Außerdem hängt die Lesbarkeit von Programmen auch sehr von der Erfahrung der Lesenden ab.
Viele dieser Regeln sorgen aber dafür, dass die Programme eine einfachere Struktur erhalten.
Am Ende sollen die Regeln auch dafür sorgen, dass Sie sich bewusst werden, dass es verschiedene Möglichkeiten gibt, ein Programm zu schreiben und man beim Programmieren reflektieren sollte, welche der Möglichkeiten am besten geeignet ist, um ein gut lesbares und wartbares Programm zu schreiben.
Grundsätzlich sollte man immer Konsistenz anstreben.
Das heißt, wenn es zweimal eine ähnliche Funktion gibt, sollten diese auch ähnlich implementiert sein.
Wenn man dagegen bei einer der Funktion eine andere Implementierung wählt, erwarten Lesende, dass dieser Unterschied einen inhaltlichen Grund hat.


### NoForbiddenFeatures

Zur Lösung der Laboraufgaben sollen nur die Sprach-Features von Elm verwendet werden, die in der Vorlesung schon vorgestellt wurden.
Die Laboraufgaben sollen häufig den Umgang mit bestimmten Features der Sprache trainieren.
Dafür ist es aber wichtig, dass diese Features der Sprache auch tatsächlich zur Lösung der Aufgabe verwendet werden.
Dabei gilt immer der Umfang der Sprache, der vor der Ausgabe der Aufgabe bekannt war.

Sprach-Features wie algebraische Datentypen, Polymorphismus, Funktionen höherer Ordnung und lokale Definitionen sollen erst verwendet werden, wenn diese auch in der Vorlesung behandelt wurden.

Die Funktion `List.append` sollte nicht verwendet werden, da stattdessen der Operator `++` verwendet werden sollte.

Die Funktion `List.map` soll erst verwendet werden, wenn diese in der Vorlesung behandelt wurde.


### NoMinimalUnderscorePattern

Um diese Regel zu illustrieren, betrachten wir den folgenden Datentyp.

``` elm
type Key
    = Left
    | Right
    | Up
    | Down
```

Die folgende Funktion verwendet _Pattern Matching_ um zu testen, ob es sich um eine der horizontalen Richtungstasten handelt.

``` elm
isHorizontal : Key -> Bool
isHorizontal key =
    case key of
        Up ->
            False

        Down ->
            False

        _ ->
            True
```

Die Verwendung des Unterstrich\-_Pattern_ hat zwei Nachteile.
Der erste Nachteil besteht darin, dass Funktionen wie `isHorizontal` weiterhin funktionieren, wenn wir einen Konstruktor zum Datentyp `Key` hinzufügen.
Das heißt, wenn wir den Datentyp `Key` um einen Konstruktor erweitern, lässt sich das Programm weiterhin kompilieren, verhällt sich ggf. nur falsch.
Wenn wir dagegen in der Funktion `isHorizontal` alle Fälle explizit auflisten, erhalten wir vom Compiler einen Fehler, wenn wir einen weiteren Konstruktor hinzufügen, da wir dann nicht mehr alle Fälle in der Funktion `isHorizontal` abdecken.

Außerdem macht die Verwedung das Unterstrich\-_Pattern_ den Code sehr viel impliziter.
Das heißt, wir müssen ggf. aktiv nachschauen, welche Fälle durch den Unterstrich abgedeckt werden.
Daher sollte das Unterstrich\-_Pattern_ nur verwendet werden, wenn der Unterstrich viele Fälle abdeckt.
Wenn so wie in `isHorizontal` nur zwei Fälle abgedeckt werden, sollte man diese Fälle besser explizit auflisten.


### UseRecordUpdate

Die Regel **UseRecordUpdate** überprüft ob die Record-Update-Syntax in sinnvoller Weise verwendet wird.
Wir betrachten das folgende Beispiel eines Records, der Nutzer\*innen in einer Anwendung modelliert.

```elm
type alias User =
    { firstName : String
    , lastName : String
    }
```

Außerdem betrachten wir die folgende Funktionsdefinition.

```elm
changeFirstName : User -> String -> User
changeFirstName user firstName =
    { firstName = firstName, lastName = user.lastName }
```

Statt alle Felder des Records explizit zu setzen, sollten wir die Record-Update-Syntax wie folgt verwenden.

```elm
changeFirstName : User -> String -> User
changeFirstName user firstName =
    { user | firstName = firstName }
```

In dieser Variante ist es viel expliziter, welche Felder des Records tatsächlich einen neuen Wert erhalten.

Auf der anderen Seite betrachten wir die folgende Funktionsdefinition.

```elm
swapFirstAndLastName : User -> User
swapFirstAndLastName user =
    { user | firstName = user.lastName, lastName = user.firstName }
```

In der Funktion `swapFirstAndLastName` sollten wir keine Update-Record-Syntax verwenden, da alle Felder einen neuen Wert erhalten.
Wenn wir uns die Definition von `swapFirstAndLastName` anschen, entsteht aber der Eindruck, dass `user` noch Felder enthält, die übernommen werden.
Um diesen Eindruck zu vermeiden, sollten wir auf die Update-Record-Syntax verzichten und stattdessen den Record explizit neu konstruieren.


### RemoveCodeDuplication

Man sollte sich beim Programmieren bemühen, Code-Duplikation zu vermeiden.
Code-Duplikation bedeutet, dass ein Programm mehrere identische oder nahezu identische Abschnitte enthält.
Diese Regel identifiziert eine spezielle Form von Code-Duplikation.

Wir betrachten das folgende Code-Beispiel.

```elm
heatMapSquare : Int -> Svg Msg
heatMapSquare value =
    if value < 50 then
        drawSquare 100 Yellow

    else
        drawSquare 100 Red
```

Wir nehmen an, dass wir eine _Heat Map_ aus Quadraten zeichnen.
Die Farbe der Quadrate hängt von einem Zahlenwert ab.
Ab dem Wert `50` soll das Quadrat rot gezeichnet werden, ansonsten gelb.

Die Regel `RemoveCodeDuplication` würde bei dieser Funktion eine Code-Duplikation erkennen.
In beiden Fällen des `if`-Ausdrucks wird die Funktion `drawSquare` aufgerufen und in beiden Fällen wird als Seitengröße `100` übergeben.
Die Aufrufe unterscheiden sich nur darin, welche Farbe die Quadrate erhalten.
Daher kann die Definition wie folgt umgeformt werden.

```elm
heatMapSquare : Int -> Svg Msg
heatMapSquare value =
    drawSquare 100
        (if value < 50 then
            Yellow

         else
            Red
        )
```

Das heißt, wir können den Aufruf der Funktion `drawSquare` aus den Zweigen des `if`-Ausdrucks herausziehen.
Bei diesem Code ist viel klarer, in welcher Hinsicht sich die beiden Fälle unterscheiden, nämlich nur in Bezug auf die Farbe.

Die Anwendung dieser Regel führt nicht immer zu besser lesbarem Code.
Die Regel führt aber dazu, dass Invarianten, die im Code vorhanden sind, besser herausgearbeitet werden.
In diesem Beispiel hängt etwa nur die Farbe des Quadrates vom Zahlenwert ab, aber nicht die Form der Graphik.
Um diese Invariante expliziter im Code auszudrücken, kann es sinnvoll sein, nach dem Herausziehen eine zusätzliche Funktion zu definieren.
Wir können unser Beispiel etwa wie folgt definieren.

```elm
heatMapSquare : Int -> Svg Msg
heatMapSquare value =
    drawSquare 100 (heatMapColor value)


heatMapColor : Int -> Color
heatMapColor value =
    if value < 50 then
        Yellow

    else
        Red
```

In dieser Implementierung ist sofort ersichtlich, dass nur die Farbe des Quadrates vom Zahlenwert abhängt, die Form der Graphik sich aber nie ändert.


### NoUnnecessaryReconstruction

Diese Regel identifiziert Fälle in Elm, in denen ein Wert unnötigerweise zerlegt und anschließend wieder identisch zusammengebaut wird.
Wir betrachten die folgende nicht sehr sinnvolle Funktion.

```elm
padLeftOne : Char -> List Char -> List Char
padLeftOne newChar list =
    case list of
        [] ->
            [ newChar ]

        char :: chars ->
            char :: chars
```

Wir führen _Pattern Matching_ auf der Variable `list` durch und Zerlegen den Wert im Fall von `::` in die Komponenten `char` und `chars`.
Anschließend wird durch den Ausdruck `char :: chars` eine Liste konstruiert.
Diese neue Liste ist identisch zur Liste, die wir zuvor zerlegt haben.
Das heißt, wir zerlegen durch das _Pattern Matching_ den Wert, der in der Variable `list` steht zuerst in seine Einzelteile, nur um ihn anschließend wieder direkt identisch zu konstruieren.
In diesem Beispiel würde die Regel `NoUnnecessaryReconstruction` feuern.
Anstatt die Liste `char :: chars` neu zu konstruieren, können wir einfach `list` als Resultat zurückgeben.

```elm
padLeftOne : Char -> List Char -> List Char
padLeftOne newChar list =
    case list of
        [] ->
            [ newChar ]

        _ :: _ ->
            list
```

Diese Änderung spart einen Arbeitsschritt, nämlich das Konstruieren der Liste und Speicher, da für die neu konstruierte Liste Speicher benötigt wird.
Wichtiger ist allerdings, dass der Code durch die Änderungen genauer sein Verhalten widerspiegelt.
Die neue Definition drückt expliziter aus, dass wir im Fall der nicht-leeren Liste, die Liste belassen wie sie ist.
Diese Information war in der Originalvariante impliziter enthalten.
