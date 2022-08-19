Grundlagen
==========

In diesem Kapitel führen wir die Grundlagen der Programmiersprache Elm
ein. Am Ende des Kapitels werden wir in der Lage sein, einfache
Funktionen in Elm zu programmieren. Wir schaffen damit die Grundlagen,
um anschließend in
<a href="#sec:architecture-basics" data-reference-type="autoref"
data-reference="sec:architecture-basics">[sec:architecture-basics]</a>
zu lernen, wie wir eine einfache Elm–Frontend-Anwendung programmieren.

Projekt-Setup
-------------

Zur Illustration der Beispiele verwenden wir das Kommando `elm repl`.
Das Akronym *REPL* steht für *Read-Evaluate-Print-Loop* und beschreibt
eine textuelle, interaktive Eingabe, in der man einfache Programme
eingeben (*read*), die Ergebnisse des Programms ausrechnen (*evaluate*)
und das Ergebnis auf der Konsole ausgeben (*print*) kann. Mit dem
Begriff *Loop* wird dabei ausgedrückt, dass dieser Vorgang wiederholt
werden kann. Wir werden die folgenden Programme immer in eine Datei mit
der Endung `elm` schreiben. Um die Datei als Modul in der REPL
importieren zu können, müssen wir den folgenden Kopf verwenden.

``` elm
module Test exposing (..)
```

Die zwei Punkte in den Klammern beschreiben dabei, dass wir alle
Definitionen im `Modul` Test zur Verfügung stellen wollen. Später werden
wir in den Klammern explizit die Objekte auflisten, die unser Modul nach
außen zur Verfügung stellen soll.

Um unser Modul in der REPL nutzen zu können, müssen wir zuerst ein
Elm-Projekt anlegen. Zu diesem Zweck muss der Aufruf `elm init`
ausgeführt werden. Das Kommando `elm init` legt unter anderem eine Datei
`elm.json` an, die unser Paket beschreibt.

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

Dieser Aufruf installiert Basispakete, die bei der Arbeit mit Elm zur
Verfügung stehen. Das Paket `elm/core` stellt zum Beispiel grundlegende
Datenstrukturen wie Listen und Funktionen darauf zur Verfügung und
`elm/html` stellt Kombinatoren zur Verfügung, um HTML-Seiten zu
erzeugen. Unter <https://package.elm-lang.org> kann man die
Dokumentationen zu diesen Paketen und vielen anderen einsehen.

Wir legen die Datei mit unserem Modul im `src`-Verzeichnis ab, das
`elm init` angelegt hat. Wir können dann das Modul laden, indem wir
`import Test exposing (..)` in der REPL eingeben.

Sprach-Grundlagen
-----------------

Der folgende Ausschnitt demonstriert, wie man in Elm Kommentare
schreibt.

``` elm
-- This is a line comment

{-
  This is a block comment
-}
```

Durch die folgende Angabe kann man in Elm eine Variable definieren.

``` elm
magicNumber : Int
magicNumber =
    42
```

Dabei gibt die erste Zeile den Typ der Variable an, in diesem Fall also
ein Integer und die zweite Zeile ordnet der Variable einen Wert zu.

In einer funktionalen Programmiersprache sind Variablen nicht
veränderbar wie in einer imperativen Sprache, sondern sind lediglich
Abkürzungen für komplexere Ausdrücke. In diesem Fall wird die Variable
sogar nicht als Abkürzung verwendet, sondern nur, um dem Wert einen
konkreten Namen zu geben und diesen an verschiedenen Stellen verwenden
zu können. Das heißt, wenn wir die Zeile

``` elm
magicNumber =
    43
```

zu unserem Modul hinzufügen, erhalten wir einen Fehler, da wir die
Variable nicht neu setzen können.

Grunddatentypen
---------------

Wir haben den Datentyp `Int` bereits kennengelernt. Daneben gibt es noch
die folgenden Grunddatentypen.

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


s : String
s =
    "Hello World!"
