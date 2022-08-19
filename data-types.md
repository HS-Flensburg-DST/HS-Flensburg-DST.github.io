Datentypen
==========

In diesem Kapitel wollen wir die Grundlagen für die Definition von
Datentypen in Elm einführen. Wir haben bereits eine Reihe von Datentypen
kennengelernt, zum Beispiel Listen und Aufzählungstypen. In diesem
Kapitel werden wir zum Beispiel lernen, wie man einen Datentyp für
Listen in Elm definiert.

Algebraische Datentypen
-----------------------

An Stelle des Namen Aufzählungstyp verwendet man auch den Namen
Summentyp. Dieser Name zeigt auch den Zusammenhang zum Namen
algebraische Datentypen auf. Eine Algebra ist in der Mathematik eine
Struktur, die eine Addition und eine Multiplikation zur Verfügung
stellt. Neben der Addition (dem Summentyp) benötigen wir für einen
algebraischen Datentyp also noch eine Multiplikation (den Produkttyp).

In Elm kann man sogenannte Produkttypen definieren, die benannten Paaren
entsprechen. So kann man zum Beispiel auf die folgende Weise einen
Datentyp für einen Punkt, zum Beispiel auf einer 2D-Zeichenfläche,
definieren.

``` elm
type Point
    = Point Float Float
```

Dieser Datentyp ist im Endeffekt nichts anderes als ein benanntes Paar.
Auch im Fall von `Point` spricht man von einem Konstruktor. Das heißt,
`Point` ist ein Konstruktor des Datentyps `Point`.

Hinter dem Namen des Konstruktors folgt ein Leerzeichen und anschließend
folgen, durch Leerzeichen getrennt, die Typen der Argumente des
Konstruktors. Im Gegensatz zu Funktionen und Variablen müssen
Konstruktoren und Datentypen immer mit einem großen Anfangsbuchstaben
beginnen. Das heißt, der Konstruktor `Point` erhält zwei Argumente, die
beide den Typ `Float` haben. Um mit Hilfe eines Konstruktors einen Wert
zu erzeugen, benutzt man den Konstruktor wie eine Funktion. Das heißt,
man schreibt den Namen des Konstruktors und durch Leerzeichen getrennt
die Argumente des Konstruktors. Wir können nun zum Beispiel wie folgt
einen Punkt definieren.

``` elm
examplePoint : Point
examplePoint =
    Point 2.3 4.2
```

Wie im Fall von Aufzählungstypen kann man auch auf Produkttypen *Pattern
Matching* durchführen. Im Fall von Produkttypen kann man mit Hilfe des
Pattern Matching nicht nur eine Fallunterscheidung durchführen, sondern
auch auf die Inhalte des Konstruktors zugreifen. Die folgende Funktion
verschiebt einen Punkt um einen Wert auf der x- und einen Wert auf der
y-Achse.

``` elm
translate : Point -> Float -> Float -> Point
translate point dx dy =
    case point of
        Point x y ->
            Point (x + dx) (y + dy)
```

Alternativ können wir zum Beispiel die folgende Funktion definieren, um
einen `Point` in einen `String` umzuwandeln.

``` elm
toString : Point -> String
toString point =
    case point of
        Point x y ->
            "(" ++ String.fromFloat x
                ++ ", "
                ++ String.fromFloat y
                ++ ")"
```

In der Definition eines Produkttyps können wir natürlich auch
selbstdefinierte Datentypen verwenden. Wir betrachten zum Beispiel
folgenden Datentyp, der einen Spieler in einem Spiel modelliert, der
einen Namen und eine aktuelle Position hat.

``` elm
type Player
    = Player String Point
```

Als Beispiel können wir nun einen `Player` definieren.

``` elm
examplePlayer :: Player
examplePlayer =
    Player "Player A" (Point 10 100)
```

Wir können nun zum Beispiel eine Funktion definieren, die den Namen
eines Spielers liefert.

``` elm
name : Player -> String
name player =
    case player of
        Player n _ ->
            n
```

Der Unterstrich bedeutet, dass wir uns für das entprechende Argument des
Konstruktors, hier also den `Point`, nicht interessieren. Wenn wir
stattdessen, an die Stelle des Argumentes eines Konstruktors eine
Variable schreiben, wird die Variable an den Wert gebunden, der an der
ensprechenden Stelle im Konstruktor steht. Im Fall von `name` wird die
Variable zum Beispiel an den Namen gebunden, der im `Player` steht.

Als weiteres Beispiel können wir auch eine Funktion zur Umwandlung eines
Spielers in einen String schreiben.

``` elm
toString : Player -> String
toString player =
    case player of
        Player pname point ->
            pname ++ " " ++ Point.toString point
```

