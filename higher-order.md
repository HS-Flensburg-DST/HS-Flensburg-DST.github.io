---
layout: post
title: "Funktionen höherer Ordnung"
---

In diesem Kapitel wollen wir uns intensiver mit dem Thema Rekursion auseinandersetzen.
Wie wir bereits gesehen haben, kann man mithilfe von Rekursion Funktionen in Elm definieren.
Wenn man sich etwas länger mit rekursiven Funktionen beschäftigt, wird aber schnell klar, dass es unter diesen rekursiven Funktionen wiederkehrende Muster gibt.
Wir wollen uns hier einige dieser Muster anschauen.

Wiederkehrende rekursive Muster
-------------------------------

Nehmen wir an, wir haben eine Liste von Nutzer\*innen und wollen diese Liste auf unserer Seite anzeigen.
Das Feld `id` stellt dabei eine Nummer dar, mit der Nutzer\*innen eindeutig identifiziert werden.

``` elm
type alias User =
    { id : Int
    , firstName : String
    , lastName : String
    , age : Int
    }
```

Zuerst definieren wir eine Funktion, die für einen Wert vom Typ `User` eine HTML-Darstellung liefert.

```elm
viewUser : User -> Html msg
viewUser user =
    text (user.firstName ++ " " ++ user.lastName)
```

Wir können nun wie folgt eine Funktion definieren, die unsere Liste von Nutzer\*innen in eine Liste von HTML-Knoten überführt.

```elm
viewUsers : List User -> List (Html msg)
viewUsers list =
    case list of
        [] ->
            []

        user :: users ->
            viewUser user :: viewUsers users
```

Das Ergebnis der Funktion `viewUsers` würden wir zum Beispiel als Kinder eines `div`-Knotens in unsere `view`-Funktion einbinden.

Nun nehmen wir an, dass wir eine _Dropdown_-Liste zu unserer Seite hinzufügen möchten, bei der wir alle Nutzer\*innen zur Auswahl stellen möchten.
Zu diesem Zweck definieren wir zuerst eine Funktion, die zu einem Wert vom Typ `User` ein `option`-HTML-Element liefert.
Wir nutzen dabei die `id` als eindeutigen Wert für die Option und zeigen bei jeder Option den vollständigen Namen als Text an.
Anhand dieses Wertes kann später identifiziert werden, welche Option gewählt wurde.

```elm
userOption : User -> Html msg
userOption user =
    option [ value (String.fromInt user.id) ] [ viewUser user ]
```

Wir können nun wie folgt eine Funktion definieren, die eine Liste von Nutzer\*innen in eine Liste von Optionen für eine _Dropdown_-Liste umwandelt.

```elm
userOptions : List User -> List (Html msg)
userOptions list =
    case list of
        [] ->
            []

        user :: users ->
            userOption user :: userOptions users
```

Mithilfe der Funktion `Html.select` können wir dann wie folgt eine _Dropdown_-Liste definieren.
Die Funktion `onInput : (String -> msg) -> Attribute msg` aus dem Modul `Html.Events` schickt den `value` der gewählten Option an die Anwendung, wenn eine Option in der _Dropdown_-Liste gewählt wird.

```elm
view : Model -> Html msg
view model =
    select [ opInput Selected ] [ viewOptions (userOptions model.users) ]
```

Zu guter Letzt wollen wir eine Funktion definieren, die das durchschnittliche Alter unserer Nutzer\*innen berechnet.
Dazu wollen wir zuerst eine Funktion definieren, welche die Summe der Alter aller Nutzer\*innen berechnet.
Elm stellt im Modul `List` eine Funktion `sum : List Int -> Int` zur Verfügung.
Wir können diese Funktion aber nur nutzen, wenn wir eine Liste von Zahlen haben, während wir eine Liste von Nutzer\*innen zur Verfügung haben.
Wir definieren daher die folgende Funktion.

```elm
ages : List User -> List Int
ages list =
    case list of
        [] ->
            []

        user :: users ->
            user.age :: ages users
```

Nun können wir wie folgt eine Funktion definieren, die das durchschnittliche Alter der Nutzer\*innen berechnet.