```

Das heißt, im Unterschied zu JavaScript unterscheidet Elm zwischen dem
Typ `Int` und dem Typ `Float`.

Wenn wir eine der Definitionen aus dem Modul `Test` nutzen möchten,
müssen wir das Modul zuerst mit dem Kommando `import Test exposing (..)`
importieren. Danach können wir die Definitionen in `Test` verwenden.
Dabei besagt das `exposing (..)`, dass wir alle Definitionen aus dem
Modul `Test` importieren möchten.

### Arithmetische Ausdrücke

Wir haben gesagt, dass in einer funktionalen Sprache und damit auch in
Elm ein Programm ausgeführt wird, indem der Wert eines Ausdrucks
berechnet wird. Dies lässt sich sehr schön mit Hilfe von arithmetischen
und booleschen Ausdrücken illustrieren. Wir müssen für einen Ausdruck in
Elm keinen Typ angeben, da der Compiler in der Lage ist, den Typ selbst
zu bestimmen. Man sagt, dass Elm den Typ *inferiert* und spricht von
*Typinferenz*.

Die folgenden Definitionen zeigen einige Beispiele für arithmetische
Ausdrücke.

``` elm
ex1 =
    1 + 2


ex2 =
    19 - 25


ex3 =
    2.35 * 2.3


ex4 =
    2.5 / 23.2


ex5 =
    modBy 19 3
```

Elm erlaubt es nicht, Zahlen unterschiedlicher Art zu kombinieren. So
liefert die folgende Definition zum Beispiel einen Fehler.

``` elm
typeError = magicNumber + f
```

Wir können Zahlen nur mit `+` addieren, wenn sie den gleichen Typ haben.
Daher müssen wir Zahlen ggf. explizit konvertieren.

Um einmal zu illustrieren, dass Elm sich sehr viel Mühe bei
Fehlermeldungen gibt, wollen wir uns den Fehler anschauen, den die REPL
liefert, wenn wir versuchen, zwei Zahlen, die unterschiedliche Typen
haben, zu addieren.

``` text
-- TYPE MISMATCH -------------------------------------------------- src/Test.elm

I need both sides of (+) to be the exact same type. Both Int or both Float.

15|     magicNumber + f
        ^^^^^^^^^^^^^^^
But I see an Int on the left and a Float on the right.

Use toFloat on the left (or round on the right) to make both sides match!

Note: Read <https://elm-lang.org/0.19.1/implicit-casts> to learn why Elm does
not implicitly convert Ints to Floats.
```

Wir wollen uns also an den Rat halten und die Funktion `toFloat`
verwenden, um den Wert vom Typ `Int` in einen Wert vom Typ `Float`
umzuwandeln. So können wir die obige Addition zum Beispiel wie folgt
definieren.

``` elm
convert = toFloat magicNumber + f
```

Im Unterschied zu anderen Sprachen führt der Operator `/` nur Divisionen
von Fließkommazahlen durch. Das heißt, ein Ausdruck der Form
`magigNumber / 10` liefert ebenfalls einen Typfehler. Um zwei ganze
Zahlen zu dividieren, muss der Operator `//` verwendet werden, der eine
ganzzahlige Division durchführt.

### Boolesche Ausdrücke

Elm stellt die üblichen booleschen Operatoren für Konjunktion,
Disjunktion und Negation zur Verfügung.

``` elm
ex9 =
    False || True


ex10 =
    not (b1 && True)
```

Daneben gibt es die Vergleichsoperatoren `==` und `/=`, so wie `<`,
`<=`, `>` und `>=`.

``` elm
ex11 =
    'a' == 'a'


ex12 =
    16 /= 3


ex13 =
    (5 > 3) && ('p' <= 'q')


ex14 =
    "Elm" > "C++"
```

