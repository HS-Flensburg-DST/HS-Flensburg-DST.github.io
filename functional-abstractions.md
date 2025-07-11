---
layout: post
title: "Funktionale Abstraktionen"
---

{% include embed-audio.html src="/assets/podcasts/Functional Abstractions.mp3" %}

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
viewUser { firstName, lastName } =
    text (firstName ++ " " ++ lastName)
```

Wir können nun wie folgt eine Funktion definieren, die unsere Liste von Nutzer\*innen in eine Liste von HTML-Knoten überführt.

```elm
viewUsers : List User -> List (Html msg)
viewUsers users =
    case users of
        [] ->
            []

        user :: users_ ->
            viewUser user :: viewUsers users_
```

Das Ergebnis der Funktion `viewUsers` würden wir zum Beispiel als Kinder eines `div`-Knotens in unsere `view`-Funktion einbinden.

Nun nehmen wir an, dass wir eine _Dropdown_-Liste zu unserer Seite hinzufügen möchten, bei der wir alle Nutzer\*innen zur Auswahl stellen möchten.
Zu diesem Zweck definieren wir zuerst eine Funktion, die zu einem Wert vom Typ `User` ein HTML-Element `option` liefert.
Wir nutzen dabei die `id` als eindeutigen Wert für die Option und zeigen bei jeder Option den vollständigen Namen als Text an.
Anhand des eindeutigen Wertes kann später identifiziert werden, welche Option gewählt wurde.

```elm
viewUserOption : User -> Html msg
viewUserOption user =
    option [ value (String.fromInt user.id) ] [ viewUser user ]
```

Wir können nun wie folgt eine Funktion definieren, die eine Liste von Nutzer\*innen in eine Liste von Optionen für eine _Dropdown_-Liste umwandelt.

```elm
viewUserOptions : List User -> List (Html msg)
viewUserOptions users =
    case users of
        [] ->
            []

        user :: users_ ->
            viewUserOption user :: viewUserOptions users_
```

Mithilfe der Funktion `Html.select` können wir dann wie folgt eine _Dropdown_-Liste definieren.
Die Funktion `onInput : (String -> msg) -> Attribute msg` aus dem Modul `Html.Events` schickt den `value` der gewählten Option an die Anwendung, wenn eine Option in der _Dropdown_-Liste gewählt wird.

```elm
view : Model -> Html Msg
view model =
    select [ opInput Selected ] (viewUserOptions model.users)
```

Zu guter Letzt wollen wir eine Funktion definieren, die das durchschnittliche Alter unserer Nutzer\*innen berechnet.
Dazu wollen wir zuerst eine Funktion definieren, welche die Summe der Alter aller Nutzer\*innen berechnet.
Elm stellt im Modul `List` eine Funktion `sum : List Int -> Int` zur Verfügung.
Wir können diese Funktion aber nur nutzen, wenn wir eine Liste von Zahlen haben, während wir eine Liste von Nutzer\*innen zur Verfügung haben.
Wir definieren daher die folgende Funktion.

```elm
ages : List User -> List Int
ages users =
    case users of
        [] ->
            []

        user :: users_ ->
            user.age :: ages users_
```

Nun können wir wie folgt eine Funktion definieren, die das durchschnittliche Alter der Nutzer\*innen berechnet.

```elm
averageAge : List User -> Float
averageAge users =
    toFloat (List.sum (ages users)) / toFloat (List.length users)
```

Die Funktionen `viewUsers`, `viewUserOptions` und `ages` durchlaufen alle eine Liste von Elementen und unterscheiden sich nur in der Operation, die sie auf die Listenelemente anwenden.
Die Funktion `viewUsers` wendet `viewUser` auf alle Elemente an und die Funktion `viewUserOptions` wendet `viewUserOption` auf alle Elemente an.
Im Abschnitt [Records](basics.md#records) haben wir gelernt, dass der Ausdruck `user.age` nur eine Kurzform für `.age user` ist.
Daher können wir die Funktion `ages` auch wie folgt definieren.

```elm
ages : List User -> List Int
ages users =
    case users of
        [] ->
            []

        user :: users_ ->
            .age user :: ages users_
