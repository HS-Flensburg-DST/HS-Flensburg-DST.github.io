---
layout: post
title: "Decoder"
---

Wenn wir HTTP-Anfragen durchführen, erhalten wir vom Server häufig eine Antwort in Form vom JSON.
Diese Antwort erhalten wir aber in Form eines _Strings_.
Das heißt, um die Informationen, die wir benötigen zu extrahieren, müssen wir den _String_ verarbeiten.
Wir wollen in unserer Anwendung aber nicht mit den _String_ hantieren, den wir vom Server erhalten haben, sondern mit einem strukturierten Elm-Datentyp arbeiten.
Um diese Aufgabe umzusetzen, werden in Elm `Decoder` verwendet.

![You shall not parse, syntax error on line 1](/assets/images/parse-error.png){: width="400px" .centered}

Ein `Decoder` ist eine Elm-spezifische Variante des allgemeineren Konzeptes eines **Parser-Kombinators**.
Parser-Kombinatoren sind eine leichtgewichtige Implementierung von Parsern.
Ein Parser ist eine Anwendung, die einen _String_ erhält und prüft, ob der _String_ einem vorgegebenen Format folgt.
Jeder Compiler nutzt zum Beispiel einen Parser, um Programmtext auf syntaktische Korrektheit zu prüfen.
Neben der Überprüfung, ob der _String_ einem Format entspricht, wird der _String_ für gewöhnlich auch noch in ein strukturiertes Format umgewandelt.
Im Fall von Elm, wird der _String_ zum Beispiel in Werte von algebraischen Datentypen umgewandelt.
In einer objektorientierten Programmiersprache würde ein Parser einen _String_ erhalten und ein Objekt liefern, das eine strukturierte Beschreibung des _Strings_ zur Verfügung stellt.

Um in einer Elm-Anwendung einen `Decoder` zu nutzen, müssen wir zuerst den folgenden Befehl ausführen.

```console
elm install elm/json
```

Die Bibliothek `elm/json` ist eine **eingebettete domänenspezifische Sprache** und stellt eine **deklarative Technik** dar, um `Decoder` zur Verarbeitung von JSON zu beschreiben.

Der Typkonstruktor `Decoder` ist im Modul `Json.Decode`[^1] definiert.
Das Modul stellt eine Funktion

```elm
decodeString : Decoder a -> String -> Result Error a
```

zur Verfügung.
Mithilfe dieser Funktion kann ein `Decoder` auf eine Zeichenkette angewendet werden.
Ein `Decoder a` liefert nach dem Parsen einen Wert vom Typ `a` als Ergebnis.
Wenn wir einen `Decoder a` mit `decodeString` auf eine Zeichenkette anwenden, erhalten wir entweder einen Fehler und eine Fehlermeldung mit einer Fehlerbeschreibung oder wir erhalten einen Wert vom Typ `a`.
Daher ist der Ergebnistyp der Funktion `decodeString` entsprechend `Result Error a`.

Das Modul `Json.Decode` stellt die folgenden primitiven `Decoder` zur Verfügung.

``` elm
string : Decoder String
int : Decoder Int
float : Decoder Float
bool : Decoder Bool
```

Um zu illustrieren, wie diese `Decoder` funktionieren, schauen wir uns die folgenden Beispiele an.
Der Aufruf

```elm
Decode.decodeString Decode.int "42"
```

liefert als Ergebnis `Ok 42`.
Das heißt, der `String` `"42"` wird erfolgreich mit dem `Decoder` `int` verarbeitet und liefert als Ergebnis den Wert `42`. Der Aufruf

```elm
Decode.decodeString Decode.int "a"
```

liefert dagegen als Ergebnis

```elm
Err (Failure ("This is not valid JSON! Unexpected token a in JSON at position 0"))
```

da der `String` `"a"` nicht der Spezifikation des Formates entspricht, da es sich nicht um einen `Int` handelt.

Die Idee der Funktion `map`, die wir für Listen kennengelernt haben, lässt sich auch auf andere Datenstrukturen anwenden. Genauer gesagt, kann man `map` für die meisten Typkonstruktoren definieren.
Da `Decoder` ein Typkonstruktor ist, können wir `map` für `Decoder` definieren.

Elm stellt die folgende Funktion für `Decoder` zur Verfügung.

