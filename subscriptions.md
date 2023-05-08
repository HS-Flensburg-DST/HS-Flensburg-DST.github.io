---
layout: post
title: "Abonnements"
---

In diesem Kapitel wollen wir uns die Funktionsweise der `subscriptions` anschauen.
Wie der Name schon sagt, handelt es sich dabei um ein Abonnement, das heißt, wir teilen Elm damit mit, dass wir eigenständig von Elm informiert werden möchten.
Um das Konzept des Abonnements zu illustrieren, werden wir eine einfache Stoppuhr implementieren, die nur einen Sekundenzeiger hat.

Elm ist eine rein funktionale Programmiersprache.
Das heißt, wir können keine Seiteneffekte ausführen, wie zum Beispiel das Schreiben von Dateien oder das Verändern von Variablen.
Man spricht in diesem Kontext auch von **referenzieller Transparenz**.
Ein Ausdruck ist referenziell transparent, wenn der Wert des Ausdrucks nur von den Werten seiner Teilausdrücke abhängt.
Damit darf der Wert eines Ausdrucks zum Beispiel nicht vom Zeitpunkt abhängen, zu dem der Ausdruck ausgewertet wird.
Ein Beispiel für einen Ausdruck dessen Wert vom Zeitpunkt seiner Auswertung abhängt, ist der aktuelle Zeitstempel.
Wenn wir in Java eine Methode schreiben, welche die Methode `currentTimeMillis()` aufruft, ist die Methode zum Beispiel mit hoher Wahrscheinlichkeit nicht referentiell transparent.

In Elm werden wir gezwungen, referentiell transparente Programme zu schreiben.
In Programmiersprachen, die uns nicht dazu zwingen, solche Programme zu schreiben, ist es aber auch guter Stil, diese Eigenschaft an möglichst vielen Stellen zu gewährleisten.
Man kann sich leicht vorstellen, dass es recht schwierig ist, Fehler zu finden, wenn
wiederholte Aufrufe der gleichen Methode mit identischen Argumenten immer wieder andere Ergebnisse liefern.
Daher versucht man auch in anderen Programmiersprachen den Teil der Anwendung, der nicht referentiell transparent ist, möglichst von dem Teil zu trennen, der referentiell transparent ist.

Zeit
----

Um über die aktuelle Zeit informiert zu werden, müssen wir zuerst das entsprechende Elm-Paket zu unserem Projekt hinzufügen.
Dazu führen wir das folgende Kommando aus.

```console
elm install elm/time
```

Da wir unsere Uhr mithilfe einer SVG zeichnen wollen, fügen wir auch noch das SVG-Paket hinzu.

```console
elm install elm/svg
```

Als wir die Elm-Architektur besprochen haben, haben wir das Programm mithilfe der Funktion `sandbox` erstellt.

``` elm
sandbox :
    { init : model
    , view : model -> Html msg
    , update : msg -> model -> model
    }
    -> Program () model msg
```

Neben dieser Funktion gibt es auch eine Funktion `element`, die den folgenden Typ hat.

``` elm
element :
    { init : flags -> ( model, Cmd msg )
    , view : model -> Html msg
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    }
    -> Program flags model msg
```

Diese Funktion nimmt als initialen Wert eine Funktion.
Die Funktion, die das initiale Modell erzeugt, erhält als Argument einen Wert vom Typ `flags`.
Es handelt sich dabei um Informationen, die das JavaScript-Programm, das die Elm-Anwendung startet, an die Anwendung übergeben kann.
Das initiale Modell besteht im Vergleich zur Sandbox außerdem nicht nur aus einem Modell sondern noch aus einem Kommando in Form eines Wertes vom Typ `Cmd msg`.
Die Funktion `update` liefert in diesem Fall auch nicht nur ein Modell als Ergebnis, sondern ein Modell und ein Kommando.
Außerdem ist ein neues Feld hinzugekommen, das `subscriptions` heißt.

