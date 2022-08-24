---
layout: post
title: "Funktionen höherer Ordnung"
---

In diesem Kapitel wollen wir uns intensiver mit dem Thema Rekursion
auseinandersetzen. Wie wir bereits gesehen haben, kann man mit Hilfe von
Rekursion Funktionen in Elm definieren. Wenn man sich etwas länger mit
rekursiven Funktionen beschäftigt, wird aber schnell klar, dass es unter
diesen rekursiven Funktionen wiederkehrende Muster gibt. Wir wollen uns
hier einige dieser Muster anschauen.

Wiederkehrende rekursive Muster
-------------------------------

Nehmen wir an, wir haben eine Liste von Zahlen und wollen alle Zahlen
inkrementieren. Wir können wie folgt eine Funktion definieren, die diese
Aufgabe übernimmt.

``` elm
incList : List Int -> List Int
incList list =
    case list of
        [] ->
            []

        i :: is ->
            i + 1 :: incList is
```

Wir müssen den rekursiven Aufruf von `incList` an dieser Stelle nicht
klammern, da, wie wir bereits gelernt haben, die Anwendung einer
Funktion stärker bindet als ein Infix-Operator und damit
`i + 1 :: incList is` implizit als `i + 1 :: (incList is)` geklammert
ist. Wir müssen auch die Anwendungen von `+` und `::` nicht klammern, da
der Operator `::` Präzedenz 5 und `+` Präzedenz 6 hat. Daher ist die
rechte Seite der zweiten Regel implizit als `(i + 1) :: (incList is)`
geklammert.

Nun nehmen wir an, wir möchten in einer Liste von Zahlen alle Zahlen
quadrieren. Diese Aufgabe können wir wie folgt lösen.

``` elm
squareList : List Int -> List Int
squareList list =
    case list of
        [] ->
            []

        i :: is ->
            i * i :: squareList is
```

Zu guter Letzt nehmen wir an, wir haben eine Liste von Zeichenketten und
wollen von jedem `String` die Länge berechnen. Diese Aufgabe können wir
wie folgt lösen.

``` elm
lengthList : List String -> List Int
lengthList list =
    case list of
        [] ->
            []

        str :: strs ->
            String.length str :: lengthList strs
```

Diese drei Funktionen unterscheiden sich nur leicht voneinander. Ein
Ziel funktionaler Programmierer ist es, solche Duplikation von Code zu
vermeiden.

Die Funktionen `incList`, `squareList` und `lengthList` durchlaufen alle
eine Liste von Elementen und unterscheiden sich nur in der Operation,
die sie auf die Listenelemente anwenden. Wir wollen einmal diese
unterschiedlichen Operationen als Funktionen definieren.

``` elm
inc : Int -> Int
inc i = i + 1

square : Int -> Int
square i = i * i
```

Mit Hilfe dieser Funktionen werden die Gemeinsamkeiten der Funktionen
`incList`, `squareList` und `lengthList` noch deutlicher.

``` elm
incList : List Int -> List Int
incList list =
    case list of
        [] ->
            []

        i :: is ->
            inc i :: incList is


squareList : List Int -> List Int
squareList list =
    case list of
        [] ->
            []

        i :: is ->
            square i :: squareList is


lengthList : List String -> List Int
lengthList list =
    case list of
        [] ->
            []

        str :: strs ->
            String.length str :: lengthList strs
```

Das heißt, die drei Definitionen unterscheiden sich nur durch die
Funktion, die jeweils verwendet wird. Allerdings unterscheiden sich auch
die Typen der Funktionen, so hat die Funktion in den ersten beiden
Beispielen den Typ `Int -> Int` und im letzten Beispiel `String -> Int`.

Wir können die Teile, die die drei Funktionen sich teilen, in eine
Funktion extrahieren. Man nennt die Funktion, die wir dadurch erhalten
`map`. Diese Funktion erhält die Operation, die auf die Elemente der
Liste angewendet wird, als Argument übergeben.

In Elm sind Funktionen *first class citizens*. Das heißt, Funktionen
können wie andere Werte, etwa Zahlen oder Zeichenketten als Argumente
und Ergebnisse in Funktionen verwendet werden. Außerdem können
Funktionen in Datenstrukturen stecken. Die Funktion `map` hat die
folgende Form.

``` elm
map : (a -> b) -> List a -> List b
map func list =
    case list of
        [] ->
            []

        x :: xs ->
            func x :: map func xs
```

Mit Hilfe der Funktion `map` können wir die Funktionen `incList`,
`squareList` und `lengthList` nun wie folgt definieren.