```elm
map : (a -> b) -> Decoder a -> Decoder b
```

Diese Funktion kann zum Beispiel genutzt werden, um das Ergebnis eines `Decoder` in einen Konstruktor einzupacken.
Wir nehmen einmal an, dass wir den folgenden – zugegebenermaßen etwas artifiziellen – Datentyp in unserer Anwendung nutzen.

``` elm
type alias User =
    { age : Int }
```

Wir können nun auf die folgende Weise einen `Decoder` definieren, der eine Zahl parst und als Ergebnis einen Wert vom Typ `User` zurückliefert.

``` elm
decodeUser : Decoder User
decodeUser =
    Decode.map User Decode.int
```

Wir sind nun nur in der Lage einen JSON-Wert, der nur aus einer Zahl besteht, in einen Elm-Datentyp umzuwandeln.
In den meisten Fällen wird das Alter des Nutzers auf JSON-Ebene nicht als einzelne Zahl dargestellt, sondern zum Beispiel durch folgendes JSON-Objekt.

```json
{
  "age": 18
}
```

Auf diese Struktur können wir unseren `Decoder` nicht anwenden, da der `Decoder` `int` nur Zahlen parsen kann.
Um dieses Problem zu lösen, nutzt man in Elm die folgende Funktion.

```elm
field : String -> Decoder a -> Decoder a
```

Mit dieser Funktion kann ein `Decoder` auf ein einzelnes Feld einer JSON-Struktur angewendet werden.
Das heißt, der folgende `Decoder` ist in der Lage die oben gezeigte JSON-Struktur zu verarbeiten.

``` elm
decodeUser : Decoder User
decodeUser =
    Decode.map User (Decode.field "age" Decode.int)
```

Der Aufruf

```elm
Decode.decodeString decodeUser "{ \"age\": 18 }"
```

liefert in diesem Fall als Ergebnis `Ok { age = 18 }`.
Das heißt, dieser Aufruf ist in der Lage, den `String`, der ein JSON-Objekt darstellt, in einen Elm-Record zu überführen.
Ein Parser verarbeitet einen `String` häufig so, dass Leerzeichen für das Ergebnis keine Rolle spielen.
So liefert der Aufruf

```elm
Decode.decodeString decodeUser "{\t   \"age\":\n     18}"
```

etwa das gleiche Ergebnis wie der Aufruf ohne die zusätzlichen Leerzeichen.

In den meisten Fällen hat die JSON-Struktur, die wir verarbeiten wollen, nicht nur ein Feld, sondern mehrere.
Für diesen Zweck stellt Elm die Funktion

```elm
map2 : (a -> b -> c) -> Decoder a -> Decoder b -> Decoder c
```

zur Verfügung, mit der wir zwei `Decoder` zu einem kombinieren können.

Wir erweitern unseren Datentyp wie folgt.

``` elm
type alias User =
    { name : String
    , age : Int
    }
```

Nun definieren wir einen `Decoder` mithilfe von `map2` und kombinieren dabei einen `Decoder` für den `Int` mit einem `Decoder` für den `String`.

``` elm
decodeUser : Decoder User
decodeUser =
    Decode.map2
        User
        (Decode.field "name" Decode.string)
        (Decode.field "age" Decode.int)
```

Der Aufruf

```elm
decodeString decodeUser "{ \"name\": \"Max Mustermann\", \"age\": 18}"
```

liefert in diesem Fall das folgende Ergebnis.

```elm
Ok { age = 18, name = "Max Mustermann" }
```

Der `Decoder` `decodeUser` illustriert wieder gut die deklarative Vorgehensweise.
Zur Implementierung des `Decoder`s beschreiben wir, welche Felder wir aus den JSON-Daten verarbeiten wollen und wie wir aus den Ergebnissen der einzelnen Parser das Endergebnis konstruieren.
Wir beschreiben aber nicht, wie genau das Verarbeiten durchgeführt wird.

Bisher können wir nur recht einfach gehaltene Decoder definieren.
Im Folgenden wollen wir uns ein komplexeres Beispiel anschauen.
Für unser Beispiel gehen wir davon aus, dass die JSON-Struktur, die wir von einem Server erhalten, ein Feld mit der Version der Schnittstelle hat.
Abhängig von der Version wollen wir jetzt den einen oder anderen `Decoder` verwenden.