Den Typ `Cmd msg` benötigen wir in diesem Kapitel erst einmal nicht.
Die Funktion `init` muss aber einen Wert von diesem Typ zurückgeben.
Um diesen Wert zu erzeugen, können wir die Konstante `Cmd.none` nutzen.

Das Paket `elm/time` stellt ein Modul mit dem Namen `Time` zur Verfügung.
Dieses Modul stellt wiederum eine Funktion mit der Signatur

``` elm
every : Float -> (Posix -> msg) -> Sub msg
```

zur Verfügung.
Das erste Argument ist ein Intervall in Millisekunden, das angibt, wie häufig wir über die aktuelle Zeit informiert werden möchten.
Wir müssen der Funktion dann noch ein funktionales Argument übergeben, das die aktuelle Zeit im Posix-Format erhält und daraus eine Nachricht unseres Nachrichtentyps macht.

Wir wollen nur die vergangenen Sekunden in unserer Uhr anzeigen, daher definieren wir uns einen Datentyp für Sekunden.

```elm
type Seconds
    = Seconds Int
```

Auf den ersten Blick erzeugt dieser Datentyp einen unnötigen zusätzlichen _Overhead_.
Zuerst einmal verbessert dieser Datentyp aber den dokumentativen Charakter unseres Codes.
Statt einen `Int` an Funktionen zu übergeben, welche die Sekunden weiterverarbeiten, übergeben wir jetzt den Typ `Seconds`, der uns die Semantik des Argumentes signalisiert.
Außerdem werden wir sehen, dass wir auf diese Weise einen Datentyp identifizieren können, den wir zur Strukturierung unserer Anwendung nutzen können.

Wir definieren den Datentyp `Seconds` daher in einem eigenen Modul mit dem Namen `Seconds` und importieren das Modul mittels `import Seconds exposing (Seconds)` im Hauptmodul und verwenden die folgenden Datentypen in unserem Hauptmodul.

``` elm
type alias Model =
    Seconds


type Msg =
    Tick
```

Mithilfe der Funktion `Time.every` definieren wir die folgende `main`-Funktion.
Die Implementierungen der Funktionen `init`, `view` und `update` werden wir im Folgenden diskutieren.
Um die Definitionen zu vereinfachen, nutzen wir hier mehrere Lambda-Ausdrücke.

``` elm
main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( Seconds.zero, Cmd.none )
        , subscriptions = \_ -> Time.every 1000 (\_ -> Tick)
        , view = view
        , update = \msg model -> ( update msg model, Cmd.none )
        }
```

Unser initiales Modell setzt den Sekundenwert zu Anfang auf null.
Die Funktion `update` soll unseren Sekundenzähler hochzählen.
Daher definieren wie die Konstante `zero` und die Funktion `inc` im Modul `Seconds`.
Die Funktion `inc` rechnet den Wert der Sekunden jeweils modulo `60`, damit immer nur valide Sekundenwerte entstehen, also Werte zwischen `0` und `59`.

```elm
module Seconds exposing (Seconds, inc, zero)


type Seconds
    = Seconds Int


zero : Seconds
zero =
    Seconds 0


inc : Seconds -> Seconds
inc (Seconds seconds) =
    Seconds (modBy 60 (seconds + 1))
```

Der Modulkopf des Moduls `Seconds` exportiert zwar den Typ `Seconds` aber nicht seine Konstruktoren.
Auf diese Weise garantieren wir, dass Werte vom Typ `Seconds` nur mithilfe der Konstante `zero` und der Funktion `inc` erzeugt werden.
Wir erreichen dadurch eine **Datenkapselung (_Information Hiding_)**, wie sie auch aus anderen Programmiersprachen bekannt ist.
Das heißt, wir stellen den Nutzer*innen eine feste Schnittstelle zur Arbeit mit `Seconds` zur Verfügung und verhindern, dass auf die interne Darstellung zugegriffen wird.

Durch diese Abstraktion können wir die Implementierung später auch einfach ersetzen.
Zum Beispiel können wir die Uhr später relativ einfach auf eine Anzeige mit Minuten **und** Sekunden umstellen, indem wir den Datentyp `Seconds` durch einen Datentyp ersetzen, der beide Informationen hält.

