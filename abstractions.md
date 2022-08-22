---
layout: post
title: "Abstraktionen"
---

Wir haben in verschiedenen Kontexten immer wieder die gleichen
Funktionen kennengelernt. In diesem Kapitel wollen wir uns ein wenig den
Hintergrund hinter diesen Funktionen anschauen. Die Konzepte, die wir in
diesem Kapitel lernen, sind vergleichbar mit *Pattern* in
objektorientierten Sprachen. Das heißt, man identifiziert Funktionen,
die man für verschiedene Datenstrukturen definieren kann und beschreibt,
welche Eigenschaften diese Funktionen haben sollten.

![You say "pattern" and nobody panics, you say "monad" and everybody is losing their mind](./assets/images/monads-and-patterns.jpg){:style="display:block; margin-left:auto; margin-right:auto"}


Funktoren
---------

Wir haben die Funktion `map` kennengelernt, die auf vielen verschiedenen
Datentypen definiert werden konnte. Wir haben zum Beispiel die folgenden
Funktionen kennengelernt.

``` elm
map : (a -> b) -> List      a -> List      b
map : (a -> b) -> Decoder   a -> Decoder   b
map : (a -> b) -> Generator a -> Generator b
```

Diese Signaturen unterschieden sich nur in dem Typkonstruktor, für den
sie definiert sind. Das heißt, es gibt eine Definition von `map` für den
Typkonstruktor `List`, eine Definition für den Typkonstruktor `Decoder`
und eine Definition für den Typkonstruktor `Generator`. Das heißt, die
Funktion `map` hat immer die Form

`map : (a -> b) -> f a -> f b`,

wobei `f` ein Typkonstruktor ist. Man bezeichnet einen Typkonstruktor
`f`, für den es eine Funktion `map` gibt, als Funktor. Es gibt noch
viele weitere Typkonstruktoren, für die wir eine Funktion `map`
definieren können. Neben den Implementierungen von `map`, die wir
kennengelernt haben, gibt es zum Beispiel noch die folgenden Funktionen.

``` elm
map : (a -> b) -> Cmd  a -> Cmd  b
map : (a -> b) -> Sub  a -> Sub  b
map : (a -> b) -> Html a -> Html b
```

Zur Illustration wollen wir eine weitere Variante der Funktion `map`
definieren, diesesmal für den Typkonstruktor `Maybe`.

``` elm
map : (a -> b) -> Maybe a -> Maybe b
map func maybev =
    case maybev of
        Nothing ->
            Nothing

        Just v ->
            Just (func v)
```

Leider können wir auch eine Funktion vom Typ
`(a -> b) -> Maybe a -> Maybe b` definieren, die keine “sinnvolle”
Implementierung darstellt.

``` elm
mapWeird : (a -> b) -> Maybe a -> Maybe b
mapWeird _ _ =
    Nothing
```

Um solche Implementierungen zu vermeiden, sollte die Implementierung der
Funktion `map` für jeden Typkonstruktor bestimmte Gesetze erfüllen. Das
heißt, die Funktion muss den angegebenen Typ haben und sich auf gewisse
Weise verhalten. Die Funktion `map` muss für alle möglichen Werte für
`fx`, `f` und `g` die folgenden beiden Gesetze erfüllen.

| `map (\x -\> x) fx       = fx`               |
| `map (\x -\> f (g x)) fx = map f (map g fx)` |

Die Funktion `mapWeird` erfüllt zum Beispiel das erste Gesetz nicht, da
für `fx = Just 42` die erste Gleichung nicht erfüllt ist.

``` elm
mapWeird (\x -> x) fx
=
mapWeird (\x -> x) (Just 42)
=
Nothing
/=
Just 42
=
fx
```

Applikative Funktoren
---------------------

Wir haben die folgende Funktion kennengelernt, um aus “einfachen”
Decodern einen komplexeren zusammenzubauen.

``` elm
apply : Decoder a -> Decoder (a -> b) -> Decoder b
apply =
    Decode.map2 (|>)
```

Auch die Funktion `apply` kann für verschiedene Typkonstruktoren
definiert werden. So können wir in Elm zum Beispiel die folgenden
Funktionen definieren.

