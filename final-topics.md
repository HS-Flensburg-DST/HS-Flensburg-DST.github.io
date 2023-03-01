---
layout: post
title: "Weitere Themen"
---

In diesem Kapitel wollen wir uns noch ein paar abschließende Themen anschauen, die bei der Programmierung mit Elm relevant sein können.

Spezielle Typvariablen
----------------------

Einige Funktionen wie zum Beispiel die Funktion `(<)` lassen sich auf verschiedene Typen anwenden.
Wir können zum Beispiel den Aufruf `3 < 4`, aber auch `3.4 < 4.3` sowie `"Schmidt" < "Smith"` auswerten.
Mit den bisher bekannten Sprachkonstrukten könnten wir der Funktion `(<)` nur den Typ `a -> a -> Bool` geben.
Dies würde aber bedeuten, dass es für alle Typen eine entsprechende Funktion zum Vergleichen gibt.
So müsste Elm etwa den Aufruf `(+) < (*)`, das heißt, den Vergleich von zwei Funktionen, akzeptieren.
Elm unterstützt für dieses Problem leider bisher nur eine Ad-hoc-Lösung.
Es ist schon seit längerer Zeit eine alternative Lösung für dieses Problem geplant, bisher ist aber keine Entscheidung für eine der möglichen Alternativen gefallen.

Es gibt spezielle Namen für Typvariablen, die ausdrücken, dass der Typ nicht komplett polymorph ist, sondern nur bestimmte Typen für die Typvariable eingesetzt werden können.
Der Typ der Funktion `(<)` ist zum Beispiel wie folgt.

```
comparable -> comparable -> Bool
```

Das heißt, wir können für die Typvariable `comparable` nur Typen einsetzen, die vergleichbar sind.
Wenn eine Funktion die Funktion `(<)` nutzt, erhält auch die nutzende Funktion diese spezielle Form von Typvariable.
Der Typ der Funktion `List.maximum` ist zum Beispiel wie folgt.

```elm
List comparable -> Maybe comparable
```

Das heißt, wir können nur zu einer Liste von vergleichbaren Elementen das Maximum bestimmen.
Vergleichbar sind in Elm die Typen `String`, `Char`, `Int`, `Float`, `Time`, sowie Listen und Tupel von vergleichbaren Typen.

Wenn wir versuchen, den Ausdruck `(+) < (*)` in Elm zu verwenden, erhalten wir den folgenden Fehler.

``` text
-- TYPE MISMATCH ---------------------------------------------------------- REPL

I cannot do a comparison with this value:

3|   (+) < (*)
     ^^^
This `+` value is a:

    number -> number -> number

But (<) only works on Int, Float, Char, and String values.
It can work on lists
and tuples of comparable values as well, but it is usually better to find a
different path.

Hint: I only know how to compare ints, floats, chars, strings, lists of
comparable values, and tuples of comparable values.
```

Das heißt, wir erhalten einen Fehler, wenn wir das Programm übersetzen.

Neben `comparable` gibt es noch die Typvariable `number`, die für die Typen `Int` und `Float` genutzt werden kann.
Die Konstante `1` hat zum Beispiel den Typ `number` und die Funktion `(+)` hat den Typ
`number -> number -> number`.
Außerdem gibt es noch die Typvariable `appendable`, die Typen repräsentiert, die sich mit `(++)` konkatenieren lassen, das sind die Typen `String` und `List`.

Die Funktion `(==)` nutzt keine Typvariable dieser Form.
Das heißt, die Funktion `(==)` hat den Typ `a -> a -> Bool`.
Man kann also zwei Werte von jedem Typ auf Gleichheit testen.
Der Aufruf `(+) == (*)` liefert zum Beispiel den folgenden Fehler.

``` text
Error: Trying to use `(==)` on functions.
There is no way to know if functions are "the same" in the Elm sense.
Read more about this at
https://package.elm-lang.org/packages/elm/core/latest/Basics#==
which describes why it is this way and what the better version will
look like.
```

Diesen Fehler erhalten wir zur Laufzeit, das heißt, wenn wir das Programm ausführen.
Im Kontext von Programmiersprachen ist die Unterscheidung zwischen _Compile Time_ und _Run Time_ sehr wichtig.
Wenn wir einen Fehler zur _Compile Time_ erhalten, heißt das, wir finden den Fehler vor der Auslieferung zum Kunden.
Wenn wir den Fehler zur _Run Time_ erhalten, heißt das, dass das Programm ggf. beim Kunden abstürzt.

Der Hauptkritikpunkt an den speziellen Variablennamen besteht darin, dass der Nutzer keine weiteren Typen hinzufügen kann.
Das heißt, alle Typen, die nicht von Haus aus zu den vergleichbaren Typen gehören, können mithilfe von `(<)` nicht verglichen werden.
Eine Lösung für dieses Problem stellen zum Beispiel Typklassen dar, die in der funktionalen Programmiersprache Haskell genutzt werden, um Funktionen überladen zu können.
In diesem Fall kann der Nutzer auch selbst Instanzen für eine Funktion hinzufügen.
Eine Erweiterung von Elm um Typklassen oder ein vergleichbares Feature[^1] ist geplant, hat aber keine hohe Priorität.

