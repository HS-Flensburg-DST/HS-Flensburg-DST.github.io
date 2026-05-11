---
layout: post
title: "Abstraktionen"
---

Wir haben in verschiedenen Kontexten immer wieder die gleichen Funktionen kennengelernt.
In diesem Kapitel wollen wir uns ein wenig den Hintergrund hinter diesen Funktionen anschauen.
Die Konzepte, die wir in diesem Kapitel lernen, sind vergleichbar mit _Pattern_ in objektorientierten Sprachen.
Das heißt, man identifiziert Funktionen, die man für verschiedene Datenstrukturen definieren kann und beschreibt, welche Eigenschaften diese Funktionen haben sollten.

![You say "pattern" and nobody panics, you say "monad" and everybody is losing their mind](./assets/images/monads-and-patterns.jpg){: .centered}

## Funktoren

Wir haben die Funktion `map` kennengelernt, die auf vielen verschiedenen Datentypen definiert werden kann.
Wir haben zum Beispiel die folgenden Funktionen kennengelernt.

```elm
map : (a -> b) -> List    a -> List    b
map : (a -> b) -> Html    a -> Html    b
map : (a -> b) -> Decoder a -> Decoder b
```

Diese Signaturen unterschieden sich nur in dem Typkonstruktor, für den sie definiert sind.
Das heißt, es gibt eine Definition von `map` für den Typkonstruktor `List`, eine Definition für den Typkonstruktor `Html` und eine Definition für den Typkonstruktor `Decoder`.
Das heißt, die Funktion `map` hat immer die Form

```elm
map : (a -> b) -> f a -> f b
```

wobei `f` ein Typkonstruktor ist.