```

Das heißt, die Funktion `ages` wendet `.age` auf alle Elemente der Liste an.

Die drei Funktionen unterscheiden sich also nur durch die Funktion, die jeweils auf alle Elemente der Liste angewendet wird.
Allerdings unterscheiden sich auch die Typen der Funktionen, so hat die Funktion in den ersten beiden Fällen den Typ `User -> Html msg` und im letzten Beispiel `User -> Int`.

Wir können die Teile, die die drei Funktionen sich teilen, in eine Funktion auslagern.
Man nennt die Funktion, die wir dadurch erhalten `map`.
Diese Funktion erhält die Operation, die auf die Elemente der Liste angewendet wird, als Argument übergeben.

In Elm sind Funktionen **_First-class Citizens_**.
Übersetzt bedeutet das in etwa, dass Funktionen die gleichen Rechte haben wie andere Werte.

{% include callout-important.html content="
Das heißt, Funktionen können wie andere Werte, etwa Zahlen oder Zeichenketten, als Argumente und Ergebnisse in Funktionen verwendet werden.
" %}

Außerdem können Funktionen in Datenstrukturen stecken.
Wenn wir uns die Umsetzung der _Model_-_View_-_Update_-Architektur in Elm genauer anschauen, werden wir sehen, dass wir schon mehrfach die Tatsache genutzt haben, dass Funktionen in Datenstrukturen stecken können.

Wie bereits erwähnt, hat das wiederkehrende rekursive Muster, das wir identifiziert haben, in der funktionalen Programmierung den Namen `map`.
Die Funktion `map` hat in Elm die folgende Form.

``` elm
map : (a -> b) -> List a -> List b
map func list =
    case list of
        [] ->
            []

        head :: tail ->
            func head :: map func tail
```

Mithilfe der Funktion `map` können wir die Funktionen `viewUsers`, `viewUserOptions` und `ages` nun wie folgt definieren.

``` elm
viewUsers : List User -> List (Html msg)
viewUsers users =
    map viewUser users

viewUserOptions : List User -> List (Html msg)
viewUserOptions users =
    map viewUserOption users

ages : List User -> List Int
ages users =
    map .age users
```

{% include callout-important.html content="
Man nennt eine Funktion, die eine andere Funktion als Argument erhält, eine **Funktion höherer Ordnung (_Higher-order Function_)**.
" %}

Neben dem rekursiven Muster für `map`, wollen wir an dieser Stelle noch ein weiteres rekursives Muster vorstellen.
Stellen wir uns vor, dass wir aus einer Liste von Nutzer\*innen alle extrahieren möchten, deren Nachname mit `A` beginnt.
Dazu können wir die folgende Funktion definieren.

``` elm
usersWithA : List User -> List User
usersWithA users =
    case users of
        [] ->
            []

        user :: users_ ->
            if String.startsWith "A" user.firstName then
                user :: usersWithA users_
            else
                usersWithA users_
```

Als nächstes nehmen wir an, wir wollen das Durchschnittsalter aller Nutzer\*innen über 18 Jahren berechnen.
Dazu definieren wir die folgende Funktion.

``` elm
keepAdultUsers : List User -> List Int
keepAdultUsers users =
    case users of
        [] ->
            []

        user :: users_ ->
            if user.age >= 18 then
                user :: keepAdultUsers users_
            else
                keepAdultUsers users_
```

Mithilfe der Funktion `keepAdultUsers` können wir jetzt wie folgt das Durchschnittsalter der volljährigen Nutzer\*innen berechnen.

```elm
averageAdultAge : List User -> Float
averageAdultAge users =
    averageAge (keepAdultUsers users)
