---
layout: post
title: "Polymorphismus"
---

In diesem Kapitel wird das Konzept des parametrischen Polymorphismus vorgestellt.
Dieses Konzept wird in anderen Programmiersprachen wie Java und C# auch als _Generics_ bezeichnet.
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

`Maybe` nimmt ein Argument, das `a` heißt, und auch als _Typparameter_ oder _Typvariable_ bezeichnet wird.
Typvariablen werden in Elm im Gegensatz zu Typen klein geschrieben.
Wenn wir den Datentyp `Maybe` verwenden, können wir für den Typparameter einen konkreten Typ angeben.
Ein Datentyp wie `Maybe`, der noch Typen als Argumente erhält, wird als **polymorpher Type** oder auch als **Typkonstruktor** bezeichnet.
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
parseMonth : String -> Maybe Int
parseMonth userInput =
    case String.toInt userInput of
        Just n ->
            toValidMonth n

        Nothing ->
            Nothing


toValidMonth : Int -> Maybe Int
toValidMonth month =
    if 1 <= month && month <= 12 then
        Just month

    else
        Nothing
```

Der Aufruf `parseMonth "a"` liefert `Nothing`, da `"a"` durch die Funktion `String.toInt` nicht in einen `Int` umgewandelt werden kann.
Der Aufruf `parseMonth "-1"` liefert `Nothing`, da `"-1"` zwar eine Zahl darstellt, die Zahl aber nicht zwischen `1` und `12` liegt.
Der Aufruf `parseMonth "1"` liefert schließlich als Ergebnis `Just 1`.

Viele andere Programmiersprachen stellen einen Datentyp wie `Maybe` ebenfalls zur Verfügung.
So gibt es in Java zum Beispiel die Klasse`java.util.Optional`, die ebenfalls einen Typparameter nimmt und für die gleichen Zweck gedacht ist.
Ein elementarer Unterschied in Programmiersprachen wie Java ist aber, dass es trotzdem noch den Wert `null` gibt.
Das heißt, man muss eigentlich an jeder Stelle weiterhin auf `null` prüfen, da es keine Garantie gibt, dass der Typ `Optional` für diesen Zweck genutzt wird.
In Programmiersprachen wie Elm und Haskell existiert aber gar keine Null-Referenz.
Das heißt, wenn eine Funktion möglicherweise kein Ergebnis zurückliefert, liefert die Funktion einen Wert vom Typ `Maybe`.
Daher wissen wir durch das Typsystem, an welchen Stellen eine Art von "Null-Referenz" auftreten kann.
Null-Referenzen sind in der Programmierung ein Problem, da sie für viele Laufzeitfehler und damit für Schaden in der Industrie sorgen.
Der Erfinder der Null-Referenz, Tony Hoare[^3], bezeichnet die Erfindung der Null-Referenz als seinen Milliarden-Dollar-Fehler[^4], da Null-Referenzen die Industrie vermutlich bereits mehrere Milliarden Dollar gekostet haben.

Als weiteres Beispiel für die Verwendung des `Maybe`-Datentyps wollen wir uns noch einmal die Funktion `rotate` anschauen, die wir im Kapitel [Records](basics.md#records) definiert haben.
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
Im Gegensatz dazu haben wir den `Maybe`-Datentyp im Fall von `parseMonth` genutzt, um einen Fehlerfall zu modellieren.

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

Wir wollen den Datentyp `Result` nutzen, um in der Funktion `parseMonth` einen Grund zu liefern, warum die Konvertierung fehlgeschlagen ist.
Hierbei bedeutet der Typ `Result String Int`, dass wir im Erfolgsfall den Konstruktor `Ok` erhalten und sein Argument den Typ `Int` hat.
Im Fehlerfall erhalten wir den Konstruktor `Err` und sein Argument ist vom Typ `String`.

``` elm
parseMonth : String -> Result String Int
parseMonth userInput =
    case String.toInt userInput of
        Just n ->
            toValidMonth n

        Nothing ->
            Err ("Error parsing \"" ++ userInput ++ "\" as Int")


toValidMonth : Int -> Result String Int
toValidMonth month =
    if 1 <= month && month <= 12 then
        Ok month

    else
        Err ("Invalid month " ++ String.fromInt month)