Um einen Ausdruck der Form `3 + 4 * 8` nicht klammern zu müssen,
definiert Elm für Operatoren Präzedenzen (Bindungsstärken). Die
Präzedenz eines Operators liegt zwischen `0` und `9`. Der Operator `+`
hat zum Beispiel die Präzedenz 6 und `*` hat 7. Daher steht der Ausdruck
`3 + 4 * 8` für den Ausdruck `3 + (4 * 8)`. Die Präzedenz einer Funktion
ist 10, das heißt, eine Funktionsanwendung bindet immer stärker als
jeder Infixoperator. Der Ausdruck `not True || False` steht daher zum
Beispiel für `(not True) || False` und nicht etwa für
`not (True || False)`.

Neben der Bindungsstärke wird bei Operatoren noch definiert, ob diese
links- oder rechts-assoziativ sind. In Elm (wie in vielen anderen
Sprachen) gibt es links- und rechts-assoziative Operatoren. Dies gibt
an, wie ein Ausdruck der Form *x* ∘ *y* ∘ *z* interpretiert wird. Falls
der Operator ∘ linksassoziativ ist, gilt
*x* ∘ *y* ∘ *z* = (*x*∘*y*) ∘ *z*,
falls er rechts-assoziativ ist, gilt
*x* ∘ *y* ∘ *z* = *x* ∘ (*y*∘*z*).

Funktionsdefinition
-------------------

In diesem Abschnitt wollen wir uns anschauen, wie man in Elm einfache
Funktionen definieren kann. Funktionen sind in einer funktionalen
Sprache das Gegenstück zu (statischen) Methoden in einer
objektorientierten Sprache.

### Konditional

Elm stellt einen `if`-Ausdruck der Form `if b then e1 else e2` zur
Verfügung. Im Unterschied zu einer `if`-Anweisung wie er in
objektorientierten Programmiersprachen zum Einsatz kommt, kann man bei
einem `if`-Ausdruck den `else`-Zweig nicht weglassen. Beide Zweige des
`if`-Ausdrucks müssen einen Wert liefern. Außerdem müssen beide Zweige
Werte liefern, die den gleichen Typ besitzen. Um den `if`-Ausdruck
einmal zu illustrieren, wollen wir eine Funktion `items` definieren. Die
Funktion `items` wird zum Beispiel für den Warenkorb eines
Shoppingsystems genutzt. Die Funktion erhält eine Zahl und liefert eine
Lokalisierung für das Wort *Gegenstand*. Die Zahl gibt dabei an, um wie
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

Die erste Zeile gibt den Typ der Funktion `items` an. Der Typ sagt aus,
dass die Funktion `items` einen Wert vom Typ `Int` nimmt und einen Wert
vom Typ `String` liefert. Der Parameter der Funktion `items` heißt
`quantity` und die Funktion prüft, ob dieser Parameter gleich `0` ist,
gleich `1` ist oder einen sonstigen Wert hat.

### Fallunterscheidung

In Elm können Funktionen mittels `case`-Ausdruck (Fallunterscheidung)
definiert werden. Ein `case`-Ausdruck ist ähnlich zu einem `switch case`
in imperativen Sprachen. Wir können in einem `case`-Ausdruck zum
Beispiel prüfen, ob ein Ausdruck eine konkrete Zahl als Wert hat. Als
Beispiel definieren wir die Funktion `items` mittels `case`-Ausdruck.
Mit dem Operator `++` hängt man zwei Zeichenketten hintereinander.

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