``` elm
apply : List      a -> List      (a -> b) -> List      b
apply : Decoder   a -> Decoder   (a -> b) -> Decoder   b
apply : Generator a -> Generator (a -> b) -> Generator b
```

Damit ein Typkonstruktor `f` ein applikativer Funktor ist, muss es eine
Funktion

`apply : f a -> f (a -> b) -> f b`

geben . Damit `f` ein applikativer Funktor ist, muss es auch noch eine
Funktion `pure : a -> f a` geben. Es gibt eine solche Funktion für alle
drei Typkonstruktoren, sie heißt nur immer anders. Im Fall von `List`
heißt die Funktion `pure` zum Beispiel `singleton`, im Fall von
`Decoder` heißt sie `succeed`.

Zur Illustration wollen wir die Funktion `apply` für den Typkonstruktor
`Maybe` einmal definieren.

``` elm
apply : Maybe a -> Maybe (a -> b) -> Maybe b
apply maybev maybef =
    case maybev of
        Nothing ->
            Nothing

        Just v ->
            case maybef of
                Nothing ->
                    Nothing

                Just f ->
                    Just (f v)
```

Wir definieren außerdem die Funktion `pure : a -> f a` für `Maybe`.

``` elm
pure : a -> Maybe a
pure =
    Just
```

Im Gegensatz zu `map` können wir mit `apply` zwei Strukturen
kombinieren. Im Fall des Typkonstruktors `Decoder` haben wir zum
Beispiel gesehen, dass wir mithilfe der Funktion `apply` aus zwei
einfachen Decodern einen komplexeren Decoder bauen können. Im Fall von
`Maybe` können wir `apply` auch nutzen, um zwei Werte zu kombinieren.
Wir betrachten das folgende Beispiel. Wir wollen vom Benutzer zwei
Zahlen einlesen und diese addieren. Wir nutzen dazu die Funktion
`String.toInt : String -> Maybe Int`. Da das Parsen von beiden Eingaben
möglicherweise fehlschlagen kann, müssen wir zwei Werte vom Typ
`Maybe Int` kombinieren. Dazu können wir die Funktion `apply` nutzen.

``` elm
add : String -> String -> Maybe Int
add userInput1 userInput2 =
    pure (+)
        |> apply (String.toInt userInput1)
        |> apply (String.toInt userInput2)
```

Damit ein Typkonstruktor ein applikativer Funktor ist, müssen die
Funktionen `pure` und `apply` ebenfalls Gesetze erfüllen. Auf diese
Gesetze wollen wir hier aber nicht eingehen. Es sei an dieser Stelle
aber noch kurz erwähnt, dass jeder applikative Funktor auch ein Funktor
ist. Wir können die Funktion `map` nämlich mit Hilfe von `pure` und
`apply` definieren.

``` elm
map : (a -> b) -> Maybe a -> Maybe b
map func maybe =
    apply maybe (pure func)
```

Monaden
-------

In der funktionalen Programmierung gibt es eine ganze Reihe von
Abstraktionen wie Funktor und applikativer Funktor. Wir wollen uns an
dieser Stelle noch eine dieser Abstraktionen anschauen, die Monade heißt
und vergleichsweise legendär auch außerhalb der funktionalen
Programmierung ist.

![Monads, monad everywhere](./assets/images/monads-everywhere.png){:style="display:block; margin-left:auto; margin-right:auto"}

Es gibt einige Funktionen, die sich mit Hilfe eines applikativen
Funktors nicht ausdrücken lassen. Wir betrachten dazu das Beispiel

`apply : Decoder a -> Decoder (a -> b) -> Decoder b`.

Für unser Beispiel gehen wir davon aus, dass die JSON-Struktur, die wir
verarbeiten wollen ein Feld mit der Version der Schnittstelle hat.
Abhängig von der Version wollen wir jetzt den einen oder anderen
`Decoder` verwenden. Wir definieren dazu erst einmal einen `Decoder`,
der die Version liefert.

``` elm
version : Decoder Int
version =
    Decode.field "version" Decode.int
```

Außerdem haben wir die folgenden beiden `Decoder` bei denen sich der
Name des Feldes geändert hat.