```

Wir können diese beiden Funktionen wieder mithilfe einer Funktion höherer Ordnung definieren.

``` elm
filter : (a -> Bool) -> List a -> List a
filter isGood list =
    case list of
        [] ->
            []

        head :: tail ->
            if isGood x then
                head :: filter isGood tail
            else
                filter isGood tail
```

Dieses Mal übergeben wir eine Funktion, die angibt, ob ein Element in die Ergebnisliste kommt oder nicht.
Man bezeichnet eine solche Funktion, die einen booleschen Wert liefert, auch als **Prädikat**.

Funktionen höherer Ordnung wie `map` und `filter` ermöglichen es, deklarativeren Code zu schreiben.
Bei der Verwendung dieser Funktionen geben Entwickler\*innen nur an, was berechnet werden soll, aber nicht, wie diese Berechnung durchgeführt wird.
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

##### Kotlin

In Kotlin stellt das _Interface_ `Iterable` Methoden `map` und `filter` zur Verfügung.

##### JavaScript

Der Prototyp `Array` bietet Methoden `map` und `filter`, welche die
Funktionalität von `map` und `filter` auf Arrays bieten.

##### Haskell

In Haskell sind die Funktionen `map` und `filter` im Modul `Prelude` definiert und werden dadurch immer implizit importiert.

##### Elm

Elm stellt die Funktionen `map` und `filter` im Modul `List` zur Verfügung.


## Lokale Definitionen

Bei der Anwendung von Funktionen wie `map` oder `filter` nutzt man in funktionalen Sprachen gerne lokale Definitionen, um die Funktion zu definieren, die auf jedes Element der Liste angewendet wird.
In Elm können Konstanten und Funktionen auch lokal definiert werden, das heißt, dass die entsprechende Konstante oder die Funktion nur innerhalb einer anderen Funktion sichtbar ist.
Anders ausgedrückt ist der _Scope_ einer **_Top Level_-Definition** das gesamte Modul.
_Top Level_-Definitionen sind die Definitionen, die wir bisher kennengelernt haben, also Konstanten wie `secretNumber` und Funktionen wie `viewUser` oder `map`.
Im Kontrast dazu ist der _Scope_ einer **lokalen Definition** auf einen bestimmten Ausdruck eingeschränkt.
Wir betrachten zuerst die Definition einer Konstante mit einer lokalen Definition.

Eine lokale Definition wird in Elm mithilfe eines `let`-Ausdrucks eingeführt.

``` elm
quartic : Int -> Int
quartic n =
    let
        square =
            n * n
    in
    square * square
```

{% include callout-info.html content="
In Haskell kann eine lokale Definition neben einem `let`-Ausdruck auch mit einer `where`-_Clause_ definiert werden, diese Möglichkeit gibt es in Elm nicht.
" %}

Ein `let`-Ausdruck startet mit dem Schlüsselwort `let`, definiert dann beliebig viele Konstanten und Funktionen und schließt schließlich mit dem Schlüsselwort `in` ab.
Die Definitionen, die ein `let`-Ausdruck einführt, stehen nur in dem Ausdruck nach dem `in` zur Verfügung.
Das heißt, wir können `square` hier im Ausdruck `square * square` verwenden, aber nicht außerhalb der Definition `quartic`.

{% include callout-important.html content="
Lokale Definitionen können auch auf die Argumente der umschließenden Funktion zugreifen.
" %}

Die Funktion `square` verwendet in unserem Beispiel etwa das Argument `n`.
Man kann in einem `let`-Ausdruck auch lokale **Funktionen** definieren.
Die Definition einer lokalen Funktion ist zum Beispiel sehr praktisch, wenn wir Listen verarbeiten.
Dort wird häufig die Verarbeitung eines einzelnen Listenelementes als lokale Funktion definiert.
Im folgenden Beispiel wird eine lokale Funktion definiert, die eine Zahl um einen erhöht.

``` elm
result : Int
result =
    let
        inc n =
            n + 1
    in
    inc 41
