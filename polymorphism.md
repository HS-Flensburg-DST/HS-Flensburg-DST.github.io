---
layout: post
title: "Polymorphismus"
---

In diesem Kapitel wird das Konzept des **parametrischen Polymorphismus** vorgestellt.
Dieses Konzept wird in anderen Programmiersprachen wie Java und C# auch als **_Generics_** bezeichnet.
Wie in Programmiersprachen wie Java und C# kann man in Elm Datentypen definieren, die generisch über dem Typ der Elemente sind.
Tatsächlich haben Programmiersprachen wie Java und C# dieses Konzept von den funktionalen Programmiersprachen übernommen.
Die Idee des parametrischen Polymorphismus[^1] wurde vor 50 Jahren für die funktionale Programmiersprache ML entwickelt.
Es hat dann zum Beispiel 30 Jahre gedauert, bis Java dieses Konzept erhalten hat.
In diesem Kapitel wollen wir uns anschauen, wie das Konzept des parametrischen Polymorphismus in Elm umgesetzt ist.

Polymorphe Datentypen
---------------------

Häufig möchte man einen Datentyp nicht nur mit einem konkreten Typ verwenden, sondern für verschiedene Typen.
Ein Beispiel für einen solchen Datentyp ist der Datentyp `Maybe`.
Dieser Datentyp wird genutzt, um anzuzeigen, dass eine Funktion möglicherweise kein Ergebnis liefert und stellt damit eine Art “Ersatz” der Null-Referenz dar, die in objekt-orientierten Sprachen für diesen Zweck genutzt wird.
Der Typ `Maybe` ist wie folgt definiert.

``` elm
type Maybe a
    = Just a
    | Nothing
```

`Maybe` nimmt ein Argument, das `a` heißt, und auch als **Typparameter** oder **Typvariable** bezeichnet wird.
Typvariablen starten in Elm im Gegensatz zu Typen mit einem kleinen Buchstaben.
Wenn wir den Datentyp `Maybe` verwenden, können wir für den Typparameter einen konkreten Typ angeben.
Ein Datentyp wie `Maybe`, der noch Typen als Argumente erhält, wird als **polymorpher Typ** oder auch als **Typkonstruktor** bezeichnet.
Im Gegensatz zu polymorphen Typen werden Datentypen, die wir zuvor kennengelernt haben, als **monomorphe Typen** bezeichnet.

Die folgenden Beispiele definieren Werte von `Maybe`-Typen.

``` elm
m1 : Maybe Int
m1 =
    Just 3


m2 : Maybe Int
m2 =
    Nothing


m3 : Maybe String
m3 =
    Nothing


m4 : Maybe String
m4 =
    Just "a"
```

Als erstes einfaches Beispiel wollen wir die Funktion

```elm
toInt : String -> Maybe Int
```

aus dem Modul `String` betrachten.
Falls das Argument der Funktion `toInt` keine ganze Zahl repräsentiert, liefert die Funktion den Wert `Nothing`.
Andernfalls erhalten wir ein `Just`, das den Integer enthält, der aus dem String erzeugt wurde.
Wir können zum Beispiel die folgende Funktion definieren, die eine Benutzereingabe für einen Monat überprüft.

``` elm
module Month exposing (Month(..), parse, fromInt)


type Month
    = Jan
    | Feb
    | Mar
    | Apr
    | May
    | Jun
    | Jul
    | Aug
    | Sep
    | Oct
    | Nov
    | Dec


parse : String -> Maybe Month
parse userInput =
    case String.toInt userInput of
        Just n ->
            fromInt n

        Nothing ->
            Nothing


fromInt : Int -> Maybe Month
fromInt int =
    case int of
        1 ->
            Just Jan

        2 ->
            Just Feb

        3 ->
            Just Mar

        4 ->
            Just Apr

        5 ->
            Just May

        6 ->
            Just Jun

        7 ->
            Just Jul

        8 ->
            Just Aug

        9 ->
            Just Sep

        10 ->
            Just Oct

        11 ->
            Just Nov

        12 ->
            Just Dec

        _ ->
            Nothing
```

Der Aufruf `parse "a"` liefert `Nothing`, da `"a"` durch die Funktion `String.toInt` nicht in einen `Int` umgewandelt werden kann.
Der Aufruf `parse "-1"` liefert `Nothing`, da `"-1"` zwar eine Zahl darstellt, die Zahl aber nicht zwischen `1` und `12` liegt.
Der Aufruf `parse "1"` liefert schließlich als Ergebnis `Just Jan`.