``` elm
incList : List Int -> List Int
incList list =
    map inc list

squareList : List Int -> List Int
squareList list =
    map square list

lengthList : List Int -> List Int
lengthList list =
    map String.length list
```

Man nennt eine Funktion, die eine andere Funktion als Argument erhält,
eine Funktion höherer Ordnung (*higher-order function*).

Neben dem Rekursionsmuster für `map`, wollen wir an dieser Stelle noch
ein weiteres Rekursionsmuster vorstellen. Stellen wir uns vor, dass wir
aus einer Liste von Zeichenketten die Liste aller Zeichenketten mit
einer geraden Länge extrahieren möchten. Dazu können wir die folgende
Funktion definieren.

``` elm
keepEvenLength : List String -> List String
keepEvenLength list =
    case list of
        [] ->
            []

        str :: strs ->
            if modBy 2 (String.length str) == 0 then
                str :: keepEvenLength strs
            else
                keepEvenLength strs
```

Als nächstes nehmen wir an, wir wollen aus einer Liste mit allen Zahlen
alle Zahlen raussuchen, die kleiner sind als `5`.

``` elm
keepLessThan5 : List Int -> List Int
keepLessThan5 list =
    case list of
        [] ->
            []

        x :: xs ->
            if x < 5 then
                x :: keepLessThan5 xs
            else
                keepLessThan5 xs
```

Wir können diese beiden Funktionen wieder mit Hilfe einer Funktion
höherer Ordnung definieren.

``` elm
filter : (a -> Bool) -> List a -> List a
filter pred list =
    case list of
        [] ->
            []

        x :: xs ->
            if pred x then
                x :: filter pred xs
            else
                filter pred xs
```

Dieses Mal übergeben wir eine Funktion, die angibt, ob ein Element in
die Ergebnisliste kommt oder nicht. Man bezeichnet eine solche Funktion,
die einen booleschen Wert liefert auch als Prädikat.

Funktionen höherer Ordnung wie `map` und `filter` ermöglichen es,
deklarativeren Code zu schreiben. Bei der Verwendung dieser Funktionen
gibt der Entwickler nur an, was berechnet werden soll, aber nicht wie
diese Berechnung durchgeführt wird. Wie die Berechnung durchgeführt
wird, wird dabei einfach durch die Abstraktionen festgelegt. Diese Form
der deklarativen Programmierung ist in jeder Programmiersprache möglich,
die es erlaubt Funktionen als Argumente zu übergeben. Heutzutage bietet
fast jede Programmiersprache dieses Sprachfeature. Daher haben
Abstraktionen wie `map` und `filter` inzwischen auch Einzug in die
meisten Programmiersprachen gehalten. Im Folgenden sind einige
Programmiersprachen aufgelistet, die diese Abstraktionen ähnlich zu
`map` und `filter` zur Verfügung stellen.

##### Java

Das Interface `java.util.stream.Stream` stellt die folgenden beiden
Methoden zur Verfügung.  
`<R> Stream<R> map(Function<? super T, ? extends R> mapper)`  
`Stream<T> filter(Predicate<? super T> predicate)`

##### C#

LINQ (Language Integrated Query)[1] ist eine Technologie der
.NET-Platform, um Anfragen elegant zu formulieren. Die folgenden beiden
Methoden, die von LINQ zur Verfügung gestellt werden, entsprechen in
etwa den Funktionen `map` und `filter`.  
`IEnumerable<TResult> Select<TSource,TResult>(IEnumerable<TSource>, Func<TSource,TResult>)`  
`IEnumerable<TSource> Where<TSource> (this IEnumerable<TSource> source, Func<TSource,bool> predicate)`

##### JavaScript

Der Prototyp `Array` bietet Methoden `map` und `filter`, welche die
Funktionalität von `map` und `filter` auf Arrays bieten.

##### Elm

Elm stellt die Funktionen `map` und `filter` im Modul `List` zur
Verfügung.

Anonyme Funktionen
------------------

Es ist recht umständlich extra die Funktionen `inc` und `square` zu
definieren, nur, um sie in den Definitionen von `incList` und
`squareList` zu verwenden. Stattdessen kann man anonyme Funktionen
verwenden. Anonyme Funktionen sind einfach Funktionen, die keinen Namen
erhalten. Die Funktion `incList` kann zum Beispiel wie folgt mit Hilfe
einer anonymen Funktion definiert werden.

``` elm
incList : List Int -> List Int
incList list =
    map (\x -> x + 1) list
```

