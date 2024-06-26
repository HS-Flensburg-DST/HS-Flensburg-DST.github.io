---
layout: post
title: "Datentypen"
---

In diesem Kapitel wollen wir die Grundlagen für die Definition von Datentypen in Elm einführen.
Wir haben bereits eine Reihe von Datentypen kennengelernt, zum Beispiel Listen und Aufzählungstypen.
In diesem Kapitel werden wir zum Beispiel lernen, wie man einen Datentyp für Listen in Elm definiert.

Algebraische Datentypen
-----------------------

In diesem Abschnitt werden wir uns ansehen, wie man in Elm sogenannte **algebraische Datentypen**[^1] definieren kann.
Dazu wollen wir erst einmal den Namen algebraische Datentypen etwas analysieren.
Anstelle des Namens Aufzählungstyp verwendet man in der Programmiersprachentheorie (PLT)[^2] auch den Namen **Summentyp**.
Dieser Name zeigt einen Zusammenhang zum Namen algebraischer Datentyp.
Eine Algebra ist in der Mathematik eine Struktur, die eine Addition und eine Multiplikation zur Verfügung stellt.
Neben der Addition (dem Summentyp) benötigen wir für einen algebraischen Datentyp also noch eine Multiplikation.
Man nennt Datentypen, die diese Multiplikation modellieren Produkttypen.

Ein Produkttyp entspricht einem benannten Paar bzw. Tupel und wir auch Verbund genannt.
In der Programmiersprache C wird er zum Beispiel durch das Schlüsselwort `struct` erzeugt.
Das heißt, wie bei einem Paar kann man Werte von unterschiedlichen Typen zu einem Wert zusammenfassen.
Im Unterschied zu einem klassischen Paar kann man der Kombination von Werten aber noch einen Namen geben.
So kann man zum Beispiel auf die folgende Weise einen Datentyp für einen Punkt, zum Beispiel auf einer 2D-Zeichenfläche, definieren.

``` elm
type Point
    = Point Float Float
```

Der Datentyp `Point` fasst zwei Werte vom Typ `Float` zu einem Wert vom Typ `Point` zusammen.