Die Funktion `String.fromInt` wandelt eine ganze Zahl in eine
Zeichenkette um. Man nennt diese Form eines Aufrufs einen qualifizierten
Funktionsaufrufs. Ein qualifizierte Aufruf bedeutet, dass wir explizit
angeben, wo eine Funktion definiert ist. Wenn wir statt `String.fromInt`
beim Aufruf nur `fromInt` verwenden, nennt man das einen
unqualifizierten Aufruf. `String` ist dabei das Modul, in dem die
Funktion `fromInt` definiert ist. Ein Modul ist vergleichbar mit einer
Klasse mit statischen Methoden in einer objektorientierten
Programmiersprache. Durch einen qualifizierten Funktionsaufruf können
wir direkt am Aufruf sehen, in welchem Modul die Funktion definiert ist.
Außerdem nutzen wir auf diese Weise den Namen des Moduls als Bestandteil
des Funktionsnamens und können den Namen der Funktion so kürzer fassen.
So kann es zum Beispiel mehrere Funktionen geben, die `fromInt` heißen
und in verschiedenen Modulen definiert sind. Durch den qualifizierten
Aufruf ist dann uns (und dem Compiler) klar, welche Funktion gemeint
ist.

Die Fälle in einem `case`-Ausdruck werden von oben nach unten geprüft.
Wenn wir zum Beispiel den Aufruf `items 0` auswerten, so passt die erste
Regel und wir erhalten `"Kein Gegenstand"` als Ergebnis. Geben wir
dagegen `items 3` ein, so passen die ersten beiden Regeln nicht. Die
dritte Regel ist eine *Default*-Regel, die immer passt und daher nur als
letzte Regel genutzt werden darf. Das heißt, wenn wir den Aufruf
`items 3` auswerten, wird anschließend der Ausdruck
`String.fromInt 3 ++ " Gegenstände"` ausgewertet. Die Auswertung dieses
Ausdrucks liefert schließlich `"3 Gegenstände"` als Ergebnis.

Man bezeichnet das Prüfen eines konkreten Wertes gegen die Angabe auf
der linken Seite einer `case`-Regel als *Pattern Matching*. Das heißt,
wenn wir den Ausdruck `items 3` auswerten, führt die Funktion Pattern
Matching durch, da überprüft wird, welcher der Regeln in der Funktion
auf den Wert von `quantity` passen. Die Konstrukte auf der linken Seite
der Regel, also in diesem Fall `0`, `1` und bezeichnet man als
*Pattern*, also als Muster.

### Mehrstellige Funktionen

Bisher haben wir nur Funktionen kennengelernt, die ein einzelnes
Argument erhalten. Um eine mehrstellige Funktion zu definieren, werden
die Argumente der Funktion einfach durch Leerzeichen getrennt
aufgelistet. Wir können zum Beispiel wie folgt eine Funktion definieren,
die den Inhalt eines Online-Warenkorbs beschreibt.

``` elm
cart : Int -> Float -> String
cart quantity price =
    "Summe (" ++ items quantity ++ "): " ++ String.fromFloat price
```

Dabei sieht der Typ der Funktion auf den ersten Blick etwas ungewöhnlich
aus. Wir werden später sehen, was es mit diesem Typ auf sich hat. An
dieser Stelle wollen wir nur festhalten, dass die Typen der Argumente
bei mehrstelligen Funktionen durch einen Pfeil getrennt werden.

Um die Funktion `cart` anzuwenden, schreiben wir ebenfalls die Argumente
durch Leerzeichen getrennt hinter den Namen der Funktion. Das heißt, der
folgende Ausdruck wendet die Funktion `cart` auf die Argumente `3` und
`23.42` an.

``` elm
cart 3 23.42
```

Wenn eines der Argumente der Funktion `cart` das Ergebnis einer anderen
Funktion sein soll, so muss diese Funktionsanwendung mit Klammern
umschlossen werden. So wendet der folgende Ausdruck die Funktion `cart`
auf die Summe von `1` und `2` und das Minimum von `1.23` und `3.14`

``` elm
cart (1 + 2) (min 1.23 3.14)
```

Diese Schreibweise stellt für viele Nutzer\*innen, die
Programmiersprachen wie Java gewöhnt sind, häufig eine große Hürde dar.
Im Grunde muss man sich bei dem Aufruf einer Funktion an Hand der
Klammern und der Leerzeichen aber nur überlegen, wie viele Argumente man
bei einem Funktionsaufruf an eine Funktion übergibt.

### Lokale Definitionen

