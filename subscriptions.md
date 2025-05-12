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

{% include callout-important.html content="
Ein Ausdruck ist referenziell transparent, wenn der Wert des Ausdrucks nur von den Werten seiner Teilausdrücke abhängt.
" %}

Damit darf der Wert eines Ausdrucks zum Beispiel nicht vom Zeitpunkt abhängen, zu dem der Ausdruck ausgewertet wird.
Ein Beispiel für einen Ausdruck dessen Wert vom Zeitpunkt seiner Auswertung abhängt, ist der aktuelle Zeitstempel.
Wenn wir in Java eine Methode schreiben, welche die Methode `currentTimeMillis()` aufruft, ist die Methode zum Beispiel mit hoher Wahrscheinlichkeit nicht referentiell transparent.

In Elm werden wir gezwungen, referentiell transparente Programme zu schreiben.
In Programmiersprachen, die uns nicht dazu zwingen, solche Programme zu schreiben, ist es aber auch guter Stil, diese Eigenschaft an möglichst vielen Stellen zu gewährleisten.
Man kann sich leicht vorstellen, dass es recht schwierig ist, Fehler zu finden, wenn
wiederholte Aufrufe der gleichen Methode mit identischen Argumenten immer wieder andere Ergebnisse liefern.
Daher versucht man auch in anderen Programmiersprachen den Teil der Anwendung, der nicht referentiell transparent ist, möglichst von dem Teil zu trennen, der referentiell transparent ist.

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
Statt einen neuen Typ `Seconds` zu definieren, könnten wir auch das folgende Typsynonym definieren.

```elm
type alias Seconds =
    Int
```

In diesem Fall können wir aber an allen Stellen, an denen ein `Int` verwendet wird auch einen Wert vom Typ `Seconds` verwenden.
Wenn wir einen neuen neuen Datentyp `Seconds` definieren, ist durch den Konstruktor `Seconds` dagegen immer klar, dass es sich tatsächlich um einen Wert vom Typ `Seconds` handelt und eben nicht um einen `Int`.

Da der Datentyp `Seconds` unabhängig vom Rest der Anwendung ist, definieren wir ihn in einem eigenen Modul mit dem Namen `Seconds` und importieren das Modul mittels `import Seconds exposing (Seconds)` im Hauptmodul.
Wir verwendet im Folgenden die folgenden Datentypen in unserem Hauptmodul.

``` elm
type alias Model =
    Seconds


type Msg =
    TickClock
```

Mithilfe der Funktion `Time.every` definieren wir die folgende `main`-Funktion.
Die Implementierungen der Funktionen `init`, `view` und `update` werden wir im Folgenden diskutieren.
Um die Definitionen zu vereinfachen, nutzen wir hier mehrere Lambda-Ausdrücke.

``` elm
main : Program () Model Msg
main =
    Browser.element
        { init = \() -> ( Seconds.zero, Cmd.none )
        , subscriptions = \_ -> Time.every 1000 (\_ -> TickClock)
        , view = view
        , update = \msg model -> ( update msg model, Cmd.none )
        }
```

Unser initiales Modell setzt den Sekundenwert zu Anfang auf null.
Die Funktion `update` soll unseren Sekundenzähler hochzählen.
Daher definieren wie die Konstante `zero` und die Funktion `increase` im Modul `Seconds`.
Die Funktion `increase` rechnet den Wert der Sekunden jeweils modulo `60`, damit immer nur valide Sekundenwerte entstehen, also Werte zwischen `0` und `59`.

```elm
module Seconds exposing (Seconds, increase, zero)


type Seconds
    = Seconds Int


zero : Seconds
zero =
    Seconds 0


increase : Seconds -> Seconds
increase (Seconds seconds) =
    Seconds (modBy 60 (seconds + 1))
```

<!-- Seconds (seconds + 1 |> modBy 60) -->

<!-- Wie im Kapitel [Piping](higher-order.md#piping) beschrieben, können wir den Operator `|>` nutzen, um die Funktion `modBy` infix zu verwenden.
Das heißt, durch den Operator `|>` können wir `modBy` zwischen seine beiden Argumente schreiben. -->

Der Modulkopf des Moduls `Seconds` exportiert zwar den Typ `Seconds` aber nicht seine Konstruktoren.
Auf diese Weise garantieren wir, dass Werte vom Typ `Seconds` nur mithilfe der Konstante `zero` und der Funktion `increase` erzeugt werden.
Wir erreichen dadurch eine **Datenkapselung (_Information Hiding_)**, wie sie auch aus anderen Programmiersprachen bekannt ist.

{% include callout-important.html content="
Das heißt, wir stellen den Nutzer*innen eine feste Schnittstelle zur Arbeit mit `Seconds` zur Verfügung und verhindern, dass auf die interne Darstellung zugegriffen wird.
" %}

Durch diese Abstraktion können wir die Implementierung später auch einfach ersetzen.
Zum Beispiel können wir die Uhr später relativ einfach auf eine Anzeige mit Minuten **und** Sekunden umstellen, indem wir den Datentyp `Seconds` durch einen Datentyp ersetzen, der beide Informationen hält.

Wir nutzen die Funktion `increase` nun wie folgt in unserer Uhr.

``` elm
update : Msg -> Model -> Model
update TickClock seconds =
    Seconds.increase seconds
```

Im Grunde könnten wir hier auch auf das _Pattern Matching_ verzichten und einen Unterstrich verwenden, da wir wissen, dass die einzige Nachricht, die wir erhalten können, die Nachricht `TickClock` ist.
Durch das _Pattern Matching_ gewährleisten wir aber, dass der Elm-Compiler sich beschwert, falls wir einen weiteren Konstruktor zum Typ `Msg` hinzufügen.
Ohne das *Pattern Matching* auf `TickClock` würde die Anwendung weiterhin kompilieren, wenn wir einen weiteren Konstruktor zu `Msg` hinzufügen.
Die Anwendung würde sich aber für diese neue Nachricht genau so verhalten wie für die Nachricht `TickClock`, was ggf. nicht das gewünschte Verhalten ist.

Als nächstes wollen wir die Uhr zeichnen.
Dazu verwenden wir die Funktion `rotate`, die wir im Abschnitt [Records](data-types.md#records) definiert haben.
Diese Funktion werden wir später nutzen, um den Wert des SVG-Attributes `transform` zu setzen.
Dabei geben wird einen Winkel in Grad und einen Punkt an und rotieren dann ein Objekt um den Winkel mit dem angegebenen Ursprung.

``` elm
type alias Point =
    { x : Float, y : Float }


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

Nun implementieren wir eine Funktion, die die aktuelle Sekundenzahl in Form einer Uhr anzeigt.

``` elm
view : Model -> Html msg
view model =
    viewClock model


viewClock : Seconds -> Html msg
viewClock seconds =
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
        [ viewClockBack center radius
        , viewClockHand center radius seconds
        ]


viewClockBack : Point -> Float -> Svg msg
viewClockBack center radius =
    circle
        [ cx (String.fromFloat center.x)
        , cy (String.fromFloat center.y)
        , r (String.fromFloat radius)
        , fill "#aaddf9"
        ]
        []


viewClockHand : Point -> Float -> Seconds -> Svg msg
viewClockHand center radius seconds =
    line
        [ x1 (String.fromFloat center.x)
        , y1 (String.fromFloat center.y)
        , x2 (String.fromFloat center.x)
        , y2 (String.fromFloat (center.y - radius))
        , stroke "#2c2f88"
        , strokeWidth "2"
        , transform (rotate { angle = Seconds.toDegrees seconds, origin = center })
        ]
        []
```

Die Funktion `toDegrees` ist wie folgt im Modul `Seconds` definiert und rechnet eine Sekundenzahl in einen Winkel einer Uhr um.

```elm
toDegrees : Seconds -> Float
toDegrees (Seconds seconds) =
    360 * toFloat seconds / 60
```

Um zu illustrieren, wie man Abonnements zeitweise aussetzt, wollen wir unsere Uhr um die Möglichkeit erweitern, sie anzuhalten und wieder zu starten.
Dazu erweitern wir erst einmal wie folgt unseren Datentyp `Msg`.

``` elm
type Msg
    = TickClock
    | StartPauseClock
```

Außerdem fügen wir einen Knopf zu unserer Anwendung hinzu, um die Uhr zu starten bzw. anzuhalten.

``` elm
viewClock : Int -> Html Msg
viewClock seconds =
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
            [ viewClockBack center radius
            , viewClockHand center radius seconds
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
        TickClock ->
            case model of
                Running seconds ->
                    Running (Seconds.increase seconds)

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
            viewClock seconds

        Paused seconds ->
            viewClock seconds
```

Unsere Implementierung ignoriert die Nachrichten, die von der `subscription` an die Anwendung geschickt werden, wenn wir im Zustand `Paused` sind.
Die Reaktionszeit der Uhr hängt dadurch davon ab, zu welchem Zeitpunkt des aktuellen Intervals wir die Uhr wieder starten.

{% include callout-important.html content="
Außerdem sollten wir die `Subscription` beenden, wenn wir sie gar nicht benötigen.
" %}

Das Feld `subscriptions` des Programms ist eine Funktion, die ein Modell als Argument erhält und eine `Subscription` liefert.
Die Konstante `Sub.none` liefert analog zu `Cmd.none` keine `Subscription`.
Wir können dadurch wie folgt die `Subscription` beenden, wenn die Uhr im Zustand `Paused` ist.

``` elm
subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Running _ ->
            Time.every 1000 (\_ -> TickClock)

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

{% include callout-important.html content="
Diese Funktion kann genutzt werden, um eine Liste von Abonnements zu einem Abonnement zusammenzufassen.
" %}

Auf diese Weise können wir in einer Anwendung über mehrere Ereignisse informiert werden.
Man kann über ein Abonnement zum Beispiel auf Tastendrücke reagieren.
Mithilfe der Funktion `batch` kann man dann zum Beispiel informiert werden, wenn ein Interval vergangen ist oder wenn eine Taste gedrückt wurde.

Wir wollen am Ende noch einmal den Aspekt aufgreifen, dass wir im besten Fall bei einer Programmiersprache die Regeln kennen sollten, nach denen Programme konstruiert werden.
So haben wir zum Beispiel gelernt, dass bei einem Lambda-Ausdruck nach dem `->` ein Ausdruck folgt.
Außerdem wissen wir, dass ein `case`-Ausdruck ein Ausdruck ist.
Daher können wir auch die folgende alternative Implementierung der Konstante `main` nutzen.

``` elm
main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( Seconds.zero, Cmd.none )
        , subscriptions =
            \model ->
                case model of
                    Running _ ->
                        Time.every 1000 (\_ -> TickClock)

                    Paused _ ->
                        Sub.none
        , view = view
        , update = \msg model -> ( update msg model, Cmd.none )
        }
```

Man kann darüber streiten, ob diese Definition übersichtlich ist bzw. ob es ggf. sinnvoll ist, Funktionen wie `view`, `update` und `subscriptions` auf _Top Level_ zu definieren, da Entwickler\*innen, die den Code einer Elm-Anwendung lesen, sich häufig anhand dieser bekannten Funktionen orientieren.
Wir sollten uns aber über die verschiedenen Optionen bewusst sein, um eine qualifizierte Einschätzung abgeben zu können.

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="higher-order.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <!-- <li class="nav-item nav-right"><a href="commands.html">weiter</a></li> -->
        <li class="nav-item nav-right"></li>
    </ul>
</div>