```elm
averageAge : List User -> Float
averageAge users =
    toFloat (List.sum (ages users)) / toFloat (List.length users)
```

Die Funktionen `viewUsers`, `userOptions` und `ages` durchlaufen alle eine Liste von Elementen und unterscheiden sich nur in der Operation, die sie auf die Listenelemente anwenden.
Die Funktion `viewUsers` wendet `viewUser` auf alle Elemente an und die Funktion `userOptions` wendet `userOption` auf alle Elemente an.
Im Abschnitt [Records](basics.md#records) haben wir gelernt, dass der Ausdruck `user.age` nur eine Kurzform für `.age user` ist.
Daher können wir die Funktion `ages` auch wie folgt definieren.

```elm
ages : List User -> List Int
ages list =
    case list of
        [] ->
            []

        user :: users ->
            .age user :: ages users
```

Das heißt, in der Funktion `ages` wendet `.age` auf alle Elemente der Liste an.

Die drei Funktionen unterscheiden sich also nur durch die Funktion, die jeweils auf alle Elemente der Liste angewendet wird.
Allerdings unterscheiden sich auch die Typen der Funktionen, so hat die Funktion in den ersten beiden Fällen den Typ `User -> Html msg` und im letzten Beispiel `User -> Int`.

Wir können die Teile, die die drei Funktionen sich teilen, in eine Funktion auslagern.
Man nennt die Funktion, die wir dadurch erhalten `map`.
Diese Funktion erhält die Operation, die auf die Elemente der Liste angewendet wird, als Argument übergeben.

In Elm sind Funktionen _First-class Citizens_.
Übersetzt bedeutet das in etwa, dass Funktionen die gleichen Rechte haben wie andere Werte.
Das heißt, Funktionen können wie andere Werte, etwa Zahlen oder Zeichenketten, als Argumente und Ergebnisse in Funktionen verwendet werden.
Außerdem können Funktionen in Datenstrukturen stecken.

Die Funktion `map` hat die folgende Form.

``` elm
map : (a -> b) -> List a -> List b
map func list =
    case list of
        [] ->
            []

        x :: xs ->
            func x :: map func xs
```

Mithilfe der Funktion `map` können wir die Funktionen `viewUsers`, `viewOptions` und `ages` nun wie folgt definieren.

``` elm
viewUsers : List User -> List (Html msg)
viewUsers list =
    map viewUser list

viewOptions : List User -> List (Html msg)
viewOptions list =
    map viewOption list

ages : List User -> List Int
ages list =
    map .age list
```

Man nennt eine Funktion, die eine andere Funktion als Argument erhält, eine Funktion höherer Ordnung (*Higher-order Function*).

Neben dem Rekursionsmuster für `map`, wollen wir an dieser Stelle noch ein weiteres Rekursionsmuster vorstellen.
Stellen wir uns vor, dass wir aus einer Liste von Nutzer\*innen alle extrahieren möchten, deren Nachname mit a beginnt.
Dazu können wir die folgende Funktion definieren.

``` elm
startWithA : List User -> List User
startWithA list =
    case list of
        [] ->
            []

        user :: users ->
            if String.startsWith "A" user.firstName then
                user :: startWithA users
            else
                startWithA users
```

Als nächstes nehmen wir an, wir wollen das Durchschnittsalter aller Nutzer\*innen über 18 berechnen.
Dazu definieren wir die folgende Funktion.

``` elm
keepAdultAges : List Int -> List Int
keepAdultAges list =
    case list of
        [] ->
            []

        ages :: ages ->
            if ages >= 18 then
                age :: keepAdultAges xs
            else
                keepAdultAges xs
```

Mithilfe der Funktion `keepAdultAges` können wir jetzt wie folgt das Durchschnittsalter `averageAdultAge`.

```elm
averageAdultAge : List User -> Float
averageAdultAge users =
    toFloat (List.sum (keepAdultAges (ages users))) / toFloat (List.length users)
```

Wir können diese beiden Funktionen wieder mithilfe einer Funktion höherer Ordnung definieren.

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

Dieses Mal übergeben wir eine Funktion, die angibt, ob ein Element in die Ergebnisliste kommt oder nicht.
Man bezeichnet eine solche Funktion, die einen booleschen Wert liefert, auch als Prädikat.

Funktionen höherer Ordnung wie `map` und `filter` ermöglichen es, deklarativeren Code zu schreiben.
Bei der Verwendung dieser Funktionen geben Entwickler\*innen nur an, was berechnet werden soll, aber nicht wie diese Berechnung durchgeführt wird.
Wie die Berechnung durchgeführt wird, wird dabei einfach durch die Abstraktionen festgelegt.
Diese Form der deklarativen Programmierung ist in jeder Programmiersprache möglich, die es erlaubt Funktionen als Argumente zu übergeben.
Heutzutage bietet fast jede Programmiersprache dieses Sprachfeature.
Daher haben Abstraktionen wie `map` und `filter` inzwischen auch Einzug in die meisten Programmiersprachen gehalten.
Im Folgenden sind einige Programmiersprachen aufgelistet, die Abstraktionen ähnlich zu `map` und `filter` zur Verfügung stellen.

##### Java

Das Interface `java.util.stream.Stream` stellt die folgenden beiden Methoden zur Verfügung.
 
```java
<R> Stream<R> map(Function<? super T, ? extends R> mapper)

Stream<T> filter(Predicate<? super T> predicate)
```

##### C#

LINQ (Language Integrated Query)[^1] ist eine Technologie der .NET-Platform, um Anfragen elegant zu formulieren.
Die folgenden beiden Methoden, die von LINQ zur Verfügung gestellt werden, entsprechen in etwa den Funktionen `map` und `filter`.

```csharp
IEnumerable<TResult> Select<TSource,TResult>(IEnumerable<TSource>, Func<TSource,TResult>)

IEnumerable<TSource> Where<TSource> (this IEnumerable<TSource> source, Func<TSource,bool> predicate)
```

##### JavaScript

Der Prototyp `Array` bietet Methoden `map` und `filter`, welche die
Funktionalität von `map` und `filter` auf Arrays bieten.

##### Elm

Elm stellt die Funktionen `map` und `filter` im Modul `List` zur Verfügung.


## Lokale Definitionen

Bei der Anwendung von Funktionen wie `map` oder `filter` nutzt man in funktionalen Sprachen gerne lokale Definitionen, um die Funktion zu definieren, die auf jedes Element der Liste angewendet wird.
In Elm können Konstanten und Funktionen auch lokal definiert werden, das heißt, dass die entsprechende Konstante oder die Funktion nur innerhalb einer anderen Funktion sichtbar ist.
Anders ausgedrückt ist der _Scope_ einer **_Top Level_-Definition** das gesamte Modul.
_Top Level_-Definitionen sind die Definitionen, die wir bisher kennengelernt haben, also Konstanten wie `secretNumber` und Funktionen wie `viewUser` oder `map`.
Im Kontrast dazu ist der _Scope_ einer lokalen Definition auf einen bestimmten Ausdruck eingeschränkt.
Wir betrachten zuerst die Definition einer Konstante mit einer lokalen Definition.

Eine lokale Definition wird mithilfe eines `let`-Ausdrucks eingeführt.

``` elm
quartic : Int -> Int
quartic x =
    let
        square =
            x * x
    in
    square * square
```

Ein `let`-Ausdruck startet mit dem Schlüsselwort `let`, definiert dann beliebig viele Konstanten und Funktionen und schließt schließlich mit dem Schlüsselwort `in` ab.
Die Definitionen, die ein `let`-Ausdruck einführt, stehen nur in dem Ausdruck nach dem `in` zur Verfügung.
Das heißt, wir können `square` hier in `square * square` verwenden, aber nicht außerhalb der Definition `quartic`.
Die lokalen Definitionen wie hier `square` können auch auf die Argumente der umschließenden Funktion zugreifen, hier `x`.

Man kann in einem `let`-Ausdruck auch **Funktionen** definieren, die dann auch nur in dem Ausdruck nach dem `in` sichtbar sind.
Wir werden später Beispiele sehen, in denen dies sehr praktisch ist, etwa, wenn wir Listen verarbeiten.
Dort wird häufig die Verarbeitung eines einzelnen Listenelementes als lokale Funktion definiert.
Im folgenden Beispiel wird eine lokale Funktion definiert, die eine Zahl um einen erhöht.

``` elm
res : Int
res =
    let
        inc n =
            n + 1
    in
    inc 41
```

Wie andere Programmiersprachen, zum Beispiel Python, Elixir und Haskell, nutzt Elm eine **Off-side Rule**.
Das heißt, die Einrückung eines Programms wird genutzt, um Klammerung auszudrücken und somit Klammern einzusparen.
In objektorientierten Sprachen wie Java wird diese Klammerung explizit durch geschweifte Klammern ausgedrückt.
Dagegen muss die Liste der Definitionen in einem `let` zum Beispiel nicht geklammert werden, sondern wird durch ihre Einrückung dem `let`-Block zugeordnet.

Das Prinzip der *Off-side Rule* wurde durch Peter J. Landin[^2] in seiner wegweisenden Veröffentlichung "The Next 700 Programming Languages" im Jahr 1966 erfunden.

> Any non-whitespace token to the left of the first such token on the previous line is taken to be the start of a new declaration.

Um diese Aussage zu illustrieren, betrachten wir das folgende
Beispielprogramm, das vom Compiler aufgrund der Einrückung nicht
akzeptiert wird.

``` elm
layout1 : Int
layout1 =
    let
    x =
        1
    in
    42
```

Das Schlüsselwort `let` definiert eine Spalte.
Alle Definitionen im `let` müssen in einer Spalte rechts vom Schlüsselwort `let` starten.
Die erste Definition, die in der Spalte des `let` oder weiter links steht, beendet die Sequenz der Definitionen.
Die Definition `layout1` wird nicht akzeptiert, da die Sequenz der Definitionen durch das `x` beendet wird, was aber keine valide Syntax ist, da die Sequenz mit dem Schlüsselwort `in` beendet werden muss.

Als weiteres Beispiel betrachten wir die folgende Definition, die ebenfalls aufgrund der Einrückung nicht akzeptiert wird.

``` elm
layout2 : Int
layout2 =
    let
        x =
            1

         y =
            2
    in
    42
```

Die erste Definition in einem `let`-Ausdruck, also hier das `x`, definiert ebenfalls eine Spalte.
Alle Zeilen, die links von der ersten Definition starten, beenden die Liste der Definitionen.
Alle Zeilen, die rechts von einer Definition starten, werden noch zu dieser Definition gezählt.
Das heißt, in diesem Beispiel geht der Compiler davon aus, dass die Definition von `y` eine Fortsetzung der Definition von `x` ist.
Dies ist auch wieder keine valide Syntax, da damit die Variable `x` den Wert des Ausdrucks `1 y = 2` erhält.
Dies ist aber kein valider Ausdruck.
Das folgende Beispiel zeigt noch einmal eine valide Definition eines `let`-Ausdrucks mit zwei lokalen Definitionen.

``` elm
layout3 : Int
layout3 =
    let
        x =
            1

        y =
            2
    in
    42
```

Das `let`-Konstrukt ist ein Ausdruck, kann also an allen Stellen stehen, an denen ein Ausdruck stehen kann.
Um diesen Aspekt zu illustrieren, betrachten wir die folgende, nicht sehr sinnvolle, aber vom Compiler akzeptierte Definition.

```elm
letExpr : Int
letExpr =
    (let
        x =
            1
     in
     x
    )
        * 23
```

Der `let`-Ausdruck liefert einen Wert vom Typ `Int`.
Daher können wir den `let`-Ausdruck mit der Zahl `23` multiplizieren.
Wir müssen hier den `let`-Ausdruck klammern, da andernfalls der Wert der Variable `x` mit `23` multipliziert wird.

Wenn eine Funktion wie `viewUser` nur in der Anwendung der Funktion `map` oder `filter` verwendet wird, nutzt man gern wie folgt eine lokale Definition.

``` elm
viewUsers : List Int -> List Int
viewUsers list =
    let
        viewUser user =
            text (user.firstName ++ " " ++ user.lastName)
    in
    List.map viewUser list
```

Diese Definition verhindert, dass die Funktion `viewUser` außerhalb der Definition `viewUsers` verwendet wird.
Dadurch kann man verhindern, dass Funktionen, die eigentlich nur im Kontext einer ganz bestimmten Funktion sinnvoll sind, aus Versehen globaler verwendet werden.
Außerdem bindet man auf diese Weise die Position der Definition `viewUser` an die Position der Definition `viewUsers`.
Das heißt, es kann nicht passieren, dass man im Modul springen muss, um die Definition von `viewUser` zu suchen.

Es gibt keine feste Regel, wann man eine Funktion wie `viewUser` lokale und wann auf _Top Level_ definieren sollte.
Grundsätzlich kann man sich überlegen, ob man eine Funktion alleinstehend als _Black Box_ verstehen kann.
In diesem Fall ist es durchaus sinnvoll, eine Funktion auf _Top Level_ zu definieren.


Anonyme Funktionen
------------------

Um die Funktion `startWithA` mithilfe von `filter` zu definieren, müssten wir das folgende Prädikat definieren.

```elm
userStartsWithA : User -> Bool
userStartsWithA user =
    String.startsWith "A" user.firstName
```

Es ist recht umständlich extra die Funktionen `userStartsWithA` zu definieren, nur, um sie in der Definition von `startWithA` einmal zu verwenden, unabhängig davon, ob wir die Funktion lokal definieren oder nicht.
Stattdessen kann man anonyme Funktionen verwenden.
Anonyme Funktionen sind einfach Funktionen, die keinen Namen erhalten.
Die Funktion `userStartsWithA` kann zum Beispiel wie folgt mithilfe einer anonymen Funktion definiert werden.

``` elm
startWithA : List User -> List User
startWithA list =
    List.filter (\user -> String.startsWith "A" user.firstName) list
```

Dabei stellt der Ausdruck `\user -> String.startsWith "A" user.firstName` die anonyme Funktion dar.
Analog können wir die Funktion `viewUsers` mithilfe einer anonymen Funktion wie folgt definieren.

``` elm
viewUsers : List User -> List (Html msg)
viewUsers list =
    List.map (\user -> text (user.firstName ++ " " ++ user.lastName)) list
```

Anonyme Funktionen, auch als Lambda-Ausdrücke bezeichnet, starten mit dem Zeichen `\` und listen dann eine Reihe von Argumenten auf, nach den Argumenten folgen die Zeichen `->` und schließlich die rechte Seite der Funktion.
Das heißt, der Ausdruck `\x y -> x * y` definiert zum Beispiel eine Funktion, die ihre beiden Argumente multipliziert.
Ein Lambda-Ausdruck der Form `\x y -> e` entspricht dabei der folgenden Funktionsdefinition.

``` elm
f x y = e
```

Der einzige Unterschied ist, dass wir die Funktion nicht verwenden, indem wir ihren Namen schreiben, sondern indem wir den gesamten Lambda-Ausdruck angeben.
Während wir `f` zum Beispiel auf Argumente anwenden, indem wir `f 1 2` schreiben, wenden wir den Lambda-Ausdruck an, indem wir `(\x y -> e) 1 2` schreiben.


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

Die Funktion `cart` nennt man die ge*curry*te Variante und die Funktion `cartP` die unge*curry*te Variante.
Die Funktion `cart` nimmt zwar auf den ersten Blick zwei Argumente, wir können den Typ der Funktion `cart` aber auch anders angeben.
Die Schreibweise `Int -> Float -> String` steht eigentlich für den Typ `Int -> (Float -> String)`, das heißt, der Typkonstruktor `->` ist rechts-assoziativ.
Das heißt, `cart` ist eine Funktion, die einen Wert vom Typ `Int` nimmt und eine Funktion vom Typ `Float -> String` liefert.
Während der Funktionspfeil rechtsassoziativ ist, ist die Anwendung einer Funktion linksassoziativ.
Das heißt, die Anwendung `cart 4 2.23` steht eigentlich für `(cart 4) 2.23`.
Wir wenden also zuerst die Funktion `cart` auf das Argument `4` an.
Wir erhalten dann eine Funktion, die noch einen `Float` als Argument erwartet.
Diese Funktion wenden wir dann auf `2.23` an und erhalten schließlich einen `String`.

Die Idee, Funktionen mit mehreren Argumenten als Funktion zu repräsentieren, die ein Argument nimmt und eine Funktion liefert, wird als *Currying* bezeichnet.
*Currying* ist nach dem amerikanischen Logiker Haskell Brooks Curry[^3] benannt (1900–1982), nach dem auch die Programmiersprache Haskell benannt ist.

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
Man spricht in diesem Zusammenhang auch von _Piping_ in Anlehung an das entsprechende Konzept in einer Shell.

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
Man sollte den Operator `|>` allerdings wirklich nur einsetzen, wenn man, wie in `sumOfAdultAges` eine Sequenz von Transformationen durchführt.
Wenn man den Operator `|>` für "normale" Funktionsanwendungen innerhalb eines komplexeren Ausdrucks verwendet, wird der Code sehr schnell schlecht lesbar.

Neben `|>` stellt Elm auch einen Operator `(<|) : (a -> b) -> a -> b` zur Verfügung.
Die Operatoren `<|` und `|>` werden gern verwendet, um Klammern zu sparen.
So kann man durch den Operator `<|` zum Beispiel eine Funktion auf ein Argument angewendet werden, ohne das Argument zu klammern.
Wir können statt `items (23 + 42)` zum Beispiel `item <| 23 + 42` schreiben.
Es ist relativ verbreitet, die Operatoren `<|` und `|>` zu nutzen.
Um existierenden Elm-Code lesen zu können, sollte man die Operatoren daher kennen.
In vielen Fällen wird der Code durch die Verwendung dieser Operatoren aber nicht unbedingt lesbarer.
Daher sollten die Operatoren vor allem genutzt werden, wenn es sich tatsächlich um eine längere Sequenz von Transformationen wie in der Definition von `sumOfAdultAges` handelt.
Ansonsten sollte man die Operatoren aber eher vermeiden.


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

An dieser Stelle soll noch kurz erwähnt werden, dass sie Eta-Reduktion auch anwenden lässt, wenn eine _Top Level_-Funktion eine lokale Definition enthält.
Dazu betrachten wir die folgende Variante der Funktion `viewUsers`.
In dieser Variante haben wir die Funktion `viewUser`, die auf jedes Element der Liste angewendet wird, als lokale Funktion in einem `let`-Ausdruck definiert.
Es kommt in Elm relativ häufig vor, dass man eine lokale Funktion definiert und diese mithilfe von `List.map` auf alle Elemente einer Liste anwendet.
Häufig definiert man die Funktion, die auf die Elemente der Liste angewendet wird, lokal, das sie außerhalb der Funktion nicht benötigt wird.

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


Funktionskomposition
--------------------

Am Ende dieses Kapitels wollen wir noch eine weitere Funktion höherer Ordnung betrachten, die es ermöglicht, Eta-Reduktion anzuwenden, wenn mehrere Funktionen hintereinander angewendet werden.
Diese Funktionen höherer Ordnung wird als Funktionskomposition bezeichnet und ist wie folgt definiert.

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
Hierbei handelt es sich um eine partielle Applikation, da die Funktion `String.startsWith` zwei Argumente nimmt, wie diese Funktion aber nur auf ein Argument anwenden.
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

[^1]: <https://docs.microsoft.com/de-de/dotnet/csharp/programming-guide/concepts/linq>

[^2]: Peter J. Landin (<https://en.wikipedia.org/wiki/Peter_Landin>) war einer der Begründer der funktionalen Programmierung.

[^3]: <https://en.wikipedia.org/wiki/Haskell_Curry>

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="design.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="architecture.html">weiter</a></li>
    </ul>
</div>