Im Allgemeinen kann man Summen- und Produkttypen auch kombinieren. Die
Kombination aus Summen- und Produkttypen wird als algebraischer Datentyp
bezeichnet. Manchmal spricht man bei diesen Datentypen auch von einer
*tagged union*. Man spricht von einer *union*, da der algebraische
Datentyp wie bei einem Aufzählungstyp in der Lage ist, verschiedene
Fälle abzubilden. Die verschiedenen Fälle, die es gibt, werden dann in
dem algebraischen Datentyp zu einem einzigen Datentyp vereinigt. Man
bezeichnet diese Vereinigung als *tagged*, da durch den Konstruktor
markiert wird, um welchen Teil der Vereinigung es sich handelt. Wir
können zum Beispiel wie folgt einen Datentyp definieren, der beschreibt,
ob ein Spiel unentschieden ausgegangen ist oder ob ein Spieler das Spiel
gewonnen hat. Der Konstruktor `Win` modelliert, dass einer der Spieler
gewonnen hat. Wenn die Spielrunde unentschieden ausgegangen ist, liefert
die Funktion als Ergebnis den Wert `Draw`. Da wir in diesem Fall keine
zusätzlichen Informationen benötigen, hat der Konstruktor keine
Argumente.

``` elm
type GameResult
    = Win Player
    | Draw
```

Pattern Matching
----------------

Wir haben gesehen, dass man *Pattern Matching* nutzen kann, um
Fallunterscheidungen über Zahlen zu treffen. Man kann *Pattern Matching*
außerdem nutzen, um die verschiedenen Fälle eines Aufzählungstyps zu
unterscheiden. Man kann *Pattern Matching* aber auch ganz allgemein
nutzen, um die verschiedenen Konstruktoren eines algebraischen Datentyps
zu unterscheiden. Wir können zum Beispiel wie folgt eine Funktion
`isDraw` definieren, um zu überprüfen, ob ein Spiel unentschieden
ausgegangen ist.

``` elm
isDraw : GameResult -> Bool
isDraw result =
    case result of
        Draw ->
            True

        Win _ ->
            False
```

Diese Funktion liefert `True`, falls das `GameResult` gleich `Draw` ist
und `False` andernfalls. Der Unterstrich besagt, dass uns egal ist, was
an dieser Stelle in dem Wert steht. Das heißt, mit dem Muster `Win _`
sagen wir, diese Regel soll genommen werden, wenn der Wert in `result`
ein `Win`-Konstruktor mit einem beliebigen Argument ist. An Stelle des
Unterstrichs können wir auch eine Variable verwenden, das heißt, statt
`Win _` können wir auch `Win player` schreiben. Wir können zum Beispiel
wie folgt eine Funktion definieren, die zu einem Spiel-Ergebnis eine
Beschreibung in Form eines `String`s liefert.

``` elm
description : GameResult -> String
description result =
    case result of
        Draw ->
            "Das Spiel ist unentschieden ausgegangen."

        Win player ->
            Player.name player ++ " hat das Spiel gewonnen."
```

In diesem Fall wird die Variable `player` an den Wert vom Typ `Player`
gebunden, der im Konstruktor `Win` steht.

*Pattern* können auch geschachtelt werden. Das heißt, an Stelle einer
Variable, können wir auch wieder ein *Pattern* verwenden. Die folgende
Funktion verwendet zum Beispiel ein geschachteltes *Pattern*, um die
x-Position eines Spielers zu bestimmen.

``` elm
playerXCoord : Player -> Float
playerXCoord player =
    case player of
        Player _ (Point x _) ->
            x
```

Als weiteres Beispiel für ein geschachteltes Pattern wollen wir eine
Funktion definieren, die einen `String` liefert, der beschreibt, wie ein
Spiel ausgegangen ist.

``` elm
description : GameResult -> String
description result =
    case result of
        Draw ->
            "Das Spiel ist unentschieden ausgegangen."

        Win (Player name _) ->
            name ++ " hat das Spiel gewonnen."
```

Wenn wir zum Beispiel den Aufruf `description player` in der REPL
auswerten[1], erhalten wir das folgende Ergebnis.

``` elm
> description (Win player)
"Spieler A hat das Spiel gewonnen." : String
```

Das heißt, der Aufruf `description (Win player)` hat das Ergebnis

`"Spieler A hat das Spiel gewonnen."`

geliefert und dieses Ergebnis ist vom Typ `String`.

Ein `case`-Ausdruck wird für zwei Aufgaben genutzt. Zum einen führen wir
eine Fallunterscheidung über die möglichen Konstruktoren eines Datentyps
durch. Zum anderen zerlegen wir Konstruktoren in ihre Einzelteile. Bei
Datentypen, die nur einen Konstruktor zur Verfügung stellen, wie etwa
der Typ `Point`, müssen wir keine Fallunterscheidung über die
verschiedenen Konstuktoren durchführen. Daher kann man ein *Pattern* für
Datentypen mit nur einem Konstuktor auch ohne einen `case`-Ausdruck
verwenden. Die folgende Funktion liefert zum Beispeil die X-Koordinate
eines Punktes.