```

Der Aufruf `parseMonth "a"` liefert in dieser Implementierung `Err "Error parsing \"a\" as Int"`.
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
            "Error parsing \"" ++ userInput ++ "\" as Int"

        InvalidMonth month ->
            "Invalid month " ++ String.fromInt month
```

Da der Datentyp `Result` polymorph im Typ des Fehlers ist, können wir den Datentyp `Result` auch mit unserem Datentyp `Error` verwenden.

``` elm
parseMonth : String -> Result Error Int
parseMonth userInput =
    case String.toInt userInput of
        Just n ->
            toValidMonth n

        Nothing ->
            Err (ParseError userInput)


toValidMonth : Int -> Result Error Int
toValidMonth month =
    if 1 <= month && month <= 12 then
        Ok month

    else
        Err (InvalidMonth month)
```

Der Aufruf `parseMonth "a"` liefert in dieser Implementierung
`Err (ParseError "a")`.

Im Kontext von polymorphen Datentypen wollen wir uns auch noch Tupel anschauen.
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
Die Funktion `cons : Char -> String -> String` hängt ein Zeichen vorne an eine Zeichenkette.

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
Tupel kommen selten zum Einsatz und sollten nur von sehr allgemein verwendtbaren Bibliotheksfunktionen genutzt werden, da ein Tupel sehr wenig Dokumentationscharakter hat.
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
Diese Kurzschreibweise stellt nur syntaktischen Zucker[^2] für die obige Schreibweise dar.
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

Als Beispiel betrachten wir den Aufruf `withDefault 1 (parseMonth "a")`.
Der Ausdruck `parseMonth "a"` hat den Typ `Result Error Int`.
Das heißt, bei diesem Aufruf wählen wir für die Typvariable `x` den Typ `Error` und für die Typvariable `a` den Typ `Int`.
Dadurch muss das erste Argument von `withDefault` ebenfalls den Typ `Int` haben.
Der Aufruf `withDefault 1 (parseMonth "a")` ist also typkorrekt.
Da wir für die Typvariable `a` den Typ `Int` gewählt haben, wissen wir außerdem, dass der Aufruf einen `Int` als Ergebnis liefert.