Zuerst betrachten wir zwei primitive `Decoder`, die für dich allein genommen, eher nutzlos erscheinen, um Zusammenspiel mit weiteren Funktionen aber sehr nützlich sind.
Die Funktion `succeed :: a -> Decoder a` liefert einen `Decoder`, der immer erfolgreich ist.
Das heißt, der folgende Aufruf

```elm
decodeString (Decode.succeed 23) "{ \"name\": \"Max Mustermann\", \"age\": 18}"
```

liefert immer als Ergebnis `23`.
Die Funktion `fail :: String -> Decoder a` liefert dagegen einen `Decoder`, der immer fehlschlägt.
Das heißt, der folgende Aufruf

```elm
decodeString (Decode.fail "Error message") "{ \"name\": \"Max Mustermann\", \"age\": 18}"
```

liefert dagegen als Ergebnis

```elm
Err (Failure ("Error message"))
```

Diese beiden primitiven `Decoder` sind für sich allein genommen nicht sehr nützlich.
Sie werden aber sehr mächtig, wenn man sie mit einer Form von Fallunterscheidung kombiniert.
In diesem Fall können wir nämlich dafür sorgen, dass der `Decoder` entweder erfolgreich ist, indem wir `succeed` verwenden und das Ergebnis liefern oder mit einer Fehlermeldung fehlschlägt.

Wir definieren dazu erst einmal einen `Decoder`, der die Version liefert.

``` elm
versionDecoder : Decoder Int
versionDecoder =
    Decode.field "version" Decode.int
```

Außerdem haben wir die folgenden beiden `Decoder` für die beiden Varianten der JSON-Struktur.
Das heißt, in einer Version hieß das Feld `bool` und in einer anderen Version hieß es `boolean`.

``` elm
boolDecoder : Decoder Bool
boolDecoder =
    Decode.field "bool" Decode.bool

booleanDecoder : Decoder Bool
booleanDecoder =
    Decode.field "boolean" Decode.bool
```

Wir möchten jetzt gern einen `Decoder` definieren, der abhängig von der Version entweder `boolDecoder` oder `booleanDecoder` verwendet.
Diese Art von `Decoder` können wir mithilfe von `map` und `map2` aber nicht definieren.
Das Problem besteht darin, dass wir abhängig von einem Wert des Felder `version` den `Decoder` bestimmen möchten, mit dem wir die restlichen Felder verarbeiten.
Die Funktionen `map` und `map2` haben aber die Typen `(a -> b) -> Decoder a -> Decoder b` und `(a -> b -> c) -> Decoder a -> Decoder b -> Decoder c`.
Das heißt, die Funktion, die wir an `map` und `map2` übergeben, können sich als Ergebnis nicht für einen `Decoder` entscheiden. 

Wir können die gewünschte Funktionalität aber mit der folgenden Funktion implementieren.

``` elm
andThen : (a -> Decoder b) -> Decoder a -> Decoder b
```

Hier haben wir statt eines Arguments `a -> b` oder `a -> b -> c` jetzt ein Argument vom Typ `a -> Decoder b`.
Das heißt, wir können abhängig vom konkreten Wert, der vom Typ `a` übergeben wird, den `Decoder` wählen, den wir anschließend verwenden.
Wir können damit den folgenden `Decoder` definieren.

``` elm
decoder : Decoder Bool
decoder =
    let
        chooseVersion version =
            case version of
                1 ->
                    boolDecoder

                2 ->
                    booleanDecoder

                _ ->
                    Decode.fail
                        ("Version "
                            ++ String.fromInt version
                            ++ " not supported"
                        )
    in
    Decode.andThen chooseVersion versionDecoder
```

Die Funktion `Decode.fail` liefert einen `Decoder`, der immer fehlschlägt.
Das heißt, wenn wir eine Version parsen und es sich weder um Version `1` noch um Version `2` handelt, liefert `decoder` einen Fehler.
Dieses Beispiel illustriert, dass wir mithilfe von `andThen` abhängig von einem Wert, den wir zuvor geparset haben, verschiedene `Decoder` ausführen können.





<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="higher-order.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="subscriptions.html">weiter</a></li>
    </ul>
</div>