```

{% include callout-important.html content="
Wie andere Programmiersprachen, zum Beispiel Python, Elixir und Haskell, nutzt Elm eine _**Off-side Rule**_.
" %}

Das heißt, die Einrückung eines Programms wird genutzt, um Klammerung auszudrücken und somit Klammern einzusparen.
In objektorientierten Sprachen wie Java wird diese Klammerung explizit durch geschweifte Klammern ausgedrückt.
Dagegen muss die Liste der Definitionen in einem `let` zum Beispiel nicht geklammert werden, sondern wird durch ihre Einrückung dem `let`-Block zugeordnet.

Das Prinzip der *Off-side Rule* wurde durch Peter J. Landin[^2] in seiner wegweisenden Veröffentlichung "The Next 700 Programming Languages" im Jahr 1966 erfunden.

> Any non-whitespace token to the left of the first such token on the previous line is taken to be the start of a new declaration.

Um diese Aussage zu illustrieren, betrachten wir das folgende
Beispielprogramm, das vom Compiler aufgrund der Einrückung nicht
akzeptiert wird.

``` elm
badLayout1 : Int
badLayout1 =
    let
    x =
        1
    in
    42
```

Das Schlüsselwort `let` definiert eine Spalte.
Alle Definitionen im `let`-Ausdruck müssen in einer Spalte rechts vom Schlüsselwort `let` starten.
Die erste Definition, die in der Spalte des `let`-Ausdrucks oder weiter links steht, beendet die Sequenz der Definitionen.
Die Definition `badLayout1` wird nicht akzeptiert, da die Sequenz der Definitionen durch das `x` beendet wird, was aber keine valide Syntax ist, da die Sequenz mit dem Schlüsselwort `in` beendet werden muss.

Als weiteres Beispiel betrachten wir die folgende Definition, die ebenfalls aufgrund der Einrückung nicht akzeptiert wird.

``` elm
badLayout2 : Int
badLayout2 =
    let
        x =
            1

         y =
            2
    in
    42
```

Die erste Definition in einem `let`-Ausdruck, also hier das `x`, definiert ebenfalls eine Spalte.
Alle Zeilen, die in der gleichen Spalte wie die erste Definition oder weiter links starten, beenden die Liste der Definitionen.
Alle Zeilen, die weiter rechts starten, werden noch zu dieser Definition gezählt.
Das heißt, in diesem Beispiel geht der Compiler davon aus, dass die Definition von `y` eine Fortsetzung der Definition von `x` ist.
Dies ist auch wieder keine valide Syntax, da damit hinter dem `=` der "Ausdruck" `1 y = 2` steht.
Dies ist aber kein valider Ausdruck.
Das folgende Beispiel zeigt noch einmal eine valide Definition eines `let`-Ausdrucks mit zwei lokalen Definitionen.

``` elm
goodLayout : Int
goodLayout =
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
letExpression : Int
letExpression =
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

Wenn man einen `let`-Ausdruck nutzt, sollte man darauf achten, dass Berechnungen nicht unnötig durchgeführt werden.
Wir betrachten etwa das folgende Beispiel

```elm
unnecessaryCalculation : Bool -> Int
unnecessaryCalculation decision =
    let
        result =
            expensiveCalculation
    in
    if decision then
        42

    else
        result
```

Da Elm eine strikte Programmiersprache ist, also als Auswertungsstrategie _call-by value_ nutzt, wird der Ausdruck `expensiveCalculation` immer berechnet, auch wenn die Variable `decision` den Wert `False` hat.
Falls die Variable `decision` den Wert `False` hat, benötigen wir den Wert von `result` aber gar nicht.
Daher sollte man den _Scope_ eines `let`-Ausdrucks so klein halten, wie möglich.
Im Beispiel `unnecessaryCalculation` ist die Variable `result` zum Beispiel im gesamten `if`-Ausdruck sichtbar.
Wir benötigen die Variable `result` aber nur im `else`-Fall des `if`-Ausdrucks.
Daher können wir den `let`-Ausdruck in den `else`-Fall des `if`-Ausdrucks ziehen.
Wir erhalten dann die folgende Definition.

