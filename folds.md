---
layout: post
title: "Faltungen"
mathjax: true
---

Nachdem wir uns die meisten Konzepte der Elm-Architektur angeschaut haben, wollen wir uns noch eine Abstraktion anschauen, die in Elm (und der funktionalen Programmierung im Allgemeinen), sehr häufig zum Einsatz kommt.
Wir haben die Funktionen `map` und `filter` kennengelernt, die wiederkehrende rekursive Muster abstrahieren.
In diesem Kapitel wollen wir uns mit der Idee der Faltung beschäftigen.
Bei einer Faltung handelt es sich um eine Funktion, die ebenfalls ein wiederkehrendes rekursives Muster bei der Verarbeitung von Listen abstrahiert.
Mithilfe einer Faltung können wir zum Beispiel die folgenden Funktionen definieren.

- Berechnung der Summe einer Liste von Zahlen
- Berechnung des Produktes einer Liste von Zahlen
- Berechnung der Länge einer Liste beliebiger Elemente
- die Funktionen `map` und `filter`

Tatsächlich kann man mit einer Faltung aber sogar alle Funktionen definieren, die eine Liste auf eine bestimmte Art und Weise verarbeiten.


Rechtsfaltung für Listen
------------------------

Zunächst definieren wir die ersten drei Beispiele mit expliziter Rekursion, also ohne die Verwendung einer Abstraktion.

```elm
sum : List Int -> Int
sum list =
    case list of
        [] ->
            0

        head :: restlist ->
            head + sum restlist


product : List Int -> Int
product list =
    case list of
        [] ->
            1

        head :: restlist ->
            head * product restlist


filter : (a -> Bool) -> List a -> List a
filter isGood list =
    case list of
        [] ->
            []

        head :: restlist ->
            if isGood head then
                head :: filter isGood restlist

            else
                filter isGood restlist
```

Wir wollen einmal schauen, was diese drei Funktionen gemeinsam haben.
Alle drei Funktionen führen eine Fallunterscheidung über die Liste durch.
Außerdem verwenden alle drei Funktionen einen einfachen Rückgabewert im Fall der leeren Liste.
Wenn wir die Funktionen als `g` bezeichnen, haben alle drei Funktionen die folgende Form, wobei `nil` eine Variable ist, die den konkreten Rückgabewert enthält.

```elm
g list =
    case list of
        [] ->
            nil

        ...
```

Alle drei Funktionen zerlegen eine nicht-leere Liste in ihren Kopf und den Rest.
Der Kopf der Liste wird dabei mit dem Ergebnis des rekursiven Aufrufs der Funktion auf die Restliste kombiniert.
Im Fall der Funktion `filter` ist es nicht direkt offensichtlich, dass der Kopf der Liste mit dem Ergebnis des rekursiven Aufrufs kombiniert wird.
Wir können die Funktion `filter` aber zum Beispiel wie folgt umdefinieren, um diesen Punkt deutlicher zu machen.

```elm
filter : (a -> Bool) -> List a -> List a
filter isGood list =
    let
        conditionalCons element result =
            if isGood element then
                element :: result

            else
                result
    in
    case list of
        [] ->
            []

        head :: restlist ->
            conditionalCons head (filter isGood restlist)
```

Das heißt, alle drei Funktionen haben die folgende Form, wobei `cons` ein funktionaler Parameter ist, der die konkrete Funktion `(+)`, `(*)` bzw. `conditionalCons` enthält.

```elm
g list =
    case list of
        [] ->
            nil

        head :: restlist ->
            cons head (g restlist)
```

Daraus ergibt sich die folgende Definition der Funktion `foldr`.
Wir werden später sehen, was das `r` in `foldr` bedeutet.

```elm
foldr : (a -> b -> b) -> b -> List a -> b
foldr cons nil list =
    case list of
        [] ->
            nil

        head :: restlist ->
            cons head (foldr cons nil restlist)
```

Wir können jetzt die Funktionen von oben wie folgt definieren.

```elm
sum : List Int -> Int
sum list =
    foldr (\element result -> element + result) 0 list


product : List Int -> Int
product list =
    foldr (\element restult -> element * result) 1 list


filter : (a -> Bool) -> List a -> List a
filter isGood list =
    let
        conditionalCons element result =
            if isGood element then
                element :: result

            else
                result
    in
    foldr conditionalCons [] list
```

<!-- ```elm
length : List a -> Int
length list =
    foldr (\_ result -> result + 1) 0 list
``` -->

Diese Definitionen können wir mithilfe von Eta-Reduktion
<!-- und der vordefinierten Funktion `always` -->
noch etwas vereinfachen.

<!--
```elm
always : a -> b -> a
always x _ = x
```
-->

Wir erhalten die folgenden Definitionen.

```elm
sum : List Int -> Int
sum =
    foldr (+) 0


product : List Int -> Int
product =
    foldr (*) 1


filter : (a -> Bool) -> List a -> List a
filter isGood =
    foldr
        (\element result ->
            if isGood element then
                element :: result

            else
                result
        )
        []
```

