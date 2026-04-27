---
layout: post
title: "Grundlagen"
---

Für die meisten Grundlagen der Programmiersprache Elm bzw. der funktionalen Programmierung wird auf die Vorlesung [Grundlagen der funktionalen Programmierung](https://hs-flensburg-gfp.github.io) verwiesen.
In diesem Kapitel führen wir noch ein paar grundlegende Aspekte ein, die in Grundlagen der funktionalen Programmierung nicht zur Sprache kamen.

## Paare

**Paare** sind vordefinierte polymorphe Produktdatentypen.
Mit einem Paar können zwei Werte von unterschiedlichen Typen zu einem Wert zusammengefasst werden.
Im Grunde sind Paare ein algebraischer Datentyp, nur dass Paare wie Listen in Elm eine spezielle Syntax nutzen.
Die Einträge eines Paares werden durch ein Komma getrennt und das Paar wird durch Klammern umschlossen.
Das heißt, der Ausdruck `(1, False)` erzeugt zum Beispiel ein Paar, bei dem die erste Komponente den Wert `1` enthält und die zweite Komponente den booleschen Wert `False`.
Der Typkonstruktor für Paare wird genau so geschrieben wie der Konstruktor für Paare und ist über zwei Typen parametrisiert, nämlich den Typ der ersten Komponente und den Typ der zweiten Komponente.
Das heißt, der Typ des Wertes `(1, False)` ist zum Beispiel `(Int, Bool)`.

Wie bei jedem anderen algebraischen Datentyp kann man _Pattern Matching_ auch für Paare verwenden.
Als Beispiel betrachten wir die Funktion

```elm
uncons : String -> Maybe ( Char, String )
```

aus dem Modul `String`.
Mithilfe dieser Funktion kann man einen `String` in das erste Zeichen und den Rest des _Strings_ zerlegen.
Die Funktion liefert `Nothing`, falls wir sie auf einen leeren `String` anwenden.

Mithilfe dieser Funktion können wir zum Beispiel wie folgt eine Funktion definieren, die alle Zeichen in einer Zeichenkette in Großbuchstaben verwandelt.
Die Funktion `String.cons : Char -> String -> String` hängt ein Zeichen vorne an eine Zeichenkette.

```elm
toUpper : String -> String
toUpper string =
    case String.uncons string of
        Nothing ->
            ""

        Just ( char, reststring ) ->
            String.cons (Char.toUpper char) (toUpper reststring)
```

Man bezeichnet Paare auch als 2-Tupel.
Neben Paaren bietet Elm auch 3-Tupel aber keine Tupel mit anderen Stelligkeiten.

{% include callout-important.html content="
Tupel kommen selten zum Einsatz und sollten nur von sehr allgemein verwendbaren Bibliotheksfunktionen genutzt werden, da ein Tupel sehr wenig Dokumentationscharakter hat.
" %}

Daher bietet sich als Alternative für ein Tupel fast immer ein algebraischer Datentyp oder ein Record an.
Einen Sonderfall eines Tupels stellt das nullstellige Tupel `()` dar, dessen Typ man ebenfalls als `()` schreibt.
Der Typ `()` hat nur einen einzigen Wert, nämlich `()`.
Wir werden später Anwendungsfälle für diesen Datentyp kennenlernen.

## Records

Da Elm als JavaScript-Ersatz gedacht ist, unterstützt es auch Recordtypen.
Wir können zum Beispiel eine Funktion, die für einen Nutzer testet, ob er volljährig ist, wie folgt definieren.

```elm
hasFullAge : { firstName : String, lastName : String, age : Int } -> Bool
hasFullAge user =
    user.age >= 18
```

Diese Funktion erhält einen Record mit dem Feldern `firstName`, `lastName` und `age` als Argument und liefert einen Wert vom Typ `Bool`.
Im Record haben die Felder `firstName` und `lastName` Einträge vom Typ `String` und das Feld `age` hat einen Eintrag vom Typ `Int`.
Die Reihenfolge der Felder spielt dabei keine Rolle.
Das heißt, der Recordtyp `{ firstName : String, lastName : String }` ist identisch zum Recordtyp `{ lastName : String, firstName : String }`.
Man spricht in diesem Fall von einer **strukturellen Typgleichheit**.
Im Gegensatz dazu wird zum Beispiel bei einem algebraischen Datentyp eine **nominelle Typgleichheit** verwendet.
Das heißt, es spielt keine Rolle, ob zwei algebraische Datentypen die gleiche Struktur aufweisen, sie werden dennoch nicht als gleich angesehen.

Der Ausdruck `user.age` ist eine Kurzform für `.age user`, das heißt, `.age` ist eine Funktion, die einen entsprechenden Record erhält und einen Wert vom Typ `Int`, nämlich das Alter zurückliefert.
Man nennt eine Funktion wie `.age` einen **Record-Selektor**, da die Funktion aus einem Record einen Teil selektiert.
Das heißt, hinter dem Ausdruck `user.age` steht eigentlich auch nur eine Funktionsanwendung, nur dass es eine etwas vereinfachte Syntax für diesen Aufruf gibt, die näher an der Syntax ist, die wir aus anderen Sprachen gewohnt sind.

Es ist recht umständlich, den Typ des Nutzers in einem Programm bei jeder Funktion explizit anzugeben.
Um unser Beispiel leserlicher zu gestalten, können wir das folgende Typsynonym für unseren Recordtyp einführen.

```elm
type alias User =
    { firstName : String
    , lastName : String
    , age : Int
    }

hasFullAge : User -> Bool
hasFullAge user =
    user.age >= 18
```

Das heißt, wir führen den Namen `User` als Kurzschreibweise für einen Record ein und nutzen diesen Typ dann an allen Stellen, an denen wir zuvor den ausführlichen Recordtyp genutzt hätten.

Es gibt eine spezielle Syntax, um initial einen Record zu erzeugen.

```elm
exampleUser : User
exampleUser =
    { firstName = "Max", lastName = "Mustermann", age = 42 }
```

Wir können einen Record natürlich auch abändern.
Zu diesem Zweck wird die folgende **_Update_-Syntax** verwendet.
Die Funktion `maturing` erhält einen Record in der Variable `user` und liefert einen Record zurück, bei dem die Felder `firstName` und `lastName` die gleichen Einträge haben wie `user`, das Feld `age` ist beim Ergebnis-Record aber auf den Wert `18` gesetzt.

```elm
maturing : User -> User
maturing user =
    { user | age = 18 }
```

{% include callout-important.html content="Da Elm eine rein funktionale Programmiersprache ist, wird hier der Record nicht wirklich abgeändert, sondern ein neuer Record mit anderen Werten erstellt." %}

Das heißt, die Funktion `maturing` erstellt einen neuen Record, dessen Einträge `firstName` und `lastName` die gleichen Werte haben wie die entsprechenden Einträge von `user` und dessen Eintrag `age` auf `18` gesetzt ist.
Dieses Beispiel demonstriert eine sehr einfache Form von deklarativer Programmierung.
In einem sehr imperativen Ansatz, müssten wir den Code, um den neuen Record zu erzeugen und die Felder `firstName` und `lastName` zu kopieren, explizit schreiben.
In einem deklarativeren Ansatz verwenden wir stattdessen eine spezielle Syntax oder eine vordefinierte Funktion, um das gleiche Ziel zu erreichen.

Wir können das Verändern eines Recordeintrags und das Lesen eines Eintrags natürlich auch kombinieren.
Wir können zum Beispiel die folgende Definition verwenden, um einen Benutzer altern zu lassen.

```elm
increaseAge : User -> User
increaseAge user =
    { user | age = user.age + 1 }
```

Es ist auch möglich, mehrere Felder auf einmal abzuändern, wie die folgende Funktion illustriert.

```elm
japanese : User -> User
japanese user =
    { user | firstName = user.lastName, lastName = user.firstName }
```

An dieser Stelle soll kurz auf die Vorteile von unveränderbaren Datenstrukturen hingewiesen werden.
Zu diesen Zweck betrachten wir die folgende "Übersetzung" des Beispiels nach Java.

```java
public static User japanese(User user) {
    user.setFirstName(user.getLastName());
    user.setLastName(user.getFirstName());
    return user;
}
```

Diese Methode liefert nicht das gewünschte Ergebnis, da wir zuerst den Vornamen auf den Nachnamen setzen und in der folgende Zeile den zuvor gesetzen Vornamen auslesen.
Das heißt, nach Ausführung der Methode `japanese` sind Vor- und Nachname auf den Nachnamen gesetzt.

Zu guter Letzt können wir auch _Pattern Matching_ verwenden, um auf die Felder eines Records zuzugreifen.
Zu diesem Zweck müssen wir die Variablen im _Pattern_ nennen wie die Felder des entsprechenden Recordtyps.

```elm
fullName : User -> String
fullName user =
    case user of
        { firstName, lastName } ->
            firstName ++ " " ++ lastName
```

Wir müssen dabei nicht auf alle Felder des Records _Pattern Matching_ machen, es ist auch möglich, nur einige Felder aufzuführen.
Das heißt, auch die folgende Definition ist erlaubt.

```elm
firstNames : User -> List String
firstNames user =
    case user of
        { firstName } ->
            List.words firstName
```

Das _Pattern Matching_ auf einem Record wirkt durch den `case`-Ausdruck recht umständlich.
Für Datentypen, die nur einen Konstruktor haben (darunter fallen auch Recordtypen) erlaubt Elm, das _Pattern Matching_ direkt in der Funktionsdefinition durchzuführen.
Das heißt, wir können die beiden Funktionen auch wie folgt definieren und auf dem `case`-Ausdruck verzichten.

```elm
fullName : User -> String
fullName { firstName, lastName } =
    firstName ++ " " ++ lastName


firstNames : User -> List String
firstNames { firstName } =
    List.words firstName
```

_Pattern Matching_ auf Records eignet sich sehr gut, wenn wir die Felder des Records nur lesen möchten.
Durch das _Pattern Matching_ können wir den Code kürzen, da die Verwendung der Record-Selektoren länger ist.
Außerdem kann es sehr sinnvoll sein, _Pattern Matching_ auf einem Record zu verwenden, wenn es schwierig ist, für den gesamten Record einen sinnvollen Namen zu vergeben.
Ein solches Beispiel werden wir weiter unten bei der Funktion `rotate` kennenlernen.

Wenn wir für einen Record ein Typsynonym einführen, gibt es eine Kurzschreibweise, um einen Record zu erstellen.
Um einen Wert vom Typ `User` zu erstellen, können wir zum Beispiel auch `User "John" "Doe" 20` schreiben.
Dabei gibt die Reihenfolge der Felder in der Definition des Records an, in welcher Reihenfolge die Argumente übergeben werden.
Diese Art der Konstruktion ist praktisch, wenn wir die Konstruktion des Records nur partiell applizieren wollen.
Wir werden im Kapitel [Decoder](json.md#decoder) Beispiele für diese Konstruktion kennenlernen.
Diese Konstruktion eines Records hat allerdings den Nachteil, dass in der Definition des Records die Reihenfolge der Einträge nicht ohne Weiteres geändert werden kann.
Insbesondere besteht die Gefahr, dass wir die Reihenfolge ändern, ohne dass ein Kompilerfehler auftritt.
Wenn wir zum Beispiel die Definition von `User` wie folgt abändern

```elm
type alias User =
    { lastName : String
    , firstName : String
    , age : Int
    }
```

und `User "John" "Doe" 20` in unserem Programm verwenden, erhalten wir keinen Fehler, die Anwendung verhält sich aber nicht mehr korrekt.

An dieser Stelle soll noch kurz ein Anwendungsfall für Records erwähnt werden.
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
In einer Programmiersprache mit benannten Argumenten, können wir den Argumenten einer Funktion/Methode Namen geben und diese Namen beim Aufruf nutzen.

{% include callout-important.html content="
In einer Programmiersprache mit Records können wir diese Funktionalität mithilfe eines Records nachstellen.
" %}

Wir können die Funktion `rotate` zum Beispiel wie folgt definieren.

```elm
rotate : { angle : String, x : String, y : String } -> String
rotate { angle, x, y } =
    "rotate(" ++ angle ++ "," ++ x ++ "," ++ y ++ ")"
```

Wenn wir die Funktion `rotate` nun aufrufen, schreiben wir `rotate { angle = "50", x = "60", y = "10" }` und sehen direkt beim Aufruf, welche Semantik die verschiedenen Parameter haben.

Wir können die Struktur der Funktion `rotate` noch weiter verbessern.
Zuerst können wir observieren, dass die Argumente der Funktion `rotate` nicht alle gleichberechtigt sind.
Anders ausgedrückt gehören die Argumente `x` und `y` der Funktion stärker zusammen, da sie gemeinsam einen Punkt bilden.
Diese Eigenschaft können wir in unserem Code wie folgt explizit darstellen.

```elm
type alias Point =
    { x : String, y : String }


rotate : { angle : String, origin : Point } -> String
rotate { angle, origin } =
    "rotate(" ++ angle ++ "," ++ origin.x ++ "," ++ origin.y ++ ")"
```

{% include callout-important.html content="
Gute Programmierer*innen zeichnen sich dadurch aus, dass sie solche Strukturen erkennen und zur Strukturierung des Programms nutzen.
" %}

Wir können diese Implementierung aber noch in einem weiteren Aspekt verbessern.
Aktuell arbeitet unsere Anwendung mit Werten vom Typ `String`.
Das heißt, wir können auch `"a"` als Winkel an die Funktion `rotate` übergeben und müssen dann erst observieren, dass die Anwendung nicht das gewünschte Ergebnis anzeigt.
Um eine offensichtlich falsche Verwendung wie diese zu verhindern, können wir statt des Typs `String` einen Datentyp mit mehr Struktur nutzen.

```elm
type alias Point =
    { x : Float, y : Float }


rotate : { angle : Float, origin : Point } -> String
rotate { angle, origin } =
    "rotate("
        ++ String.fromFloat angle
        ++ ","
        ++ String.fromFloat origin.x
        ++ ","
        ++ String.fromFloat origin.y
        ++ ")"
```

Wenn wir nun versuchen würden, den `String` `"a"` als Winkel an die Funktion `rotate` zu übergeben, würden wir direkt beim Übersetzen des Codes einen Fehler vom Compiler erhalten.
Grundsätzlich sind Fehler zur Kompilierzeit (_Compile Time_) besser als Fehler zur Laufzeit (_Run Time_), da Fehler zur Kompilierzeit nicht bei Kund\*innen auftreten können.

{% include callout-important.html content="
Man sollte in allen Programmiersprachen mit Datentypen mit möglichst viel Struktur arbeiten.
Der Datentyp `String` ist zum Beispiel nur die richtige Wahl, wenn es sich tatsächlich um einen beliebigen Text handeln kann.
" %}

<!-- Zu guter Letzt soll hier noch auf eine Möglichkeit zur Strukturierung von Quellcode hingewiesen werden, der von Anfänger\*innen vergleichsweise selten genutzt wird.

{% include callout-important.html content="
Sequentielle Datenstrukturen wie Listen oder Arrays können genutzt werden, um repetitiven Code besser zu strukturieren.
" %}

In der obigen Definition von `rotate` wird immer wieder die Funktion `++` genutzt.
Statt diese Funktion wiederholt zu verwenden, können wir eine Hilfsfunktion nutzen, welche eine Liste erhält und die Funktion `++` wiederholt anwendet.
Die vordefinierte Funktion `String.concat : List String -> String` erhält eine Liste von `String`s und hängt diese alle aneinander.
Wir können diese Funktion zum Beispiel wie folgt nutzen, um die Definition von `rotate` erweiterbarer zu gestalten.


```elm
rotate : { angle : Float, origin : Point } -> String
rotate { angle, origin } =
    String.concat
        [ "rotate("
        , String.fromFloat angle
        , ","
        , String.fromFloat origin.x
        , ","
        , String.fromFloat origin.y
        , ")"
        ]
```

Durch die Verwendung einer Liste könnten wir nun zum Beispiel viel einfacher eine

Wenn wir diese Funktion noch etwas genauer betrachten, stellen wir fest, dass die Wiederholung in der Definition vor allem durch die Trennung der Argumente von `rotate` durch Kommata entsteht.
Mithilfe der Funktion `String.join : String -> List String -> String` können wir diesen Aspekt noch klarer herausarbeiten.
Hier verwenden wir wieder eine Liste, um das wiederholte Hinzufügen eines Kommas besser zu strukturieren.

```elm
rotate : { angle : Float, origin : Point } -> String
rotate { angle, origin } =
    "rotate("
        ++ String.join ","
            [ String.fromFloat angle
            , String.fromFloat origin.x
            , String.fromFloat origin.y
            ]
        ++ ")"
```

Durch die Verwendung einer Liste können wir nun zum Beispiel Transformationen, die auf alle Einträge der Liste angewendet werden sollen durch


```elm
rotate : { angle : Float, origin : Point } -> String
rotate { angle, origin } =
    "rotate("
        ++ String.join ","
            (List.map String.fromFloat [ angle, origin.x, origin.y ])
        ++ ")"
``` -->

## Benennungsstil

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
Tatsächlich werden in Elm-Code bei GitHub für Variablen wesentlich seltener Einbuchstabenvariablen wie `a`, `p` oder `x` verwendet als in anderen statisch-getypten funktionalen Programmiersprachen.
Auch die durchschnittliche Länge von Variablenbezeichnern ist in Elm wesentlich länger als in anderen statisch-getypten funktionalen Programmiersprachen.[^2]

Unabhängig davon sollte man bei der Benennung die Größe des Gültigkeitsbereichs (_Scope_) einer Variable beachten.
Das heißt, bei einer Variable, die einen sehr kleinen _Scope_ hat, kann ein Name wie `x` angemessen sein, während er es bei einer Variable mit größerem _Scope_ auf jeden Fall nicht ist.

<!-- Am Ende dieses Kapitels wollen wir noch betrachten, wie Definitionen in Elm benannt werden.
Die Muster, die hier diskutiert werden, finden sich auch in anderen Programmiersprachen wie Java wieder.
Bei der Benennung von Funktionen und Konstanten treten vor allem drei Muster auf, imperative Verbalphrasen, indikative Verbalphrasen und Nominalphrasen.
Diese drei Kategorien werden im Folgenden erläutert.

#### Imperative Verbalphrasen

In diese Kategorie fallen Funktionsnamen wie `List.reverse`, `List.filter`, `List.sort`, `List.sortBy` und `List.sortWith`.
Eine Verbalphrase ist dabei ein Verb mit einer möglichen Ergänzung.
Die Funktionsnamen in dieser Kategorie nutzen ein Verb im Imperativ.
Diese Art der Namen wird genutzt, wenn eine Funktion Daten nimmt und in veränderter Form zurückliefert.
Die oben genannten Funktionen erhalten zum Beispiel alle eine Liste als Argument und liefern eine Liste als Ergebnis.
Im Unterschied zum Elm werden imperative Verbalphrasen in Java vor allem für Methoden genutzt, die einen Seiteneffekt haben und ihr Argument verändern.

#### Indikative Verbalphrasen

In diese Kategorie fallen Funktionsnamen wie `List.isEmpty`, `Char,isUpper`,  -->

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

[^1]:
    Die Funktion `pluralize` ist im Paket [elm-community/string-extra](https://package.elm-lang.org/packages/elm-community/string-extra/latest/String-Extra#pluralize) definiert.
    Das Paket enthält eine Reihe von Funktionen, die bei der Arbeit mit Zeichenketten nützlich sind.

[^2]: [How developers choose names in statically-typed functional programming languages](https://hs-flensburg-pltp.github.io/files/Christiansen - How developers choose names in statically-typed fu.pdf) - Unpublished Draft

{% include bottom-nav.html previous="preface.html" next="first-application.html" %}