Interop mit JavaScript
----------------------

Um in Elm mit JavaScript-Code zu kommunizieren, kann man Ports verwenden.
Ein Port besteht dabei aus zwei Komponenten, einer Komponente, die Informationen an den JavaScript-Code schickt und einer Komponente, die informiert wird, wenn der JavaScript-Code ein Ergebnis produziert hat.
Um Informationen an den JavaScript-Code zu senden, wird ein Kommando genutzt und um über ein Ergebnis informiert zu werden, nutzt man ein Abonnement.

Bisher haben wir Elm-Anwendungen ausgeführt, indem wir `elm reactor` genutzt haben.
Um einen Port zu verwenden, müssen wir aber Zugriff auf den JavaScript-Code haben, der ausgeführt wird.
Um dies zu erreichen, können wir `elm make Snake.elm` aufrufen, wobei `Snake.elm` den Elm-Code enthält.
Dieser Aufruf erzeugt eine HTML-Datei[^2], in die der gesamte erzeugte JavaScript-Code eingebettet ist.
Im erzeugten JavaScript-Code wird eine Zeile der folgenden Art genutzt, um die Elm-Anwendung zu erzeugen.

``` javascript
var app = Elm.Snake.init({ node: document.getElementById("elm") });
```

Wir wollen uns jetzt zuerst anschauen, wie wir eine JavaScript-Funktion aus dem Elm-Code heraus aufrufen können.
Ein Modul, das Ports verwendet, muss mit den Schlüsselwörtern `port module` starten.
Als Beispiel fügen wir die folgende Zeile in unser Elm-Programm ein.

``` elm
port callFunction : String -> Cmd msg
```

Hier definieren wir, dass wir einen `String` an eine JavaScript-Funktion übergeben möchten.
Um diese Aktion auszuführen, nutzen wir das gewohnte Konzept eines Kommandos.
Auf JavaScript-Ebene können wir mit dem folgenden Code einen *Callback* registrieren, der aufgerufen wird, wenn wir in unserer Elm-Anwendung das Kommando ausführen, das wir von `callFunction` erhalten.

``` javascript
app.ports.callFunction.subscribe(function(str) {
  ...
});
```

An der Stelle des `...` können wir JavaScript-Code ausführen, der den übergebenen `String` in der Variable `str` nutzt.

Um informiert zu werden, wenn dieser *Callback* seine Ausführung beendet hat, nutzen wir ein Abonnement.
Wir definieren dazu zuerst den folgenden Port in unserer Elm-Anwendung.

``` elm
port returnResult : (String -> msg) -> Sub msg
```

Wir modellieren hier eine Funktion, die ebenfalls einen `String` als Ergebnis liefert.
Mithilfe dieser *Subscription* können wir uns in der Elm-Anwendung informieren lassen, wenn der JavaScript-Code ein Ergebnis liefert.
In der JavaScript-Anwendung rufen wir an einer beliebigen Stelle den folgenden Code auf.

``` javascript
app.ports.returnResult.send(...);
```

Das `...` ist dabei der `String`, den wir an die Elm-Anwendung geben möchten.
Wenn im JavaScript-Code diese Zeile aufgerufen wird, wird die Elm-Anwendung über das entsprechende Abonnement darüber informiert.

Die Seite [JavaScript Interop](https://guide.elm-lang.org/interop/) gibt noch mal eine etwas ausführlichere Einführung in die Verwendung von Ports.

Umsetzung einer größeren Anwendung
----------------------------------

Die Seite [Web Apps](https://guide.elm-lang.org/webapps/) des Elm-Guide bietet noch weitere Themen, die bei der Umsetzung einer größeren Anwendung relevant sein können.
Dazu gehört zum Beispiel die Umsetzung einer Anwendung mit Routing, also eine Anwendung, die aus mehreren Seiten besteht.
Die Seite enthält außerdem Tipps, was man bei der Umsetzung einer Anwendung mit mehreren Modulen beachten sollte.

Die Seite [Optimization](https://guide.elm-lang.org/optimization/) bietet Informationen zur Performance einer Webanwendung.
Dort findet sich zum Beispiel eine Erklärung des *virtual DOM*, der dafür sorgt, dass das Rendern von HTML im Browser effizient durchgeführt wird, obwohl die Funktion `view` immer die gesamte HTML-Struktur als Ergebnis liefert.
Das Kapitel stellt außerdem die Funktion `lazy : (a -> Html msg) -> a -> Html msg` vor, die Caching von Funktionsaufrufen implementiert.
Das heißt, wenn man eine Funktion hat, die eine HTML-Struktur liefert, kann man mithilfe von `lazy` dafür sorgen, dass diese Funktion nur ausgeführt wird, wenn sich die Argumente der Funktion im Vergleich zum vorherigen Aufruf geändert haben.

[^1]: <https://github.com/elm-lang/elm-compiler/issues/38>

[^2]: Alternativ kann man mithilfe des Parameters `-–output` auch dafür sorgen, dass der JavaScript-Code in eine JavaScript-Datei geschrieben wird.

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="abstractions.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"></li>
    </ul>
</div>