Viele andere Programmiersprachen stellen einen Datentyp wie `Maybe` ebenfalls zur Verfügung.
So gibt es in Java zum Beispiel die Klasse`java.util.Optional`, die ebenfalls einen Typparameter nimmt und für die gleichen Zweck gedacht ist.
Ein elementarer Unterschied in Programmiersprachen wie Java ist aber, dass es trotzdem noch den Wert `null` gibt.
Das heißt, man muss eigentlich an jeder Stelle weiterhin auf `null` prüfen, da es keine Garantie gibt, dass der Typ `Optional` an allen Stellen als "Null-Ersatz" genutzt wird.
In Programmiersprachen wie Elm und Haskell existiert aber gar keine Null-Referenz.
Das heißt, wenn eine Funktion möglicherweise kein Ergebnis zurückliefert, liefert die Funktion einen Wert vom Typ `Maybe`.
Daher wissen wir durch das Typsystem, an welchen Stellen eine Art von "Null-Referenz" auftreten kann.
Null-Referenzen sind in der Programmierung ein Problem, da sie für viele Laufzeitfehler und damit für Schaden in der Industrie sorgen.
Der Erfinder der Null-Referenz, Tony Hoare[^3], bezeichnet die Erfindung der Null-Referenz als seinen Milliarden-Dollar-Fehler[^4], da Null-Referenzen die Industrie vermutlich bereits mehrere Milliarden Dollar gekostet haben.