In Elm können Konstanten und Funktionen auch lokal definiert werden, das
heißt, dass die entsprechende Konstante oder die Funktion nur innerhalb
einer anderen Funktion sichtbar ist. Anders ausgedrückt ist der *Scope*
einer *Top Level*-Definition das gesamte Modul. Im Kontrast dazu ist der
*Scope* einer lokalen Definition auf einen bestimmten Ausdruck
eingeschränkt.

Eine lokale Definition wird mit Hilfe eines `let`-Ausdrucks eingeführt.

``` elm
quartic : Int -> Int
quartic x =
    let
        square =
            x * x
    in
    square * square
```

Ein `let`-Ausdruck startet mit dem Schlüsselwort `let`, definiert dann
beliebig viele Konstanten und Funktionen und schließt schließlich mit
dem Schlüsselwort `in` ab. Die Definitionen, die ein `let`-Ausdruck
einführt, stehen nur in dem Ausdruck nach dem `in` zur Verfügung. Sie
können wie im Beispiel `quartic` aber auf die Argumente der
umschließenden Funktion zugreifen.

Man kann in einem `let`-Ausdruck auch Funktionen definieren, die dann
auch nur in dem Ausdruck nach dem `in` sichtbar sind. Wir werden später
Beispiele sehen, in denen dies sehr praktisch ist, zum Beispiel, wenn
wir Listen verarbeiten. Dort wird häufig die Verarbeitung eines
einzelnen Listenelementes als lokale Funktion definiert.

``` elm
res : Int
res =
    let
        inc n =
            n + 1
    in
    inc 41
```

Wie andere Programmiersprachen, zum Beispiel Python, Elixir und Haskell,
nutzt Elm eine *Off-side Rule*. Das heißt, die Einrückung eines
Programms wird genutzt, um Klammerung auszudrücken und somit Klammern
einzusparen. In objektorientierten Sprachen wie Java wird diese
Klammerung durch geschweifte Klammern ausgedrückt. Dagegen muss die
Liste der Definitionen in einem `let` zum Beispiel nicht geklammert
werden, sondern wird durch ihre Einrückung dem `let`-Block zugeordnet.

Das Prinzip der *Off-side Rule* wurde durch Peter J. Landin[1] in seiner
wegweisenden Veröffentlichung “The Next 700 Programming Languages”
erfunden.

Any non-whitespace token to the left of the first such token on the
previous line is taken to be the start of a new declaration.

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

Das `let` definiert eine Spalte. Alle Definitionen im `let` müssen in
einer Spalte rechts vom Schlüsselwort `let` starten. Die erste
Definition, die in einer Spalte steht, die in der Spalte des `let` oder
weiter links steht, beendet das `let`. Die Definition `layout1` wird
nicht akzeptiert, da das `let` durch das `x` beendet wird, was aber
keine valide Syntax ist, da das `let` mit dem Schlüsselwort `in` beendet
werden muss.

Als weiteres Beispiel betrachten wir die folgende Definition, die
ebenfalls aufgrund der Einrückung nicht akzeptiert wird.

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

Die erste Definition in einem `let`-Ausdruck, also hier das `x`,
definiert ebenfalls eine Spalte. Alle Zeilen, die links von der ersten
Definition starten, beenden die Liste der Definitionen. Alle Zeilen, die
rechts von der ersten Definition starten, werden noch zur vorherigen
Definition gezählt. Das heißt, in diesem Beispiel geht der Compiler
davon aus, dass die Definition von `y` eine Fortsetzung der Definition
von `x` ist.

Weitere Datentypen
------------------

In diesem Abschnitt wollen wir die Verwendung einiger einfacher
Datentypen vorstellen, die wir zur Implementierung unserer ersten
Anwendung benötigen.

### Typ-Synonyme

