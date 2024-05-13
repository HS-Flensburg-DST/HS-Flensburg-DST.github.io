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

Als Beispiel für ein Abonnement wollen wir in diesem Abschnitt eine Uhr implementieren.
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
    IncreaseSeconds
```

Mithilfe der Funktion `Time.every` definieren wir die folgende `main`-Funktion.
Die Implementierungen der Funktionen `init`, `view` und `update` werden wir im Folgenden diskutieren.
Um die Definitionen zu vereinfachen, nutzen wir hier mehrere Lambda-Ausdrücke.

``` elm
main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( Seconds.zero, Cmd.none )
        , subscriptions = \_ -> Time.every 1000 (\_ -> IncreaseSeconds)
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
update IncreaseSeconds model =
    Seconds.inc model
```

Im Grunde könnten wir hier auch auf das Pattern Matching verzichten und einen Unterstrich verwenden, da wir wissen, dass die einzige Nachricht, die wir erhalten können, die Nachricht `IncreaseSeconds` ist.
Durch das _Pattern Matching_ gewährleisten wir aber, dass der Elm-Compiler sich beschwert, falls wir einen weiteren Konstruktor zum Typ `Msg` hinzufügen.
Ohne das *Pattern Matching* auf `IncreaseSeconds` würde die Anwendung weiterhin kompilieren, wenn wir einen weiteren Konstruktor zu `Msg` hinzufügen.
Die Anwendung würde sich aber für diese neue Nachricht genau so verhalten wie für die Nachricht `IncreaseSeconds`, was ggf. nicht das gewünschte Verhalten ist.

Als nächstes wollen wir die Uhr zeichnen.
Dazu verwenden wir die Funktion `rotate`, die wir im Abschnitt [Records](basics.md#records) definiert haben.
Diese Funktion werden wir später nutzen, um den Wert des SVG-Attributes `transform` zu setzen.
Dabei geben wird einen Winkel in Grad und einem Punkt an und rotieren dann ein Objekt um den Winkel und um den angegebenen Punkt.

``` elm
type alias Point =
    { x : Float, y : Float }


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

Nun implementieren wir eine Funktion, die die aktuelle Sekundenzahl in Form einer Uhr anzeigt.

``` elm
view : Model -> Html msg
view model =
    clock model


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
    = IncreaseSeconds
    | StartPauseClock
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
        , button [ onClick StartPauseClock ] [ text "Start/Pause" ]
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
        IncreaseSeconds ->
            case model of
                Running seconds ->
                    Running (Seconds.inc seconds)

                Paused _ ->
                    model

        StartPauseClock ->
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
            Time.every 1000 (\_ -> IncreaseSeconds)

        Paused _ ->
            Sub.none


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( Seconds.zero, Cmd.none )
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


Tasten
------

Wir wollen uns nun eine Anwendung von `Decoder`n anschauen und zwar wollen wir auf die Eingabe einer Taste in unserer Anwendung horchen.
Als Beispiel wollen wir einen einfachen Zähler implementieren, bei dem es möglich ist, den Zähler mithilfe der Pfeiltasten zu erhöhen oder zu erniedrigen.
Zu diesem Zweck müssen wir über alle Tastendrücke informiert werden.
Die Funktion

```elm
onKeyDown : Decoder msg -> Sub msg
```

aus dem Modul `Browser.Events` erlaubt es uns, auf _KeyDown_-Ereignisse zu reagieren.
Der `Decoder`, den wir übergeben, wandelt die JSON-Struktur, die bei einem Tastendruck geliefert wird, in einen Elm-Wert um.
Zur Modellierung der Tastendrücke als Elm-Wert definieren wir den folgenden Aufzählungstyp.

```elm
type Key
    = Up
    | Down
    | Unknown