```elm
noUnnecessaryCalculation : Bool -> Int
noUnnecessaryCalculation decision =
    if decision then
        42

    else
        let
            result =
                expensiveCalculation
        in
        result
```

Refaktorierungen dieser Art haben auch den Vorteil, dass wir durch die Struktur des Codes besser sein Verhalten ausdrücken.
Durch die Struktur ist klar, dass die Variable `result` gar nicht im gesamtem `let`-Ausdruck benötigt wird, was wiederum Leser\*innen dabei hilft, den Code zu verstehen.

In diesem artifiziellen Beispiel stellt sich nun allerdings die Frage, warum wir überhaupt die Variable `result` mithilfe eines `let`-Ausdrucks definieren.
Davon abgesehen kann ein entsprechendes Problem auch in einer imperativen Programmiersprache observiert werden, wenn wir eine Variable definieren, obwohl sie gar nicht in allen Fällen benötigt wird.
Auch in diesem Fall können wir den _Scope_ der Variable verkleinern, um dieses Problem zu beheben.

{% include callout-info.html content="In Haskell tritt dieses Problem nicht auf, da Haskell eine **nicht-strikte** Auswertung nutzt und daher den Wert von `result` erst berechnet, wenn er benötigt wird.
Da der Wert in einem Zweig des `if`-Ausdrucks nicht benötigt wird, wird der Wert in diesem Fall auch nicht berechnet.
Elm nutzt dagegen eine strikte Auswertung wie viele andere Programmiersprachen." %}

Wenn eine Funktion wie `viewUser` nur in der Anwendung der Funktion `map` oder `filter` verwendet wird, nutzt man gern wie folgt eine lokale Definition.

``` elm
viewUsers : List Int -> List Int
viewUsers users =
    let
        viewUser { firstName, lastName } =
            text (firstName ++ " " ++ lastName)
    in
    List.map viewUser users
```

Diese Definition verhindert, dass die Funktion `viewUser` außerhalb der Definition `viewUsers` verwendet wird.
Dadurch kann man verhindern, dass Funktionen, die eigentlich nur im Kontext einer ganz bestimmten Funktion sinnvoll sind, aus Versehen globaler verwendet werden.
Außerdem bindet man auf diese Weise die Position der Definition `viewUser` an die Position der Definition `viewUsers`.
Das heißt, es kann nicht passieren, dass man im Modul springen muss, um die Definition von `viewUser` zu suchen.

Es gibt keine feste Regel, wann man eine Funktion wie `viewUser` lokal und wann auf _Top Level_ definieren sollte.
Grundsätzlich kann man sich überlegen, ob man die Funktionsweise einer Funktion erklären kann, ohne darauf einzugehen, wie sie verwendet wird.
Falls es möglich ist, eine Funktion in diesem Fall zu erklären, kann sie vermutlich auf _Top Level_ definiert werden.
Darüber hinaus kann man noch darüber nachdenken, wie hoch die Wahrscheinlichkeit ist, dass die Funktion auch noch in einem anderen Kontext verwendet wird.
Falls die Funktion auch in einem anderen Kontext Verwendung finden könnte, ist es durchaus sinnvoll, sie auf _Top Level_ zu definieren.


Anonyme Funktionen
------------------

Um die Funktion `usersWithA` mithilfe von `filter` zu definieren, müssten wir das folgende Prädikat definieren.

```elm
startsWithA : User -> Bool
startsWithA { firstName } =
    String.startsWith "A" firstName
```

Es ist recht umständlich extra die Funktionen `startsWithA` zu definieren, nur, um sie in der Definition von `startWithA` einmal zu verwenden, unabhängig davon, ob wir die Funktion lokal definieren oder nicht.
Stattdessen kann man anonyme Funktionen verwenden.
Anonyme Funktionen sind einfach Funktionen, die keinen Namen erhalten.
Die Funktion `startsWithA` kann zum Beispiel wie folgt mithilfe einer anonymen Funktion definiert werden.

``` elm
usersWithA : List User -> List User
usersWithA users =
    List.filter (\user -> String.startsWith "A" user.firstName) users
```

Dabei stellt der Ausdruck `\user -> String.startsWith "A" user.firstName` die anonyme Funktion dar.
Analog können wir die Funktion `viewUsers` mithilfe einer anonymen Funktion wie folgt definieren.

``` elm
viewUsers : List User -> List (Html msg)
viewUsers users =
    List.map (\user -> text (user.firstName ++ " " ++ user.lastName)) users
```

**Anonyme Funktionen**, auch als **Lambda-Ausdrücke** oder **Lambda-Funktionen** bezeichnet[^3], starten mit dem Zeichen `\` und listen dann eine Reihe von Argumenten auf, nach den Argumenten folgen die Zeichen `->` und schließlich die rechte Seite der Funktion.
Das heißt, der Ausdruck `\x y -> x * y` definiert zum Beispiel eine Funktion, die ihre beiden Argumente multipliziert.
Ein Lambda-Ausdruck der Form `\x y -> expression` entspricht dabei der folgenden Funktionsdefinition.

``` elm
f x y = expression
```

Der einzige Unterschied ist, dass wir die Funktion nicht verwenden, indem wir ihren Namen schreiben, sondern indem wir den gesamten Lambda-Ausdruck angeben.
Während wir `f` zum Beispiel auf Argumente anwenden, indem wir `f 1 2` schreiben, wenden wir den Lambda-Ausdruck an, indem wir `(\x y -> e) 1 2` schreiben.

In den Argumenten einer anonymen Funktion können wir analog zur Definition einer _Top Level_-Funktion auch _Pattern_ verwenden.
Daher können wir die Funktion `usersViewA` auch wie folgt definieren, indem wir ein _Record Pattern_ im Argument der anonymen Funktion nutzen.

``` elm
usersWithA : List User -> List User
usersWithA users =
    List.filter (\{ firstName } -> String.startsWith "A" firstName) users
```

Analog können wir die Funktion `viewUsers` wie folgt definieren.

``` elm
viewUsers : List User -> List (Html msg)
viewUsers users =
    List.map (\{firstName, lastName} -> text (firstName ++ " " ++ lastName)) users
```

Wir haben im Abschnitt [Fallunterscheidungen](basics.md#fallunterscheidungen) eine Grammatik für Ausdrücke gesehen.
Dieses Kapitel illustriert nun, dass die Grammatik zwei weitere mögliche Ausprägungen aufweist, nämlich Let-Ausdrücke und Lambda-Funktionen.

```elm
expression = ...
           | "let" definition { definition } "in" expression ;
           | '\' pattern { pattern } "->" expression ;
           | ...
```

[^1]: <https://docs.microsoft.com/de-de/dotnet/csharp/programming-guide/concepts/linq>

[^2]: [Peter J. Landin](<https://en.wikipedia.org/wiki/Peter_Landin>) war einer der Begründer der funktionalen Programmierung.

[^3]: Der Name Lambda-Ausdruck stammt vom Lambda-Kalkül. Durch den Lambda-Kalkül wird formal beschrieben, welche Arten von Berechnungen man in einer Programmiersprache ausdrücken kann. Der Lambda-Kalkül hat die Grundidee für funktionale Programmiersprachen geliefert. Im Lambda-Kalkül sind Lambda-Funktionen ein sehr wichtiger Bestandteil, daher hat dieses Konstrukt den Präfix Lambda erhalten. Das Zeichen `\` wird für Lambda-Ausdrücke verwendet, da es dem kleinen Lambda ähnelt.

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="polymorphism.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="architecture.html">weiter</a></li>
    </ul>
</div>