In einer Typinferenz oder Typprüfung wird der Prozess, den wir hier händisch durchgeführt haben, durch einen Algorithmus durchgeführt, der [**Unifikation**](https://en.wikipedia.org/wiki/Unification_(computer_science)) genannt wird.
Bei der Unifikation werden Gleichungen aufgestellt, die Typen gleichsetzen.
Diese Typen enthalten zum Teil Typvariablen.
Die Unifikation sucht nun nach einer Ersetzung der Typvariablen, so dass die Gleichungen erfüllt sind.
Durch den Aufruf `withDefault 1 (parseMonth "a")` würden wir zum Beispiel die Gleichung `a = Int` durch das erste Argument und `Result x a = Result Error Int` durch das zweite Argument des Aufrufs erhalten.
Aus der Gleichung `Result x a = Result Error Int` leitet der Unifikationsalgorithmus die Gleichungen `x = Error` und `a = Int` ab.
Das heißt, wir erhalten insgesamt die Gleichungen `a = Int`, `x = Error` und `a = Int`.
Die Unifikation liefert am Ende Ersetzungen der Typvariablen.
Das heißt, die Gleichung `a = Int` sagt, dass wir die Typvariable `a` durch den Typ `Int` ersetzen müssen, damit unser Funktionsaufruf typkorrekt ist.
Um zu überprüfen, ob die berechnete Substitution Widersprüche enthält, werden die Ersetzungen bei der Unifikation direkt angewendet.
In unserem Beispiel würden wir zum Beispiel die Ersetzung `a = Int` auf die Gleichungen `a = Int` und `x = Error` anwenden.
Wir erhalten dadurch die Gleichungen `Int = Int` und `x = Error`.
Diese Gleichungen enthalten keinen Widerspruch, die Unifikation war also erfolgreich.

Wenn wir den Aufruf `withDefault False (parseMonth "a")` in der REPL ausführen, erhalten wir dagegen einen Fehler.

```
-- TYPE MISMATCH ---------------------------------------------------------- REPL

The 2nd argument to `withDefault` is not what I expect:

4|   withDefault False (parseMonth "a")
                        ^^^^^^^^^^^^^^
This `parseMonth` call produces:

    Result Error Int

But `withDefault` needs the 2nd argument to be:

    Result Error Bool

Hint: I always figure out the argument types from left to right. If an argument
is acceptable, I assume it is "correct" and move on. So the problem may actually
be in one of the previous arguments!

Hint: Elm does not have "truthiness" such that ints and strings and lists are
automatically converted to booleans. Do that conversion explicitly!
```

Um zu illustrieren, warum dieser Aufruf einen Typfehler liefert, wenden wir eine Unifikation auf den Funktionsaufruf an.
Durch den Aufruf `withDefault False (parseMonth "a")` erhalten wir die Gleichung `a = Bool` durch das erste Argument und `Result x a = Result Error Int` durch das zweite Argument des Aufrufs.
Aus der Gleichung `Result x a = Result Error Int` leitet der Unifikationsalgorithmus die Gleichungen `x = Error` und `a = Int` ab.
Das heißt, wir erhalten insgesamt die Gleichungen `a = Bool`, `x = Error` und `a = Int`.
Wir wenden nur die Ersetzung `a = Int` auf die Gleichungen `a = Bool` und `x = Error` an und erhalten `Bool = Int` und `x = Error`.
Diese Gleichungen enthalten einen Widerspruch, da die Typen `Bool` und `Int` niemals gleich sein können.
Daher liefert uns die Unifikation in diesem Fall einen Fehler.

Wenn wir eine polymorphe Funktion verwenden, wählen wir für die Typvariablen konkrete Typen.
Wir müssen aber für die gleiche Typvariable immer die gleiche Wahl treffen.
Das heißt, die drei Vorkommen von `a` in der Signatur von `withDefault` müssen alle durch den gleichen konkreten Typ ersetzt werden.
Wenn wir die Funktion `withDefault` auf die Argumente `False` und `parseMonth "a"` anwenden, würden wir das erste `a` aber durch `Bool` und das zweite `a` durch `Int` ersetzen.
Dies ist nicht erlaubt und wir erhalten einen Fehler.
Die Fehlermeldung schlägt vor, dass wir für beide Vorkommen den Typ `Bool` wählen und erwartet daher als zweites Argument einen Wert vom Typ `Result Error Bool`.
Alternativ könnte die Fehlermeldung auch vorschlagen, dass wir für beide Vorkommen den Typ `Int` wählen.
Dieses Beispiel illustriert bereits, dass es schwierig ist, für Typfehler bei polymorphen Funktionen gute Fehlermeldungen zu liefern, da es mehrere Möglichkeiten gibt, das Problem zu beheben.

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
Das heißt, die Variable `restlist` enthält die Liste `list` aber ohne das erste Element der Liste.

Da das Argument den Typ `List a` hat, können wir diese Funktion mit jeder Art von Liste aufrufen.
Wenn wir die Funktion mit einem Wert vom Typ `List Bool` aufrufen, wird die Typvariable `a` zum Beispiel durch den konkreten Typ `Bool` ersetzt.
Wenn wir `length` mit einem Argument vom Typ `List (Maybe String)` aufrufen, wird die Typvariable `a` durch den konkreten Typ `Maybe String` ersetzt.

[^1]: Milner, R., Morris, L., Newey, M. "A Logic for Computable Functions with reflexive and polymorphic types", In Proceedings of the Conference on Proving and Improving Programs (1975)

[^2]: Der Begriff [syntaktischer Zucker](https://de.wikipedia.org/wiki/Syntaktischer_Zucker) geht ebenfalls auf Peter J. Landin zurück.

[^3]: [Sir Charles Antony Richard (C. A. R.) bzw. Tony Hoare](https://en.wikipedia.org/wiki/Tony_Hoare) ist einer der bedeutensten Informatiker der frühern Jahre der Informatik.

[^4]: Vortrag ["Null References: The Billion Dollar Mistake"](https://www.infoq.com/presentations/Null-References-The-Billion-Dollar-Mistake-Tony-Hoare/) aus dem Jahr 2009 von Tony Hoare.

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="data-types.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="functional-abstractions.html">weiter</a></li>
    </ul>
</div>