{% include callout-important.html content="
Das Wort `Point` hinter dem Schlüsselwort `type` ist dabei der Name des **Typs**.
Das Wort `Point` hinter dem `=`-Zeichen nennt man wie bei den Aufzählungstypen einen **Konstruktor**.
" %}

Hinter dem Namen des Konstruktors folgt ein Leerzeichen und anschließend folgen, durch Leerzeichen getrennt, die Typen der Argumente des Konstruktors.
Im Gegensatz zu Funktionen und Variablen müssen Konstruktoren und Datentypen immer mit einem großen Anfangsbuchstaben beginnen.
Der Konstruktor `Point` erhält zwei Argumente, die beide den Typ `Float` haben.
Um mithilfe eines Konstruktors einen Wert zu erzeugen, benutzt man den Konstruktor wie eine Funktion.
Das heißt, man schreibt den Namen des Konstruktors und durch Leerzeichen getrennt die Argumente des Konstruktors.
Wir können nun zum Beispiel wie folgt einen Punkt erstellen.

``` elm
examplePoint : Point
examplePoint =
    Point 2.3 4.2
```

Wie im Fall von Aufzählungstypen kann man auch auf Produkttypen _Pattern Matching_ durchführen.
Im Fall von Produkttypen kann man mithilfe des _Pattern Matching_ auf die Inhalte des Konstruktors zugreifen.
Die folgende Funktion verschiebt einen Punkt um einen Wert auf der x- und einen Wert auf der y-Achse.

``` elm
translate : Point -> Float -> Float -> Point
translate point dx dy =
    case point of
        Point x y ->
            Point (x + dx) (y + dy)
```

Wenn wir ein _Pattern_ für einen Produkttyp angeben, muss das _Pattern_ die gleiche Struktur wie der entsprechende Wert haben.
Das heißt, im Fall von `Point` muss der Konstruktor _Point_ im _Pattern_ auch zwei Argumente haben.
Die Argumente des _Pattern_ sind im Fall von `translate` Variablen, nämlich `x` und `y`.
Wenn wir die Funktion `translate` zum Beispiel mit dem Wert `examplePoint` aufrufen, werden die Variablen `x` und `y` an die Werte an der entsprechende Stelle im Wert `examplePoint` gebunden.
Das heißt, die Variable `x` wird in diesem Beispiel an den Wert `2.3` und die Variable `y` an den Wert `4.2` gebunden.

Als weiteres Beispiel können wir etwa die folgende Funktion definieren, um einen `Point` in einen `String` umzuwandeln.

``` elm

toString : Point -> String
toString point =
    case point of
        Point x y ->
            String.concat
                [ "("
                , String.fromFloat x
                , ", "
                , String.fromFloat y
                , ")"
                ]
```

In der Definition eines Produkttyps können wir natürlich auch selbstdefinierte Datentypen verwenden.
Wir betrachten zum Beispiel folgenden Datentyp, der einen Spieler in einem Spiel modelliert, der einen Namen und eine aktuelle Position hat.

``` elm
type Player
    = Player String Point
```

Als Beispiel können wir nun einen `Player` definieren.

``` elm
examplePlayer :: Player
examplePlayer =
    Player "Player A" (Point 0 0)
```

Wir können nun zum Beispiel eine Funktion definieren, die den Namen eines Spielers liefert.

``` elm
playerName : Player -> String
playerName player =
    case player of
        Player name _ ->
            name
```

Der Unterstrich bedeutet, dass wir uns für das entsprechende Argument des Konstruktors, hier also den `Point`, nicht interessieren.
Wenn wir stattdessen, an die Stelle des Argumentes eines Konstruktors eine Variable schreiben, wird die Variable an den Wert gebunden, der an der entsprechenden Stelle im Konstruktor steht.
Im Fall von `playerName` wird die Variable `name` zum Beispiel an den Namen gebunden, der im `Player` steht.
Das heißt, wenn wir den Aufruf `playerName examplePlayer` betrachten, wird die Variable `name` an den Wert `"Player A"` gebunden.

Als weiteres Beispiel können wir auch eine Funktion zur Umwandlung eines Spielers in einen String schreiben.

``` elm
toString : Player -> String
toString player =
    case player of
        Player name point ->
            name ++ " " ++ Point.toString point
```

Wir gehen hier davon aus, dass die Funktion `toString` für den Datentyp `Point`, die wir zuvor definiert haben, sich in einem Modul `Point` befindet.

{% include callout-important.html content="
In der funktionalen Programmierung werden Module häufig um einen Datentyp herum organisiert.
Das heißt, wenn man einen Datentyp benötigt, dessen Bedeutung ohne Kontext klar ist, definiert man diesen Datentyp häufig in einem neuen Modul.
In das Modul werden dann auch alle Funktionen, die auf dem Datentyp arbeiten, geschrieben.
" %}

Im Allgemeinen kann man Summen- und Produkttypen auch kombinieren.
Die Kombination aus Summen- und Produkttypen wird als algebraischer Datentyp bezeichnet.
Anders ausgedrückt sind Summen- und Produkttypen jeweils Spezialfälle von algebraischen Datentypen.

{% include callout-info.html content="
Wie mit einer Algebra in der Mathematik kann man tatsächlich mit algebraischen Datentypen auch \"rechnen\".
" %}

Der algebraische Datentyp `Bool` hat zwei Werte.
Wenn wir den folgenden Datentyp definieren

```elm
type Product
    = Product Bool Bool
```

erzeugen wir das Product aus dem Datentyp `Bool` mit sich selbst, das heißt, wir "multiplizieren" den Typ `Bool` mit dem Typ `Bool`.
Analog hat der Datentyp `Product` tatsächlich auch `4 = 2 * 2` mögliche Werte, nämlich `Product False False`, `Product False True`, `Product True False` und `Product True True`.
Die Analogie zu algebraischen Regeln, wie sie aus der Mathematik bekannt sind, geht noch wesentlich weiter und lässt sich mit polymorphen Datentypen noch besser illustrieren als mit monomorphen Datentypen, wie sie hier verwendet werden.

Im folgenden ist ein algebraischer Datentyp definiert.
Der Datentyp beschreibt, ob ein Spiel unentschieden ausgegangen ist oder ob ein Spieler das Spiel gewonnen hat.

``` elm
type GameResult
    = Win Player
    | Draw
```

Der Konstruktor `Win` modelliert, dass einer der Spieler gewonnen hat.
Wenn die Spielrunde unentschieden ausgegangen ist, liefert die Funktion als Ergebnis den Wert `Draw`.
Da wir in diesem Fall keine zusätzlichen Informationen benötigen, hat der Konstruktor keine Argumente.

{% include callout-important.html content="
Man bezeichnet algebraische Datentypen manchmal auch als **_Tagged Union_**.
" %}

Man spricht von einer _Union_, da der algebraische Datentyp wie bei einem Aufzählungstyp in der Lage ist, verschiedene Fälle zu einem Datentyp zu vereinigen.
Die verschiedenen Fälle, die es gibt, werden dann in dem algebraischen Datentyp zu einem einzigen Datentyp vereinigt.
Man bezeichnet diese Vereinigung als _Tagged_, da durch den Konstruktor immer eindeutig ist, um welchen Teil der Vereinigung es sich handelt.

Der folgende Datentyp illustriert noch einmal den Namen _Tagged Union_.

```elm
type IntOrString
    = IntValue Int
    | StringValue String
```

Der Datentyp `IntOrString` stellt entweder einen `Int` oder einen `String` dar, vereinigt also die möglichen Werte der Datentypen `Int` und `String`.
Man nennt Typen, welche mehrere anderen Typen zu einem neuen vereinigen auch Vereinigungstyp.
Im Unterschied zu einem einfachen Vereinigungstyp ist bei einem Wert vom Typ `IntOrString` durch den Konstruktor klar, um welchen Teil der Vereinigung es sich handelt, also ob es sich um einen `Int` oder einen `String` handelt.
Anders ausgedrückt: wenn wir den Typ `IntOrString` verwenden möchten, müssen wir den jeweiligen Konstruktor verwenden.
Diese Eigenschaft ist elementar wichtig für die Typinferenz.
Wenn die Typinferenz zum Beispiel den Konstruktor `IntValue` sieht, ist klar, dass es sich um den Typ `IntOrString` handelt.
Bei Programmiersprachen, die Formen von _Untagged Unions_ bieten, ist eine allgemeine Typinferenz wesentlich schwieriger.

_Pattern Matching_
------------------

Wir haben gesehen, dass man _Pattern Matching_ nutzen kann, um Fallunterscheidungen über Zahlen durchzuführen.
Man kann _Pattern Matching_ außerdem nutzen, um die verschiedenen Fälle eines Aufzählungstyps zu
unterscheiden.
Man kann _Pattern Matching_ aber auch ganz allgemein nutzen, um die verschiedenen Konstruktoren eines algebraischen Datentyps zu unterscheiden.
Wir können zum Beispiel wie folgt eine Funktion `isDraw` definieren, um zu überprüfen, ob ein Spiel unentschieden ausgegangen ist.

``` elm
isDraw : GameResult -> Bool
isDraw result =
    case result of
        Draw ->
            True

        Win _ ->
            False
```

Diese Funktion liefert `True`, falls das `GameResult` gleich `Draw` ist und `False` andernfalls.
Der Unterstrich besagt, dass wir ignorieren, welche Form das Argument von `Win` hat.
Das heißt, mit dem Muster `Win _` sagen wir, diese Regel soll genommen werden, wenn der Wert in `result` ein `Win`-Konstruktor mit einem beliebigen Argument ist.
Anstelle des Unterstrichs können wir auch eine Variable verwenden, das heißt, statt `Win _` können wir auch `Win player` schreiben.
Wir können zum Beispiel wie folgt eine Funktion definieren, die zu einem Spiel-Ergebnis eine Beschreibung in Form eines `String`s liefert.

``` elm
description : GameResult -> String
description result =
    case result of
        Draw ->
            "Das Spiel ist unentschieden ausgegangen."

        Win player ->
            playerName player ++ " hat das Spiel gewonnen."
```

In diesem Fall wird die Variable `player` an den Wert vom Typ `Player` gebunden, der im Konstruktor `Win` steckt.

_Pattern_ können auch geschachtelt werden.
Das heißt, anstelle einer Variable können wir auch wieder ein komplexes _Pattern_ verwenden.
Die folgende Funktion verwendet zum Beispiel ein geschachteltes _Pattern_, um die x-Position eines Spielers zu bestimmen.

``` elm
playerXCoord : Player -> Float
playerXCoord player =
    case player of
        Player _ (Point x _) ->
            x
```

Im zweiten Argument des Konstruktors `Player` steht ein Wert vom Typ `Point`.
Daher können wir im _Pattern_ an der entsprechenden Stelle auch ein _Pattern_ für einen `Point` verwenden.
Der Konstruktor `Point` erhält zwei Argumente, daher hat das _Pattern_ `Point x _` hier ebenfalls zwei Argumente.

Als weiteres Beispiel für ein geschachteltes _Pattern_ wollen wir noch einmal die Funktion definieren, die einen `String` liefert, der beschreibt, wie ein Spiel ausgegangen ist.
In diesem Fall verzichten wir aber auf die Hilfsfunktion `playerName` und verwenden stattdessen ein geschachteltes _Pattern_.

``` elm
description : GameResult -> String
description result =
    case result of
        Draw ->
            "Das Spiel ist unentschieden ausgegangen."

        Win (Player name _) ->
            name ++ " hat das Spiel gewonnen."
```

Wenn wir zum Beispiel den Aufruf `description (Win examplePlayer)` in der REPL auswerten -- wobei `examplePlayer` die weiter oben definierte Konstante ist -- erhalten wir das folgende Ergebnis.

``` elm
> description (Win examplePlayer)
"Spieler A hat das Spiel gewonnen." : String
```

Die Ausgabe der REPL bedeutet, dass der Aufruf `description (Win examplePlayer)` das Ergebnis

`"Spieler A hat das Spiel gewonnen."`

geliefert hat und dieses Ergebnis vom Typ `String` ist.

Ein `case`-Ausdruck wird für zwei Aufgaben genutzt.
Zum einen führen wir eine Fallunterscheidung über die möglichen Konstruktoren eines Datentyps durch.
Zum anderen zerlegen wir Konstruktoren in ihre Einzelteile.
Bei Datentypen, die nur einen Konstruktor zur Verfügung stellen, wie etwa der Typ `Point`, müssen wir keine Fallunterscheidung über die verschiedenen Konstruktoren durchführen.
Daher kann man ein _Pattern_ für Datentypen mit nur einem Konstruktor auch ohne einen `case`-Ausdruck verwenden.
Die folgende Funktion liefert zum Beispiel die x-Koordinate eines Punktes.
Wir schreiben in dieser Variante das _Pattern_ also an die Stelle, an der wir sonst die Variable für den Parameter der Funktion schreiben.

``` elm
xCoord : Point -> Float
xCoord (Point x _) =
    x
```

{% include callout-info.html content="
Diese Art des _Pattern Matching_ entspricht dem Stil der regel-basierten Definition in Haskell.
Der einzige Unterschied besteht darin, dass es in Elm in diesem Fall immer nur eine Regel gibt, da es immer nur einen Konstruktor gibt, wenn diese Art des _Pattern Matching_ angewendet werden kann.
" %}

Wenn wir sowohl die gesamte Struktur, die übergeben wird, benötigen als auch einen Teil der Struktur kann man mit dem Schlüsselwort `as` einen Namen für die gesamte Struktur einführen.
Das heißt, im folgenden Beispiel wird der übergebene Punkt an die Variable `point` gebunden und die x-Koordinate an die Variable `x`.

``` elm
xCoord : Point -> Float
xCoord ((Point x _) as point) =
    ...
```

Diese Art des _Pattern_ wird als **_Pattern Alias_** bezeichnet, da ein Alias für ein _Pattern_ eingeführt wird.
Ein _Pattern Alias_ kann an jeder Stelle eingesetzt werden, an der ein _Pattern_ steht.

```elm
playerXCoord : Player -> Float
playerXCoord player =
    case player of
        Player _ ((Point x _) as point) ->
            ...
```

Hier wird der _Pattern Alias_ geschachtelt in einem anderen _Pattern_ verwendet.

{% include callout-info.html content="
In Haskell wird für ein _Pattern Alias_ anstelle des Schlüsselwortes `as` das `@` verwendet und der Alias wird vor das _Pattern_ geschrieben.
Das heißt, wir schreiben in Haskell zum Beispiel `point@Point x _`.
" %}


Rekursive Datentypen
--------------------

Datentypen können auch rekursiv sein.
Das heißt, wie eine rekursive Funktion kann ein Datentyp in seiner Definition wieder auf sich selbst verweisen.
Wir können zum Beispiel wie folgt einen Datentyp definieren, der Listen mit Integern darstellt.
In der funktionalen Programmierung haben sich die Namen _Nil_ für eine leere Liste und _Cons_ für eine nicht-leere Liste eingebürgert.
Das Wort _Nil_ ist eine Kurzform des lateinischen Wortes _nihil_, das “nichts” bedeutet.

``` elm
type IntList
    = Nil
    | Cons Int IntList
```

Zuerst einmal wollen wir uns anschauen, wie wir mit diesem Datentyp Listen konstruieren können.
Die Konstruktion eines Wertes funktioniert bei einem rekursiven Datentyp genau so wie bei den nicht-rekursiven Datentypen, die wir bisher kennengelernt haben.
Um einen Wert zu konstruieren, verwenden wir einen Konstruktor.
Wenn wir einen Konstruktor anwenden, dann gibt die Datentypdefinition an, welche Typen die Argumente jeweils haben müssen.

Wenn wir jetzt eine Liste definieren wollen, können wir also zum Beispiel den Konstruktor `Nil` verwenden, der keine Argumente nimmt.

``` elm
exampleList1 : IntList
exampleList1 =
    Nil
```

Alternativ können wir eine Liste konstruieren, indem wir den Konstruktor `Cons` verwenden.
Das erste Argument von `Cons` muss vom Typ `Int` sein.
Das zweite Argument von `Cons` muss wiederum vom Typ `IntList` sein.
Das heißt, wir können als zweites Argument von `Cons` zum Beispiel `Nil` verwenden.

``` elm
exampleList2 : IntList
exampleList2 =
    Cons 23 Nil
```

Statt als zweites Argument von `Cons` den Konstruktor `Nil` zu verwenden, können wir auch wieder `Cons` verwenden.
So definieren wir wie folgt zum Beispiel eine Liste mit zwei Elementen, nämlich `23` und `42`.

``` elm
exampleList3 : IntList
exampleList3 =
    Cons 23 (Cons 42 Nil)
```

Wir wollen einmal eine Funktion definieren, die die Länge einer solchen Liste berechnet.
Die meisten Funktionen, die eine rekursive Datenstruktur verarbeiten, sind selbst rekursiv.
Um eine solche Funktion zu definieren, verwenden wir wie bei den nicht-rekursiven Funktionen _Pattern Matching_.

``` elm
length : IntList -> Int
length list =
    case list of
        Nil ->
            0

        Cons _ restlist ->
            1 + length restlist
```

Die Funktion `length` testet zuerst, ob die Liste leer ist.
In diesem Fall liefert `length` als Ergebnis `0` zurück.
Falls die Liste nicht leer ist, wird der Konstruktor `Cons` zerlegt.
Da wir nur die Länge der Liste berechnen wollen, ignorieren wir den `Int`-Wert, der im `Cons`-Konstruktor steht.
Wir rufen die Funktion `length` rekursiv auf die Restliste `restlist` auf.
Da die Liste `Cons _ restlist` um einen Eintrag länger ist als die Liste `restlist`, addieren wir auf das Ergebnis von `length restlist` noch `1` rauf.
So erhalten wir die Länge der Liste `Cons _ restlist`.

Als weiteres Beispiel zeigt die folgende Funktion, wie wir die Zahlen in einer Liste aufaddieren können.

``` elm
sum : IntList -> Int
sum list =
    case list of
        Nil ->
            0

        Cons int restlist ->
            int + sum restlist
```

Das Muster ist bei der Funktion `sum` sehr ähnlich zur Funktion `length`.
In diesem Fall ignorieren wir den Wert, der im `Cons`-Konstruktor steht, aber nicht, sondern addieren ihn auf das rekursive Ergebnis.

Als nächstes wollen wir eine Funktion definieren, die zu einer Liste eine Liste berechnet, die jedes zweite Element der Originalliste enthält.
Das heißt, der Aufruf `everySecond (Cons 23 (Cons 42 (Cons 13 Nil)))` soll als Ergebnis die Liste `Cons 42 Nil` liefern, da wir das erste und das dritte Element verwerfen.

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

Um diese Funktion umzusetzen, verwenden wir ein geschachteltes _Pattern_.
Das Muster `Cons _ (Cons int restlist)` prüft, ob die Liste mindestens zwei Elemente enthält.
Im Ergebnis erstellen wir dann eine Liste, die nur das Element `int` enthält und als Restliste das Ergebnis des rekursiven Aufrufs `everySecond restlist` enthält.

Als Abschluss für rekursive Funktionen auf Listen wollen wir eine Funktion definieren, die zwei Listen hintereinanderhängt.
Diese Funktion wird klassischerweise als `append` bezeichnet.

``` elm
append : IntList -> IntList -> IntList
append list1 list2 =
    case list1 of
        Nil ->
            list2

        Cons int restlist1 ->
            Cons int (append restlist1 list2)
```

Diese Funktion rekonstruiert sein erstes Argument.
Wenn die Rekonstruktion schließlich bei der leeren Liste angekommen ist, liefert die Funktion das zweite Argument zurück.
Auf diese Weise wird die leere Liste in der Liste `list1` durch die Liste `list2` ersetzt.

Wir wollen an dieser Stelle auch ganz kurz das Speichermodell und die Laufzeit von Funktionen in Elm diskutieren.
Das Aufrufen eines Konstruktors sowie _Pattern Matching_ sind konstante Operationen.
Das heißt, die Laufzeit der Funktion `append` ist linear in der Länge der ersten Liste.
Wenn wir einen Konstruktor verwenden, wird im Heap eine entsprechende Struktur angelegt.
In der Funktion `append` wird zum Beispiel die Liste `list1` neu erstellt, da wir in der Regel für `Cons` den Konstruktor jeweils neu erstellen.
Wenn die Funktion `append` am Ende von `list1` angekommen ist, wird die Liste `list2` aber einfach zurückgegeben, wie sie ist.
Dadurch entsteht nach einem Aufruf von `append` im Speicher die folgende Struktur.

<figure id="memory" markdown="1">
![Darstellung der Speicherstruktur der Listen nach einem Aufruf von append](/assets/graphics/memory.svg){: width="100%" .centered}
<figcaption>Speicherstruktur nach dem Aufruf <code class="language-plaintext highlighter-rouge">append list1 list2</code></figcaption>
</figure>

Das heißt, das Ergebnis des Aufrufs `append list1 list2` hat die `Cons`-Zellen mit den Werten `1`, `2` und `3` neu erstellt.
Diese existieren jetzt doppelt im Speicher.
Falls wir die Liste `list1` anschließend nicht weiter verwenden, wird sie durch den _Garbage Collector_ aus dem Speicher entfernt.
Die Liste `list2` wird aber nicht dupliziert, sondern die Variable `list2` und das Ergebnis von `append list1 list2` verweisen beide auf die gleiche Struktur im Speicher.

Als weiteres Beispiel eines rekursiven Datentyps wollen wir uns eine Baumstruktur anschauen.
Der folgende Datentyp stellt zum Beispiel einen binären Baum mit ganzen Zahlen in den Knoten dar.

``` elm
type IntTree
    = Empty
    | Node IntTree Int IntTree
```

Die folgende Definition gibt einen Wert dieses Typs an.

``` elm
exampleTree : IntTree
exampleTree =
    Node (Node Empty 3 (Node Empty 5 Empty)) 8 Empty
```

Wir können zum Beispiel wie folgt eine Funktion schreiben, die testet, ob ein Eintrag in einem Baum vorhanden ist.

``` elm
find : Int -> IntTree -> Bool
find n tree =
    case tree of
        Empty ->
            False

        Node leftree int righttree ->
            n == int || find n lefttree || find n righttree
```

{% include callout-important.html content="
Im Unterschied zur Programmiersprache Haskell ist Elm eine **strikte** Sprache, nutzt also **call-by-value** als Auswertungsstrategie.
" %}

Das heißt, bei Definitionen wie `find` müssen wir beachten, dass rekursive Aufrufe auch durchgeführt werden, wenn ihr Ergebnis ggf. gar nicht benötigt wird.
Der Ausdruck `n == int || find n lefttree` müsste zum Beispiel beide Argumente von `||` auswerten, auch wenn der gesuchte Eintrag bereits gefunden wurde, also `n == int` als Ergebnis `True` liefert.

In Elm -- wie in vielen anderen Programmiersprachen -- sind die logischen Operatoren `||` und `&&` daher als Kurzschlussoperatoren definiert.
Das heißt, der rekursive Aufruf `find n lefttree` wird nur durchgeführt, falls die Bedingung `n == int` nicht erfüllt ist.

[^1]: Wikipedia-Artikel zum Thema [Algebraische Datentypen](https://en.wikipedia.org/wiki/Algebraic_data_type)

[^2]: Wikipedia-Artikel zum Thema [Programmiersprachentheorie](https://en.wikipedia.org/wiki/Programming_language_theory)

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="first-application.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="polymorphism.html">weiter</a></li>
    </ul>
</div>