``` elm
xCoord : Point -> Float
xCoord (Point x _) =
    x
```

Rekursive Datentypen
--------------------

Datentypen können auch rekursiv sein. Das heißt, wie eine rekursive
Funktion kann ein Datentyp in seiner Definition wieder auf sich selbst
verweisen. Wir können zum Beispiel wie folgt einen Datentypen
definieren, der Listen mit Integern darstellt. In der funktionalen
Programmierung haben sich die Namen *Nil* für eine leere Liste und
*Cons* für eine nicht-leere Liste eingebürgert. Das Wort *Nil* ist eine
Kurzform des lateinischen Wortes *nihil*, das “nichts” bedeutet.

``` elm
type IntList
    = Nil
    | Cons Int IntList
```

Wir wollen einmal eine Funktion definieren, die die Länge einer solchen
Liste berechnet. Wir können diese Funktion ebenfalls rekursiv
definieren, indem wir *Pattern Matching* verwenden.

``` elm
length : IntList -> Int
length list =
    case list of
        Nil ->
            0

        Cons _ restlist ->
            1 + length restlist
```

Als weiteres Beispiel zeigt die folgende Funktion, wie wir die Zahlen in
einer Liste aufaddieren können.

``` elm
sum : IntList -> Int
sum list =
    case list of
        Nil ->
            0

        Cons int restlist ->
            int + sum restlist
```

Als nächstes wollen wir eine Funktion definieren, die zu einer Liste
eine Liste berechnet, die jedes zweite Element der Originalliste
enthält.

``` elm
everySecond : IntList -> IntList
everySecond list =
    case list of
        Nil ->
            Nil

        Cons _ Nil ->
            Nil

        Cons _ (Cons int restlist) ->
            Cons int (everySecond restlist)
```

Als Abschluss für rekursive Funktionen auf Listen wollen wir eine
Funktion definieren, die zwei Listen hintereinanderhängt. Diese Funktion
wird klassischerweise als `append` bezeichnet.

``` elm
append : IntList -> IntList -> IntList
append list1 list2 =
    case list1 of
        Nil ->
            list2

        Cons x xs ->
            Cons x (append xs list2)
```

Wir wollen an dieser Stelle auch ganz kurz das Speichermodell und die
Laufzeit von Funktionen in Elm diskutieren. Das Aufrufen eines
Konstruktors so wie Pattern Matching sind konstante Operationen. Das
heißt, die Laufzeit der Funktion `append` ist linear in der Länge der
ersten Liste.

Als weiteres Beispiel eines rekursiven Datentyps wollen wir uns eine
Baumstruktur anschauen. Der folgende Datentyp stellt zum Beispiel einen
binären Baum mit ganzen Zahlen in den Knoten dar.

``` elm
type IntTree
    = Empty
    | Node IntTree Int IntTree
```

Die folgende Definition gibt einen Wert dieses Typs an.

``` elm
tree : IntTree
tree =
    Node (Node Empty 3 (Node Empty 5 Empty)) 8 Empty
```

Wir können zum Beispiel wie folgt eine Funktion schreiben, die testet,
ob ein Eintrag in einem Baum vorhanden ist.

``` elm
find : Int -> IntTree -> Bool
find n tree =
    case tree of
        Empty ->
            False

        Node leftree int righttree ->
            n == int |\mintinline{elm}{ find n leftree }| find n righttree
```

Im Unterschied zur Programmiersprache Haskell ist Elm eine strikte
Sprache, nutzt also *call-by-name* als Auswertungsstrategie. Das heißt,
bei Definitionen wie `find` müssen wir beachten, dass rekursive auch
durchgeführt werden, wenn ihr Ergebnis ggf. gar nicht benötigt wird. In
Elm, wie in vielen anderen Sprachen, sind die logischen Operatoren
@`\mintinline{elm}{@ und }&&` als Kurzschlussoperatoren definiert. Das
heißt, der rekursive Aufruf `find n lefttree` wird nur durchgeführt,
falls die Bedingung `n == int` nicht erfüllt ist.

[1] Wobei `player` die oben definierte Konstante ist.

<div style="display:table;width:100%">
    <ul style="display:table-row;list-style:none">
        <li style="display:table-cell;width:33%;text-align:left"><a href="first-application.html">zurück</a></li>
        <li style="display:table-cell;width:33%;text-align:center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li style="display:table-cell;width:33%;text-align:right"><a href="polymorphism.html">weiter</a></li>
    </ul>
</div>