---
layout: post
title: "Grundlagen"
---

In diesem Kapitel führen wir die Grundlagen der Programmiersprache Elm ein.
Am Ende des Kapitels werden wir in der Lage sein, einfache Funktionen in Elm zu programmieren.
Wir schaffen damit die Grundlagen, um anschließend im Abschnitt [Eine Erste Anwendung](first-application.md) zu lernen, wie wir eine einfache Elm–Frontend-Anwendung programmieren.

Projekt-Setup
-------------

Zur Illustration der Beispiele verwenden wir das Kommando `elm repl`.
Das Akronym *REPL* steht für **_Read Evaluate Print Loop_** und beschreibt eine textuelle, interaktive Eingabe, in der man einfache Programme eingeben (_Read_), die Ergebnisse des Programms ausrechnen (_Evaluate_) und das Ergebnis auf der Konsole ausgeben (_Print_) kann.
Mit dem Begriff *loop* wird dabei ausgedrückt, dass dieser Vorgang wiederholt werden kann.

Wir werden die folgenden Programme immer in eine Datei mit der Endung `elm` schreiben.
Um die Datei als Modul in der REPL importieren zu können, müssen wir den folgenden Kopf verwenden.

``` elm
module Test exposing (..)
```

Die zwei Punkte in den Klammern beschreiben dabei, dass wir **alle** Definitionen im Modul `Test` zur Verfügung stellen wollen.
Später werden wir in den Klammern explizit die Definitionen auflisten, die unser Modul nach außen zur Verfügung stellen soll.

Um unser Modul in der REPL nutzen zu können, müssen wir zuerst ein Elm-Projekt anlegen.
Zu diesem Zweck muss der Aufruf `elm init` ausgeführt werden.
Das Kommando `elm init` legt unter anderem eine Datei `elm.json` an, die unser Paket beschreibt.

``` json
{
    "type": "application",
    "source-directories": [
        "src"
    ],
    "elm-version": "0.19.1",
    "dependencies": {
        "direct": {
            "elm/browser": "1.0.2",
            "elm/core": "1.0.5",
            "elm/html": "1.0.0"
        },
        "indirect": {
            "elm/json": "1.1.3",
            "elm/time": "1.0.0",
            "elm/url": "1.0.0",
            "elm/virtual-dom": "1.0.2"
        }
    },
    "test-dependencies": {
        "direct": {},
        "indirect": {}
    }
}
```

Dieser Aufruf installiert Basispakete, die bei der Arbeit mit Elm zur Verfügung stehen.
Das Paket `elm/core` stellt zum Beispiel grundlegende Datenstrukturen wie Listen und Funktionen darauf zur Verfügung und `elm/html` stellt Kombinatoren zur Verfügung, um HTML-Seiten zu erzeugen.
Unter <https://package.elm-lang.org> kann man die Dokumentationen zu diesen Paketen und vielen anderen einsehen.

Wir legen die Datei mit unserem Modul im `src`-Verzeichnis ab, das `elm init` erstellt hat.
Wir können dann das Modul laden, indem wir `import Test exposing (..)` in der REPL eingeben.
Die Punkte bedeuten dabei, dass wir **alle** Definitionen, die das Modul `Test` zur Verfügung stellt, importieren wollen.
Später werden wir bei einem Import immer genau angeben, welche Definitionen wir importieren wollen.

Sprachgrundlagen
-----------------

Der folgende Ausschnitt demonstriert, wie man in Elm Kommentare schreibt.

``` elm
-- This is a line comment

{-
  This is a block comment
-}
```

Durch die folgende Angabe kann man in Elm eine Variable definieren.

``` elm
secretNumber : Int
secretNumber =
    42
```

Dabei gibt die erste Zeile den Typ der Variable an, in diesem Fall also ein Integer und die zweite Zeile ordnet der Variable einen Wert zu.

In einer rein funktionalen Programmiersprache sind Variablen nicht veränderbar wie in einer imperativen Sprache, sondern sind lediglich Abkürzungen für komplexere Ausdrücke.
In diesem Fall wird die Variable sogar nicht als Abkürzung verwendet, sondern nur, um dem Wert einen konkreten Namen zu geben und diesen an verschiedenen Stellen verwenden
zu können.
Das heißt, wenn wir die Zeile

``` elm
secretNumber =
    43
```

zu unserem Modul hinzufügen, erhalten wir einen Fehler, da wir die
Variable nicht neu setzen können.

Grunddatentypen
---------------

Wir haben den Datentyp `Int` bereits kennengelernt.
Daneben gibt es noch die folgenden Grunddatentypen.

``` elm
f : Float
f =
    4.567


b1 : Bool
b1 =
    True


b2 : Bool
b2 =
    False


c1 : Char
c1 =
    'a'


c2 : Char
c2 =
    ' '


{-| This definition demonstrates literal strings
-}
s : String
s =
    "Hello World!"
```

Das heißt, im Unterschied zu JavaScript, unterscheidet Elm zwischen dem Typ `Int` und dem Typ `Float`.