``` elm
decoderVersion1 : Decoder Bool
decoderVersion1 =
    Decode.field "bool" Decode.bool

decoderVersion2 : Decoder Bool
decoderVersion2 =
    Decode.field "boolean" Decode.bool
```

Wir möchten jetzt gern einen `Decoder` definieren, der abhängig von der
Version entweder `decoderVersion1` oder `decoderVersion2` verwendet.
Diese Art von `Decoder` können wir mit Hilfe von `apply` aber nicht
definieren. Das Problem besteht darin, dass wir abhängig von einem Wert
den `Decoder` bestimmen möchten. Das Argument `Decoder (a -> b)` erlaubt
es aber nicht, den `Decoder` danach zu wählen, welchen Wert wir als `a`
übergeben bekommen.

Zu diesem Zweck können wir die folgende Funktion verwenden.

``` elm
andThen : (a -> Decoder b) -> Decoder a -> Decoder b
```

Hier haben wir statt eines Arguments `Decoder (a -> b)` jetzt ein
`a -> Decoder b`. Das heißt, wir können abhängig vom konkreten Wert, der
vom Typ `a` übergeben wird, den `Decoder` wählen, den wir anschließend
verwenden. Wir können damit den folgenden `Decoder` definieren. Wir
verwenden hier die Funktion `|>` um die Argumente von
`andThen\mintinline{elm}` zu tauschen, ähnlich wie wir es bei der
Verwendung von `apply` gemacht haben.

``` elm
decoder : Decoder Bool
decoder =
    let
        chooseVersion v =
            case version of
                1 ->
                    decoderVersion1

                2 ->
                    decoderVersion2

                _ ->
                    Decode.fail
                        ("Version "
                            ++ String.fromInt v
                            ++ " not supported"
                        )
    in
    version
        |> Decode.andThen chooseVersion
```

Wir wollen uns noch ein weiteres Beispiel für die Verwendung von
`andThen` anschauen. Dazu betrachten wir die Funktion
`andThen : Maybe a -> (a -> Maybe b) -> Maybe b`. Außerdem betrachten
wir die folgenden beiden Funktionen, die wir in
<a href="#chapter:polymorphism" data-reference-type="autoref"
data-reference="chapter:polymorphism">[chapter:polymorphism]</a>
definiert haben.

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

Wir können die Funktion `parseMonth` mithilfe von `andThen` wie folgt
definieren.

``` elm
parseMonth : String -> Maybe Int
parseMonth userInput =
    String.toInt userInput |> Maybe.andThen toValidMonth
```

Neben der Funktion `andThen` muss ein Typkonstruktor `f`, der eine
Monade ist, noch eine Funktion `return : a -> f a` zur Verfügung
stellen. Im Fall von `Decoder` ist `return` wie folgt definiert.

``` elm
return : a -> Decoder a
return =
    Decode.succceed
```

Wie beim Funktor und beim applikativen Funktor müssen die Funktionen
einer Monade auch Gesetze erfüllen.

| `andThen f (return x) = f x`                                    |
| `andThen return fx = fx`                                        |
| `andThen (\x -> andThen f (g x)) fx = andThen f (andThen g fx)` |

Wenn ein Typkonstruktor eine Monade ist, dann ist er auch ein
applikativer Funktor. Wir können nämlich wie folgt die Funktionen eines
applikativen Funktors definieren, indem wir die Funktionen der Monade
verwenden.

``` elm
pure : a -> Decoder a
pure =
    return


apply : Decoder a -> Decoder (a -> b) -> Decoder b
apply dx df =
    Decode.andThen (\x -> Decode.andThen (\f -> return (f x)) df) dx
```

Die [Typeclassopedia](https://wiki.haskell.org/Typeclassopedia) bietet
noch weitere Informationen zu Abstraktionen in der funktionalen
Programmierung.

<div style="display:table;width:100%;margin-bottom:15px">
    <ul style="display:table-row;list-style:none">
        <li style="display:table-cell;width:33%;text-align:left"><a href="commandos.html">zurück</a></li>
        <li style="display:table-cell;width:33%;text-align:center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li style="display:table-cell;width:33%;text-align:right"><a href="final-topics.html">weiter</a></li>
    </ul>
</div>