In Elm kann ein neuer Typ eingeführt werden, indem ein neuer Name für
einen bereits bestehenden Typ angegeben wird. Der folgende Code führt
zum Beispiel den Namen `Weight` als Synonym für den Typ `Int` ein. Das
heißt, an allen Stellen, an denen wir den Typ `Int` verwenden können,
können wir auch den Typ `Weight` verwenden.

``` elm
type alias Weight =
    Int
```

Ein Typsynonym wird verwendet, um einem Typ zu Dokumentationszwecken
einen spezifischeren Namen zu geben. Außerdem wird ein Typsynonym
verwendet, um Schreibarbeit zu sparen. Wir werden diesen Effekt später
sehen, wenn wir komplexere Typen wie Recordtypen kennenlernen.

### Aufzählungstypen

Wie andere Programmiersprachen stellt Elm Aufzählungstypen zur
Verfügung. So kann man zum Beispiel wie folgt einen Datentyp definieren,
der die Richtungstasten der Tastatur modelliert.

``` elm
type Key
    = Left
    | Right
    | Up
    | Down
```

Wir können für den Datentyp `Key` Funktionen mit Hilfe von Pattern
Matching definieren. Bei den einzelnen Werten des Typs spricht man auch
von Konstruktoren. Das heißt, `Left` und `Up` sind zum Beispiel
Konstruktoren des Datentyps `Key`.

Die folgende Funktion testet, ob es sich um eine der horizontalen
Richtungstasten handelt.

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

Wir können diese Funktion auch definieren, indem wir im Pattern Matching
alle Konstruktoren aufzählen und auf den Unterstrich verzichten. Der
Unterstrich ist gleichbedeutend zu einer Variable, nur dass wir auf den
in der Variable gespeicherten Wert nicht zugreifen können. Das heißt,
der Fall mit dem Unterstrich passt für alle möglichen Fällen, die `key`
noch annehmen kann. Im Fall der Funktion `isHorizontal` wird der
Unterstrich-Fall zum Beispiel verwendet, wenn `key` den Wert `Up` oder
den Wert `Down` hat. Die Verwendung des Unterstrichs ist zwar praktisch,
sollte aber mit Bedacht eingesetzt werden. Wenn wir einen weiteren
Konstruktor zum Datentyp `Key` hinzufügen, würde die Funktion
`isHorizontal` zum Beispiel weiterhin funktionieren. Hätten wir
`isHorizontal` definiert, indem wir alle Fälle auflisten, würde der
Elm-Compiler einen Fehler liefern, da einer der Fälle nicht abgedeckt
ist. Es ist besser, wenn der Compiler einen Fehler liefert, da sich
sonst, ohne dass wir es bemerken, Fehler in der Anwendung einschleichen
können, die schwer zu finden sind. Daher sollte man ein
Unterstrich-Pattern nur verwenden, wenn man damit viele Fälle abdecken
kann und somit den Code stark vereinfacht. Ein Beispiel wäre etwas die
Funktion `items`, die wir mithilfe von Pattern Matching definiert haben.
In dieser Funktion müssen wir einen Unterstrich verwenden, da es zu
viele mögliche Wert des Typs `Int` gibt, um sie alle explizit
aufzuzählen.

Die folgende Funktion macht vollständiges Pattern Matching und liefert
zu einer Richtung eine entsprechende Zeichenkette zurück.

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

Da Elm als JavaScript-Ersatz gedacht ist, unterstützt es auch
Record-Typen. Wir können zum Beispiel eine Funktion, die für einen
Nutzer testet, ob er volljährig ist, wie folgt definieren.

``` elm
hasFullAge : { firstName : String, lastName : String, age : Int } -> Bool
hasFullAge user =
    user.age >= 18
```

Der Ausdruck `user.age` ist eine Kurzform für `.age user`, das heißt,
`.age` ist eine Funktion, die einen Wert vom Typ `User` nimmt und dessen
Alter zurückliefert.

Es ist recht umständlich, den Typ des Nutzers in einem Programm jedes
mal anzugeben. Um unser Beispiel leserlicher zu gestalten, können wir
das folgende Typsynonym für unseren Record-Typ einführen.

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

