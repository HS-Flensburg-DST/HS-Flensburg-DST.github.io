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
Mit dem Begriff *Loop* wird dabei ausgedrückt, dass dieser Vorgang wiederholt werden kann.

Wir werden die folgenden Programme immer in eine Datei mit der Endung `elm` schreiben.
Um die Datei als Modul in der REPL importieren zu können, müssen wir den folgenden Kopf verwenden.

``` elm
module Test exposing (..)
```

Die zwei Punkte in den Klammern beschreiben dabei, dass wir **alle** Definitionen im Modul `Test` zur Verfügung stellen wollen.
Später werden wir in den Klammern explizit die Definitionen auflisten, die unser Modul nach außen zur Verfügung stellen soll.

Um unser Modul in der REPL nutzen zu können, müssen wir zuerst ein Elm-Projekt anlegen.
Zu diesem Zweck muss der Aufruf `elm init` ausgeführt werden.
Das Kommando `elm init` legt unter anderem eine Datei `elm.json` an, die unsere Anwendung beschreibt.
In der `elm.json` ist zum Beispiel angegeben, dass es sich um eine Anwendung und keine Bibliothek handelt, dass die Elm-Dateien im Ordner `src` liegen und welche Pakete unsere Anwendung als Abhängigkeiten nutzt.

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

Der Aufruf `elm init` installiert Basispakete, die bei der Arbeit mit Elm zur Verfügung stehen.
Das Paket `elm/core` stellt zum Beispiel grundlegende Datenstrukturen wie Listen und Funktionen darauf zur Verfügung und `elm/html` stellt Kombinatoren zur Verfügung, um HTML-Seiten zu erzeugen.

{% include callout-important.html content="Unter <https://package.elm-lang.org> kann man die Dokumentationen zu den Elm-Paketen `elm/core`, `elm/html` und vielen anderen einsehen." %}

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