Dabei stellt der Ausdruck `\x -> x + 1` die anonyme Funktion dar. Analog
können wir die Funktion `squareList` mit Hilfe einer anonymen Funktion
wie folgt definieren.

``` elm
squareList : List Int -> List Int
squareList list =
    map (\x -> x * x) list
```

Annonyme Funktionen, auch als Lambda-Ausdrücke bezeichnet, starten mit
dem Zeichen `\` und listen dann eine Reihe von Argumenten auf, nach den
Argumenten folgen die Zeichen `->` und schließlich die rechte Seite der
Funktion. Das heißt, der Ausdruck `\x y -> x * y` definiert zum Beispiel
eine Funktion, die ihre beiden Argumente multipliziert. Ein
Lambda-Ausdruck der Form `\x y -> e` entspricht dabei der folgenden
Funktionsdefinition.

``` elm
f x y = e
```

Der einzige Unterschied ist, dass wir die Funktion nicht verwenden,
indem wir ihren Namen schreiben, sondern indem wir den gesamten
Lambda-Ausdruck angeben. Während wir `f` zum Beispiel auf Argumente
anwenden, indem wir `f 1 2` schreiben, wenden wir den Lambda-Ausdruck
an, indem wir `(\x y -> e) 1 2` schreiben.

Als weiteres Beispiel wollen wir eine Lambda-Funktion nutzen, um ein
Prädikat zu definieren. Dazu betrachten wir noch einmal die Funktion
`filter`. Wenn wir zum Beispiel aus einer Liste von Zeichenketten
extrahieren möchten, deren Länge gerade ist, können wir diese Anwendung
wie folgt definieren.

``` elm
keepEvenLength : List String -> List String
keepEvenLength list =
    filter (\str -> modBy 2 (String.length str) == 0) list
```

Ge*curry*te Funktionen
----------------------

Um Funktionen höherer Ordnung in vollem Umfang nutzen zu können, müssen
wir uns eine grundlegende Eigenschaft von Funktionen in Elm anschauen,
die wir bisher unter den Tisch gekehrt haben. Dazu schauen wir uns noch
einmal die Definition von mehrstelligen Funktionen an, die wir in
<a href="#subsec:twoary" data-reference-type="ref"
data-reference="subsec:twoary">[subsec:twoary]</a> eingeführt haben.

``` elm
cart : Int -> Float -> String
cart quantity price =
    "Summe (" ++ items quantity ++ "): " ++ String.fromFloat price
```

Wir haben dabei gelernt, dass man zwischen zwei Argumente immer einen
Pfeil schreiben muss, wir haben aber bisher nicht diskutiert warum. In
einer Programmiersprache wie Java würden wir die Funktion eher wie folgt
definieren.

``` elm
cartP : ( Int, Float ) -> String
cartP ( quantity, price ) =
    "Summe (" ++ items quantity ++ "): " ++ String.fromFloat price
```

Die Funktion `cart` nennt man die ge*curry*te Variante und die Funktion
`cartP` die unge*curry*te Variante. Die Funktion `cart` nimmt zwar auf
den ersten Blick zwei Argumente, wir können den Typ der Funktion `cart`
aber auch anders angeben. Die Schreibweise `Int -> Float -> String`
steht eigentlich für den Typ `Int -> (Float -> String)`, das heißt, der
Typkonstruktor `->` ist rechts-assoziativ. Das heißt, `cart` ist eine
Funktion, die einen Wert vom Typ `Int` nimmt und eine Funktion vom Typ
`Float -> String` liefert. Während der Funktionspfeil rechtsassoziativ
ist, ist die Anwendung einer Funktion in Elm linksassoziativ. Das heißt,
die Anwendung `cart 4 2.23` steht eigentlich für `(cart 4) 2.23`. Wir
wenden also zuerst die Funktion `cart` auf das Argument `4` an. Wir
erhalten dann eine Funktion, die noch einen `Float` als Argument
erwartet. Diese Funktion wenden wir dann auf `2.23` an und erhalten
schließlich einen `String`.

Die Idee, Funktionen mit mehreren Argumenten als Funktion zu
repräsentieren, die ein Argument nimmt und eine Funktion liefert, wird
als *Currying* bezeichnet. *Currying* ist nach dem amerikanischen
Logiker Haskell Brooks Curry[2] benannt (1900–1982), nach dem auch die
Programmiersprache Haskell benannt ist.

Die Definition von `cart` ist im Grunde nur eine vereinfachte
Schreibweise der folgenden Definition.

``` elm
cartL : Int -> Float -> String
cartL =
    \quantity ->
        \price ->
            "Summe ("
                ++ items quantity
                ++ "): "
                ++ String.fromFloat price