<!-- ```elm
length : List a -> Int
length =
    foldr (always ((+) 1)) 0
``` -->

Eine mögliche Sichtweise der Funktion `foldr` ist das Ersetzen aller Konstruktoren einer Liste durch Funktionsaufrufe bzw. Konstanten.
Genauer gesagt werden bei einem Aufruf `foldr cons nil list` in einer Liste `list` alle Vorkommen des Konstruktors `::` durch die Funktion `cons` und alle Vorkommen des Konstruktors `[]` durch den Wert `nil` ersetzt.
Im Folgenden werden wir den Konstruktor `::` als `(::)` vor seine Argumente schreiben, um diesen Punkt zu illustrieren.
Wir betrachten eine Liste `[ a, b, c ]` und erhalten durch den Aufruf `foldr cons nil [ a, b, c ]` das folgende Ergebnis.

```
foldr cons nil [ a, b, c ]
=
foldr cons nil (a :: (b :: (c :: [])))
=
foldr cons nil ((::) a ((::) b ((::) c [])))
=
cons a (cons b (cons c nil))
```

Hier sieht man, dass alle Vorkommen von `::` durch Aufrufe von `cons` ersetzt werden und das Vorkommen von `[]` durch `nil`.

<!-- Wenn wir uns das konkrete Beispiel |sum_ [1, 2, 3]| zum Beispiel anschauen, erhalten die das folgende.
```
sum_ [1, 2, 3]
=
foldr (\x r -> x + r) 0 [1, 2, 3]
=
(\x r -> x + r) 1 ((\x r -> x + r) 2 ((\x r -> x + r) 3 0))
=
1 + (2 + (3 + 0))
=
6
```
Wir nutzen hier, dass |(\x r -> x + r) 1 2 = 1 + 2| gilt, das heißt, wenn wir einen Lambda-Ausdruck, der seine beiden Argumente addiert auf zwei Argumente anwenden, erhalten wir eine Addition der Argumente. -->


Linksfaltung für Listen
-----------------------

Neben der Funktion `foldr` stellt Elm auch eine Funktion `foldl` zur Verfügung.
Die Funktion `foldl` ist eine endrekursive Variante der Faltung.
Endrekursiv bedeutet dabei, dass die letzte Aktion der Funktion der rekursive Aufruf ist.
Die letzte Aktion der Funktion `foldr` ist zum Beispiel die Anwendung von `f` auf die Argumente `x` und `foldr f e xs`.
Endrekursive Funktionen sind wichtig, da sie sich effizienter in Maschinencode übersetzen lassen als nicht endrekursive Funktionen.
Bei der Ausführung eines Funktionsaufrufs muss auf dem Stack gespeichert werden, wie nach Beendung des Aufrufs fortgefahren wird.
Wenn eine Funktion endrekursiv ist, kann diese Information einfach durch die neue Information ersetzt werden.
Endrekursive Funktionen können daher auch ohne Verbrauch von Speicher auf dem Laufzeitstack übersetzt werden.
Zu diesem Zweck muss der Compiler aber eine entsprechende Optimierung, die Endrekursions-Optimierung (_Tail Call Optimization_) implementieren.
Viele Programmiersprachen, die nicht für Rekursion gedacht sind, reservieren standardmäßig einen vergleichsweise kleinen Speicherbereich für den Stack.
Daher kann es in solchen Sprachen bei der Verwendung von Rekursion schnell zu einem _Stack Overflow_ kommen, das heißt, dass der Stack-Speicher komplett aufgebraucht ist.
Wenn endrekursive Funktionen verwendet werden und der Compiler eine _Tail Cail Optimization_ macht, kann es nicht zu einem _Stack Overflow_ kommen.
Diese Argumentation gilt nicht nur für Faltungen sondern für alle rekursiven Funktionen.
Es kann sich also unter Umständen lohnen, eine Funktion endrekursiv zu definieren, um den Stack-Verbrauch gering zu halten.

Um zu verstehen, wie die Linksfaltung funktioniert, implementieren wir endrekursive Varianten von `sum`, `product` und `length`.

```elm
sum : List Int -> Int
sum =
    let
        sumIter acc list =
            case list of
                [] ->
                    acc

                head :: restlist ->
                    sumIter (head + acc) restlist
    in
    sumIter 0


product : List Int -> Int
product =
    let
        productIter acc list =
            case list of
                [] ->
                    acc

                head :: restlist ->
                    productIter (head * acc) restlist
    in
    productIter 1
```

<!--
```elm
length : List Int -> Int
length = lengthIter 0
  where
    lengthIter acc list =
        case list of
            [] ->
                acc

            _ :: restlist ->
                lengthIter acc (acc + 1) restlist
```
-->

Wir können aus dem Muster der Hilfsfunktionen wie im Fall von `foldr` die folgende abstrakten Variante definieren.

```elm
foldl : (a -> b -> b) -> b -> List a -> b
foldl func acc list =
    case list of
        [] ->
            acc

        head :: restlist ->
            foldl func (func head acc) restlist
```