```

Wir wollen in unserer Anwendung Pfeiltasten _Up_ und _Down_ verarbeiten, daher enthält der Datentyp `Key` die Konstruktoren `Up` und `Down`.
Da wir von Elm über alle Tastendrücke informiert werden, also auch über Tastendrücke, die für die Anwendung irrelevant sind, fügen wir einen Fall `Unknown` hinzu, den wir für sonstige Tastendrücke nutzen werden.

{% include callout-important.html content="Ein Datentyp wie `Key` sollte die tatsächlich gedrückten Tasten modellieren und nicht deren Semantik.
Die Semantik der Tastendrücke sollte erst in der `update`-Funktion interpretiert werden." %}

Die Konstruktoren `Up` und `Down` beschreiben zum Beispiel nur, welche Tasten gedrückt wurden.
Welche Aktion diese Tasten auslösen, werden wir erst in der `update`-Funktion implementieren.
Alternativ könnten wir auch den folgenden Datentyp definieren, der bereits eine Semantik in den Namen der Konstruktoren kodiert.

```elm
type Key
    = IncreaseCounter
    | DecreaseCounter
    | Unknown
```

Diese Definition ist aber schlechter Stil, da wir an dieser Stelle unnötigerweise die Taste mit ihrer Interpretation koppeln.

Um die Funktion `onKeyDown` nutzen zu können, müssen wir einen `Decoder` definieren.
Wir definieren den folgenden `Decoder`, der abhängig davon, welchen `String` das Feld mit dem Namen `"key"`[^2] enthält, einen Wert vom Typ `Key` liefert.

``` elm
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

Diesen `Decoder` können wir nun nutzen, um in unserer Anwendung auf Tastendrücke zu lauschen.
Wir werden mit hoher Wahrscheinlichkeit neben den Tastendrücken später noch weitere Nachrichten in unserer Anwendung verarbeiten.
Daher definieren wir einen Nachrichtentyp, der als eine Ausprägung einen Tastendruck enthält.

```elm
type Msg
    = HandleKey Key
```

Auf Grundlagen dieses Nachrichtentyps können wir nun eine Anwendung definieren, die mithilfe von Tastendrücken einen Zähler hoch- bzw. runterzählt.

``` elm
type alias Model =
    Int


update : Msg -> Model -> Model
update msg model =
    case msg of
        HandleKey key ->
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
    Browser.element
        { init = \_ -> ( 0, Cmd.none )
        , subscriptions = \_ -> Sub.map Pressed (onKeyDown keyDecoder)
        , view = view
        , update = \msg model -> ( update msg model, Cmd.none )
        }
```

Die `view`-Funktion stellt einfach den Zähler als Text in einer HTML-Struktur dar.

Wir wollen an dieser Stelle noch kurz eine alternative, aber schlechtere Strukturierung des Datentyps `Msg` diskutieren.
Wir hätten auch den folgenden flachen Nachrichtentyp definieren können.

```elm
type Msg
    = Up
    | Down
    | Unknown
```

Wenn wir später weitere Nachrichten zu unserer Anwendung hinzufügen wollen, fügen wir dann einfach weitere Konstruktoren zum Datentyp `Msg` hinzu.

{% include callout-important.html content="Die Verwendung eines solchen flachen Nachrichtentyps hat mehrere Nachteile und sollte vermieden werden." %}

Zuerst einmal müsste die Funktion `keyDecoder` nun den Typ `Decoder Msg` erhalten.
Das heißt, wir verlieren die statische Information, dass der `keyDecoder` auch wirklich nur einen `Key` liefert.
Solche statischen Informationen sind aber für eine wartbare Codebasis unerlässlich.
Durch diesen alternativen `Msg`-Datentyp verlieren wir auch die Möglichkeit eine Funktion wie `updateKey` aus der Definition von `update` herauszuziehen.
Wir werden diese Aspekte der Strukturierung einer Anwendung noch einmal gesammelt im Kapitel [Strukturierung einer Anwendung](structure.md) diskutieren.

[^1]: Dieses Modul wird hier mittels `import Json.Decode as Decode exposing (Decoder)` importiert.

[^2]: Unter <https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key> lässt sich überprüfen, welchen Wert dieses Feld beim Druck einer bestimmten Taste annimmt.

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="decoder.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="commands.html">weiter</a></li>
    </ul>
</div>