```

In dieser Form der Definition ist ganz explizit dargestellt, dass
`cartL` eine Funktion ist, die ein Argument `quantity` nimmt und als
Ergebnis wiederum eine Funktion liefert. Um Schreibarbeit zu reduzieren,
entsprechen alle Definitionen, die wir in Elm angeben, im Endeffekt
diesem Muster. Wir können die Funktionen aber mit der Kurzschreibweise
von `cart`, die auf die Verwendung der Lambda-Funktionen verzichtet,
definieren.

Mit Hilfe der Definition `cartL` können wir noch einmal illustrieren,
dass die Funktionsanwendung linksassoziativ ist.

``` elm
cartL 4 2.23
=
(cartL 4) 2.23
=
(\quantity ->
    \price ->
        "Summe (" ++ items quantity ++ "): " ++ String.fromFloat price
)
    4
    2.23
=
(\price ->
    "Summe (" ++ items 4 ++ "): " ++ String.fromFloat price
)
    2.23
=
"Summe (" ++ items 4 ++ "): " ++ String.fromFloat 2.23
```

Partielle Applikationen
-----------------------

Mit der ge*curry*ten Definition von Funktionen gehen zwei wichtige
Konzepte einher. Das erste Konzept wird partielle Applikation oder
partielle Anwendung genannt. Funktionen in der ge*curry*ten Form lassen
sich sehr leicht partiell applizieren. Applikation ist der Fachbegriff
für das Anwenden einer Funktion auf konkrete Argumente. Eine partielle
Applikation ist die Anwendung einer Funktion auf eine Anzahl von
konkreten Argumenten, so dass der Anwendung noch weitere Argumente
fehlen. Um zu illustrieren, was eine partielle Anwendung bedeutet,
betrachten wir die Anwendung von `cartL` auf das Argument `4`.

``` elm
cartL 4
=
(\quantity ->
    \price ->
        "Summe (" ++ items quantity ++ "): " ++ String.fromFloat price
)
    4
=
\price ->
      "Summe (" ++ items 4 ++ "): " ++ String.fromFloat price
```

Das heißt, wenn wir die Funktion `cartL` partiell auf das Argument `4`
anwenden, erhalten wir eine Funktion, die noch den Preis erwartet und
einen Text liefert, der vier Gegenstände enthält. Wir können die
Funktion `cart` genau auf diese Weise partiell anwenden. Wir betrachten
das folgende Beispiel.

``` elm
items : List String
items =
    List.map (cart 4) [ 2.23, 1.99, 9.99 ]
```

Die partielle Applikation `cart 4` nimmt noch ein weiteres Argument,
nämlich den Preis. Daher können wir sie mit Hilfe von `map` auf alle
Elemente einer Liste anwenden. Wir erhalten dann die Beschreibungen von
Einkaufswagen, die alle jeweils vier Elemente enthalten und
unterschiedliche Preise haben.

Piping
------

Funktionen höherer Ordnung haben viele Verwendungen. Wir wollen uns hier
noch eine Anwendung anschauen, die sich recht stark von Funktionen wie
`map` und `filter` unterscheidet. Wir betrachten dazu folgendes
Beispiel. Wir haben eine Liste von Zahlen `list`, aus dieser wollen wir
die geraden Zahlen filtern, dann wollen wir die verbleibenden Zahlen
quadrieren und schließlich die Summe aller Zahlen bilden. Wir können
diese Funktionalität wie folgt implementieren.

``` elm
sumOfEvenSquares : List Int -> Int
sumOfEvenSquares list =
    List.sum (List.filter (\x -> modBy 2 x == 0) (List.map (\x -> x * x) list))
```

Die Verarbeitungsschritte müssen dabei in umgekehrter Reihenfolge
angegeben werden. Das heißt, wir geben zuerst den letzten
Verarbeitungsschritt an, nämlich das Summieren. Elm stellt einen
Operator `(|>) : a -> (a -> b) -> b` zur Verfügung mit dessen Hilfe wir
die Reihenfolge der Verarbeitungsschritte umkehren können. Wir können
die Funktion mit Hilfe dieses Operators wie folgt definieren.

``` elm
sumOfEvenSquares : List Int -> Int
sumOfEvenSquares list =
    list
        |> List.map (\x -> x * x)
        |> List.filter (\x -> modBy 2 x == 0)
        |> List.sum
```

Aus Gründen der Lesbarkeit wird eine solche Sequenz von
Verarbeitungsschritten häufig wie oben aufgeführt eingerückt. Man
spricht in diesem Zusammenhang auch von *piping*.

Hinter dem Operator `(|>)` steckt die folgende einfache Definition.

``` elm
(|>) : a -> (a -> b) -> b
(|>) x f =
  f x