Die Funktion überprüft, ob die Liste leer ist oder nicht.
Falls die Liste nicht leer ist, berechnet die Funktion `func x acc` und ruft sich anschließend rekursiv auf.
Das heißt, die Funktion `foldl` führt als letzte Aktion den rekursiven Aufruf durch.

Wie die Funktion `foldr` ersetzt auch die Funktion `foldl` alle Vorkommen des Konstruktors `::` durch eine Funktion `cons` und den Konstruktor `[]` durch `nil`, hierbei wird allerdings auch noch die Reihenfolge der Elemente in der Liste umgekehrt.

```
foldl cons nil [ a, b, c ]
=
foldl cons nil (a :: (b :: (c :: [])))
=
foldl cons nil ((::) a ((::) b ((::) c [])))
=
cons c (cons b (cons a nil))
```

Das Umkehren der Liste macht bei den bisherigen Funktionen keinen Unterschied, so liefern die Aufrufe `foldl (+) 0` und `foldl (*) 1` die gleichen Resultate wie die analogen Aufrufe mit `foldr`.
In diesen beiden Fällen liegt das daran, dass `(+)` und `(*)` kommutativ und assoziativ sind.
Im Allgemeinen liefern die beiden Funktionen aber nicht die gleichen Ergebnisse, wenn wir die gleichen Argumente verwenden.
Der Aufruf `foldr (::) []` liefert zum Beispiel eine Funktion, die eine Liste ab und genau so wieder aufbaut.
Im Gegensatz dazu liefert `foldl (::) []` eine Funktion, die eine Liste in umgekehrter Reihenfolge zurückliefert.


Faltungen auf anderen Datentypen
--------------------------------

Die Idee der Funktion `foldr` lässt sich auch auf andere Datentypen übertragen.
Der folgende Algorithmus liefert uns zu einem Datentyp $$\tau$$ den Typ der Faltung für diesen Datentyp.

1. Schreiben Sie die Typen aller Konstruktoren von $$\tau$$ auf.
2. Ersetzen Sie in den Typen der Konstruktoren den Datentyp $$\tau$$ durch eine noch nicht verwendete Typvariable.
3. Schreiben Sie die Signatur für `fold`, indem sie all diese Typen als Argumente übergeben, dann den Typ $$\tau$$ und die neugewählt Typvariable als Ergebnis.

Wir wollen diesen Algorithmus einmal am Beispiel des Listendatentyps durchführen.
Das heißt, wir betrachten $$\tau = $$`List a`.
Die Typen der Konstruktoren von $$\tau$$ sind `[] : List a` und `(::) : a -> List a -> List a`.
In diesen Typen ersetzen wir den Typ `List a` jetzt durch `b` und erhalten `b` und `a -> b -> b`.
Die Signatur für die Faltung für Listen lautet dann also

```elm
fold : b -> (a -> b -> b) -> List a -> b
```

Nachdem wir gesehen haben, dass wir mithilfe des Algorithmus den Typ der Funktion `foldr` im Fall von Listen erhalten, wollen wir uns noch ein Beispiel für einen anderen Datentyp anschauen.
Wir wenden den Algorithmus auf den folgenden polymorphen Baum-Datentyp an.

```elm
type Tree a
    = Leaf a
    | Node (Tree a) (Tree a)
```

Die Typen der Konstruktoren sind `Leaf : a -> Tree a` und `Node : Tree a -> Tree a -> Tree a` und es gilt $$\tau = $$`Tree a`.
Wir ersetzen jetzt alle Vorkommen von $$\tau$$ durch `b` und erhalten `a -> b` und `b -> b -> b`.
Daraus ergibt sich die folgende Signatur für die Faltung von $$\tau$$.

```elm
fold : (a -> b) -> (b -> b -> b) -> Tree a -> b
```

Wir können diese Funktion nun wie folgt definieren.

```elm
fold : (a -> b) -> (b -> b -> b) -> Tree a -> b
fold leaf node tree =
    case tree of
        Leaf x ->
            leaf x

        Node lefttree righttree ->
            node (fold leaf node lefttree) (fold leaf node righttree)
```

Als Beispiel für die Verwendung von `fold` für den Datentyp `Tree` wollen wir eine Funktion definieren, die die Anzahl der Blätter in einem Baum zählt.
Dazu definieren wir die Funktion erst einmal mithilfe expliziter Rekursion wie folgt.

```elm
leaves : Tree a -> Int
leaves tree =
    case tree of
        Leaf _ ->
            1

        Node lefttree righttree ->
            leaves lefttree + leaves righttree
```

Mithilfe der Funktion `foldTree` können wir diese Funktion wie folgt definieren.

```elm
leaves : Tree a -> Int
leaves =
    fold (\_ -> 1) (+)
```

Als weiteres Beispiel können wir wie folgt eine Funktion definieren, die alle Blätter eines Baumes in einer Liste gesammelt zurückgibt.

```elm
flatten : Tree a -> List a
flatten =
    fold List.singleton (++)
```

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="commands.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="abstractions.html">weiter</a></li>
    </ul>
</div>