{% include callout-important.html content="
Man bezeichnet einen Typkonstruktor `f`, für den es eine Funktion `map` gibt, als **Funktor**.
" %}

Es gibt noch viele weitere Typkonstruktoren, für die wir eine Funktion `map` definieren können.
Neben den Implementierungen von `map`, die wir kennengelernt haben, gibt es in den Standardbibliotheken von Elm zum Beispiel noch die folgenden Funktionen.

```elm
map : (a -> b) -> Cmd      a -> Cmd      b
map : (a -> b) -> Sub      a -> Sub      b
map : (a -> b) -> Result x a -> Result x b
```

Zur Illustration wollen wir eine weitere Variante der Funktion `map` definieren, dieses Mal für den Typkonstruktor `Maybe`.

```elm
map : (a -> b) -> Maybe a -> Maybe b
map func maybeValue =
    case maybeValue of
        Nothing ->
            Nothing

        Just value ->
            Just (func value)
```

Die obige Implementierung der Funktion `map` für `Maybe` ist aber nicht die einzige mögliche Implementierung.
Wir können zum Beispiel die folgende Funktion vom Typ `(a -> b) -> Maybe a -> Maybe b` definieren, die keine "sinnvolle" Implementierung darstellt.

```elm
mapWeird : (a -> b) -> Maybe a -> Maybe b
mapWeird _ _ =
    Nothing
```

Um solche Implementierungen zu vermeiden, sollte die Implementierung der Funktion `map` für jeden Typkonstruktor bestimmte Gesetze erfüllen.
Das heißt, die Funktion muss den angegebenen Typ haben und sich auf gewisse Weise verhalten.
Die Funktion `map` sollte für alle möglichen Werte für `fx`, `f` und `g` die folgenden beiden Gesetze erfüllen.

| `map (\x -> x) fx` | = | `fx` |
| `map f (map g fx)` | = | `map (\x -> f (g x)) fx` |

Die Funktion `mapWeird` erfüllt zum Beispiel das erste Gesetz nicht, da für `fx = Just 42` die erste Gleichung nicht erfüllt ist, wie die folgenden Umformungen illustrieren.

{% include callout-important.html content="
Diese Form der Argumentation über das Verhalten von funktionalen Programmen bezeichnet man als **_equational reasoning_**.
" %}

In einer referenziell transparenten Programmiersprache kann man den Aufruf einer Funktion durch die Definition ersetzen.
Es handelt sich dabei um eine mathematische Gleichheit.
Bei Programmiersprachen mit Seiteneffekten ist eine solche gleichheitsbasierte Umformung nur möglich, wenn die Seiteneffekte ebenfalls berücksichtigt werden.
Dies ist zwar möglich, aber sehr aufwendig.

Die Gesetze für Abstraktionen wie Funktoren und Monaden sind Allaussagen.
Daher ist es vergleichsweise einfach zu zeigen, dass eine Implementierung ein Gesetz nicht erfüllt.
Wir müssen dazu lediglich ein Gegenbeispiel angeben.
Um zu zeigen, dass eine Funktion ein Gesetz erfüllt, müssen wir eine Allaussage beweisen.
Der Beweis einer Allaussage ist im Vergleich zur Widerlegung einer Allaussage vergleichsweise schwierig.
Bevor wir mit einem solchen Beweis starten, überprüfen wir, ob das Gegenbeispiel für `mapWeird` auch ein Gegenbeispiel für die Funktion `Maybe.map` ist.

{% include evaluation.html config=site.data.mapMaybeExample %}

Diese Umformung zeigt, dass `Just 42` kein Gegenbeispiel die Funktion `Maybe.map` ist.
Wir haben damit nicht gezeigt, dass die Funktion `Maybe.map` das Gesetz erfüllt.
Um zu zeigen, dass eine Implementierung ein Gesetz erfüllt, müssen wir einen Beweis führen.

Sei `t` ein Typ.
Sei `fx` vom Typ `Maybe t`.
Wir betrachten den Ausdruck `Maybe.map (\x -> x) fx`.
Wir führen eine Fallunterscheidung über `fx` durch.

<ol> 
<li><p>Wir betrachten den Fall <code class="language-plaintext highlighter-rouge">fx</code> = <code class="language-plaintext highlighter-rouge">Nothing</code></p>
{% include evaluation.html config=site.data.mapMaybeNothing %}
</li>
<li><p>Wir betrachten den Fall <code class="language-plaintext highlighter-rouge">fx</code> = <code class="language-plaintext highlighter-rouge">Just x</code></p>
{% include evaluation.html config=site.data.mapMaybeJust %}
</li>
</ol>

Das heißt, dass in allen Fällen `map (\x -> x) fx = fx` gilt.
Damit haben wir bewiesen, dass die Funktion `Maybe.map` das erste Funktorengesetz erfüllt.
Wir ignorieren an dieser Stelle, dass die Auswertung von `fx` einen Fehler liefern oder nicht terminieren könnte.
Wenn wir formal korrekt arbeiten möchten, müssten wir diesen Fall ebenfalls berücksichtigen.
Der Einfachheit halber ignorieren wir hier aber, dass die Auswertung eines Ausdrucks einen Fehler liefern oder nicht terminieren könnte.

Wir betrachten als nächstes das zweite Funktorengesetz.
Seien `t1`, `t2`, `t3` Typen.
Sei `f` vom Typ `t2 -> t3`.
Sei `g` vom Typ `t1 -> t2`
Sei `fx` vom Typ `Maybe t1`.
Wir betrachten den Ausdruck `Maybe.map f (Maybe.map g fx)`.
Wir führen eine Fallunterscheidung über `fx` durch.

<ol> 
<li><p>Wir betrachten den Fall <code class="language-plaintext highlighter-rouge">fx</code> = <code class="language-plaintext highlighter-rouge">Nothing</code></p>
{% include evaluation.html config=site.data.mapMaybeNothingLeft %}
<p>Für die andere Seite der Gleichung argumentieren wir wie folgt.</p>
{% include evaluation.html config=site.data.mapMaybeNothingRight %}
</li>
<li><p>Wir betrachten den Fall <code class="language-plaintext highlighter-rouge">fx</code> = <code class="language-plaintext highlighter-rouge">Just x</code></p>
{% include evaluation.html config=site.data.mapMaybeJustLeft %}
<p>Für die andere Seite der Gleichung argumentieren wir wie folgt.</p>
{% include evaluation.html config=site.data.mapMaybeJustRight %}
</li>
</ol>

Zuletzt betrachten wir noch ein weiteres Beispiel für einen Funktor, um zu illustrieren, dass das Konzept der `map`-Funktion weit über Container-Datentypen hinausgeht.
Zuerst definieren wir das folgende Typsynonym.

```elm
type alias Function a b =
    a -> b
```

Dieser Typ ist ebenfalls ein Funktor und wir können die folgende `map`-Funktion definieren.

```elm
map : (a -> b) -> Function c a -> Function c b
map f g =
    \c -> f (g c)
```

Es handelt sich bei dieser Funktion um die Definition der Funktionskomposition.

Wir wollen nun einmal zeigen, dass diese Implementierung der Funktion `map` ebenfalls die beiden Funktorgesetze erfüllt.
Seien `t1` und `t2` Typen und sei `fx` vom Typ `Function t1 t2`.
Dann gilt das Folgende. 

{% include evaluation.html config=site.data.mapFunctionIdentity %}

Seien `t1`, `t2`, `t3` und `t4` Typen.
Seien `fx` vom Typ `Function t1 t2`, `f` vom Typ `t3 -> t4` und `g` vom Typ `t2 -> t3`. 
Dann gilt das Folgende.

{% include evaluation.html config=site.data.mapFunctionCompose %}


<!-- ## Applikative Funktoren

Wir haben die folgende Funktion kennengelernt, um aus "einfachen" Decodern einen komplexeren zusammenzubauen.

```elm
apply : Decoder a -> Decoder (a -> b) -> Decoder b
```

Auch die Funktion `apply`[^1] kann für verschiedene Typkonstruktoren definiert werden.
So können wir in Elm zum Beispiel die folgenden Funktionen definieren.

```elm
apply : Maybe    a -> Maybe    (a -> b) -> Maybe    b
apply : Result e a -> Result e (a -> b) -> Result e b
apply : List     a -> List     (a -> b) -> List     b
```

Während ein Funktor die Funktion `map` zur Verfügung stellt, stellt ein **applikativer Funktor** die Funktion `apply` zur Verfügung.
Damit ein Typkonstruktor `f` ein applikativer Funktor ist, muss es also eine Funktion

```elm
apply : f a -> f (a -> b) -> f b
```

geben.
Damit `f` ein applikativer Funktor ist, muss es neben der Funktion `apply` noch eine Funktion `pure : a -> f a` geben.
Es gibt eine solche Funktion für alle drei Typkonstruktoren, sie heißt nur immer anders.
Im Fall von `List` heißt die Funktion `pure` zum Beispiel `singleton`, im Fall von `Decoder` heißt sie `succeed` und im Fall von `Maybe` einfach `Just`.

Um zu illustrieren, wofür die Funktionen `pure` und `apply` genutzt werden, wollen wir die beiden Funktionen für den Typkonstruktor `Maybe` definieren.
Wir definieren zuerst eine Funktion `pure : a -> f a` für den Typkonstruktor `Maybe`.

```elm
pure : a -> Maybe a
pure =
    Just
```

Außerdem definieren wir die Funktion `apply : f a -> f (a -> b) -> f b` für den Typkonstruktor `Maybe` wie folgt.

```elm
apply : Maybe a -> Maybe (a -> b) -> Maybe b
apply maybeValue maybeFunc =
    case maybeValue of
        Nothing ->
            Nothing

        Just value ->
            case maybeFunc of
                Nothing ->
                    Nothing

                Just func ->
                    Just (func value)
```

Im Gegensatz zu `map` können wir mit `apply` zwei Strukturen kombinieren.
Im Fall des Typkonstruktors `Decoder` haben wir zum Beispiel gesehen, dass wir mithilfe der Funktion `apply` aus zwei einfachen Decodern einen komplexeren Decoder bauen können.
Im Fall von `Maybe` können wir `apply` auch nutzen, um zwei Werte zu kombinieren.
Wir betrachten das folgende Beispiel.
Wir wollen vom Benutzer zwei Zahlen einlesen und diese addieren.
Wir nutzen zum Einlesen der Zahlen die Funktion `String.toInt : String -> Maybe Int`.
Da das Parsen von beiden Eingaben möglicherweise fehlschlagen kann, müssen wir zwei Werte vom Typ `Maybe Int` kombinieren.
Dazu können wir die Funktion `apply` nutzen.

```elm
parseAndAdd : String -> String -> Maybe Int
parseAndAdd userInput1 userInput2 =
    pure (+)
        |> apply (String.toInt userInput1)
        |> apply (String.toInt userInput2)
```

Die Implementierung von `parseAndAdd` liefert `Nothing` zurück, sobald einer der Aufrufe von `String.toInt` als Ergebnis `Nothing` liefert.
Nur falls beide Aufrufe ein Ergebnis der Form `Just value` liefern, wird die Funktion `+` auf diese beiden Ergebnisse angewendet und das Ergebnis der Addition anschließend wieder in den Konstruktor `Just` eingepackt.

Wie können auch für den Typkonstruktor `Function a` die Funktionen `pure` und `apply` implementieren.

```elm
pure : a -> Function b a
pure a =
    \_ -> a
```

```elm
apply : Function c a -> Function c (a -> b) -> Function c b
apply f g =
    \c -> g c (f c)
```

Wie der Name applikativer Funktor schon andeutet, ist ein applikativer Funktor auch ein Funktor.
Wir können die Funktion `map` mithilfe von `pure` und `apply` wie folgt definieren.

```elm
map : (a -> b) -> Maybe a -> Maybe b
map func maybe =
    pure func |> apply maybe
``` -->

<!-- Auf diese Weise können wir für jeden applikativen Funktor die Funktion `map` definieren.
Wir hatten im Abschnitt [Funktoren](#funktoren) gelernt, dass die Funktion `map` Gesetze erfüllen muss, damit es sich um einen Funktor handelt.
Diese Gesetze lassen sich durch die Definition von `map` auf die Funktionen `pure` und `apply` übertragen.
Für die Funktion `map` hatten wir `map (\x -> x) fx` = `fx` gefordert.
Aus diesem Gesetz erhalten wir durch einsetzen, das erste Gesetz eines applikativen Funktors.

{% include evaluation.html config=site.data.applicativeLaw1 %}

| `pure (\x -> x) |> apply fx` | = | `fx` |

Als nächstes betrachten 

| `map f (map g fx)` | = | `map (\x -> f (g x)) fx` |

{% include evaluation.html config=site.data.applicativeLaw2 %}

| `pure (<<) |> apply ax |> apply ay |> apply az = ax |> (apply ay |> apply az)` |
| `pure f |> apply (pure x) = pure (f x)` |
| `ax |> apply (pure y) = pure (\h -> h y) |> apply ax` |

Die Standardbibliotheken von Elm bieten für Datenstrukturen wie `List` und `Maybe` nicht die Funktion `apply` an, sondern nutzen die folgende Funktion.

```elm
map2 : (a -> b -> c) -> f a -> f b -> f c
```

Diese Funktion ist für Einsteiger vermutlich besser zugänglich.
Elm bietet zum Beispiel die Funktion

```elm
map2 : (a -> b -> c) -> List a -> List b -> List c
```

im Modul `List`, die Funktion

```elm
map2 : (a -> b -> c) -> Maybe a -> Maybe b -> Maybe c
```

im Modul `Maybe` und

```elm
map2 : (a -> b -> c) -> Decoder a -> Decoder b -> Decoder c
```

im Modul `Json.Decode`.
Wie haben die Funktion `apply` für `Decoder` mithilfe von `map2` definiert.
Falls eine Datenstruktur eine Funktion `map2 : (a -> b -> c) -> f a -> f b -> f c` zur Verfügung stellt, können wir `apply` mittels `map2 (|>)` definieren.

Falls eine Struktur eine Funktion `pure` zur Verfügung stellt, können wir mithilfe von `pure` und `apply` auch die Funktion `map2` definieren.

```elm
map2 (a -> b -> c) -> Maybe a -> Maybe b -> Maybe c
map2 func ma mb =
    pure func
        |> apply ma
        |> apply mb
```

Das heißt, statt --- wie in Haskell üblich --- die Funktionen `pure` und `apply` für einen applikativen Funktor zu definieren, könnten wir auch die Funktion `pure` und `map2` definieren.
Diesen Ansatz wählt die Programmiersprache Elm, um Einsteigern den Zugang zu vereinfachen.

Ähnlich wie ein Funktor muss auch ein applikativer Funktor Gesetze erfüllen.

| `pure id |> apply ax = ax` |
| `pure (<<) |> apply ax |> apply ay |> apply az = ax |> (apply ay |> apply az)` |
| `pure f |> apply (pure x) = pure (f x)` |
| `ax |> apply (pure y) = pure (\h -> h y) |> apply ax` |

Damit ein Typkonstruktor ein applikativer Funktor ist, müssen die Funktionen `pure` und `apply` ebenfalls Gesetze erfüllen.
Auf diese Gesetze wollen wir hier aber nicht eingehen[^2].
Es sei an dieser Stelle aber noch kurz erwähnt, dass jeder applikative Funktor auch ein Funktor ist. -->

<!-- ## Monaden

In der funktionalen Programmierung gibt es eine ganze Reihe von Abstraktionen wie Funktor und applikativer Funktor.
Wir wollen uns an dieser Stelle noch eine dieser Abstraktionen anschauen, die **Monade** heißt und vergleichsweise legendär auch außerhalb der funktionalen Programmierung ist.

![Monads, monad everywhere](./assets/images/monads-everywhere.png){: .centered}

Es gibt einige Funktionen, die sich mithilfe eines applikativen Funktors nicht ausdrücken lassen.
Wir betrachten dazu die folgende `apply`-Funktion.

```elm
apply : Decoder a -> Decoder (a -> b) -> Decoder b
```

Für unser Beispiel gehen wir davon aus, dass die JSON-Struktur, die wir verarbeiten wollen ein Feld mit der Version der Schnittstelle hat.
Abhängig von der Version wollen wir jetzt den einen oder anderen `Decoder` verwenden.
Wir definieren dazu erst einmal einen `Decoder`, der die Version liefert.

```elm
versionDecoder : Decoder Int
versionDecoder =
    Decode.field "version" Decode.int
```

Außerdem haben wir die folgenden beiden `Decoder` für die beiden Varianten der JSON-Struktur.
Das heißt, in einer Version hieß das Feld `bool` und in einer anderen Version hieß es `boolean`.

```elm
boolDecoder : Decoder Bool
boolDecoder =
    Decode.field "bool" Decode.bool

booleanDecoder : Decoder Bool
booleanDecoder =
    Decode.field "boolean" Decode.bool
```

Wir möchten jetzt gern einen `Decoder` definieren, der abhängig von der Version entweder `boolDecoder` oder `booleanDecoder` verwendet.
Diese Art von `Decoder` können wir mithilfe von `apply` aber nicht definieren.
Das Problem besteht darin, dass wir abhängig von einem Wert den `Decoder` bestimmen möchten.
Das Argument `Decoder (a -> b)` erlaubt es aber nicht, den `Decoder` danach zu wählen, welchen Wert wir als `a` übergeben bekommen.

Wir können die gewünschte Funktionalität aber mit der folgenden Funktion implementieren.

```elm
andThen : (a -> Decoder b) -> Decoder a -> Decoder b
```

Hier haben wir statt eines Arguments `Decoder (a -> b)` jetzt ein Argument vom Typ `a -> Decoder b`.
Das heißt, wir können abhängig vom konkreten Wert, der vom Typ `a` übergeben wird, den `Decoder` wählen, den wir anschließend verwenden.
Wir können damit den folgenden `Decoder` definieren.
Wir verwenden hier die Funktion `|>` um die Argumente von `andThen` zu tauschen, ähnlich wie wir es bei der Verwendung von `apply` gemacht haben.

```elm
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
                    Decode.fail ("Version " ++ String.fromInt version ++ " not supported")
    in
    versionDecoder
        |> Decode.andThen chooseVersion
```

Die Funktion `Decode.fail` liefert einen `Decoder`, der immer fehlschlägt.
Das heißt, wenn wir eine Version parsen und es sich weder um Version `1` noch um Version `2` handelt, liefert `decoder` einen Fehler.
Dieses Beispiel illustriert, dass wir mithilfe von `andThen` abhängig von einem Wert, den wir zuvor geparset haben, verschiedene `Decoder` ausführen können.

Wir wollen uns noch ein weiteres Beispiel für die Verwendung von `andThen` anschauen.
Dazu betrachten wir die Funktion `andThen : Maybe a -> (a -> Maybe b) -> Maybe b`.
Außerdem betrachten wir die folgenden beiden Funktionen, die wir im Kapitel [Polymorphismus](polymorphism.md) definiert haben.

```elm
parseMonth : String -> Maybe Int
parseMonth userInput =
    case String.toInt userInput of
        Just number ->
            toValidMonth number

        Nothing ->
            Nothing


toValidMonth : Int -> Maybe Int
toValidMonth month =
    if 1 <= month && month <= 12 then
        Just month

    else
        Nothing
```

Wir können die Funktion `parseMonth` mithilfe von `andThen` wie folgt definieren.

```elm
parseMonth : String -> Maybe Int
parseMonth userInput =
    String.toInt userInput |> Maybe.andThen toValidMonth
```

Neben der Funktion `andThen` muss ein Typkonstruktor `f`, der eine Monade ist, noch eine Funktion `return : a -> f a` zur Verfügung stellen.
Im Fall von `Decoder` ist `return` wie folgt definiert.

```elm
return : a -> Decoder a
return =
    Decode.succeed
```

Wie beim Funktor und beim applikativen Funktor müssen die Funktionen einer Monade auch Gesetze erfüllen.
Die Funktionen `andThen` und `return` sollten für alle möglichen Werte für `x`, `fx`, `f` und `g` die folgenden drei Gesetze erfüllen.

| `return x |> andThen f = f x` |
| `fx |> andThen return = fx` |
| `(fx |> andThen f) |> andThen g = fx |> andThen (\x -> f x |> andThen g)` |

Wenn ein Typkonstruktor eine Monade ist, dann ist er auch ein applikativer Funktor.
Wir können nämlich wie folgt die Funktionen eines applikativen Funktors definieren, indem wir die Funktionen der Monade verwenden.

```elm
pure : a -> Decoder a
pure =
    return


apply : Decoder a -> Decoder (a -> b) -> Decoder b
apply dx df =
    dx |> Decode.andThen (\x -> df |> Decode.andThen (\f -> return (f x)))
```

Die [Typeclassopedia](https://wiki.haskell.org/Typeclassopedia) bietet noch weitere Informationen zu Abstraktionen in der funktionalen Programmierung.

<!-- Um komplexere `Decoder` zu definieren benötigen wir noch eine weitere Definition.
Diese Definition wollen wir bereits auch dieser Stelle einführen, auch wenn sie erst später benötigt wird.
Die Funktion `succeed : a -> Decoder a` liefert einen `Decoder`, der für alle JSON-Strukturen immer den Wert vom Typ `a` als Ergebnis liefert.
Das heißt, der Aufruf

```elm
decodeString (Decode.succeed 42) "true"
```

liefert genau so `Ok 42` als Ergebnis, wie der Aufruf

```elm
decodeString (Decode.succeed 42) "[1,2,3]"
``` -->

<!-- ## Arrows -->

[^1]: In Elm wird die Funktion `apply` manchmal auch `andMap` genannt.

[^2]: Mehr Informationen zu applikativen Funktoren finden Sie in der wissenschaftlichen Publikation ["Applicative programming with effects"](https://openaccess.city.ac.uk/id/eprint/13222/1/) oder im [Wiki-Artikel](https://wiki.haskell.org/Typeclassopedia#Applicative) zur entsprechenden Struktur in Haskell.

{% include bottom-nav.html previous="commands.html" %}