```

Das heißt, `(|>)` nimmt einfach das Argument und eine Funktion und
wendet die Funktion auf das Argument an. Neben dieser Definition enthält
die Elm-Implementierung noch die folgende Angabe.

``` elm
infixl 0 |>
```

Das heißt, der Operator hat die Präzedenz `0` und ist links-assoziativ.
Neben `(|>)` stellt Elm auch einen Operator `(<|) : (a -> b) -> a -> b`
zur Verfügung. Die Operatoren `(<|)` und `(|>)` werden gern verwendet,
um Klammern zu sparen. So kann man durch den Operator `(<|)` zum
Beispiel eine Funktion auf ein Argument angewendet werden, ohne das
Argument zu klammern. Wir können statt `items (23 + 42)` zum Beispiel
`item <| 23 + 42` schreiben. Die Operatoren `(<|)` und `(|>)` sollten
aber in Maßen genutzt werden, da der Code dadurch schnell schlecht
lesbar wird.

Eta-Reduktion und -Expansion
----------------------------

Mit der ge*curry*ten Schreibweise geht noch ein weiteres wichtiges
Konzept einher, die Eta-Reduktion bzw. die Eta-Expansion. Dies sind die
wissenschaftlichen Namen für Umformungen eines Ausdrucks. Bei der
Reduktion lässt man Argumente einer Funktion weg und bei der Expansion
fügt man Argumente hinzu. In
<a href="#sec:recursion-schemes" data-reference-type="ref"
data-reference="sec:recursion-schemes">1.1</a> haben wir die Funktion
`map` mittels `map inc list` auf die Funktion `inc` und die Liste `list`
angewendet. Wenn wir eine Lambda-Funktion verwenden, können wir den
Aufruf aber auch als `map (\x -> inc x) list` definieren. Diese beiden
Aufrufe verhalten sich exakt gleich. Den Wechsel von `\x -> inc x` zu
`inc` bezeichnet man als Eta-Reduktion. Den Wechsel von `inc` zu
`\x -> inc x` bezeichnet man als Eta-Expansion. Ganz allgemein kann man
durch die Anwendung der Eta-Reduktion einen Ausdruck der Form
`\x -> f x` in `f` umwandeln, wenn `f` eine Funktion ist, die mindestens
ein Argument nimmt. Durch die Eta-Expansion kann man einen Ausdruck der
Form `f` in `\x -> f x` umwandeln, wenn `f` eine Funktion ist, die
mindestens ein Argument nimmt.

Das Konzept der Eta-Reduktion und -Expansion lässt sich aber nicht nur
auf Lambda-Funktionen sondern ganz allgemein auf die Definition von
Funktionen anwenden. Als Beispiel betrachten wir noch einmal die
folgende Definition aus
<a href="#sec:recursion-schemes" data-reference-type="ref"
data-reference="sec:recursion-schemes">1.1</a>.

``` elm
incList : List Int -> List Int
incList list =
    map inc list
```

In <a href="#sec:currying" data-reference-type="ref"
data-reference="sec:currying">1.3</a> haben wir gelernt, dass diese
Definition nur eine Kurzform für die folgende Definition ist.

``` elm
incList : List Int -> List Int
incList =
    \list -> map inc list
```

Durch Eta-Reduktion können wir diese Definition jetzt zur folgenden
Definition abändern.

``` elm
incList : List Int -> List Int
incList =
    map inc
```

Das heißt, wenn wir eine Funktion definieren und diese Funktion ruft nur
eine andere Funktion mit dem Argument auf, dann können wir dieses
Argument durch die Anwendung von Eta-Reduktion auch weglassen.

Anders ausgedrückt stellen die beiden Varianten von `incList` einfach
unterschiedliche Sichtweisen auf die Definition einer Funktion dar. In
der Variante mit dem expliziten Argument `list` wird eine Funktion
definiert, indem beschrieben wird, was die Funktion mit ihrem Argument
macht. In der Variante ohne explizites Argument `list` wird eine
Funktion definiert, indem eine Funktion als partielle Applikation einer
anderen Funktion definiert wird. Man nennt diese zweite Variante auch
punkt-frei (*point-free*).

[1] https://docs.microsoft.com/de-de/dotnet/csharp/programming-guide/concepts/linq/

[2] <https://en.wikipedia.org/wiki/Haskell_Curry>

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="polymorphism.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="architecture.html">weiter</a></li>
    </ul>
</div>