Wir nutzen die Funktion `inc` nun wie folgt in unserer Uhr.

``` elm
update : Msg -> Model -> Model
update msg seconds =
    case msg of
        Tick ->
            Seconds.inc seconds
```

Im Grunde könnten wir hier auch auf das Pattern Matching verzichten, da wir wissen, dass die einzige Nachricht, die wir erhalten können, die Nachricht `Tick` ist.
Durch das _Pattern Matching_ gewährleisten wir aber, dass der Elm-Compiler sich über ein fehlendes _Pattern_ beschwert, falls wir einen weiteren Konstruktor zum Typ `Msg` hinzufügen.
Ohne das *Pattern Matching* auf `Tick` würde die Anwendung weiterhin kompilieren, wenn wir einen weiteren Konstruktor zu `Msg` hinzufügen.
Die Anwendung würde sich aber für diese neue Nachricht genau so verhalten wie für die Nachricht `Tick`, was ggf. nicht das gewünschte Verhalten ist.

Als nächstes wollen wir die Uhr zeichnen.
Dazu verwenden wir die Funktion `rotate`, die wir im Abschnitt [Records](basics.md#records) definiert haben.
Diese Funktion werden wir später nutzen, um den Wert des SVG-Attributes `transform` zu setzen.
Dabei geben wird einen Winkel in Grad und einem Punkt an und rotieren dann ein Objekt um den Winkel und um den angegebenen Punkt.

``` elm
type alias Point =
    { x : Float, y : Float }


rotate : { angle : Float, point : Point }
rotate { angle, point } =
    "rotate("
        ++ String.fromFloat angle
        ++ ","
        ++ String.fromFloat point.x
        ++ ","
        ++ String.fromFloat point.y
        ++ ")"
```

Nun implementieren wir eine Funktion, die die aktuelle Sekundenzahl in Form einer Uhr anzeigt.

``` elm
view : Model -> Html msg
view seconds =
    clock seconds


clock : Seconds -> Html msg
clock seconds =
    let
        center =
            Point 200 200

        radius =
            100
    in
    svg
        [ width "500"
        , height "500"
        ]
        [ clockBack center radius
        , clockHand center radius seconds
        ]


clockBack : Point -> Float -> Svg msg
clockBack center radius =
    circle
        [ cx (String.fromFloat center.x)
        , cy (String.fromFloat center.y)
        , r (String.fromFloat radius)
        , fill "#aaddf9"
        ]
        []


clockHand : Point -> Float -> Seconds -> Svg msg
clockHand center radius seconds =
    line
        [ x1 (String.fromFloat center.x)
        , y1 (String.fromFloat center.y)
        , x2 (String.fromFloat center.x)
        , y2 (String.fromFloat (center.y - radius))
        , stroke "#2c2f88"
        , strokeWidth "2"
        , transform (rotate { angle = Seconds.toDegree seconds, point = center })
        ]
        []
```

Die Funktion `toDegree` ist wie folgt im Modul `Seconds` definiert und rechnet eine Sekundenzahl in einen Winkel einer Uhr um.

```elm
toDegree : Seconds -> Float
toDegree (Seconds seconds) =
    360 * toFloat seconds / 60
```

Um zu illustrieren, wie man Abonnements zeitweise aussetzt, wollen wir unsere Uhr um die Möglichkeit erweitern, sie anzuhalten und wieder zu starten.
Dazu erweitern wir erst einmal wie folgt unseren Datentyp `Msg`.

``` elm
type Msg
    = Tick
    | StartPause
```

Außerdem fügen wir einen Knopf zu unserer Anwendung hinzu, um die Uhr zu starten bzw. anzuhalten.

``` elm
clock : Int -> Html Msg
clock seconds =
    let
        center =
            Point 200 200

        radius =
            100
    in
    div []
        [ svg
            [ width "500"
            , height "500"
            ]
            [ clockBack center radius
            , clockHand center radius seconds
            ]
        , button [ onClick StartPause ] [ text "Start/Pause" ]
        ]
```

Da unsere Uhr nun auch pausiert sein kann, müssen wir diese Information in unserem Zustand modellieren.
Wir nutzen den folgenden Datentyp, um zu gewährleisten, dass wir immer überprüfen müssen, ob die Uhr läuft oder nicht, bevor wir auf die Sekunden zugreifen können.

``` elm
type Model
    = Running Seconds
    | Paused Seconds
```

Als nächstes adaptieren wir die Funktion `update` wie folgt.

``` elm
update : Msg -> Model -> Model
update msg model =
    case msg of
        Tick ->
            case model of
                Running seconds ->
                    Running (Seconds.inc seconds)

                Paused _ ->
                    model

        StartPause ->
            case model of
                Running seconds ->
                    Paused seconds

                Paused seconds ->
                    Running seconds
```

Um an die aktuellen Sekunden heranzukommen, müssen wir unsere Funktion `view` noch entsprechend anpassen.

``` elm
view : Model -> Html Msg
view model =
    case model of
        Running seconds ->
            clock seconds

        Paused seconds ->
            clock seconds
```

Unsere Implementierung ignoriert die Nachrichten, die von der `subscription` an die Anwendung geschickt werden, wenn wir im Zustand `Paused` sind.
Die Reaktionszeit der Uhr hängt dadurch davon ab, zu welchem Zeitpunkt des aktuellen Intervals wir die Uhr wieder starten.
Außerdem sollten wir die `Subscription` beenden, wenn wir sie gar nicht benötigen.
Das Feld `subscriptions` des Programms ist eine Funktion, die ein Modell als Argument erhält und eine `Subscription` liefert.
Die Konstante `Sub.none` liefert analog zu `Cmd.none` keine `Subscription`.
Wir können dadurch wie folgt die `Subscription` beenden, wenn die Uhr im Zustand `Paused` ist.

``` elm
subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Running _ ->
            Time.every 1000 (\_ -> Tick)

        Paused _ ->
            Sub.none


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( 0, Cmd.none )
        , subscriptions = subscriptions
        , view = view
        , update = \msg model -> ( update msg model, Cmd.none )
        }
```

Zum Abschluss soll hier noch die Funktion `batch : List (Sub msg) -> Sub msg` vorgestellt werden.
Diese Funktion kann genutzt werden, um eine Liste von Abonnements zu einem Abonnement zusammenzufassen.
Auf diese Weise können wir in einer Anwendung über mehrere Ereignisse informiert werden.
Im folgenden Abschnitt werden wir zum Beispiel lernen, wie man sich über Tastendrücke informieren lassen kann.
Mithilfe der Funktion `batch` kann man dann zum Beispiel informiert werden, wenn ein Interval vergangen ist oder wenn eine Taste gedrückt wurde.

Decoder
-------

Bei einigen Arten von Abonnements aber auch bei anderen Konzepten, die wir später kennenlernen werden, müssen Daten im JSON-Format in einen stärker strukturierten Elm-Datentyp umgewandelt werden.
Um diese Aufgabe umzusetzen, werden in Elm `Decoder` verwendet.

![You shall not parse, syntax error on line 1](/assets/images/parse-error.png){: width="400px" .centered}

Ein `Decoder` ist eine Elm-spezifische Variante des allgemeineren Konzeptes eines Parser-Kombinators.
Parser-Kombinatoren sind eine leichtgewichtige Implementierung von Parsern.
Ein Parser ist eine Anwendung, die einen String erhält und prüft, ob der String einem vorgegebenen Format folgt.
Jeder Compiler nutzt zum Beispiel einen Parser, um Programmtext auf syntaktische Korrektheit zu prüfen.
Neben der Überprüfung, ob der String einem Format entspricht, wird der String für gewöhnlich auch noch in ein strukturiertes Format umgewandelt.
Im Fall von Elm, wird der String zum Beispiel in Werte von algebraischen Datentypen umgewandelt.
In einer objektorientierten Programmiersprache würde ein Parser einen String erhalten und ein Objekt liefern, das eine strukturierte Beschreibung des Strings zur Verfügung stellt.

Um in einer Elm-Anwendung einen `Decoder` zu nutzen, müssen wir zuerst den folgenden Befehl ausführen.

```console
elm install elm/json
```

Die Bibliothek `elm/json` ist eine eingebettete domänenspezifische Sprache und stellt eine deklarative Technik dar, um `Decoder` zur Verarbeitung von JSON zu beschreiben.

Der Typkonstruktor `Decoder` ist im Modul `Json.Decode`[^1] definiert.
Das Modul stellt eine Funktion

```elm
decodeString : Decoder a -> String -> Result Error a
```

zur Verfügung.
Mithilfe dieser Funktion kann ein `Decoder` auf eine Zeichenkette angewendet werden.
Ein `Decoder a` liefert einen Wert vom Typ `a` als Ergebnis nach dem Parsen.
Wenn wir einen `Decoder a` mit `decodeString` auf eine Zeichenkette anwenden, erhalten wir entweder einen Fehler und eine Fehlermeldung mit einer Fehlerbeschreibung oder wir erhalten einen Wert vom Typ `a`.
Daher ist der Ergebnistyp der Funktion `decodeString` `Result Error a`.

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
In den meisten Fällen werden wir das Alter des Nutzers auf JSON-Ebene nicht als einzelne Zahl dargestellt, sondern zum Beispiel durch folgendes JSON-Objekt.

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
    { name : String, age : Int }
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

Tasten
------

Wir wollen uns nun eine Anwendung von `Decoder`n anschauen und zwar wollen wir auf die Eingabe einer Taste in unserer Anwendung horchen.
Als Beispiel wollen wir einen einfachen Zähler implementieren, bei dem es möglich ist, den Zähler mithilfe der Pfeiltasten zu erhöhen oder zu erniedrigen.
Zu diesem Zweck müssen wir über alle Tastendrücke informiert werden.
Die Funktion

```elm
onKeyDown : Decoder msg -> Sub msg
```

aus dem Modul `Browser.Events` erlaubt es uns, auf *KeyDown*-Ereignisse zu reagieren.
Der `Decoder`, den wir übergeben, wandelt die JSON-Struktur, die bei einem Tastendruck geliefert wird, in einen Elm-Wert um.
Wir definieren zum Beispiel den folgenden Decoder.

``` elm
type Msg
    = Key Key


type Key
    = Up
    | Down
    | Unknown


keyDecoder : Decoder Key
keyDecoder =
    let
        toKey string =
            case string of
                "ArrowUp" ->
                    Up

                "ArrowDown" ->
                    Down

                _ ->
                    Unknown
    in
    Decode.map toKey (Decode.field "key" Decode.string)
```

Dieser `Decoder` liefert abhängig davon, welchen `String` das Feld mit dem Namen `"key"`[^2] enthält, einen Wert vom Typ `Key`.
Diesen `Decoder` können wir nun nutzen, um in unserer Anwendung auf Tastendrücke zu lauschen.
Hierzu nutzen wir die folgende Definition unserer Anwendung.

``` elm
type alias Model =
    Int


update : Msg -> Model -> Model
update msg model =
    case msg of
        Key key ->
            updateKey key model


updateKey : Key -> Model -> Model
updateKey key model =
    case key of
        Up ->
            model + 1

        Down ->
            model - 1

        Unknown ->
            model


main : Program () Model Msg
main =
    program
        { init = \_ -> ( 0, Cmd.none )
        , subscriptions = \_ -> Sub.map Key (onKeyDown keyDecoder)
        , view = view
        , update = \msg model -> ( update msg model, Cmd.none )
        }
```

Die `view`-Funktion stellt einfach den Zähler als Text in einer HTML-Struktur dar.

[^1]: Dieses Modul wird hier mittels `import Json.Decode as Decode exposing (Decoder)` importiert.

[^2]: Unter <https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key> lässt sich überprüfen, welchen Wert dieses Feld beim Druck einer bestimmten Taste annimmt.

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="architecture.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="commands.html">weiter</a></li>
    </ul>
</div>