Wenn ein Kommentar zu einer Definition geschrieben werden soll, muss ein sogenannter Doc-Kommentar verwendet werden.
Diese Art von Kommentar wird einer Definition zugeordnet.
Wenn wir Elm-Programme schreiben, werden wir das Programm [`elm-format`](https://github.com/avh4/elm-format) verwenden, um den Quellcode zu formatieren.
Auf diese Weise ersparen wir uns das manuelle Formatieren des Quellcodes.
Bei den Kommentaren, die wir bisher kennengelernt haben, wird durch `elm-format` eine Leerzeile zwischen Kommentar und Definition hinzugefügt.
Da ein Doc-Kommentar sich auf eine Definition bezieht, fügt `elm-format` zwischen den Kommentar `This definition demonstrates literal strings` und die Definition von `s` keine Leerzeile ein.


### Arithmetische Ausdrücke

Wir haben gesagt, dass in einer funktionalen Sprache und damit auch in Elm ein Programm ausgeführt wird, indem der Wert eines Ausdrucks berechnet wird.
Dies lässt sich sehr schön mithilfe von arithmetischen und booleschen Ausdrücken illustrieren.
Wir müssen für einen Ausdruck in Elm keinen Typ angeben, da der Compiler in der Lage ist, den Typ selbst zu bestimmen.
Man sagt, dass Elm den Typ inferiert und spricht von [**Typinferenz**](https://en.wikipedia.org/wiki/Type_inference).

Die folgenden Definitionen zeigen einige Beispiele für arithmetische Ausdrücke.

``` elm
ex1 =
    1 + 2


ex2 =
    19 - 25


ex3 =
    2.35 * 2.3


ex4 =
    2.5 / 23.2
```

Elm erlaubt es nicht, Zahlen unterschiedlicher Art zu kombinieren.
So liefert die folgende Definition zum Beispiel einen Fehler.

``` elm
typeError = secretNumber + f
```

Wir können Zahlen nur mit `+` addieren, wenn sie den gleichen Typ haben.
Daher müssen wir Zahlen ggf. explizit konvertieren.

Um einmal zu illustrieren, dass Elm sich sehr viel Mühe bei **Fehlermeldungen** gibt, wollen wir uns den Fehler anschauen, den die REPL liefert, wenn wir versuchen, zwei Zahlen, die unterschiedliche Typen haben, zu addieren.

``` text
-- TYPE MISMATCH -------------------------------------------------- src/Test.elm

I need both sides of (+) to be the exact same type.
Both Int or both Float.

15|     secretNumber + f
        ^^^^^^^^^^^^^^^
But I see an Int on the left and a Float on the right.

Use toFloat on the left (or round on the right) to make both sides match!

Note: Read <https://elm-lang.org/0.19.1/implicit-casts> to learn why Elm does
not implicitly convert Ints to Floats.
```

Wir wollen uns also an den Rat halten und die Funktion `toFloat` verwenden, um den Wert vom Typ `Int` in einen Wert vom Typ `Float` umzuwandeln.
Bisher haben wir nur gesehen, wie binäre Infixoperatoren, wie `+` und `*` verwendet werden.
Um eine Funktion, wie `toFloat` in Elm anzuwenden, schreiben wir den Namen der Funktion, dann ein Leerzeichen und dann das Argument, auf das wir die Funktion anwenden wollen.
Um den Wert der Variable `secretNumber` also in einen `Float` umzuwandeln, schreiben wir `toFloat secretNumber`.
Dieser Ausdruck wendet die Funktion `toFloat` auf das Argument `secretNumber` an.
Im Unterschied zu vielen anderen Programmiersprachen, wie Java, C# oder JavaScript werden in Elm die Argumente einer Funktion/Methode nicht geklammert.
In JavaScript schreibt man zum Beispiel `toFloat(secretNumber)`, um eine Funktion `toFloat` auf ein Argument `secretNumber` anzuwenden.
Wir werden im Kapitel [Funktionen höherer Ordnung](recursion.md) genauer lernen, welchen Hintergrund der Unterschied in der Schreibweise von **Funktionsanwendungen** hat.

Um unser konkretes Problem zu lösen und die Zahlen `secretNumber` und `f` zu addieren, können wir die folgende Definition nutzen.
Das Ergebnis dieser Addition ist dann wieder vom Typ `Float`, das heißt, die Variable `convert` hat den Typ `Float`.

``` elm
convert = toFloat secretNumber + f
```

Im Unterschied zu anderen Sprachen führt der Operator `/` nur Divisionen
von Fließkommazahlen durch.
Das heißt, ein Ausdruck der Form
`secretNumber / 10` liefert ebenfalls einen Typfehler.
Um zwei ganze
Zahlen zu dividieren, muss der Operator `//` verwendet werden, der eine
**ganzzahlige Division** durchführt.

### Boolesche Ausdrücke

Durch Elms Typinferenz müssen wir die Typen von Definitionen zwar nicht angeben, es ist aber guter Stil, die Typen dennoch explizit anzugeben.
Daher werden wir im folgenden bei allen Definitionen immer explizit Typen angeben.
Diese Typen helfen den Leser\*innen das Programm zu verstehen.
Später werden wir in komplexeren Beispielen sehen, dass wir trotzdem im Vergleich zu Sprachen wie Java nur eine geringe Anzahl an Stellen mit einem Typ versehen müssen.

Elm stellt die üblichen booleschen Operatoren für Konjunktion und Disjunktion zur Verfügung.
Die Negation eines booleschen Ausdrucks wird in Elm durch eine Funktion `not` durchgeführt.

``` elm
ex9 : Bool
ex9 =
    False || True


ex10 : Bool
ex10 =
    not (b1 && True)
```

Im Beispiel `ex10` sehen wir auch gleich eine weitere Besonderheit bei der **Funktionsanwendung** in Elm.
Während das Argument bei der Anwendung einer Funktion auf ein Argument an sich nicht geklammert wird, müssen wir das Argument aber klammern, wenn es sich selbst um das Ergebnis einer Anwendung handelt.
In diesem Beispiel wollen wir etwa das Ergebnis der Berechnung `b1 && True` negieren.
Daher klammern wir den Ausdruck `b1 && True` und übergeben so das Ergebnis dieser Berechnung an die Funktion `not`.
Wir könnten auch `(not b1) && True` schreiben.
In diesem Fall würden wir aber das Ergebnis der Berechnung `not b1` als erstes Argument an `&&` übergeben.

Neben den booleschen Operatoren gibt es die üblichen **Vergleichsoperatoren** `==` und `/=`, so wie `<`,
`<=`, `>` und `>=`.
Die Funktion `==` führt immer einen Wert-Vergleich und keinen Referenz-Vergleich durch.
Das heißt, die Funktion `==` überprüft, ob die beiden Argumente die gleiche Struktur haben.
Das Konzept eines Referenz-Vergleichs existiert ist einer funktionalen Sprache wie Elm nicht.

``` elm
ex11 : Bool
ex11 =
    'a' == 'a'


ex12 : Bool
ex12 =
    16 /= 3


ex13 : Bool
ex13 =
    5 > 3 && 'p' <= 'q'


ex14 : Bool
ex14 =
    "Elm" > "C++"
```


### Präzedenzen

Um einen Ausdruck der Form `3 + 4 * 8` nicht klammern zu müssen, definiert Elm für Operatoren Präzedenzen (Bindungsstärken).
Die Präzedenz eines Operators liegt zwischen 0 und 9.
Der Operator `+` hat zum Beispiel die Präzedenz 6 und `*` hat die Präzedenz 7.
Da die Präzedenz von `*` also höher ist als die Präzedenz von `+` bindet `*` stärker als `+` und der Ausdruck `3 + 4 * 8` steht für den Ausdruck `3 + (4 * 8)`.

Wie auch in anderen Programmiersprachen üblich binden die **relationalen Operatoren**, wie `<`, `<=`, `>`, `>=`, `==` und `/=` stärker als die logischen Operatoren `&&` und `||`.
Daher steht der Ausdruck `5 > 3 && 'p' <= 'q'` ohne Klammern für den Ausdruck `(5 > 3) && ('p' <= 'q')`.

Wenn Code mit Operatoren mehrzeilig ist, formatiert `elm-format` den Code so, dass die Operatoren am Beginn der jeweiligen Zeile stehen.
Das Beispiel `ex13` formatiert `elm-format` zum Beispiel wie folgt.

```elm
ex13 =
    5
        > 3
        && 'p'
        <= 'q'
```

Wenn ein Ausdruck mit Operatoren so lang ist, dass er in mehrere Zeile geschrieben werden sollte, können wir explizit Klammern setzen, um eine etwas lesbarere Formatierung zu erhalten.

```elm
ex13 =
    (5 > 3)
        && ('p' <= 'q')
```

Die Präzedenz einer Funktion ist 10, das heißt, eine Funktionsanwendung bindet immer stärker als jeder Infixoperator.
Der Ausdruck `not True || False` steht daher zum Beispiel für `(not True) || False` und nicht etwa für `not (True || False)`.
Wir werden später noch weitere Beispiele für diese Regel sehen.

Neben der Bindungsstärke wird bei Operatoren noch definiert, ob diese **links- oder rechts-assoziativ** sind.
In Elm (wie in vielen anderen Sprachen) gibt es links- und rechts-assoziative Operatoren.
Dies gibt an, wie ein Ausdruck der Form *x* ∘ *y* ∘ *z* interpretiert wird.
Falls der Operator ∘ linksassoziativ ist, gilt *x* ∘ *y* ∘ *z* = (*x*∘*y*) ∘ *z*, falls er rechts-assoziativ ist, gilt *x* ∘ *y* ∘ *z* = *x* ∘ (*y*∘*z*).
Das heißt, im Unterschied zur Bindungsstärke wird die Assoziativität genutzt, um auszudrücken, wie ein Ausdruck geklammert ist, wenn er mehrfach den gleichen Operator enthält.
Im Kapitel [Funktionen höherer Ordnung](recursion.md) werden wir sehen, dass für einige Konzepte der Programmiersprache Elm, die Assoziativität eine entscheidende Rolle spielt.

Funktionsdefinitionen
---------------------

In diesem Abschnitt wollen wir uns anschauen, wie man in Elm einfache Funktionen definieren kann.
Funktionen sind in einer funktionalen Sprache das Gegenstück zu (statischen) Methoden in einer objektorientierten Sprache.
Bevor wir uns die Definition von Funktionen anschauen, führen wir erst einmal ein paar Sprachkonstrukte ein, die wir in der Definition einer Funktion nutzen werden.

### Konditionale

Elm stellt einen `if`-Ausdruck der Form `if b then e1 else e2` zur Verfügung.
Im Unterschied zu einer `if`-Anweisung wie sie in
objektorientierten Programmiersprachen zum Einsatz kommt, kann man bei
einem `if`-Ausdruck den `else`-Zweig nicht weglassen.
Beide Zweige des `if`-Ausdrucks müssen einen Wert liefern.
Da Elm eine statisch getypte Programmiersprache ist -- das heißt, wenn wir das Programm übersetzen, wird eine Typprüfung durchgeführt -- müssen beide Zweige eines `if`-Ausdrucks außerdem Werte liefern, die den gleichen Typ besitzen.
Das heißt, die Ausdrücke `e1` und `e2` müssen nach der Auswertung Werte vom gleichen Typ liefern.

Um den `if`-Ausdruck einmal zu illustrieren, wollen wir eine Funktion `items` definieren.
Die Funktion `items` könnte zum Beispiel für den Warenkorb eines Online-Shops genutzt werden.
Die Funktion erhält eine Zahl und liefert eine
Pluralisierung des Wortes *Gegenstand*.
Die Zahl gibt dabei an, um wie
viele Gegenstände es sich handelt.

``` elm
items : Int -> String
items quantity =
    if quantity == 0 then
        "Kein Gegenstand"

    else if quantity == 1 then
        "Ein Gegenstand"

    else
        String.fromInt quantity ++ " Gegenstände"
```

Die erste Zeile gibt den Typ der Funktion `items` an.
Der Typ sagt aus,
dass die Funktion `items` einen Wert vom Typ `Int` nimmt und einen Wert
vom Typ `String` liefert.
Zwischen den Typ des Arguments und den Typ des Ergebnisses schreiben wir in Elm einen Pfeil.
Der Parameter der Funktion `items` heißt
`quantity` und die Funktion prüft, ob dieser Parameter gleich `0` ist,
gleich `1` ist oder einen sonstigen Wert hat.
Mit dem Operator `++` hängt man zwei Zeichenketten hintereinander.
Die Funktion `String.fromInt` wandelt einen Wert vom Typ `Int` in den entsprechenden `String` um.

Die Funktion `fromInt` ist im Modul `String` definiert.
Ein Modul ist vergleichbar mit einer Klasse mit statischen Methoden in einer objektorientierten Programmiersprache.
Wenn wir beim Import nur `import String` schreiben, ohne ein `exposing (..)` anzugeben, dann können wir Definitionen aus dem Modul `String` nur **qualifiziert** verwenden.
Das heißt, wir müssen vor die Definition, die wir verwenden wollen, noch den Namen des Moduls und einen Punkt schreiben.
Wenn wir statt `String.fromInt` bei der Anwendung nur `fromInt` schreiben, nennt man den Namen der Funktion **unqualifiziert**.
Durch einen qualifizierten Namen können wir direkt am Namen sehen, in welchem Modul die Funktion definiert ist.
Außerdem nutzen wir auf diese Weise den Namen des Moduls als Bestandteil
des Funktionsnamens und können den Namen der Funktion so kürzer fassen.
So kann es zum Beispiel mehrere Funktionen geben, die `fromInt` heißen
und in verschiedenen Modulen definiert sind.
Durch den qualifizierten Namen ist dann uns (und dem Compiler) klar, welche Funktion gemeint ist.

In diesem Beispiel greift wieder die Regeln, dass Funktionsanwendungen -- auch Funktionsapplikationen oder nur **Applikationen** genannt -- stärker binden als Infixoperatoren.
Daher steht der Ausdruck `String.fromInt quantity ++ " Gegenstände"` für den Ausdruck `(String.fromInt quantity) ++ " Gegenstände"`.
Das heißt, wir hängen das Ergebnis des Aufrufs `String.fromInt quantity` vorne an den String `" Gegenstände"`.


### Fallunterscheidungen

In Elm können Funktionen mittels `case`-Ausdruck (Fallunterscheidung) definiert werden.
Ein `case`-Ausdruck ist ähnlich zu einem `switch case` in imperativen Sprachen.
Wir können in einem `case`-Ausdruck zum Beispiel prüfen, ob ein Ausdruck eine konkrete Zahl als Wert hat.
Als Beispiel definieren wir die Funktion `items` mittels `case`-Ausdruck.

``` elm
items : Int -> String
items quantity =
    case quantity of
        0 ->
            "Kein Gegenstand"

        1 ->
            "Ein Gegenstand"

        _ ->
            String.fromInt quantity ++ " Gegenstände"
```

Die Fälle in einem `case`-Ausdruck werden von oben nach unten geprüft.
Wenn wir zum Beispiel die Anwendung `items 0` auswerten, so passt die erste Regel und wir erhalten `"Kein Gegenstand"` als Ergebnis.
Werten wir dagegen `items 3` aus, so passen die ersten beiden Regeln nicht.
Die dritte Regel ist eine *Default*-Regel, die immer passt und daher nur als letzte Regel genutzt werden darf.
Das heißt, wenn wir die Anwendung `items 3` auswerten, wird anschließend der Ausdruck `String.fromInt 3 ++ " Gegenstände"` ausgewertet.
Die Auswertung dieses Ausdrucks liefert schließlich `"3 Gegenstände"` als Ergebnis.

Man bezeichnet das Prüfen eines konkreten Wertes gegen die Angabe auf der linken Seite einer `case`-Regel als _Pattern Matching_.
Das heißt, wenn wir den Ausdruck `items 3` auswerten, führt die Funktion _Pattern Matching_ durch, da überprüft wird, welche der Regeln in der Funktion auf den Wert von `quantity` passt.
Die Konstrukte auf der linken Seite der Regel, also in diesem Fall `0`, `1` und `_` bezeichnet man als *Pattern*, also als Muster.

Wir nutzen _Pattern Matching_ auf Zahlen hier als einfaches und intuitives Beispiel.
In vielen Fällen ist _Pattern Matching_ für eine Funktion, die einen `Int` verarbeitet, keine gute Lösung, da nicht auf negative Zahlen geprüft werden kann.
In der Funktion `items` landen negativen Argumente zum Beispiel im dritten Fall, was nicht unbedingt gewünscht ist.

An dieser Stelle soll noch erwähnt werden, dass wir eine Fallunterscheidung nicht nur über den Wert einer Variable durchführen können, sondern über den Wert eines beliebigen Ausdrucks.
Das heißt, wir können auch die folgende nicht sehr sinnvolle Funktion definieren.

```elm
items : Int -> String
items quantity =
    case quantity + 1 of
        1 ->
            "Kein Gegenstand"

        2 ->
            "Ein Gegenstand"

        _ ->
            String.fromInt quantity ++ " Gegenstände"
```

Diese Funktion verhält sich genau so, wie die zuvor definierte Funktion.
Wir werden später Anwendungsfälle kennenlernen, bei denen es sinnvoll ist, eine Fallunterscheidung über einen komplexen Ausdruck durchzuführen.


### Mehrstellige Funktionen

Bisher haben wir nur Funktionen kennengelernt, die ein einzelnes Argument erhalten.
Um eine mehrstellige Funktion zu definieren, werden die Parameter der Funktion einfach durch Leerzeichen getrennt aufgelistet.
Wir können zum Beispiel wie folgt eine Funktion definieren, die den Preis eines Online-Warenkorbs beschreibt.

``` elm
cart : Int -> Float -> String
cart quantity price =
    "Summe (" ++ items quantity ++ "): " ++ String.fromFloat price
```

Dabei sieht der Typ der Funktion auf den ersten Blick etwas ungewöhnlich aus.
Wir werden später sehen, was es mit diesem Typ auf sich hat.
An dieser Stelle wollen wir nur festhalten, dass die Typen der Parameter bei mehrstelligen Funktionen durch einen Pfeil getrennt werden.
Das heißt, wenn wir den Typ einer Funktion angeben, listen wir die Typen der Argumente und den Ergebnistyp auf und schreiben jeweils `->` dazwischen.

Um die Funktion `cart` anzuwenden, schreiben wir ebenfalls die Argumente durch Leerzeichen getrennt hinter den Namen der Funktion.
Das heißt, der folgende Ausdruck wendet die Funktion `cart` auf die Argumente `3` und `23.42` an.

``` elm
cart 3 23.42
```

Wenn eines der Argumente der Funktion `cart` das Ergebnis einer anderen
Funktion sein soll, so muss diese Funktionsanwendung mit Klammern umschlossen werden.
So wendet der folgende Ausdruck die Funktion `cart`
auf die Summe von `1` und `2` und das Minimum von `1.23` und `3.14` an.

``` elm
cart (1 + 2) (min 1.23 3.14)
```

Diese Schreibweise stellt für viele Nutzer\*innen, die Programmiersprachen wie Java gewöhnt sind, häufig eine große Hürde dar.
Im Grunde muss man sich bei der Anwendung einer Funktion an Hand der Klammern und der Leerzeichen nur überlegen, wie viele Argumente man bei einer Funktionsanwendung an eine Funktion übergibt.
Diese Anzahl muss man dann mit der Anzahl der Parameter der Funktion vergleichen.
Wir betrachten zum Beispiel die Anwendung `cart 1 + 2 3`.
Nach der Leerzeichen- und Klammerregel erhält die Funktion `cart` hier vier Argumente, nämlich `1`, `+`, `2` und `3`, denn diese Argumente sind alle durch Leerzeichen getrennt und keines der Argumente ist von Klammern umschlossen.
Die Funktion `cart` soll aber nur zwei Argumente erhalten, daher fehlen an dieser Stelle Klammern.
Wenn wir dagegen die Anwendung `cart (1 + 2) 3` betrachten, dann werden zwei Argumente an `cart` übergeben, nämlich `(1 + 2)` und `3`.


<!-- ### Lokale Definitionen

In Elm können Konstanten und Funktionen auch lokal definiert werden, das heißt, dass die entsprechende Konstante oder die Funktion nur innerhalb einer anderen Funktion sichtbar ist.
Anders ausgedrückt ist der _Scope_ einer **_Top Level_-Definition** das gesamte Modul.
_Top Level_-Definitionen sind die Definitionen, die wir bisher kennengelernt haben, also Konstanten wie `secretNumber` und Funktionen wie `items` oder `cart`.
Im Kontrast dazu ist der _Scope_ einer lokalen Definition auf einen bestimmten Ausdruck eingeschränkt.

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

Das Prinzip der *Off-side Rule* wurde durch Peter J. Landin[^1] in seiner wegweisenden Veröffentlichung "The Next 700 Programming Languages" im Jahr 1966 erfunden.

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
Wir müssen hier den `let`-Ausdruck klammern, da andernfalls der Wert der Variable `x` mit `23` multipliziert wird. -->


Weitere Datentypen
------------------

In diesem Abschnitt wollen wir die Verwendung einiger einfacher Datentypen vorstellen, die wir zur Implementierung unserer ersten Anwendung benötigen.

### Typ-Synonyme

In Elm kann ein neuer Typ eingeführt werden, indem ein neuer Name für einen bereits bestehenden Typ definiert wird.
Der folgende Code führt zum Beispiel den Namen `Width` als Synonym für den Typ `Int` ein.
Das heißt, an allen Stellen, an denen wir den Typ `Int` verwenden können, können wir auch den Typ `Width` verwenden.

``` elm
type alias Width =
    Int
```

Ein Typsynonym wird verwendet, um einem komplexen Typ einen kürzeren Namen zu geben.
Wir werden diesen Effekt sehen, wenn wir Recordtypen kennenlernen.
Ein Typsynonym wie `Width` ist eigentlich schlechter Programmierstil, da wir ein Typsysnonym für einen einfachen Typ einführen.
Bei dieser Modellierung können wir weiterhin jeden Wert vom Typ `Int` als `Width` verwenden, auch wenn es sich gar nicht um eine Breite handelt.
Wir werden später sehen, wie wir diese Fehlnutzung besser verhindern können.
Wir werden zu Anfang aus didaktischen Gründen diese Form eines Typsynonyms nutzen, später dann aber darauf verzichten.


### Aufzählungstypen

Wie andere Programmiersprachen stellt Elm Aufzählungstypen (_Enumerations_) zur Verfügung.
So kann man zum Beispiel wie folgt einen Datentyp definieren, der die Richtungstasten der Tastatur modelliert.

``` elm
type Key
    = Left
    | Right
    | Up
    | Down
```

Wir können für den Datentyp `Key` Funktionen mithilfe von _Pattern Matching_ definieren.
Bei den einzelnen Werten des Typs spricht man auch von Konstruktoren.
Das heißt, `Left` und `Up` sind zum Beispiel Konstruktoren des Datentyps `Key`.

Die folgende Funktion verwendet _Pattern Matching_ um zu testen, ob es sich um eine der horizontalen Richtungstasten handelt.

``` elm
isHorizontal : Key -> Bool
isHorizontal key =
    case key of
        Left ->
            True

        Right ->
            True

        _ ->
            False
```

Der **Unterstrich** ist ein _Default_-Fall, der für alle Konstruktoren von `Key` passt.
Das heißt, der Fall mit dem Unterstrich (_Underscore Pattern_) passt für alle möglichen Fälle, die `key` noch annehmen kann.
Im Fall der Funktion `isHorizontal` wird der Unterstrich-Fall zum Beispiel verwendet, wenn `key` den Wert `Up` oder den Wert `Down` hat.

Wir können diese Funktion auch definieren, indem wir im _Pattern Matching_ alle Konstruktoren aufzählen und auf den Unterstrich verzichten.
Das heißt, die folgende Funktion `isHorizontalAll` verhält sich genau so wie die Funktion `isHorizontal`.

``` elm
isHorizontalAll : Key -> Bool
isHorizontalAll key =
    case key of
        Left ->
            True

        Right ->
            True

        Up ->
            False

        Down ->
            False
```

Die Verwendung des Unterstrichs ist zwar praktisch, sollte aber mit Bedacht eingesetzt werden.
Wenn wir einen weiteren Konstruktor zum Datentyp `Key` hinzufügen, würde die Funktion `isHorizontal` zum Beispiel weiterhin funktionieren.
Bei der Definition `isHorizontalAll` erhalten wir vom Elm-Compiler dagegen in diesem Fall einen Fehler, da einer der Fälle nicht abgedeckt ist.
Das heißt, wir erhalten einen Fehler zur Kompilierzeit, also bevor der Nutzer die Anwendung verwendet.
Es ist besser, wenn der Compiler einen Fehler liefert, da sich sonst, ohne dass wir es bemerken, Fehler in der Anwendung einschleichen können, die schwer zu finden sind.
Daher sollte man ein Unterstrich\-_Pattern_ nur verwenden, wenn man damit viele Fälle abdecken kann und somit den Code stark vereinfacht.
Ein Beispiel wäre etwa die Funktion `items`, die wir mithilfe von _Pattern Matching_ definiert haben.
In dieser Funktion müssen wir einen Unterstrich verwenden, da es zu
viele mögliche Werte des Typs `Int` gibt, um sie alle explizit aufzuzählen.
Im Fall von `isHorizontal` sparen wir durch den Unterstrich aber nur eine einzige Regel.
In solchen Fällen sollte man auf den Unterstrich verzichten und lieber alle Fälle explizit auflisten.

Als weiteres Beispiel für _Pattern Matching_ führt die folgende Funktion vollständiges _Pattern Matching_ durch und liefert zu einer Richtung eine entsprechende Zeichenkette zurück.

``` elm
toString : Key -> String
toString key =
    case key of
        Left ->
            "Left"

        Right ->
            "Right"

        Up ->
            "Up"

        Down ->
            "Down"
```

### Records

Da Elm als JavaScript-Ersatz gedacht ist, unterstützt es auch Record-Typen.
Wir können zum Beispiel eine Funktion, die für einen Nutzer testet, ob er volljährig ist, wie folgt definieren.

``` elm
hasFullAge : { firstName : String, lastName : String, age : Int } -> Bool
hasFullAge user =
    user.age >= 18
```

Diese Funktion erhält einen Record mit dem Feldern `firstName`, `lastName` und `age` als Argument und liefert einen Wert vom Typ `Bool`.
Im Record haben die Felder `firstName` und `lastName` Einträge vom Typ `String` und das Feld `age` hat einen Eintrag vom Typ `Int`.
Der Ausdruck `user.age` ist eine Kurzform für `.age user`, das heißt, `.age` ist eine Funktion, die einen entsprechenden Record erhält und einen Wert vom Typ `Int`, nämlich das Alter zurückliefert.
Das heißt, hinter dem Ausdruck `user.age` steht eigentlich auch nur eine Funktionsanwendung, nur dass es eine etwas vereinfachte Syntax für diesen Aufruf gibt, die näher an der Syntax ist, die wir aus anderen Sprachen gewohnt sind.

Es ist recht umständlich, den Typ des Nutzers in einem Programm bei jeder Funktion explizit anzugeben.
Um unser Beispiel leserlicher zu gestalten, können wir das folgende Typsynonym für unseren Record-Typ einführen.

``` elm
type alias User =
    { firstName : String
    , lastName : String
    , age : Int
    }

hasFullAge : User -> Bool
hasFullAge user =
    user.age >= 18
```

Das heißt, wir führen den Namen `User` als Kurzschreibweise für einen Record ein und nutzen diesen Typ dann an allen Stellen, an denen wir zuvor den ausführlichen Record-Typ genutzt hätten.

Es gibt eine spezielle Syntax, um initial einen Record zu erzeugen.

``` elm
exampleUser : User
exampleUser =
    { firstName = "Max", lastName = "Mustermann", age = 42 }
```

Wir können einen Record natürlich auch abändern.
Zu diesem Zweck wird die folgende **_Update_-Syntax** verwendet.
Die Funktion `maturing` erhält einen Record in der Variable `user` und liefert einen Record zurück, bei dem die Felder `firstName` und `lastName` die gleichen Einträge haben wie `user`, das Feld `age` ist beim Ergebnis-Record aber auf den Wert `18` gesetzt.

``` elm
maturing : User -> User
maturing user =
    { user | age = 18 }
```

Da Elm eine rein funktionale Programmiersprache ist, wird hier der Record nicht wirklich abgeändert, sondern ein neuer Record mit anderen Werten erstellt.
Das heißt, die Funktion `maturing` erstellt einen neuen Record, dessen Einträge `firstName` und `lastName` die gleichen Werte haben wie die entsprechenden Einträge von `user` und dessen Eintrag `age` auf `18` gesetzt ist.
Dieses Beispiel demonstriert eine sehr einfache Form von deklarativer Programmierung.
In einem sehr imperativen Ansatz, müssten wir den Code, um den neuen Record zu erzeugen und die Felder `firstName` und `lastName` zu kopieren, explizit schreiben.
In einem deklarativeren Ansatz verwenden wir stattdessen eine spezielle Syntax oder eine vordefinierte Funktion, um das gleiche Ziel zu erreichen.

Wir können das Verändern eines Record-Eintrags und das Lesen eines Eintrags natürlich auch kombinieren.
Wir können zum Beispiel die folgende Definition verwenden, um einen Benutzer altern zu lassen.

``` elm
increaseAge : User -> User
increaseAge user =
    { user | age = user.age + 1 }
```

Es ist auch möglich, mehrere Felder auf einmal abzuändern, wie die folgende Funktion illustriert.

``` elm
japanese : User -> User
japanese user =
    { user | firstName = user.lastName, lastName = user.firstName }
```

Zu guter Letzt können wir auch _Pattern Matching_ verwenden, um auf die Felder eines Records zuzugreifen.
Zu diesem Zweck müssen wir die Variablen im _Pattern_ nennen wie die Felder des entsprechenden Record-Typs.

``` elm
fullName : User -> String
fullName { firstName, lastName } =
    firstName ++ " " ++ lastName
```

Diese Variante ist relativ unflexibel, da wir nicht mehr auf den gesamten Record zugreifen können und unsere Funktion zum Beispiel nicht mehr direkt auf die _Update_-Syntax umstellen können.

Wenn wir für einen Record ein Typsynonym einführen, gibt es eine Kurzschreibweise, um einen Record zu erstellen.
Um einen Wert vom Typ `User` zu erstellen, können wir zum Beispiel auch `User "John" "Doe" 20` schreiben.
Dabei gibt die Reihenfolge der Felder in der Definition des Records an, in welcher Reihenfolge die Argumente übergeben werden.
Wir werden im Kapitel [Funktionen höherer Ordnung](higher-order.md) sehen, dass diese Art der Konstruktion bei der Verwendung einer partiellen Applikation praktisch ist.
Diese Konstruktion eines Records hat allerdings den Nachteil, dass in der Definition des Records die Reihenfolge der Einträge nicht ohne Weiteres geändert werden kann, da dadurch unser Programm ggf. nicht mehr kompilieren würde.

An dieser Stelle soll noch kurz ein interessanter Anwendungsfall für Records erwähnt werden.
Einige Programmiersprachen bieten **benannte Argumente** als Sprachfeature.
Das heißt, Argumente einer Funktion bzw. Methode können einen Namen erhalten, um Entwickler\*innen beim Aufruf der Methode klarzumachen, welche Semantik die einzelnen Argumente haben.
Wir betrachten als Beispiel die folgende Funktion, die genutzt werden kann, um das `transform`-Attribut in einer SVG-Graphik zu setzen.

```elm
rotate : String -> String -> String -> String
rotate angle x y =
    "rotate(" ++ angle ++ "," ++ x ++ "," ++ y ++ ")"
```

Wir können diese Funktion nun zum Beispiel mittels `rotate "50" "60" "10"` aufrufen.
Um bei diesem Aufruf herauszufinden, welches der Argumente welche Bedeutung hat, müssen wir uns die Funktion `rotate` anschauen.
In einer Programmiersprache mit benannten Argumenten, können wir den Argumenten einer Funktion/Methode Namen geben und diese beim Aufruf nutzen.
In einer Programmiersprache mit Records können wir diese Funktionalität mithilfe eines Records nachstellen.
Wir können die Funktion `rotate` zum Beispiel wie folgt definieren.

```elm
rotate : { angle : String, x : String, y : String } -> String
rotate { angle, x, y } =
    "rotate(" ++ angle ++ "," ++ x ++ "," ++ y ++ ")"
```

Wenn wir die Funktion `rotate` nun aufrufen, nutzen wir `rotate { angle = "50", x = "60", y = "10" }` und sehen am Argument der Funktion direkt, welche Semantik die verschiedenen Parameter haben.

Wir können die Struktur der Funktion `rotate` noch weiter verbessern.
Zuerst können wir observieren, dass die Argumente der Funktion `rotate` nicht alle gleichberechtigt sind.
Anders ausdrückt gehören die Argumente `x` und `y` der Funktion stärker zusammen, da sie gemeinsam einen Punkt bilden.
Diese Eigenschaft können wir in unserem Code wie folgt explizit darstellen.

```elm
type alias Point =
    { x : String, y : String }


rotate : { angle : String, point : Point } -> String
rotate { angle, point } =
    "rotate(" ++ angle ++ "," ++ point.x ++ "," ++ point.y ++ ")"
```

Wir können diese Implementierung aber noch in einem weiteren Aspekt verbessern.
Aktuell arbeitet unsere Anwendung mit Werten vom Typ `String`.
Das heißt, wir können auch `"a"` als Winkel an die Funktion `rotate` übergeben und müssen dann erst observieren, dass die Anwendung nicht das gewünschte Ergebnis anzeigt.
Um eine offensichtlich falsche Verwendung wie diese zu verhindern, können wir statt des Typs `String` einen Datentyp mit mehr Information nutzen.

```elm
type alias Point =
    { x : Float, y : Float }


rotate : { angle : Float, point : Point } -> String
rotate { angle, point } =
    "rotate("
        ++ String.fromFloat angle
        ++ ","
        ++ String.fromFloat point.x
        ++ ","
        ++ String.fromFloat point.y
        ++ ")"
```

Wenn wir nun versuchen würden, den `String` `"a"` als Winkel an die Funktion `rotate` zu übergeben, würden wir direkt beim Übersetzen des Codes einen Fehler vom Compiler erhalten.
Grundsätzlich sind Fehler zur _Compile Time_ besser als Fehler zur _Run Time_, da Fehler zur _Compile Time_ nicht bei Kund\*innen auftreten können.


### Listen

Elm stellt einen vordefinierten Datentyp für Listen zur Verfügung.
Wir werden hier die Details dieses Datentyps erst einmal ignorieren und uns vor allem damit beschäftigen, wie man eine Liste konstruiert.
Der Datentyp heißt `List` und erhält nach einem Leerzeichen den Typ der Elemente in der Liste.
Das heißt, wir nutzen den Typ `List Int` für eine Liste von Zahlen.

Listen werden in Elm mit eckigen Klammern konstruiert und die Elemente der Liste werden durch Kommata getrennt.
Das heißt, die folgende Definition enthält eine konstante Liste, welche die ersten fünf ganzen Zahlen enthält.

``` elm
list : List Int
list =
    [ 1, 2, 3, 4, 5 ]
```

Eine leere Liste stellt man einfach durch zwei eckige Klammern dar, also als `[]`.
Der Infixoperator `::` hängt vorne an eine Liste ein zusätzliches Element an.
Das heißt, der Ausdruck `1 :: [ 2, 3 ]` liefert die Liste `[ 1, 2, 3 ]`.
Der Infixoperator `++` hängt zwei Listen hintereinander.
Das heißt, der Ausdruck `[ 1, 2 ] ++ [ 3, 4 ]` liefert die Liste `[ 1, 2, 3, 4 ]`.
Dabei ist immer zu beachten, dass in einer funktionalen Programmiersprache Datenstrukturen nicht verändert werden.
Das heißt, der Operator `::` liefert eine neue Liste und verändert nicht etwa sein Argument.

[^1]: Peter J. Landin (<https://en.wikipedia.org/wiki/Peter_Landin>) war einer der Begründer der funktionalen Programmierung.

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="preface.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="first-application.html">weiter</a></li>
    </ul>
</div>