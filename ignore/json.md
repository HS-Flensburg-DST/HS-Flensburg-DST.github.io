---
layout: post
title: "JSON-Daten"
---

Die Kommunikation mit einem Server läuft über ein Austauschformat, zumeist JSON oder XML.
In diesem Kapitel beschäftigen wir uns damit, wie wir Daten im JSON-Format mit einem Server austauschen.
Der Abschnitt [Decoder](#decoder) beschreibt, wie wir Daten, die wir im JSON-Format erhalten, in Elm-Datentypen umwandeln können.
Der Abschnitt [Encode](#encode) beschreibt, wie wir Daten aus unserer Anwendung in das JSON-Format umwandeln.


## Decoder

Wenn wir HTTP-Anfragen durchführen, erhalten wir vom Server häufig eine Antwort in Form von JSON.
Diese Antwort erhalten wir aber in Form eines _Strings_.
Das heißt, um die Informationen, die wir benötigen zu extrahieren, müssen wir den _String_ verarbeiten.
Wir wollen in unserer Anwendung aber nicht mit dem _String_ hantieren, den wir vom Server erhalten haben, sondern mit einem strukturierten Elm-Datentyp arbeiten.
Um diese Aufgabe umzusetzen, werden in Elm `Decoder` verwendet.

![You shall not parse, syntax error on line 1](/assets/images/parse-error.png){: width="400px" .centered}

Ein `Decoder` ist eine elm-spezifische Variante des allgemeineren Konzeptes eines **Parser-Kombinators**.
Parser-Kombinatoren sind eine leichtgewichtige Implementierung eines Parsers.

{% include callout-important.html content="
Ein **Parser** ist ein Programm, das einen _String_ erhält und prüft, ob der _String_ einem vorgegebenen Format folgt.
Der Parser liefert ein strukturiertes Format, das die Inhalte des _Strings_ darstellt.
" %}

Jeder Compiler nutzt zum Beispiel einen Parser, um Programmtext auf syntaktische Korrektheit zu prüfen.
Im Fall von Elm, wird der _String_ zum Beispiel in Werte von algebraischen Datentypen umgewandelt.
In einer objektorientierten Programmiersprache würde ein Parser einen _String_ erhalten und ein Objekt liefern, das eine strukturierte Beschreibung des _Strings_ zur Verfügung stellt.
Funktionen wie `String.toInt : String -> Maybe Int` sind eine sehr einfache Form eines Parsers.
Diese Funktion erhält einen _String_ als Eingabe.
Die Funktion überprüft, ob es sich bei dem _String_ um eine Zahl handelt, also ob der _String_ sich an das Format "ist eine Zahl" hält.
Da ein Parser überprüft, ob die Eingabe sich an das Format hält, liefert ein Parser potentiell einen Fehler zurück.
Daher liefert die Funktion `String.toInt` als Result einen Wert vom Typ `Maybe`, um auszudrücken, falls die Eingabe sich nicht an das Format hält.
Falls das Parsen erfolgreich ist, liefert ein Parser eine strukturierte Darstellung der Eingabe.
Im Fall von `String.toInt` liefert die Funktion im Erfolgsfall einen Wert vom Typ `Int` zurück.
Dies ist die strukturierte Darstellung des entsprechenden _Strings_.

Um in einer Elm-Anwendung einen `Decoder` zu nutzen, müssen wir zuerst den folgenden Befehl ausführen.

```console
elm install elm/json
```

Die Bibliothek `elm/json` ist eine **eingebettete domänenspezifische Sprache** und stellt eine **deklarative Technik** dar, um `Decoder` zur Verarbeitung von JSON zu beschreiben.
`Decoder` sind eine Form von Parser-Kombinatoren.
Bei Parser-Kombinatoren kombiniert man einfache Parser miteinander, um einen komplexeren Parser zu definieren.
Wir schauen uns als nächstes an, wie dieses Kombinieren im Fall des Typs `Decoder` in Elm funktioniert.

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
Decoder.decodeString Decoder.int "42"
```

liefert als Ergebnis `Ok 42`.
Das heißt, der `String` `"42"` wird erfolgreich mit dem `Decoder` `int` verarbeitet und liefert als Ergebnis den Wert `42`. Der Aufruf

```elm
Decoder.decodeString Decoder.int "a"
```

liefert dagegen das folgende Ergebnis.

```elm
Err (Failure ("This is not valid JSON! Unexpected token a in JSON at position 0"))
```

Der `String` `"a"` entspricht in diesem Fall nicht dem Format, da es sich nicht um einen `Int` handelt.
Daher liefert der Parser einen Fehler.

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
userDecoder : Decoder User
userDecoder =
    Decoder.map User Decoder.int
```

Wir sind nun nur in der Lage einen JSON-Wert, der nur aus einer Zahl besteht, in einen Elm-Datentyp umzuwandeln.
In den meisten Fällen wird das Alter des Nutzers auf JSON-Ebene nicht als einzelne Zahl dargestellt, sondern zum Beispiel durch folgendes JSON-Objekt.

```json
{
  "age": 18
}
```

Auf diese Struktur können wir `userDecoder` nicht anwenden, da `Decoder.int` nur Zahlen parsen kann.
Um dieses Problem zu lösen, nutzt man in Elm die folgende Funktion.

```elm
field : String -> Decoder a -> Decoder a
```

Mit dieser Funktion kann ein `Decoder` auf ein einzelnes Feld einer JSON-Struktur angewendet werden.
Das heißt, der folgende `Decoder` ist in der Lage die oben gezeigte JSON-Struktur zu verarbeiten.

``` elm
userDecoder : Decoder User
userDecoder =
    Decoder.map User (Decoder.field "age" Decoder.int)
```

Der Aufruf

```elm
Decoder.decodeString userDecoder "{ \"age\": 18 }"
```

liefert in diesem Fall als Ergebnis `Ok { age = 18 }`.
Das heißt, dieser Aufruf ist in der Lage, den `String`, der ein JSON-Objekt darstellt, in einen Elm-Record zu überführen.
Ein Parser verarbeitet einen `String` häufig so, dass Leerzeichen für das Ergebnis keine Rolle spielen.
So liefert der Aufruf

```elm
Decoder.decodeString userDecoder "{\t   \"age\":\n     18}"
```

etwa das gleiche Ergebnis wie der Aufruf ohne die zusätzlichen Leerzeichen.

In den meisten Fällen hat die JSON-Struktur, die wir verarbeiten wollen, nicht nur ein Feld, sondern mehrere.
Für diesen Zweck stellt Elm die Funktion

```elm
map2 : (a -> b -> c) -> Decoder a -> Decoder b -> Decoder c
```

zur Verfügung, mit der wir zwei `Decoder` zu einem komplexeren `Decoder` kombinieren können.

Um die Verwendung von `Decoder.map2` zu illustrieren, erweitern wir unseren Datentyp `User` wie folgt.

``` elm
type alias User =
    { name : String
    , age : Int
    }
```

Nun definieren wir einen `Decoder` mithilfe von `map2` und kombinieren dabei einen `Decoder` für den `Int` mit einem `Decoder` für den `String`.

``` elm
userDecoder : Decoder User
userDecoder =
    Decoder.map2
        User
        (Decoder.field "name" Decoder.string)
        (Decoder.field "age" Decoder.int)
```

Der Aufruf

```elm
decodeString userDecoder "{ \"name\": \"Max Mustermann\", \"age\": 18}"
```

liefert in diesem Fall das folgende Ergebnis.

```elm
Ok { age = 18, name = "Max Mustermann" }
```

Der `Decoder` `userDecoder` illustriert wieder gut die deklarative Vorgehensweise.
Zur Implementierung des `Decoder`s beschreiben wir, welche Felder wir aus den JSON-Daten verarbeiten wollen und wie wir aus den Ergebnissen der einzelnen Parser das Endergebnis konstruieren.
Wir beschreiben aber nicht, wie genau das Verarbeiten durchgeführt wird.

Bisher können wir nur recht einfach gehaltene Decoder definieren.
Im Folgenden wollen wir uns ein komplexeres Beispiel anschauen.
Für unser Beispiel gehen wir davon aus, dass die JSON-Struktur, die wir von einem Server erhalten, ein Feld mit der Version der Schnittstelle hat.
Abhängig von der Version wollen wir jetzt den einen oder anderen `Decoder` verwenden.

Zuerst betrachten wir zwei primitive `Decoder`, die für sich allein genommen, eher nutzlos erscheinen, im Zusammenspiel mit weiteren Funktionen aber sehr nützlich sind.
Die Funktion `succeed :: a -> Decoder a` liefert einen `Decoder`, der immer erfolgreich ist.
Das heißt, der folgende Aufruf

```elm
decodeString (Decoder.succeed 23) "{ \"name\": \"Max Mustermann\", \"age\": 18}"
```

liefert immer als Ergebnis `23`.
Die Funktion `fail :: String -> Decoder a` liefert dagegen einen `Decoder`, der immer fehlschlägt.
Das heißt, der folgende Aufruf

```elm
decodeString (Decoder.fail "Error message") "{ \"name\": \"Max Mustermann\", \"age\": 18}"
```

liefert das folgende Ergebnis.

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
    Decoder.field "version" Decoder.int
```

Außerdem haben wir die folgenden beiden `Decoder` für die beiden Varianten der JSON-Struktur.
Das heißt, in einer Version hieß das Feld `bool` und in einer anderen Version hieß es `boolean`.

``` elm
boolDecoder : Decoder Bool
boolDecoder =
    Decoder.field "bool" Decoder.bool

booleanDecoder : Decoder Bool
booleanDecoder =
    Decoder.field "boolean" Decoder.bool
```

Wir möchten jetzt gern einen `Decoder` definieren, der abhängig von der Version entweder `boolDecoder` oder `booleanDecoder` verwendet.
Diese Art von `Decoder` können wir mithilfe von `map` und `map2` aber nicht definieren.
Das Problem besteht darin, dass wir abhängig vom Wert, der im Feld `version` steht, den `Decoder` bestimmen möchten, mit dem wir die restlichen Felder verarbeiten.
Die Funktionen `map` und `map2` haben aber die Typen `(a -> b) -> Decoder a -> Decoder b` und `(a -> b -> c) -> Decoder a -> Decoder b -> Decoder c`.
Das heißt, die Funktion, die wir an `map` und `map2` übergeben, können sich als Ergebnis nicht für einen `Decoder` entscheiden.
Beide Funktionen können nur auf dem Ergebnistyp des `Decoder` arbeiten.

Wir können die gewünschte Funktionalität aber mit der folgenden Funktion implementieren.

``` elm
andThen : (a -> Decoder b) -> Decoder a -> Decoder b
```

Hier haben wir statt eines Arguments `a -> b` oder `a -> b -> c` jetzt ein Argument vom Typ `a -> Decoder b`.
Das heißt, wir können abhängig vom konkreten Wert, der vom Typ `a` übergeben wird, den `Decoder` wählen, den wir anschließend verwenden.
Wir können damit den folgenden `Decoder` definieren.

``` elm
versionedDecoder : Decoder Bool
versionedDecoder =
    let
        chooseVersion version =
            case version of
                1 ->
                    boolDecoder

                2 ->
                    booleanDecoder

                _ ->
                    Decoder.fail
                        ("Version "
                            ++ String.fromInt version
                            ++ " is not supported."
                        )
    in
    Decoder.andThen chooseVersion versionDecoder
```

Die Funktion `Decoder.fail` liefert einen `Decoder`, der immer fehlschlägt.
Das heißt, wenn wir eine Version parsen und es sich weder um Version `1` noch um Version `2` handelt, liefert `versionedDecoder` einen Fehler.
Dieses Beispiel illustriert, dass wir mithilfe von `andThen` abhängig von einem Wert, den wir zuvor geparst haben, verschiedene `Decoder` ausführen können.

Es stellt sich die Frage, warum die Funktion `Decoder.andThen` als erstes Argument die Funktion erhält.
Bei einem Aufruf wie `Decoder.andThen chooseVersion versionDecoder` ist die Reihenfolge der Argumente unglücklich, da wir zuerst den `Decoder` `versionDecoder` durchführen und anschließend die Funktion `chooseVersion`.
Es stellt sich also die Frage, warum die Funktion `Decoder.andThen` ihre Argumente in dieser Reihenfolge erhält.
Der Grund besteht darin, dass man die Funktion `Decoder.andThen` infix verwendet, wie es im Kapitel [Piping](higher-order.md#piping) erläutert wurde.
Das heißt, wir nutzen die Schreibweise `|> Decoder.andThen`, um die Funktion infix zu verwenden.

Um den Operator `|>` anzuwenden, benötigen wir eine einstellige Funktion.
Die Funktion `Decoder.andThen` ist aber zweistellig.
Daher wird die Funktion `Decoder.andThen` zuerst partiell auf das Argument `chooseVersion` appliziert.
Wir erhalten somit, `Decoder.andThen chooseVersion`, also eine einstellige Version.
Diese Funktion können wir mithilfe von `|>` auf ihr Argument anwenden.
Aus didaktischen Gründen haben wir die Definitionen `boolDecoder`, `booleanDecoder` und `versionDecoder` eingeführt, bevor wir die Definition von `versionedDecoder` angegeben haben.
In einer realen Implementierung würde man für diese `Decoder` keine eigenständigen _Top Level_-Definitionen angeben und den `Decoder` eher wie folgt definieren.

``` elm
versionedDecoder : Decoder Bool
versionedDecoder =
    let
        chooseVersion version =
            case version of
                1 ->
                    Decoder.field "bool" Decoder.bool

                2 ->
                    Decoder.field "boolean" Decoder.bool

                _ ->
                    Decoder.fail
                        ("Version "
                            ++ String.fromInt version
                            ++ " is not supported."
                        )
    in
    Decoder.field "version" Decoder.int
        |> Decoder.andThen chooseVersion
```

Wir können mithilfe von `Decoder.andThen` aber nicht nur auf unterschiedliche Felder der JSON-Struktur zugreifen, wir können die Felder auch ganz unterschiedlich behandeln.
Wir nehmen einmal an, dass in Version `1` unserer JSON-Struktur der boolesche Wert durch einen `Int` kodiert wurde.
Um diesen `Int` zu verarbeiten definieren wir zuerst den folgenden `Decoder`, der den `Int` in einen `Bool` umwandelt.

``` elm
intAsBoolDecoder : Decoder Bool
intAsBoolDecoder =
    let
        boolDecoder int =
            case int of
                0 ->
                    Decoder.succeed False

                1 ->
                    Decoder.succeed True

                _ ->
                    Decoder.fail 
                        ("The value "
                            ++ String.fromInt int
                            ++ " should be 0 or 1.")
    in
    Decoder.int
        |> Decoder.andThen boolDecoder
```

Auf Grundlage dieses `Decoder`s können wir nun den folgenden `Decoder` definieren, der in Version `1` der Schnittstelle den `Int` einen `Bool` umwandelt.

```elm
versionedDecoder : Decoder Bool
versionedDecoder =
    let
        chooseVersion version =
            case version of
                1 ->
                    Decoder.field "bool" intAsBoolDecoder

                2 ->
                    Decoder.field "boolean" Decoder.bool

                _ ->
                    Decoder.fail
                        ("Version "
                            ++ String.fromInt version
                            ++ " is not supported."
                        )
    in
    Decoder.field "version" Decoder.int
        |> Decoder.andThen chooseVersion
```

Um noch einmal zu illustrieren, dass die Funktion `Decoder.andThen` mächtiger ist als die Funktion `Decoder.map` wollen wir versuchen, die Funktionsweise von `intAsBoolDecoder` mithilfe von `Decoder.map` zu implementieren.

``` elm
badIntAsBoolDecoder : Decoder Bool
badIntAsBoolDecoder =
    let
        boolFromInt int =
            case int of
                0 ->
                    False

                1 ->
                    True

                _ ->
                    False

    in
    Decoder.map boolFromInt Decoder.int
```

Aufgrund des Typs von `Decoder.map` bleibt uns nichts anderes übrig als für Zahlen, die nicht `0` oder `1` sind, einen _Default_-Wert zu nutzen.
Damit verschleiern wir aber einen Fehlerfall.

{% include callout-important.html content="
Das Verschleiern von Fehlerfällen ist eine ganz schlechte Idee, da es damit später sehr schwierig ist, den Fehler in der Anwendung zu finden.
" %}

Um die Funktion `Decoder.andThen` noch etwas zu illustrieren, wollen wir den `Decoder` `userDecoder`, den wir zuvor bereits definiert haben, noch einmal mithilfe von `Decoder.andThen` definieren.

```elm
user : Decoder User
user =
    Decoder.field "id" Decoder.int
        |> Decoder.andThen
            (\id ->
                Decoder.field "name" Decoder.string
                    |> Decoder.andThen
                        (\name ->
                            Decoder.succeed
                                { id = id
                                , name = name
                                }
                        )
            )
```

Aufgrund der Schachtelung ist dieser Code vergleichsweise schwierig zu lesen.
Daher sollte man für diesen Anwendungsfall die Funktion `map2` verwenden.
Dieses Beispiel illustriert aber, dass wir die Funktion vom Typ `a -> Decoder b` definieren können, indem wir wiederum `andThen` verwenden.
Auf diese Weise, können wir die Entscheidung, die in der Funktion vom Typ `a -> Decoder b` getroffen wird, von mehreren Werten abhängig machen.
Wir könnten in der Definition von `user` zum Beispiel abhängig von den Werten von `id` **und** `name` den Decoder erfolgreich ein Ergebnis liefern oder scheitern lassen.

{% include callout-info.html content="
Die Funktion `andThen` ist die Elm-Variante des _Bind_-Operators `>>=` in Haskell.
" %}

{% include callout-info.html content="
Die Programmiersprache Haskell stellt die `do`-Notation zur Verfügung, um Funktionen übersichtlicher zu gestalten, wenn sie mehrere Aufrufe einer Funktion wie `andThen` enthalten.
" %}

Die Funktion `andThen` bzw. `>>=` ist Teil des allgemeineren Konzeptes einer Monade.
Man kann eine Funktion wie `andThen` bzw. `>>=` für viele Strukturen definieren, nicht nur für Parser bzw. `Decoder`.
Auch wenn das Konzept einer Monade in anderen Programmiersprachen nicht explizit genutzt wird, taucht diese Struktur bei der Programmierung häufig auf.
Die JavaScript-Funktion `then` für `Promise` ist etwa ein Beispiel hierfür.
Diese Funktion erhält nämlich einen `Promise a` und eine Funktion `a -> Promise b`, ist also sehr ähnlich zur Funktion `Decoder.andThen`, nur dass sie für den Datentyp `Promise` genutzt wird und nicht für den Datentyp `Decoder`.


## Encode

Wenn wir mit einem Server kommunizieren, müssen wir nicht nur in der Lage sein, die JSON-Daten, die wir vom Server erhalten, in Elm-Datentypen umzuwandeln.
Wir müssen auch in der Lage sein, JSON-Daten, zu erzeugen, die wir an den Server schicken können.
Für diesen Zweck wird in Elm das Modul `Json.Encode`[^2] aus der Bibliothek `elm/json` verwendet.

Der Typ `Value` repräsentiert JSON-Daten.
Dieser Datentyp stellt keine Konstruktoren zur Verfügung.
Stattdessen stellt das Modul `Json.Encode` eine Reihe von Funktionen zur Verfügung, mit denen wir die verschiedenen Formen von JSON-Daten erzeugen können.
Das Modul stellt außerdem eine Funktion `encode : Int -> Value -> String` zur Verfügung, mit der wir aus einem `Value` einen `String` erzeugen können.
Der `Int` gibt dabei die Einrückungstiefe an, die bei der Formatierung des JSON-Strings verwendet wird.

Zuerst wollen wir einen Wert vom Typ `User`, den wir im Abschnitt [Decoder](#decoder) definiert haben, in einen JSON-Wert umwandeln.
Wir wollen einen `User` als JSON-Objekt mit zwei Feldern darstellen.
Daher verwenden wir die Funktion `object : List ( String, Value ) -> Value`.
Die erste Komponente der Paare in der Liste gibt dabei die Namen der Felder an.
Die zweite Komponente der Paare ist ein JSON-Wert.
Neben der Funktion `object` stellt das Modul `Json.Encode` zum Beispiel die Funktion `string : String -> Value` zur Verfügung, um aus einem `String` auf Elm-Ebene einen entsprechenden JSON-Wert zu machen.

Der folgende Aufruf

```elm
Encode.encode 4 (Encode.string "test")
```

liefert zum Beispiel `"\"test\"` als Ergebnis.
Das heißt, wir erhalten einen `String`, der Anführungszeichen und den Text `test` enthält.
Bei dem Ergebnis handelt es sich um einen validen JSON-Wert.

Der `User` enthält neben dem Namen vom Typ `String` noch ein Alter vom Typ `Int`.
Um dieses zu encodieren, mutzen wir die Funktion `Encode.int : Int -> Value`.
Der folgende Aufruf

```elm
Encode.encode 4 (Encode.int 23)
```

liefert zum Beispiel `"23"` als Ergebnis.
Das heißt, wir erhalten einen `String`, der den Text `23` enthält.
Dabei handelt es sich wieder um einen validen JSON-Wert, da eine einzelne Zahl ein valider JSON-Wert ist.

Um einen Wert vom Typ `User` in ein JSON-Objekt umzuwandeln, nutzen wir die folgende Definition.
Wir gehen davon aus, dass die folgende Definition in einem Modul `User` definiert wird, daher können wir den Namen `encode` wählen.

```elm
encode : User -> Encode.Value
encode { name, age } =
    Encode.object
        [ ( "name", Encode.string name )
        , ( "age", Encode.int age )
        ]
```

[^1]: Dieses Modul wird hier mittels `import Json.Decode as Decoder exposing (Decoder)` importiert.
      Wir benennen das Modul in `Decoder` um, da der Name `Decode` unglücklich gewählt ist, da das Modul den Typ `Decoder` exportiert.

[^2]: Dieses Modul wird hier mittels `import Json.Encode as Encode` importiert.
      Im Gegensatz zum Modul `Json.Decode` stellt das Modul `Json.Encode` eben **keinen** `Encoder` zur Verfügung, sondern Funktionen.
      Diese Funktionen laufen unter dem Oberbegriff `Encode`.

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="higher-order.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <!-- <li class="nav-item nav-right"><a href="subscriptions.html">weiter</a></li> -->
        <li class="nav-item nav-right"></li>
    </ul>
</div>