Dabei gibt die erste Zeile den Typ der Variable an, in diesem Fall also ein Integer und die zweite und dritte Zeile ordnen der Variable einen Wert zu.
Wir nutzen hier und im Folgenden immer [`elm-format`](https://github.com/avh4/elm-format) um Elm-Programme zu formatieren, damit unsere Programme immer einheitlich formatiert sind.
Dieser _Code Formatter_ sorgt dafür, dass der Wert der Variable in die nächste Zeile geschrieben wird.
Wir erhalten aber auch ein valides Elm-Programm, wenn wir stattdessen `secretNumber = 42` schreiben.
Bei einer Definition wie `secretNumber` bezeichnet man den Teil hinter dem `=`-Zeichen als **rechte Seite der Definition**.

{% include callout-info.html content="In Haskell wird statt des einfachen Doppelpunktes `:` der doppelte Doppelpunkt `::` verwendet, um den Typ einer Definition anzugeben." %}

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
float : Float
float =
    4.567


bool1 : Bool
bool1 =
    True


bool2 : Bool
bool2 =
    False


char1 : Char
char1 =
    'a'


char2 : Char
char2 =
    ' '


{-| This comment illustrates how to attach a comment to a definition
-}
string : String
string =
    "Hello World!"
```

Das heißt, im Unterschied zu JavaScript, unterscheidet Elm zwischen dem Typ `Int` und dem Typ `Float`.

Wenn ein Kommentar zu einer Definition geschrieben werden soll, muss ein sogenannter Doc-Kommentar verwendet werden.
Diese Art von Kommentar wird einer Definition zugeordnet.
Wie bereits erwähnt, verwenden wir [`elm-format`](https://github.com/avh4/elm-format), um den Quellcode zu formatieren.
Bei den Kommentaren, die wir bisher kennengelernt haben, wird durch `elm-format` eine Leerzeile zwischen Kommentar und Definition hinzugefügt.
Da ein Doc-Kommentar sich auf eine Definition bezieht, fügt `elm-format` zwischen den Kommentar `This comment illustrates how to attach a comment to a definition` und die Definition von `string` keine Leerzeile ein.


### Arithmetische Ausdrücke

Wir haben gesagt, dass in einer funktionalen Sprache und damit auch in Elm ein Programm ausgeführt wird, indem der Wert eines Ausdrucks berechnet wird.
Dies lässt sich sehr schön mithilfe von arithmetischen und booleschen Ausdrücken illustrieren.
Wir müssen für einen Ausdruck in Elm keinen Typ angeben, da der Compiler in der Lage ist, den Typ selbst zu bestimmen.
Man sagt, dass Elm den Typ inferiert und spricht von [**Typinferenz**](https://en.wikipedia.org/wiki/Type_inference).

Die folgenden Definitionen zeigen einige Beispiele für arithmetische Ausdrücke.

``` elm
arith1 =
    1 + 2


arith2 =
    19 - 25


arith3 =
    2.35 * 2.3


arith4 =
    2.5 / 23.2
```

Elm erlaubt es nicht, Zahlen unterschiedlicher Art zu kombinieren.
So liefert die folgende Definition zum Beispiel einen Fehler.

``` elm
typeError =
    secretNumber + float
```

Wir können Zahlen nur mit `+` addieren, wenn sie den gleichen Typ haben.
Daher müssen wir Zahlen ggf. explizit konvertieren.

Um einmal zu illustrieren, dass der Elm-Compiler vergleichsweise gute **Fehlermeldungen** liefert, wollen wir uns den Fehler anschauen, den die REPL liefert, wenn wir versuchen, zwei Zahlen, die unterschiedliche Typen haben, zu addieren.

``` text
-- TYPE MISMATCH -------------------------------------------------- src/Test.elm

I need both sides of (+) to be the exact same type.
Both Int or both Float.

15|     secretNumber + float
        ^^^^^^^^^^^^^^^^^^^^
But I see an Int on the left and a Float on the right.

Use toFloat on the left (or round on the right) to make both sides match!

Note: Read <https://elm-lang.org/0.19.1/implicit-casts> to learn why Elm does
not implicitly convert Ints to Floats.
```

Wir wollen uns also an den Rat halten und die Funktion `toFloat` verwenden, um den Wert vom Typ `Int` in einen Wert vom Typ `Float` umzuwandeln.
Bisher haben wir nur gesehen, wie binäre Infixoperatoren, wie `+` und `*` verwendet werden.

{% include callout-important.html content="Um eine Funktion, wie `toFloat` in Elm anzuwenden, schreiben wir den Namen der Funktion, dann ein Leerzeichen und dann das Argument, auf das wir die Funktion anwenden wollen." %}

Um den Wert der Variable `secretNumber` also in einen `Float` umzuwandeln, schreiben wir `toFloat secretNumber`.
Dieser Ausdruck wendet die Funktion `toFloat` auf das Argument `secretNumber` an.

Im Unterschied zu vielen anderen Programmiersprachen, wie Java, C# oder JavaScript werden in Elm die Argumente einer Funktion/Methode nicht geklammert.
In JavaScript schreibt man zum Beispiel `toFloat(secretNumber)`, um eine Funktion `toFloat` auf ein Argument `secretNumber` anzuwenden.
Wir werden im Kapitel [Funktionen höherer Ordnung](higher-order.md) genauer lernen, welchen Hintergrund der Unterschied in der Schreibweise von **Funktionsanwendungen** hat.

Um unser konkretes Problem zu lösen und die Zahlen `secretNumber` und `float` zu addieren, können wir die folgende Definition nutzen.
Das Ergebnis dieser Addition ist dann wieder vom Typ `Float`, das heißt, die Variable `convert` hat den Typ `Float`.

``` elm
convert =
    toFloat secretNumber + float
```

Im Unterschied zu anderen Sprachen führt der Operator `/` nur Divisionen
von Fließkommazahlen durch.
Das heißt, ein Ausdruck der Form
`secretNumber / 10` liefert ebenfalls einen Typfehler.
Um zwei ganze
Zahlen zu dividieren, muss der Operator `//` verwendet werden, der eine
**ganzzahlige Division** durchführt.

### Boolesche Ausdrücke

{% include callout-important.html content="Durch Elms Typinferenz müssen wir die Typen von Definitionen zwar nicht angeben, es ist aber guter Stil, die Typen dennoch explizit anzugeben." %}

Die Typangaben fungieren als eine Art überprüfte Dokumentation und helfen Leser\*innen, sich schneller im Code zurechtzufinden.
Daher werden wir im folgenden bei allen Definitionen immer explizit Typen angeben.
Im Vergleich zu Programmiersprachen wie Java müssen wir dennoch wesentlich weniger Stellen mit Typinformationen versehen, da wir uns durch die Typinferenz wiederholende Typangaben sparen können.

Elm stellt die üblichen booleschen Operatoren für Konjunktion und Disjunktion zur Verfügung.
Die Negation eines booleschen Ausdrucks wird in Elm durch eine Funktion `not` durchgeführt.

``` elm
bool3 : Bool
bool3 =
    False || True


bool4 : Bool
bool4 =
    not (bool1 && True)
```

Im Beispiel `bool4` sehen wir auch gleich eine weitere Besonderheit bei der Funktionsanwendung in Elm.

{% include callout-important.html content="Während das Argument bei der Anwendung einer Funktion auf ein Argument an sich nicht geklammert wird, müssen wir das Argument aber klammern, wenn es sich selbst um das Ergebnis einer Anwendung handelt." %}

In diesem Beispiel wollen wir etwa das Ergebnis der Berechnung `bool1 && True` negieren.
Daher klammern wir den Ausdruck `bool1 && True` und übergeben so das Ergebnis dieser Berechnung an die Funktion `not`.
Wir könnten auch `(not bool1) && True` schreiben.
In diesem Fall würden wir aber das Ergebnis der Berechnung `not bool1` als erstes Argument an `&&` übergeben.

Neben den booleschen Operatoren gibt es die üblichen **Vergleichsoperatoren** `==` und `/=`, so wie `<`,
`<=`, `>` und `>=`.

{% include callout-important.html content="
Die Funktion `==` führt immer einen Wert-Vergleich und keinen Referenz-Vergleich durch.
" %}

Das heißt, die Funktion `==` überprüft, ob die beiden Argumente die gleiche Struktur haben.
Das Konzept eines Referenz-Vergleichs existiert in einer rein funktionalen Sprache wie Elm nicht.

``` elm
bool5 : Bool
bool5 =
    'a' == 'a'


bool6 : Bool
bool6 =
    16 /= 3


bool7 : Bool
bool7 =
    5 > 3 && 'p' <= 'q'


bool8 : Bool
bool8 =
    "Elm" > "C++"
```

{% include callout-important.html content="
Die Funktionen `==` und `/=` stehen für jeden Datentyp zur Verfügung.
Die Funktionen `<`, `<=`, `>` und `>=` stehen dagegen nur für bestimmte Datentypen zur Verfügung.
" %}

Im Kapitel [Spezielle Typvariablen](other-elm-topics.md#spezielle-typvariablen) wird dieser Aspekt im Detail diskutiert.
Zum Verständnis werden aber Kenntnisse aus den Kapiteln zuvor benötigt.


### Präzedenzen

Um einen Ausdruck der Form `3 + 4 * 8` nicht klammern zu müssen, definiert Elm für Operatoren Präzedenzen (Bindungsstärken).
Die Präzedenz eines Operators liegt zwischen 0 und 9.
Der Operator `+` hat zum Beispiel die Präzedenz 6 und `*` hat die Präzedenz 7.
Da die Präzedenz von `*` also höher ist als die Präzedenz von `+` bindet `*` stärker als `+` und der Ausdruck `3 + 4 * 8` steht für den Ausdruck `3 + (4 * 8)`.

Wie auch in anderen Programmiersprachen üblich binden die **relationalen Operatoren** wie `<`, `<=`, `>`, `>=`, `==` und `/=` stärker als die logischen Operatoren `&&` und `||`.
Daher steht der Ausdruck `5 > 3 && 'p' <= 'q'` ohne Klammern für den Ausdruck `(5 > 3) && ('p' <= 'q')`.

Wenn Code mit Operatoren mehrzeilig ist, formatiert `elm-format` den Code so, dass die Operatoren am Beginn der jeweiligen Zeile stehen.
Das Beispiel `bool7` formatiert `elm-format` zum Beispiel wie folgt.

```elm
bool7 =
    5
        > 3
        && 'p'
        <= 'q'
```

Wir werden erst sehr viel später sehen, warum diese Formatierung in vielen Fällen sinnvoll ist.
Wenn ein Ausdruck mit Operatoren so lang ist, dass er in mehrere Zeile geschrieben werden sollte, können wir explizit Klammern setzen, um eine etwas lesbarere Formatierung zu erhalten.

```elm
bool7 =
    (5 > 3)
        && ('p' <= 'q')
```

{% include callout-important.html content="Die Präzedenz einer Funktion ist 10, das heißt, eine Funktionsanwendung bindet immer stärker als jeder Infixoperator." %}

Der Ausdruck `not True || False` steht daher zum Beispiel für `(not True) || False` und nicht etwa für `not (True || False)`.
Wir werden später noch weitere Beispiele für diese Regel sehen.

Neben der Bindungsstärke wird bei Operatoren noch definiert, ob diese **links-** oder **rechts-assoziativ** sind.
In Elm (wie in vielen anderen Sprachen) gibt es links- und rechts-assoziative Operatoren.
Dies gibt an, wie ein Ausdruck der Form *x* ∘ *y* ∘ *z* interpretiert wird.
Falls der Operator ∘ linksassoziativ ist, gilt *x* ∘ *y* ∘ *z* = (*x* ∘ *y*) ∘ *z*, falls er rechts-assoziativ ist, gilt *x* ∘ *y* ∘ *z* = *x* ∘ (*y* ∘ *z*).
Das heißt, im Unterschied zur Bindungsstärke wird die Assoziativität genutzt, um auszudrücken, wie ein Ausdruck geklammert ist, wenn er mehrfach den gleichen Operator enthält.
Im Kapitel [Funktionen höherer Ordnung](recursion.md) werden wir sehen, dass für einige Konzepte der Programmiersprache Elm die Assoziativität eine entscheidende Rolle spielt.

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
Die Zahl gibt dabei an, um wie viele Gegenstände es sich handelt.
Bei einer Definition wie `items` bezeichnet man den Teil hinter dem `=`-Zeichen als **rechte Seite der Definition**.

``` elm
items : Int -> String
items quantity =
    if quantity == 1 then
        "1 Gegenstand"

    else
        String.fromInt quantity ++ " Gegenstände"
```

Die erste Zeile gibt den Typ der Funktion `items` an.
Der Typ sagt aus,
dass die Funktion `items` einen Wert vom Typ `Int` nimmt und einen Wert
vom Typ `String` liefert.
Zwischen den Typ des Arguments und den Typ des Ergebnisses schreiben wir in Elm einen Pfeil.
Der Parameter der Funktion `items` heißt
`quantity` und die Funktion prüft, ob dieser Parameter gleich `1` ist oder einen sonstigen Wert hat.
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
Das heißt, wir hängen den `String` `" Gegenstände"` hinter das Ergebnis des Aufrufs `String.fromInt quantity`. 

Um komplexere Programme zu konstruieren, folgt man in Elm --- wie in allen Programmiersprachen --- Bauprinzipien.
Zum Beispiel können im `then`- und im `else`-Zweig eines `if`-Ausdrucks wieder Ausdrücke stehen.
Da ein `if`-Ausdruck selbst ein Ausdruck ist, können wir auf diese Weise Mehrfachfallunterscheidungen umsetzen.
Wir betrachten zum Beispiel die folgende Variante der Funktion `items`.
Hier ist der Ausdruck, der hinter dem Schlüsselwort `else` steht wieder ein `if`-Ausdruck.

``` elm
items : Int -> String
items quantity =
    if quantity == 0 then
        "Keine Gegenstände"

    else if quantity == 1 then
        "1 Gegenstand"

    else
        String.fromInt quantity ++ " Gegenstände"
```


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
            "Keine Gegenstände"

        1 ->
            "1 Gegenstand"

        _ ->
            String.fromInt quantity ++ " Gegenstände"
```

Die Fälle in einem `case`-Ausdruck werden von oben nach unten geprüft.
Wenn wir zum Beispiel die Anwendung `items 0` auswerten, so passt die erste Regel und wir erhalten `"Keine Gegenstände"` als Ergebnis.
Werten wir dagegen `items 3` aus, so passen die ersten beiden Regeln nicht.
Die dritte Regel mit dem Unterstrich ist eine *Default*-Regel, die immer passt und daher nur als letzte Regel genutzt werden darf.
Das heißt, wenn wir die Anwendung `items 3` auswerten, wird anschließend der Ausdruck `String.fromInt 3 ++ " Gegenstände"` ausgewertet.
Die Auswertung dieses Ausdrucks liefert schließlich `"3 Gegenstände"` als Ergebnis.

Man bezeichnet das Prüfen eines konkreten Wertes gegen die Angabe auf der linken Seite einer `case`-Regel als **_Pattern Matching_**.
Das heißt, wenn wir den Ausdruck `items 3` auswerten, führt die Funktion _Pattern Matching_ durch, da überprüft wird, welche der Regeln in der Funktion auf den Wert von `quantity` passt.
Die Konstrukte auf der linken Seite der Regel, also in diesem Fall `0`, `1` und `_` bezeichnet man als **_Pattern_**, also als **Muster**.
Der Ausdruck, über den wir eine Fallunterscheidung durchführen -- in diesem Fall also die Variable `quantity` -- wird als **_Scrutinee_** bezeichnet.
Dieses Wort bedeutet so viel wie "Der Geprüfte" und stammt vom Verb _scrutinize_ (genau untersuchen, genau prüfen).

{% include callout-important.html content="Wir nutzen _Pattern Matching_ auf Zahlen hier als einfaches und intuitives Beispiel.
In vielen Fällen ist _Pattern Matching_ für eine Funktion, die einen `Int` verarbeitet, keine gute Lösung, da nicht auf negative Zahlen geprüft werden kann." %}

In der Funktion `items` landen negative Argumente zum Beispiel im dritten Fall, was nicht unbedingt gewünscht ist.
Daher sollte man zur Prüfung eines Wertes vom Typ `Int` in vielen Fällen einen `if`-Ausdruck nutzen.

An dieser Stelle soll noch erwähnt werden, dass wir eine Fallunterscheidung nicht nur über den Wert einer Variable durchführen können, sondern über den Wert eines beliebigen Ausdrucks.
Als Beispiel betrachten wir die folgende nicht sehr sinnvolle Funktion.

```elm
items : Int -> String
items quantity =
    case quantity + 1 of
        1 ->
            "Keine Gegenstände"

        2 ->
            "1 Gegenstand"

        _ ->
            String.fromInt quantity ++ " Gegenstände"
```

Diese Funktion verhält sich genau so, wie die zuvor definierte Funktion.
Statt der Addition können wir für den _Scrutinee_ auch einen beliebigen anderen Ausdruck nutzen.
Zum Beispiel könnten wir auch eine Fallunterscheidung über das Ergebnis eines `if`-Ausdrucks durchführen.
Wir werden später Anwendungsfälle kennenlernen, bei denen es sinnvoll ist, eine Fallunterscheidung über einen komplexen Ausdruck durchzuführen.

Wenn man eine Programmiersprache lernt, sieht man häufig nur bestimmte Formen von Beispielen.
Die meisten Beispiele für `case`-Ausdrücke in funktionalen Sprachen haben etwa eine Variable als _Scrutinee_.
Daher denken viele Studierende, dass der _Scrutinee_ immer eine Variable sein muss.
Dieses Beispiel illustriert, dass man anhand von einzelnen Beispielen eine Programmiersprache nicht vollständig beherrschen kann.
Um wirklich zu verstehen, welche Formen von Programmen erlaubt sind, reichen daher einzelne Beispielprogramme nicht aus.
Um ein tieferes Verständnis für den Aufbau von Programmen zu erhalten, kann es daher hilfreich sein, sich eine Grammatik für die Sprache anzuschauen.
Im Folgenden ist ein Auszug aus einer Grammatik für Elm in [_Extended Backus-Naur form_](https://en.wikipedia.org/wiki/Extended_Backus–Naur_form) angegeben.

```elm
expression = literal ;
           | identifier ;
           | expression expression ;
           | "(" expression ")" ;
           | expression operator expression ;
           | "if" expression "then" expression "else" expression ;
           | "case" expression "of" "{" pattern "->" expression { pattern "->" expression } "}" ;
           | "(" expression "," expression { "," expression } ")", ;
           | "[" [ expression { "," expression } ] "]" ;
           | "{" [ field_expression, { "," field_expression } ] "}" ;
           | ...
```

Man kann an dieser Grammatik erkennen, dass die _Scrutinee_ des `case`-Ausdrucks eine `expression` ist.
Außerdem kann man andeutungsweise erkennen, was in Elm ein Ausdruck ist, nämlich ein Literal, ein Bezeichner, eine Funktionsanwendung, ein geklammerter Ausdruck, die Anwendung eines Operators, ein `if`-Ausdruck, ein `case`-Ausdruck etc.
Das heißt, all diese Konstrukte können als _Scrutinee_ verwendet werden.


### Mehrstellige Funktionen

Bisher haben wir nur Funktionen kennengelernt, die ein einzelnes Argument erhalten.
Um eine mehrstellige Funktion zu definieren, werden die Parameter der Funktion einfach durch Leerzeichen getrennt aufgelistet.
Wir können zum Beispiel wie folgt eine Verallgemeinerung der Funktion `items` definieren.
Die Funktion `pluralize` nimmt die Singular- und die Pluralform eines Wortes und eine Anzahl und verwendet je nach Anzahl die Singular- oder Pluralform.

``` elm
pluralize : String -> String -> Int -> String
pluralize singular plural quantity  =
    if quantity == 1 then
        "1 " ++ singular

    else
        String.fromInt quantity ++ " " ++ plural
```

Dabei sieht der Typ der Funktion auf den ersten Blick etwas ungewöhnlich aus.
Wir werden später sehen, was es mit diesem Typ auf sich hat.
An dieser Stelle wollen wir nur festhalten, dass die Typen der Parameter bei mehrstelligen Funktionen durch einen Pfeil getrennt werden.
Das heißt, wenn wir den Typ einer Funktion angeben, listen wir die Typen der Argumente und den Ergebnistyp auf und schreiben jeweils `->` dazwischen.

Um die Funktion `pluralize` anzuwenden, schreiben wir ebenfalls die Argumente durch Leerzeichen getrennt hinter den Namen der Funktion.
Das heißt, der folgende Ausdruck wendet die Funktion `pluralize` auf die Argumente `"Gegenstand"`, `"Gegenstände"` und `3` an.

``` elm
pluralize "Gegenstand" "Gegenstände" 3
```

Wenn eines der Argumente der Funktion `pluralize` das Ergebnis einer anderen Funktion sein soll, so muss diese Funktionsanwendung mit Klammern umschlossen werden.
So wendet der folgende Ausdruck die Funktion `pluralize` auf die Argumente `"Gegenstand"`, `"Gegenstände"` und die Summe von `1` und `2` an.

``` elm
pluralize "Gegenstand" "Gegenstände" (1 + 2)
```

Diese Schreibweise stellt für viele Nutzer\*innen, die Programmiersprachen wie Java gewöhnt sind, häufig eine große Hürde dar.

{% include callout-important.html content="Bei der Anwendung einer Funktion kann man sich anhand der Klammern und der Leerzeichen überlegen, wie viele Argumente man bei einer Funktionsanwendung an eine Funktion übergibt.
Diese Anzahl kann man dann mit der Anzahl der Parameter der Funktion vergleichen." %}

Wir betrachten zum Beispiel die Anwendung `pluralize "Gegenstand" "Gegenstände" 1 + 2`.
Nach der Leerzeichen- und Klammerregel erhält die Funktion `pluralize` hier fünf Argumente, nämlich `"Gegenstand"`, `"Gegenstände"`, `1`, `+` und `2`, denn diese Argumente sind alle durch Leerzeichen getrennt und keines der Argumente ist von Klammern umschlossen.
Die Funktion `pluralize` soll aber nur drei Argumente erhalten, daher fehlen an dieser Stelle Klammern.
Wenn wir dagegen die Anwendung `pluralize "Gegenstand" "Gegenstände" (1 + 2)` betrachten, dann werden drei Argumente an `pluralize` übergeben, nämlich `"Gegenstand"`, `"Gegenstände"` und `(1 + 2)`.


Weitere Datentypen
------------------

In diesem Abschnitt wollen wir die Verwendung einiger einfacher Datentypen vorstellen, die wir zur Implementierung unserer ersten Anwendung benötigen.

### Typsynonyme

In Elm kann ein neuer Typ eingeführt werden, indem ein neuer Name für einen bereits bestehenden Typ definiert wird.
Der folgende Code führt zum Beispiel den Namen `Width` als Synonym für den Typ `Int` ein.
Das heißt, an allen Stellen, an denen wir den Typ `Int` verwenden können, können wir auch den Typ `Width` verwenden.

``` elm
type alias Width =
    Int
```

{% include callout-info.html content="In Haskell wird statt der Schlüsselwörter `type alias` nur das Schlüsselwort `type` verwendet, um ein Typsynonym zu definieren." %}

Ein Typsynonym wird verwendet, um einem komplexen Typ einen kürzeren Namen zu geben.
Wir werden diesen Effekt sehen, wenn wir Recordtypen kennenlernen.

{% include callout-important.html content="Ein Typsynonym wie `Width` ist eigentlich schlechter Programmierstil, da wir ein Typsynonym für einen einfachen Typ einführen.
Wir werden zu Anfang aus didaktischen Gründen diese Form eines Typsynonyms nutzen, später dann aber darauf verzichten." %}

Bei dieser Modellierung können wir weiterhin jeden Wert vom Typ `Int` als `Width` verwenden, auch wenn es sich gar nicht um eine Breite handelt.
Wir werden später sehen, wie wir diese Fehlnutzung besser verhindern können.


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

{% include callout-info.html content="In Haskell wird statt des Schlüsselwortes `type` das Schlüsselwort `data` verwendet, um einen Aufzählungstyp zu definieren." %}

Wir können für den Datentyp `Key` Funktionen mithilfe von _Pattern Matching_ definieren.
Bei den einzelnen Werten des Typs spricht man auch von **Konstruktoren**.
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
Im Fall der Funktion `isHorizontal` wird der Unterstrichfall zum Beispiel verwendet, wenn `key` den Wert `Up` oder den Wert `Down` hat.

Wir können diese Funktion auch definieren, indem wir im _Pattern Matching_ alle Konstruktoren aufzählen und auf den Unterstrich verzichten.
Das heißt, die folgende Funktion `isHorizontalComplete` verhält sich genau so wie die Funktion `isHorizontal`.

``` elm
isHorizontalComplete : Key -> Bool
isHorizontalComplete key =
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
Es könnte aber sein, dass das _Default_-Verhalten für den neu hinzugefügten Konstruktor gar nicht korrekt ist.
Bei der Definition `isHorizontalComplete` erhalten wir vom Elm-Compiler dagegen in diesem Fall einen Fehler, da einer der Fälle nicht abgedeckt ist.
Wenn wir immer vollständiges _Pattern Matching_ verwenden, können wir daher nach dem Hinzufügen eines Konstruktors zu einem Datentyp alle Fehlermeldungen des Compilers durchgehen, um das Verhalten für den neu definierten Konstruktor in allen Funktionen zu definieren.
Diese Strategie, sich vom Compiler leiten zu lassen, ist in der funktionalen Programmierung verbreitet und wird in der wissenschaftlichen Publikation [How Statically-Typed Functional Programmers Write Code](https://dl.acm.org/doi/pdf/10.1145/3485532) als _Compilers as directive tools_ bezeichnet.

{% include callout-important.html content="Man sollte ein Unterstrich\-_Pattern_ nur verwenden, wenn man damit viele Fälle abdecken kann und somit den Code stark vereinfacht." %}

Ein Beispiel ist etwa die Funktion `items`, die wir mithilfe von _Pattern Matching_ definiert haben.
In dieser Funktion müssen wir einen Unterstrich verwenden, da es zu viele mögliche Werte des Typs `Int` gibt, um sie alle explizit aufzuzählen.
Im Fall von `isHorizontal` sparen wir durch den Unterstrich aber nur eine einzige Regel.
In solchen Fällen sollte man auf den Unterstrich verzichten und lieber alle Fälle explizit auflisten.

Als weiteres Beispiel für _Pattern Matching_ betrachten wir einen Datentyp für Monate, der im Elm-Paket [elm-time](https://package.elm-lang.org/packages/elm/time/latest) verwendet wird.

```elm
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
```

Wenn wir mit dem Paket [elm-time](https://package.elm-lang.org/packages/elm/time/latest) arbeiten, können wir wie folgt eine Funktion definieren, die für einen Monat einen für deutsche Nutzer\*innen lesbaren Namen liefert.

```elm
monthToString : Month -> String
monthToString month =
    case month of
        Jan ->
            "Januar"

        Feb ->
            "Februar"

        Mar ->
            "März"

        Apr ->
            "April"

        May ->
            "Mai"

        Jun ->
            "Juni"

        Jul ->
            "Juli"

        Aug ->
            "August"

        Sep ->
            "September"

        Oct ->
            "Oktober"

        Nov ->
            "November"

        Dec ->
            "Dezember"
```


### Listen

Elm stellt einen vordefinierten Datentyp für Listen zur Verfügung.
Wir werden hier die Details dieses Datentyps erst einmal ignorieren und uns vor allem damit beschäftigen, wie man eine Liste konstruiert.
Der Datentyp heißt `List` und erhält nach einem Leerzeichen den Typ der Elemente in der Liste.
Das heißt, wir nutzen den Typ `List Int` für eine Liste von Zahlen.

{% include callout-info.html content="In Haskell nutzt der Listendatentyp eine spezielle Syntax und statt `List Int` schreiben wir in Haskell `[Int]`." %}

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

{% include callout-info.html content="In Haskell wird statt des doppelten Doppelpunktes `::` der einfache Doppelpunkt `:` für die Konstruktion einer Liste verwendet." %}

Der Infixoperator `++` hängt zwei Listen hintereinander.
Das heißt, der Ausdruck `[ 1, 2 ] ++ [ 3, 4 ]` liefert die Liste `[ 1, 2, 3, 4 ]`.
Dabei ist immer zu beachten, dass in einer funktionalen Programmiersprache Datenstrukturen nicht verändert werden.
Das heißt, der Operator `::` liefert eine neue Liste und verändert nicht etwa sein Argument.
Gleiches gilt für Funktionen wie den Operator `++`.


### Benennungsstil

In Elm wird grundsätzlich _Caml Case_ verwendet.
In der funktionalen Programmierung ist es nicht unüblich kurze Bezeichner für Variablen zu verwenden.
Der folgende Code-Ausschnitt stammt zum Beispiel von der [offiziellen Seite zur Programmiersprache Haskell](https://www.haskell.org).

```haskell
primes = filterPrime [2..] where
  filterPrime (p:xs) =
    p : filterPrime [x | x <- xs, x `mod` p /= 0]
```

Hier werden die Variablennamen `p`, `xs` und `x` verwendet.
Das `s` im Namen `xs` ist dabei die Pluralbildung in der englischen Sprache.
Das heißt, eine Variable `xs` enthält normalerweise eine Datenstruktur, die mehrere `x` enthält.
Im Fall von Haskell wird mit `xs` in den meisten Fällen eine Liste bezeichnet.

Im Unterschied zu Haskell, ist im offiziellen [Elm Style Guide](https://elm-lang.org/docs/style-guide) die folgende Aussage zu finden.

> **Be Descriptive.** One character abbreviations are rarely acceptable, especially not as arguments for top-level function declarations where you have no real context about what they are.

Das heißt, Elm versucht explizit längere Variablennamen zu fördern.
Tatsächlich werden in Elm-Code bei GitHub wesentlich seltener Einbuchstabenvariablen wie `a`, `p` oder `x` verwendet als in anderen statisch-getypten funktionalen Programmiersprachen.

Unabhängig davon sollte man bei der Benennung die Größe des Gültigkeitsbereichs (_Scope_) einer Variable beachten.
Das heißt, bei einer Variable, die einen sehr kleinen _Scope_ hat, kann ein Name wie `x` angemessen sein, während er es bei einer Variable mit größerem _Scope_ auf jeden Fall nicht ist.

Für Hilfsfunktionen nutzt man in Haskell gern den Suffix `'`.
Das heißt, wenn der Name `primes` schon vergeben ist, nutzt man `primes'`.

{% include callout-info.html content="
In Elm ist das Zeichen `'` als Bestandteil von Bezeichnern nicht erlaubt.
Stattdessen nutzt man den Unterstrich, das heißt, man nutzt Namen wir `primes_`.
" %}


<!-- ### Grundlegendes zur Benennung

An dieser Stelle soll es noch ein paar grundlegende Hinweise zu guter Benennung geben, die auch in anderen Programmiersprachen gültig sind.
Benennungen von Variablen sollten _concise_ und _consistent_ sein[^1].

Mit **konsistent** (_consistent_) ist dabei gemeint, dass identische Konzepte im Programm auch identisch benannt sein sollten.
Das heißt zum Beispiel, wenn in der Funktion `rotate` der Winkel als `angle` bezeichnet wird, sollte diese Bezeichnung auch an anderen Stellen im Programm verwendet werden.
Es wäre also zum Beispiel keine gute Idee, den Winkel an einer Stelle mit `angle` zu bezeichnen und an einer anderen Stelle mit `rotationAngle`. -->

<!-- Es gibt in der natürlichen Sprache zwei Formen von Inkonsistenzen: Homonyme und Synonyme.
Ein Homonym ist ein Wort, dass mehrere Bedeutungen hat. -->

<!-- Um das Konzept der _conciseness_ zu beschreiben, fordern wir erst einmal, dass Bezeichnungen **korrekt** sind.
Damit ist gemeint, dass der Name zumindest ein Oberbegriff des Konzeptes ist, den es beschreibt.
Zum Beispiel wäre der folgende Funktionskopf korrekt, da das Argument der Funktion `rotate` den Mittelpunkt des Objektes beschreibt und der Begriff Punkt ein Oberbegriff von Ursprung ist.
Wenn wir dagegen den Bezeichner `color` an Stelle von `point` wählen würden, wäre dieser nicht korrekt, da Farbe kein Oberbegriff des Konzeptes ist, auf das sich der Bezeichner bezieht.

```elm
rotate : { angle : Float, point : Point } -> String
```

Der Bezeichner `point` ist zwar korrekt, aber vermutlich nicht **präzise** (_concise_).
Wenn wir in unserer Anwendung neben dem Mittelpunkt noch eine weitere Art Punkt nutzen und beide mit dem Bezeichner `point` bezeichnen, so ist der Bezeichner nicht mehr präzise, da wir aus dem Bezeichner nicht ableiten können, welches der beiden Konzepte gemeint ist.
Das heißt, wir versuchen bei der Benennung einen Namen zu wählen, der im Kontext der Anwendung möglichst eindeutig bestimmt, welches Konzept wir meinen.

[^1]: [Concise and consistent naming](https://wwwbroy.in.tum.de/publ/papers/deissenboeck_pizka_identifier_naming.pdf) - Software Quality Journal 14 (2006): 261-282. -->


<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="preface.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="first-application.html">weiter</a></li>
    </ul>
</div>