Es gibt eine spezielle Syntax, um initial einen Record zu erzeugen.

``` elm
exampleUser : User
exampleUser =
    { firstName = "Max", lastName = "Mustermann", age = 42 }
```

Wir können einen Record natürlich auch abändern. Zu diesem Zweck wird
die folgende Schreibweise verwendet.

``` elm
maturing : User -> User
maturing user =
    { user | age = 18 }
```

Da Elm eine rein funktionale Programmiersprache ist, wird hier der
Record nicht wirklich abgeändert, sondern ein neuer Record mit anderen
Werten erstellt. Wir können das Verändern eines Record-Eintrags und das
Lesen eines Eintrags natürlich auch kombinieren. Wir können zum Beispiel
die folgende Definition verwenden, um einen Benutzer altern zu lassen.

``` elm
increaseAge : User -> User
increaseAge user =
    { user | age = user.age + 1 }
```

Es ist auch möglich, mehrere Felder auf einmal abzuändern, wie die
folgende Funktion illustriert.

``` elm
japanese : User -> User
japanese user =
    { user | firstName = user.lastName, lastName = user.firstName }
```

Zu guter Letzt können wir auch Pattern Matching verwenden, um auf die
Felder eines Records zuzugreifen. Zu diesem Zweck müssen wir die
Variablen im Pattern nennen wie die Felder des entsprechenden
Record-Typs.

``` elm
fullName : User -> String
fullName { firstName, lastName } =
    firstName ++ " " ++ lastName
```

Wenn wir für einen Record ein Typsynonym einführen, können wir auch die
Syntax der algebraischen Datentypen nutzen, um einen Record zu
erstellen. Das heißt, um einen Wert vom Typ `User` zu erstellen, können
wir zum Beispiel auch `User "John" "Doe" 20` schreiben. Dabei gibt die
Reihenfolge der Felder in der Definition des Records an, in welcher
Reihenfolge die Argumente übergeben werden. Wir werden in
<a href="#chapter:higher-order" data-reference-type="ref"
data-reference="chapter:higher-order">[chapter:higher-order]</a> sehen,
dass diese Art der Konstruktion bei der Verwendung einer partiellen
Applikation praktisch ist. Diese Verwendung hat allerdings den Nachteil,
dass in der Definition des Records die Reihenfolge der Einträge nicht
ohne Weiteres ändern können.

### Listen

Listen werden in Elm mit eckigen Klammern definiert und die Elemente der
Liste werden durch Kommata getrennt.

``` elm
list : List Int
list =
    [ 1, 2, 3, 4, 5 ]
```

Eine leere Liste stellt man einfach durch zwei eckige Klammern dar, also
als `[]`. Der Infixoperator `(::)` hängt vorne an eine Liste ein
zusätzliches Element an. Das heißt, der Ausdruck `1 :: [ 2, 3 ]` liefert
die Liste `[ 1, 2, 3 ]`. Der Infixoperator `(++)` hängt zwei Listen
hintereinander. Das heißt, der Ausdruck `[ 1, 2 ] ++ [ 3, 4 ]` liefert
die List `[ 1, 2, 3, 4 ]`. Dabei ist immer zu beachten, dass in einer
funktionalen Programmiersprache Datenstrukturen nicht verändert werden.
Das heißt, der Operator `(::)` liefert eine neue Liste und verändert
nicht etwa sein Argument.

[1] Peter J. Landin (<https://en.wikipedia.org/wiki/Peter_Landin>) war
einer der Begründer der funktionalen Programmierung.

<div style="display:table;width:100%">
    <ul style="display:table-row;list-style:none">
        <li style="display:table-cell;width:33%;text-align:left"><a href="preface.html">zurück</a></li>
        <li style="display:table-cell;width:33%;text-align:center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li style="display:table-cell;width:33%;text-align:right"><a href="first-application.html">weiter</a></li>
    </ul>
</div>