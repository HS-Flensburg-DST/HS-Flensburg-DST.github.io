---
layout: post
title: "Funktionen höherer Ordnung"
---

Im Kapitel [Funktionale Abstraktionen](functional-abstractions.md) haben wir bereits gesehen, dass man sich wiederholende Muster in Funktionen höherer Ordnung auslagern kann.
In diesem Kapitel wollen wir uns jetzt noch einmal ein paar fortgeschrittene Themen aus dem Bereich der Funktionen höherer Ordnung diskutieren.


Gecurryte Funktionen
----------------------

Um Funktionen höherer Ordnung in vollem Umfang nutzen zu können, müssen wir uns eine grundlegende Eigenschaft von Funktionen in Elm anschauen, die wir bisher unter den Tisch gekehrt haben.
Dazu schauen wir uns noch einmal die Definition von mehrstelligen Funktionen an, die wir im Abschnitt [Mehrstellige Funktionen](basics.md#mehrstellige-funktionen) eingeführt haben.

``` elm
cart : Int -> Float -> String
cart quantity price =
    "Summe (" ++ items quantity ++ "): " ++ String.fromFloat price
```

Wir haben dabei gelernt, dass man zwischen zwei Argumente immer einen Pfeil schreiben muss, wir haben aber bisher nicht diskutiert warum.
In einer Programmiersprache wie Java würden wir die Funktion eher wie folgt definieren.

``` elm
cartP : ( Int, Float ) -> String
cartP ( quantity, price ) =
    "Summe (" ++ items quantity ++ "): " ++ String.fromFloat price
```

Die Funktion `cart` nennt man die **ge*curry*te** Variante und die Funktion `cartP` die **unge*curry*te** Variante.
Die Funktion `cart` nimmt zwar auf den ersten Blick zwei Argumente, wir können den Typ der Funktion `cart` aber auch anders angeben.
Die Schreibweise `Int -> Float -> String` steht eigentlich für den Typ `Int -> (Float -> String)`, das heißt, der Typkonstruktor `->` ist rechts-assoziativ.
Das heißt, `cart` ist eine Funktion, die einen Wert vom Typ `Int` nimmt und eine Funktion vom Typ `Float -> String` liefert.
Während der Funktionspfeil rechtsassoziativ ist, ist die Anwendung einer Funktion linksassoziativ.
Das heißt, die Anwendung `cart 4 2.23` steht eigentlich für `(cart 4) 2.23`.
Wir wenden also zuerst die Funktion `cart` auf das Argument `4` an.
Wir erhalten dann eine Funktion, die noch einen `Float` als Argument erwartet.
Diese Funktion wenden wir dann auf `2.23` an und erhalten schließlich einen `String`.

Die Idee, Funktionen mit mehreren Argumenten als Funktion zu repräsentieren, die ein Argument nimmt und eine Funktion liefert, wird als *Currying* bezeichnet.
*Currying* ist nach dem amerikanischen Logiker Haskell Brooks Curry[^1] benannt (1900–1982), nach dem auch die Programmiersprache Haskell benannt ist.

Die Definition von `cart` ist im Grunde nur eine vereinfachte Schreibweise der folgenden Definition.

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

In dieser Form der Definition ist ganz explizit dargestellt, dass `cartL` eine Funktion ist, die ein Argument `quantity` nimmt und als Ergebnis wiederum eine Funktion liefert.
Um Schreibarbeit zu reduzieren, entsprechen alle Definitionen, die wir in Elm angeben, im Endeffekt diesem Muster.
Wir können die Funktionen aber mit der Kurzschreibweise von `cart`, die auf die Verwendung der Lambda-Funktionen verzichtet, definieren.

Mithilfe der Definition `cartL` können wir noch einmal illustrieren, dass die Funktionsanwendung linksassoziativ ist.

``` elm
cartL 4 2.23
=
(cartL 4) 2.23
=
((\quantity -> \price ->
    "Summe (" ++ items quantity ++ "): " ++ String.fromFloat price)
       4) 2.23
=
(\price ->
    "Summe (" ++ items 4 ++ "): " ++ String.fromFloat price)
          2.23
=
"Summe (" ++ items 4 ++ "): " ++ String.fromFloat 2.23
```

Partielle Applikationen
-----------------------

Mit der ge*curry*ten Definition von Funktionen gehen zwei wichtige Konzepte einher.
Das erste Konzept wird partielle Applikation oder partielle Anwendung genannt.
Funktionen in der ge*curry*ten Form lassen sich sehr leicht partiell applizieren.
Applikation ist der Fachbegriff für das Anwenden einer Funktion auf konkrete Argumente.
Eine partielle Applikation ist die Anwendung einer Funktion auf eine Anzahl von konkreten Argumenten, so dass der Anwendung noch weitere Argumente fehlen.
Um zu illustrieren, was eine partielle Anwendung bedeutet, betrachten wir die Anwendung von `cartL` auf das Argument `4`.

``` elm
cartL 4
=
(\quantity -> \price ->
    "Summe (" ++ items quantity ++ "): " ++ String.fromFloat price)
      4
=
\price ->
    "Summe (" ++ items 4 ++ "): " ++ String.fromFloat price
```

Das heißt, wenn wir die Funktion `cartL` partiell auf das Argument `4` anwenden, erhalten wir eine Funktion, die noch den Preis erwartet und einen Text liefert, der vier Gegenstände enthält.
Wir können die Funktion `cart` genau auf diese Weise partiell anwenden.
Wir betrachten das folgende Beispiel.

``` elm
items : List String
items =
    List.map (cart 4) [ 2.23, 1.99, 9.99 ]
```

Die partielle Applikation `cart 4` nimmt noch ein weiteres Argument, nämlich den Preis.
Daher können wir sie mithilfe von `map` auf alle Elemente einer Liste anwenden.
Wir erhalten dann die Beschreibungen von Einkaufswagen, die alle jeweils vier Elemente enthalten und unterschiedliche Preise haben.

Piping
------

Funktionen höherer Ordnung haben viele Verwendungen.
Wir wollen uns hier noch eine Anwendung anschauen, die sich recht stark von Funktionen wie `map` und `filter` unterscheidet.
Wir betrachten dazu folgendes Beispiel.
Wir wollen wiederum das Durchschnittsalter aller volljährigen Nutzer\*innen berechnen.
Dazu berechnen wir die Summe der Alter aller Nutzer\*innen über 18.
Wir nutzen erst `List.map`, um eine Liste von Altersangaben zu erhalten, wir filtern die Altersangaben, die größer gleich `18` sind und summieren schließlich das Ergebnis.

``` elm
sumOfAdultAges : List User -> Int
sumOfAdultAges list =
    List.sum (List.filter (\age -> age >= 18) (List.map .age list))
```

Die Verarbeitungsschritte müssen dabei in umgekehrter Reihenfolge angegeben werden.
Das heißt, wir geben zuerst den letzten Verarbeitungsschritt an, nämlich das Summieren.
Elm stellt einen Operator `(|>) : a -> (a -> b) -> b` zur Verfügung mit dessen Hilfe wir die Reihenfolge der Verarbeitungsschritte umkehren können.
Wir können die Funktion mithilfe dieses Operators wie folgt definieren.

``` elm
sumOfAdultAges : List Int -> Int
sumOfAdultAges list =
    list
        |> List.map .age
        |> List.filter (\age -> age >= 18)
        |> List.sum
```

Aus Gründen der Lesbarkeit wird eine solche Sequenz von Verarbeitungsschritten häufig wie oben aufgeführt eingerückt.
Man spricht in diesem Zusammenhang auch von _Piping_ in Anlehung an das entsprechende Konzept in einer _Shell_.

Hinter dem Operator `(|>)` steckt die folgende einfache Definition.

``` elm
(|>) : a -> (a -> b) -> b
(|>) x f =
  f x
```

Das heißt, `(|>)` nimmt einfach das Argument und eine Funktion und wendet die Funktion auf das Argument an.
Neben dieser Definition enthält die Elm-Implementierung noch die folgende Angabe.

``` elm
infixl 0 |>
```

Das heißt, der Operator hat die Präzedenz `0` und ist links-assoziativ.

Neben `|>` stellt Elm auch einen Operator `(<|) : (a -> b) -> a -> b` zur Verfügung.
Die Operatoren `<|` und `|>` werden gern verwendet, um Klammern zu sparen.
So kann man durch den Operator `<|` zum Beispiel eine Funktion auf ein Argument angewendet werden, ohne das Argument zu klammern.
Wir können statt `items (23 + 42)` zum Beispiel `item <| 23 + 42` schreiben.
Es ist relativ verbreitet, die Operatoren `<|` und `|>` zu nutzen.
Um existierenden Elm-Code lesen zu können, sollte man die Operatoren daher kennen.
In vielen Fällen wird der Code durch die Verwendung dieser Operatoren aber nicht unbedingt lesbarer.
Daher sollten die Operatoren vor allem genutzt werden, wenn es sich tatsächlich um eine längere Sequenz von Transformationen wie in der Definition von `sumOfAdultAges` handelt.
Ansonsten sollte man die Operatoren aber eher vermeiden.
Leider ist die Verwendung der Operatoren `<|` und `|>` auch in solchen Fällen, in denen die Verwendung den Code eher schlechter lesbar macht, in Elm relativ weit verbreitet.


Eta-Reduktion und -Expansion
----------------------------

Mit der gecurryten Schreibweise geht noch ein weiteres wichtiges Konzept einher, die Eta-Reduktion bzw. die Eta-Expansion.
Dies sind die wissenschaftlichen Namen für Umformungen eines Ausdrucks.
Bei der Reduktion lässt man Argumente einer Funktion weg und bei der Expansion fügt man Argumente hinzu.
Im Abschnitt [Wiederkehrende rekursive Muster](#wiederkehrende-rekursive-muster) haben wir die Funktion `map` mittels `map viewUser list` auf die Funktion `viewUser` und die Liste `list` angewendet.
Wenn wir eine Lambda-Funktion verwenden, können wir den Aufruf aber auch als `map (\user -> viewUser user) list` definieren.
Diese beiden Aufrufe verhalten sich exakt gleich.
Den Wechsel von `\user -> viewUser user` zu `viewUser` bezeichnet man als Eta-Reduktion.
Den Wechsel von `viewUser` zu `\user -> viewUser user` bezeichnet man als Eta-Expansion.
Ganz allgemein kann man durch die Anwendung der Eta-Reduktion einen Ausdruck der Form `\x -> f x` in `f` umwandeln, wenn `f` eine Funktion ist, die mindestens ein Argument nimmt.
Durch die Eta-Expansion kann man einen Ausdruck der Form `f` in `\x -> f x` umwandeln, wenn `f` eine Funktion ist, die mindestens ein Argument nimmt.

Das Konzept der Eta-Reduktion und -Expansion lässt sich aber nicht nur auf Lambda-Funktionen sondern ganz allgemein auf die Definition von Funktionen anwenden.
Als Beispiel betrachten wir noch einmal die folgende Definition aus dem  Abschnitt [Wiederkehrende rekursive Muster](#wiederkehrende-rekursive-muster).

``` elm
viewUsers : List User -> List (Html msg)
viewUsers list =
    List.map viewUser list
```

Im Abschnitt [Gecurryte Funktionen](#gecurryte-funktionen) haben wir gelernt, dass diese Definition nur eine Kurzform für die folgende Definition ist.

``` elm
viewUsers : List User -> List (Html msg)
viewUsers =
    \list -> List.map viewUser list
```

Durch Eta-Reduktion können wir diese Definition jetzt zur folgenden Definition abändern.

``` elm
viewUsers : List User -> List (Html msg)
viewUsers =
    List.map viewUser
```

Das heißt, wenn wir eine Funktion definieren und diese Funktion ruft nur eine andere Funktion mit dem Argument auf, dann können wir dieses Argument durch die Anwendung von Eta-Reduktion auch weglassen.

Anders ausgedrückt stellen die beiden Varianten von `viewUsers` einfach unterschiedliche Sichtweisen auf die Definition einer Funktion dar.
In der Variante mit dem expliziten Argument `list` wird eine Funktion definiert, indem beschrieben wird, was die Funktion mit ihrem Argument macht.
In der Variante ohne explizites Argument `list` wird eine Funktion definiert, indem eine Funktion als partielle Applikation einer anderen Funktion definiert wird. Man nennt diese zweite Variante auch punkt-frei (*point-free*).

An dieser Stelle soll noch kurz erwähnt werden, dass sich Eta-Reduktion auch anwenden lässt, wenn eine _Top Level_-Funktion eine lokale Definition enthält.
Dazu betrachten wir die folgende Variante der Funktion `viewUsers`.
In dieser Variante haben wir die Funktion `viewUser`, die auf jedes Element der Liste angewendet wird, als lokale Funktion in einem `let`-Ausdruck definiert.
Es kommt in Elm relativ häufig vor, dass man eine lokale Funktion definiert und diese mithilfe von `List.map` auf alle Elemente einer Liste anwendet.
Häufig definiert man die Funktion, die auf die Elemente der Liste angewendet wird, lokal, da sie außerhalb der Funktion nicht benötigt wird.

``` elm
viewUsers : List Int -> List Int
viewUsers list =
    let
        viewUser user =
            text (user.firstName ++ " " ++ user.lastName)
    in
    List.map viewUser list
```

Auf diese Variant von `viewUsers` kann man ebenfalls Eta-Reduktion anwenden und erhält die folgende Definition.

``` elm
viewUsers : List Int -> List Int
viewUsers =
    let
        viewUser user =
            text (user.firstName ++ " " ++ user.lastName)
    in
    List.map viewUser
```

Die Definition einer Funktion wie `viewUsers` mithilfe eines `let`-Ausdrucks ist relativ beliebt.
Sie hat den Vorteil, dass die Funktion `viewUser` nur in der Definition von `viewUsers` verwendet werden kann.
Dies ist vor allem sinnvoll, wenn die Funktion `viewUser` wirklich nur im Kontext dieser Funktion verwendet werden sollte.
Im Fall von `viewUsers` verwerfen wir zum Beispiel einige der Komponenten, was in vielen anderen Anwendungsfällen möglicherweise nicht sinnvoll ist.
Im Unterschied zur Definition mithilfe einer Lambda-Funktion, können wir der Funktion `viewUser` bei der Verwendung eines `let`-Ausdrucks einen Namen geben, der Entwickler\*innen ggf. hilft, den Code zu verstehen.
Im Allgemeinen verwendet man meistens eine Lambda-Funktion, solange die Funktion recht einfach ist und nutzt einen `let`-Ausdruck sobald die Funktion etwas komplizierter wird.

{% include callout-info.html content="In Elm ist es im Gegensatz zu Haskell nicht möglich, Infixoperatoren partiell zu applizieren.
Das heißt, während man in Haskell mit dem Ausdruck `(1 +)` eine Funktion definiert, die ein Argument nimmt und dieses Argument um eins erhöht, ist dies in Elm nicht möglich." %}


Funktionskomposition
--------------------

Am Ende dieses Kapitels wollen wir noch eine weitere Funktion höherer Ordnung betrachten, die es ermöglicht, Eta-Reduktion anzuwenden, wenn mehrere Funktionen hintereinander angewendet werden.
Diese Funktion höherer Ordnung wird als Funktionskomposition bezeichnet und ist wie folgt definiert.

```elm
(<<) : (b -> c) -> (a -> b) -> a -> c
g << f =
    \x -> g (f x)
```

Die Funktionskomposition kann genutzt werden, um eine neue Funktion zu definieren, indem wir zwei bestehende Funktionen kombinieren.
Wir betrachten noch einmal die Funktion `startWithA`.

``` elm
startWithA : List User -> List User
startWithA list =
    List.filter (\user -> String.startsWith "A" user.firstName) list
```

Mithilfe der Funktionskomposition können wir diese Funktion wie folgt definieren.

``` elm
startWithA : List User -> List User
startWithA list =
    List.filter (String.startsWith "A" << .firstName) list
```

Die Funktion `String.startsWith "A" << .firstName` erhält ein Argument und wendet auf dieses Argument zuerst die Funktion `.firstName` an.
Auf das Ergebnis der Funktion `.firstName` wird die Funktion `String.startsWith "A"` angewendet.
Hierbei handelt es sich um eine partielle Applikation, da die Funktion `String.startsWith` zwei Argumente nimmt, wir `String.startsWith` aber nur auf ein Argument anwenden.
Die partielle Applikation `String.startsWith "A"` nimmt einen `String` und testet, ob der `String` mit dem Buchstaben `"A"` startet.

Um die Funktionsweise der Funktionskomposition noch etwas zu illustrieren, können wir das funktionale Argument von `List.filter` Eta-expandieren und erhalten die folgende Definition.

``` elm
startWithA : List User -> List User
startWithA list =
    List.filter (\user -> (String.startsWith "A" << .firstName) user) list
```

Das heißt, das funktionale Argument ist eine Funktion, die das Argument `user` nimmt und die Funktion `(String.startsWith "A" << .firstName)` auf `user` anwendet.

Als weiteres Beispiel wollen wir uns noch einmal die Funktion `sumOfAdultAges` anschauen.

``` elm
sumOfAdultAges : List User -> Int
sumOfAdultAges list =
    List.sum (List.filter (\age -> age >= 18) (List.map .age list))
```

Die Funktion wendet mehrere Funktionen nacheinander auf das Argument `list` an.
Daher können wir diese Funktion auch mithilfe der Funktionskomposition definieren.

``` elm
sumOfAdultAges : List User -> Int
sumOfAdultAges list =
    (List.sum << List.filter (\age -> age >= 18) << List.map .age) list
```

Da wir `sumOfAdultAges` nun mittels Funktionskomposition definiert haben, können wir Eta-Reduktion anwenden und erhalten das folgende Ergebnis.

``` elm
sumOfAdultAges : List User -> Int
sumOfAdultAges =
    List.sum << List.filter (\age -> age >= 18) << List.map .age
```

Das heißt, mithilfe der Funktionskomposition können wir Funktionen eta-reduzieren, die mehrere Funktionen nacheinander auf ein Argument anwenden.

Analog zu den Funktionen `<|` und `|>` gibt es neben der klassischen Form der Funktionskomposition `<<` in Elm noch den Operator `(>>) : (a -> b) -> (b -> c) -> a -> c`, bei dem die Argumente im Vergleich zu `<<` vertauscht sind.
Mit der Funktion `>>` können wir `sumOfAdultAges` jetzt zum Beispiel im Stil des _Pipings_ wie folgt definieren.

``` elm
sumOfAdultAges : List User -> Int
sumOfAdultAges =
    List.map .age
        >> List.filter (\age -> age >= 18)
        >> List.sum
```

Das heißt, auf das Argument der Funktion `sumOfAdultAges` wird zuerst die Funktion `List.map .age` angewendet, dann wird `List.filter (\age -> age >>= 18)` angewendet und zu guter Letzt `List.sum`.

[^1]: <https://en.wikipedia.org/wiki/Haskell_Curry>

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="design.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="commands.html">weiter</a></li>
    </ul>
</div>