Als weiteres Beispiel für die Verwendung des `Maybe`-Datentyps wollen wir uns noch einmal die Funktion `rotate` anschauen, die wir im Kapitel [Records](data-types.md#records) definiert haben.
Wenn wir uns die Spezifikation dieser Eigenschaft unter <https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/transform#rotate> anschauen, können wir sehen, dass die Angabe des Punktes optional ist.
Daher können wir unsere Definition wie folgt erweitern.

```elm
type alias Point =
    { x : Float, y : Float }


rotate : { angle : Float, maybeOrigin : Maybe Point } -> String
rotate { angle, maybeOrigin } =
    String.concat
        [ "rotate("
        , String.fromFloat angle
        , case maybeOrigin of
            Nothing ->
                ""

            Just origin ->
                String.concat
                    [ ","
                    , String.fromFloat origin.x
                    , ","
                    , String.fromFloat origin.y
                    ]
        , ")"
        ]
```

Dieses Beispiel illustriert, dass ähnlich wie bei der Null-Referenz der Datentyp `Maybe` verwendet wird, um verschiedene Arten von fehlenden Werten zu modellieren.
In der Definition von `rotate` nutzen wir den `Maybe`-Datentyp zur Modellierung von optionalen Informationen.
Im Gegensatz dazu haben wir den `Maybe`-Datentyp im Fall von `parse` genutzt, um einen Fehlerfall zu modellieren.

Wenn man in einer Anwendung einen Fehlerfall modelliert, möchte man häufig noch einen Grund für das Fehlschlagen der Operation zur Verfügung stellen.
Für diesen Zweck wird der Datentyp `Result` genutzt.
Der Datentyp `Result` ist dabei wie folgt definiert.

``` elm
type Result error value
    = Ok value
    | Err error
```

Der Typkonstruktor `Result` erhält zwei Typparameter.
Der erste Typparameter ist dabei der Typ, der im Konstruktor `Err` gespeichert wird.
Der zweite Typparameter ist der Typ, der im Konstruktor `Ok` gespeichert wird.

Wir wollen den Datentyp `Result` nutzen, um in der Funktion `parse` einen Grund zu liefern, warum die Konvertierung fehlgeschlagen ist.
Hierbei bedeutet der Typ `Result String Month`, dass wir im Erfolgsfall den Konstruktor `Ok` erhalten und sein Argument den Typ `Month` hat.
Im Fehlerfall erhalten wir den Konstruktor `Err` und sein Argument ist vom Typ `String`.

``` elm
parse : String -> Result String Month
parse userInput =
    case String.toInt userInput of
        Just int ->
            fromInt int

        Nothing ->
            Err ("Fehler beim Parsen von \"" ++ userInput ++ "\" als Int")


fromInt : Int -> Result String Month
fromInt int =
    case int of
        1 ->
            Ok Jan

        2 ->
            Ok Feb

        3 ->
            Ok Mar

        4 ->
            Ok Apr

        5 ->
            Ok May

        6 ->
            Ok Jun

        7 ->
            Ok Jul

        8 ->
            Ok Aug

        9 ->
            Ok Sep

        10 ->
            Ok Oct

        11 ->
            Ok Nov

        12 ->
            Ok Dec

        _ ->
            Err ("Invalider Monat " ++ String.fromInt month)
```

Der Aufruf `parse "a"` liefert in dieser Implementierung `Err "Error parsing \"a\" as Int"`.
Das heißt, wir erhalten nicht nur die Information, dass die Verarbeitung fehlgeschlagen ist, sondern auch, warum die Verarbeitung fehlgeschlagen ist.

Wir verwenden an dieser Stelle zur Vereinfachung einen Wert vom Typ `String` für die Fehlermeldung.
In einer Anwendung sollte man für die Modellierung von Fehlern immer auf einen strukturierten Datentyp wie den folgenden zurückgreifen.
Andernfalls ist es zum Beispiel nicht sinnvoll möglich, eine Fallunterscheidung über den Fehler durchzuführen, der aufgetreten ist.
Wenn wir den Datentyp `String` für Fehler verwenden, ist es auch nicht möglich, die Fehler zu internationalisieren, also in verschiedene Sprachen zu übersetzen.

In unserem Beispiel können wir den folgenden Datentyp für mögliche Fehlermeldungen verwenden.

``` elm
type Error
    = ParseError String
    | InvalidMonth Int
```

Der `ParseError` beschreibt, dass der `String`, den wir eingelesen haben, bereits keine Zahl repräsentiert und der Konstruktor `InvalidMonth` beschreibt, dass die Zahl kein valider Monat war.
Um die Fehlermeldung dem Nutzer später anzeigen zu können, definieren wir eine Funktion, welche einen `Error` in eine lesbare Fehlermeldung umwandelt.

```elm
description : Error -> String
description error =
    case error of
        ParseError userInput ->
            "Fehler beim Parsen von \"" ++ userInput ++ "\" als Int"

        InvalidMonth month ->
            "Invalider Monat " ++ String.fromInt month
```

Da der Datentyp `Result` polymorph im Typ des Fehlers ist, können wir den Datentyp `Result` auch mit unserem Datentyp `Error` verwenden.

``` elm
parse : String -> Result Error Month
parse userInput =
    case String.toInt userInput of
        Just int ->
            fromInt int

        Nothing ->
            Err (ParseError userInput)


fromInt : Int -> Result String Month
fromInt int =
    case int of
        1 ->
            Ok Jan

        2 ->
            Ok Feb

        3 ->
            Ok Mar

        4 ->
            Ok Apr

        5 ->
            Ok May

        6 ->
            Ok Jun

        7 ->
            Ok Jul

        8 ->
            Ok Aug

        9 ->
            Ok Sep

        10 ->
            Ok Oct

        11 ->
            Ok Nov

        12 ->
            Ok Dec

        _ ->
            Err (InvalidMonth month)
```

Der Aufruf `parse "a"` liefert in dieser Implementierung `Err (ParseError "a")`.

Im Kontext von polymorphen Datentypen wollen wir uns auch noch **Tupel** anschauen.
Neben den benannten Paaren stellt Elm auch ganz klassische **Paare** zur Verfügung.
Im Grunde handelt es sich dabei auch um algebraische Datentypen, nur dass die Paare so wie die Listen eine spezielle Syntax nutzen.
Die Einträge eines Paares werden durch ein Komma getrennt und das Paar wird durch Klammern umschlossen.
Das heißt, der Ausdruck `(1, False)` erzeugt zum Beispiel ein Paar, bei dem die erste Komponente den Wert `1` enthält und die zweite Komponente den booleschen Wert `False`.
Der Typkonstruktor für Paare wird genau so geschrieben wie der Konstruktor für Paare und ist über zwei Typen parametrisiert, nämlich den Typ der ersten Komponente und den Typ der zweiten Komponente.
Das heißt, der Typ des Wertes `(1, False)` ist zum Beispiel `(Int, Bool)`.

Wie bei jedem anderen algebraischen Datentyp kann man *Pattern Matching* auch für Paare verwenden.
Als Beispiel betrachten wir die Funktion

```elm
uncons : String -> Maybe ( Char, String )
```

aus dem Modul `String`.
Mithilfe dieser Funktion kann man einen `String` in das erste Zeichen und den Rest des *Strings* zerlegen.
Die Funktion liefert `Nothing`, falls wir sie auf einen leeren `String` anwenden.

Mithilfe dieser Funktion können wir zum Beispiel wie folgt eine Funktion definieren, die alle Zeichen in einer Zeichenkette in Großbuchstaben verwandelt.
Die Funktion `String.cons : Char -> String -> String` hängt ein Zeichen vorne an eine Zeichenkette.

``` elm
toUpper : String -> String
toUpper string =
    case String.uncons string of
        Nothing ->
            ""

        Just ( char, reststring ) ->
            String.cons (Char.toUpper char) (toUpper reststring)
```

Neben Paaren bietet Elm auch Tupel anderer Stelligkeiten.

{% include callout-important.html content="
Tupel kommen selten zum Einsatz und sollten nur von sehr allgemein verwendbaren Bibliotheksfunktionen genutzt werden, da ein Tupel sehr wenig Dokumentationscharakter hat.
" %}

Daher bietet sich als Alternative für ein Tupel fast immer ein algebraischer Datentyp oder ein Record an.
Einen Sonderfall eines Tupels stellt das nullstellige Tupel `()` dar, dessen Typ man ebenfalls als `()` schreibt.
Wir werden später Anwendungsfälle für diesen Datentyp kennenlernen.

Als weiteres Beispiel für einen polymorphen Datentyp wollen wir uns einen Listen-Datentyp anschauen, der nicht nur Zahlen enthalten kann sondern Werte eines beliebigen Typs.
Der folgende Datentyp definiert einen polymorphen Listendatentyp.

``` elm
type List a
    = Nil
    | Cons a (List a)
```

Hierbei ist vor allem zu beachten, dass wir auch bei der rekursiven Verwendung den Typparameter `a` übergeben müssen, da `List` ein Typkonstruktor ist und somit ein Argument verlangt.
Wir geben damit an, dass der Rest der Liste Elemente vom gleichen Typ wie die bisherige Liste enthält.

Wir können wie folgt Werte vom Typ `List` definieren.

``` elm
clist1 : List Int
clist1 =
    Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))


clist2 : List String
clist2 =
    Cons "a" (Cons "z" (Cons "y" Nil))


clist3 : List Bool
clist3 =
    Cons False (Cons True (Cons True (Cons False Nil)))
```

Der Listendatentyp ist in Elm genau definiert wie der Datentyp `List`, verwendet aber eine spezielle Syntax.
Die folgende Definition liefert in Elm einen Syntaxfehler, illustriert aber den Listendatentyp, wie er in Elm definiert ist.

``` elm
type List a
    = []
    | a :: List a
```

Das heißt, der Konstruktor für die leere Liste verwendet in Elm nicht den Namen `Nil` sondern die Zeichenfolge `[]`.
Der Konstruktor, um ein Element vorne an eine Liste anzuhängen, heißt außerdem nicht `Cons`, sondern `::` und wird infix verwendet.
Das heißt, der Konstruktor `::` wird zwischen seine Argumente geschrieben.
Alle anderen Konstruktoren werden vor ihre Argumente geschrieben.
Bei Funktionen kennen wir auch beide Varianten, so wird eine selbstdefinierte Funktion vor ihre Argumente geschrieben, also zum Beispiel `f 1 2`.
Die Funktion für die Addition wird aber zum Beispiel auch infix verwendet, also zum Beispiel `1 + 2`.

Mithilfe des vordefinierten Listendatentyps können wir wie folgt eine Liste definieren.

``` elm
list1 : List Int
list1 =
    1 :: (2 :: (3 :: (4 :: [])))
```

Der Operator `::` ist rechts-assoziativ.
Wir können die Klammern bei der Definition einer Liste also auch weglassen.

``` elm
list2 : List String
list2 =
    "a" :: "z" :: "y" :: []
```

Wir haben in der Einleitung bereits eine Kurzschreibweise für konkrete Listen kennengelernt.
Diese Kurzschreibweise stellt nur **syntaktischen Zucker**[^2] für die obige Schreibweise dar.
Daher kann man diese Kurzschreibweise auch in *Pattern* verwenden.

``` elm
list3 : List Bool
list3 =
    [ False, True, True, False ]
```

So wie eine Liste definiert wird, die polymorph über dem Typ der Elemente ist, kann auch ein Baum-Datentyp definiert werden, der polymorph über dem Typ der Elemente ist.

``` elm
type Tree a
    = Empty
    | Node (Tree a) a (Tree a)
```

Wir können dann wie folgt einen Baum mit ganzen Zahlen definieren.

``` elm
tree1 : Tree Int
tree1 =
    Node (Node Empty 3 (Node Empty 5 Empty)) 8 Empty
```

Wir können den gleichen Datentyp aber auch nutzen, um einen Baum zu definieren, der Werte vom Typ `Maybe String` enthält.

``` elm
tree2 : Tree (Maybe String)
tree2 =
    Node Empty (Just "a") (Node Empty Nothing Empty)
```

Polymorphe Funktionen
---------------------

Wie wir polymorphe Datentypen definieren können, können wir auch polymorphe Funktionen definieren.
Als einfachstes Beispiel wollen wir die Funktion `identity` aus dem Modul `Basics` betrachten.

``` elm
identity : a -> a
identity x =
    x
```

Der Typ `a` in der Definition der Funktion `identity` wird als Typvariable bezeichnet.
Alle Typvariablen in einem Funktionstyp sind implizit allquantifiziert.
Das heißt, der Typ `a -> a` steht eigentlich für den Typ `forall a. a -> a`.
Das heißt, die Funktion hat für alle möglichen Typen `tau`, den Typ `tau -> tau`.
Wenn wir die Funktion `identity` verwenden, wählen wir implizit einen konkreten Typ, den wir für die Typvariable `a` einsetzen.
Wenn wir zum Beispiel die Anwendung `identity "a"` betrachten, dann wählt der Compiler für die Typvariable `a` den Typ `String` und die konkrete Verwendung der Funktion `identity` erhält den Typ `String -> String`.
In Haskell und Java kann man den Typ, den man für die Typvariable einsetzen möchte, bei der Anwendung einer Funktion/Methode auch konkret angeben.

Als weiteres einfaches Beispiel für eine polymorphe Funktion, wollen wir uns die Funktion anschauen, die das erste Element einer Liste liefert.
In Elm, ist diese Funktion im Modul `List` definiert.

```elm
head : List a -> Maybe a
head list =
    case list of
        x :: xs ->
            Just x

        [] ->
            Nothing
```

Diese Funktion illustriert noch einmal einen Anwendungsfall für den `Maybe`-Typen.
Die Funktion `head` erhält eine Liste und liefert das erste Element der Liste.
Wir können dieser Funktion nicht den Typ `List a -> a` geben.
In diesem Fall müsste die Funktion bei einer leeren Liste ein Element vom Typ `a` zurückliefern.
Die Funktion `head` weiß aber gar nicht, von welchem Typ dieses Element sein muss, da die Funktion polymorph über diesem Typ ist.
Das heißt, wenn wir eine Liste vom Typ `List Int` an `head` übergeben, müsste `head` sich für die leere Liste einen Wert vom Typ `Int` "ausdenken".
Wenn wir eine Liste vom Typ `List String` an `head` übergeben, müsste `head` sich für die leere Liste einen Wert vom Typ `String` "ausdenken".
Aus diesem Grund liefert die Funktion `head` einen `Maybe`-Wert als Ergebnis.
Falls wir eine leere Liste an `head` übergeben, liefert die Funktion den Wert `Nothing` als Ergebnis.

Als weiteres Beispiel wollen wir uns noch eine Funktion auf dem Datentyp `Result` anschauen.
Die folgende Funktion kann genutzt werden, um einen *Default*-Wert für die Verwendung einer fehlgeschlagenen Berechnung anzugeben.
Das heißt, falls die Berechnung erfolgreich war, verwenden wir den Wert, der im `Result`-Typ zur Verfügung steht und für den Fehlerfall geben wir einen *Default*-Wert an.

``` elm
withDefault : a -> Result x a -> a
withDefault default result =
    case result of
        Ok value ->
            value

        Err _ ->
            default
```

Im Unterschied zur Funktion `identity`, ist die Funktion `withDefault` über zwei Typparameter parametrisiert.
Wenn wir die Funktion `withDefault` anwenden, wählen wir implizit konkrete Typen für diese Typparameter.

Als Beispiel betrachten wir den Aufruf `withDefault Jan (parse "a")`.
Der Ausdruck `parse "a"` hat den Typ `Result Error Month`.
Das heißt, bei diesem Aufruf wählen wir für die Typvariable `x` den Typ `Error` und für die Typvariable `a` den Typ `Month`.
Dadurch muss das erste Argument von `withDefault` ebenfalls den Typ `Month` haben.
Der Aufruf `withDefault Jan (parse "a")` ist also typkorrekt.
Da wir für die Typvariable `a` den Typ `Month` gewählt haben, wissen wir außerdem, dass der Ausdruck `withDefault Jan (parse "a")` den Typ `Month` hat.

In einer Typinferenz oder Typprüfung wird der Prozess, den wir hier händisch durchgeführt haben, durch einen Algorithmus durchgeführt, der [**Unifikation**](https://en.wikipedia.org/wiki/Unification_(computer_science)) genannt wird.
Bei der Unifikation werden Gleichungen aufgestellt, die Typen gleichsetzen.
Diese Typen enthalten zum Teil Typvariablen.
Die Unifikation sucht nun nach einer Ersetzung der Typvariablen, so dass die Gleichungen erfüllt sind.
Eine solche Ersetzung nennt man eine **Substitution**.
Um ein tieferes Verständnis dafür zu vermitteln, wann der Aufruf einer polymorphen Funktion typkorrekt ist, wollen wir hier eine Unifikation beispielhaft durchführen.

Wir betrachten den Aufruf `withDefault Jan (parse "a")`.
Die Funktion `withDefault` hat den Typ `a -> Result x a -> a`.
Das Argument `Jan` hat den Typ `Month`, das Argument `parse "a"` den Typ `Result Error Month`.
Durch das erste Argument erhalten wir daher die Gleichung `a = Month`.
Hierbei handelt es sich direkt um eine Ersetzung, da auf einer Seite der Gleichung bereits eine Variable steht und nicht wie später ein komplexer Typ.
Um Widerspruche in den Ersetzungen aufzudecken, wird diese Ersetzung direkt angewendet, wenn wir weitere Gleichungen aufstellen.
Durch das zweite Argument des Aufruf erhalten wir die Gleichung `Result x a = Result Error Month`.
Hierauf wenden wir zuerst die Ersetzung `a = Month` an und erhalten `Result x Month = Result Error Month`.
Aus der Gleichung `Result x Month = Result Error Month` leitet der Unifikationsalgorithmus die Gleichungen `x = Error` und `Month = Month` ab.
Die Gleichung `x = Error` übernehmen wir zu unseren Ersetzungen.
Die Gleichung `Month = Month` ist gültig, liefert aber keine neue Ersetzung.
Das heißt, wir erhalten insgesamt die Ersetzungen `a = Month` und `x = Error`.
Das heißt, wir müssen die Typvariable `a` durch den Typ `Month` ersetzen  und die Typvariable `x` durch den Typ `Error`, damit unser Funktionsaufruf typkorrekt ist.

Wenn wir den Aufruf `withDefault 1 (parse "a")` in der REPL ausführen, erhalten wir einen Fehler, da der Aufruf nicht typkorrekt ist.

```
-- TYPE MISMATCH ---------------------------------------------------------- REPL

The 2nd argument to `withDefault` is not what I expect:

4|   withDefault 1 (parse "a")
                   ^^^^^^^^^^^
This `parse` call produces:

    Result Error Month

But `withDefault` needs the 2nd argument to be:

    Result Error Int

Hint: I always figure out the argument types from left to right. If an argument
is acceptable, I assume it is "correct" and move on. So the problem may actually
be in one of the previous arguments!

Hint: Elm does not have "truthiness" such that ints and strings and lists are
automatically converted to booleans. Do that conversion explicitly!
```

Um zu illustrieren, warum dieser Aufruf einen Typfehler liefert, wenden wir eine Unifikation auf den Funktionsaufruf an.
Durch den Aufruf `withDefault 1 (parse "a")` erhalten wir aus dem ersten Argument die Gleichung `a = Int`.
Hierbei handelt es sich um eine Ersetzung und wir merken uns diese Ersetzung.
Aus dem zweiten Argument erhalten wir die Gleichung `Result x a = Result Error Month`.
Wir wenden die Ersetzung `a = Int` auf die Gleichung `Result x a = Result Error Month` an und erhalten `Result x Int = Result Error Month`.
Aus dieser Gleichung leitet der Unifikationsalgorithmus die Gleichungen `x = Error` und `Int = Month` ab.
Die Gleichung `x = Error` übernehmen wir zu unseren Ersetzungen.
Die Gleichung `Int = Month` ist aber ungültig, da die beiden Typen unterschiedlich sind.
Die Typprüfung von Elm identifiziert diese Stelle als Fehler.

Wenn wir eine polymorphe Funktion verwenden, wählen wir für die Typvariablen konkrete Typen.
Wir müssen aber für die gleiche Typvariable immer die gleiche Wahl treffen.
Falls wir unterschiedliche Wahlten treffen, kann die Typprüfung nicht wissen, welche der Wahlen falsch ist.
In unserem Fall geht die Typprüfung zum Beispiel von links nach rechts vor.
Das heißt, die Typprüfung geht davon aus, dass die Ersetzung `a = Int`, die aus dem Argument `1` entsteht korrekt ist.
Das ist aber nicht notwendigerweise der Fall.
Das heißt, es kann sein, dass der Typfehler einer Typprüfung fehlleitend ist.
Im Fall von `withDefault 1 (parse "a")` ist Elm zum Beispiel der Meinung, dass das zweite Argument, also der Ausdruck `parse "a"` einen anderen Typ haben sollte.
Es könnte aber genau so gut sein, dass wir uns beim ersten Argument vertan haben und der Ausdruck `1` das Problem ist.

Zum Abschluss dieses Abschnitts wollen wir uns noch eine Funktion auf dem vordefinierten Listendatentyp anschauen.
Da die vordefinierten Listen in Elm polymorph sind, können wir auch Funktionen definieren, die auf allen Arten von Listen arbeiten, unabhängig davon, welchen Typ die Elemente der Liste haben.
Wir schauen uns einmal die Längenfunktion auf Listen an, die wie folgt definiert ist.

``` elm
length : List a -> Int
length list =
    case list of
        [] ->
            0

        _ :: restlist ->
            1 + length restlist
```

So wie wir den Konstruktor für eine nicht-leere Liste infix schreiben, so schreiben wir auch das *Pattern* für die nicht-leere Liste infix.
Das heißt, das Muster `_ :: restlist` passt nur, wenn die Liste nicht leer ist.
Außerdem wird die Variable `restlist` an den Rest der Liste gebunden.
Das heißt, die Variable `restlist` enthält die Liste `list`, aber ohne das erste Element der Liste.

Da das Argument den Typ `List a` hat, können wir diese Funktion mit jeder Art von Liste aufrufen.
Wenn wir die Funktion mit einem Wert vom Typ `List Bool` aufrufen, wird die Typvariable `a` zum Beispiel durch den konkreten Typ `Bool` ersetzt.
Wenn wir `length` mit einem Argument vom Typ `List (Maybe String)` aufrufen, wird die Typvariable `a` durch den konkreten Typ `Maybe String` ersetzt.
Hierbei ist es wieder wichtig zu verstehen, dass einer Typvariable wie `a` nicht nur durch einfache Typen wie `Int` oder `Bool` ersetzt werden kann.
Eine Typvariable kann durch jeden Typ, der in Elm zur Verfügung steht, ersetzt werden.
Dazu gehören aber auch komplexe Typen wie `Maybe String` oder Recordtypen wie `{ firstName : String, lastName : String }`.
In einer funktionalen Sprachen können wir Typvariablen aber auch durch Funktionstypen wie `Int -> Bool` ersetzen.
An dieser Stelle ist es wieder wichtig zu verstehen, dass es die Kategorie Typ gibt und welche Konstrukte genutzt werden können, um ein Element der Kategorie Typ zu konstruieren.

[^1]: A Logic for Computable Functions with reflexive and polymorphic types - Milner, R., Morris, L., Newey, M. (1975)

[^2]: Der Begriff [syntaktischer Zucker](https://de.wikipedia.org/wiki/Syntaktischer_Zucker) geht ebenfalls auf Peter J. Landin zurück.

[^3]: [Sir Charles Antony Richard (C. A. R.) bzw. Tony Hoare](https://en.wikipedia.org/wiki/Tony_Hoare) ist einer der bedeutendsten Informatiker der früheren Jahre der Informatik.

[^4]: Vortrag ["Null References: The Billion Dollar Mistake"](https://www.infoq.com/presentations/Null-References-The-Billion-Dollar-Mistake-Tony-Hoare/) aus dem Jahr 2009 von Tony Hoare.

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="data-types.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="functional-abstractions.html">weiter</a></li>
    </ul>
</div>
