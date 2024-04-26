---
layout: post
title: "Kommandos"
---

In diesem Kapitel wollen wir uns anschauen, wie man den Datentyp `Cmd` nutzt, den wir bisher ignoriert haben.
Wir haben zuvor bereits gelernt, dass Elm eine rein funktionale Programmiersprache ist und man daher
keine Seiteneffekte ausführen kann.
Einige Teile einer Frontend-Anwendung benötigen aber natürlich Seiteneffekte.
Als ein Beispiel für einen solchen Seiteneffekt wollen wir uns das Würfeln einer Zufallszahl anschauen.
Um Seiteneffekte in Elm ausführen zu können und dennoch eine referenziell transparente Anwendung zu behalten, wird die Durchführung von Seiteneffekten von der Elm-_Runtime_ übernommen.
Genauer gesagt, teilen wir Elm nur mit, dass wir einen Seiteneffekt durchführen möchten.
Elm führt dann diesen Seiteneffekt durch und informiert uns über das Ergebnis.
Auch die Kommandos sind wieder ein Beispiel für den deklarativen Ansatz, da man nur beschreibt, dass ein Seiteneffekt durchgeführt werden soll, man beschreibt aber nicht, wie dieser genau ausgeführt wird.

Zufall
------

Wir wollen eine Anwendung schreiben, mit der man einen Würfel werfen kann.
Zuerst installieren wir das Paket `elm/random`.
Als nächstes modellieren wir die möglichen Ergebnisse eines Würfels.

``` elm
type Side
    = One
    | Two
    | Three
    | Four
    | Five
    | Six
```

Als nächstes definieren wir ein Modell für unsere Anwendung.

``` elm
type alias Model =
    Maybe Side
```

Wir nutzen `Maybe`, da wir gern modellieren wollen, dass der Würfel noch nicht geworfen wurde.

Nun definieren wir einen initialen Zustand.
Initial haben wir kein Würfelergebnis, daher ist der initiale Zustand unserer Anwendung `Nothing`.

``` elm
init : Model
init =
    Nothing
```

Als nächstes definieren wir die Nachrichten, die unsere Anwendung verarbeiten kann.
Die Anwendung soll nur in der Lage sein, einen Würfel zu würfeln, daher benötigen wir nur eine einzige Nachricht.

``` elm
type Msg
    = RollDie
```

Mithilfe eines Knopfes können wir diese Nachricht an die Anwendung schicken.

``` elm
view : Model -> Html Msg
view model =
    div []
        [ case model of
              Nothing ->
                  text "Please roll the die!"

              Just side ->
                  text (toString side)
        , button [ onClick RollDie ] [ text "Roll" ]
        ]
```

Als nächstes benötigen wir die `update`-Funktion.
Diese liefert neben dem neuen Modell auch ein Kommando, das als nächstes ausgeführt werden soll.
Um dieses Kommando zu konstruieren, verwenden wir im Fall des Zufalls die vordefinierte Funktion

```elm
generate : (a -> msg) -> Generator a -> Cmd msg
```

aus dem Modul `Random`.
Diese Funktion nimmt einen Zufallsgenerator, eine Funktion, die das Ergebnis des Zufallsgenerators in eine Nachricht verpackt und liefert ein Kommando.
Wir benötigen also noch eine Nachricht und erweitern unseren Datentyp `Msg` wie folgt.

``` elm
type Msg
    = RollDie
    | RolledDie Side
```

Außerdem benötigen wir einen Generator, der zufällig eine Seite liefert.
Wir nutzen dafür die Funktion `uniform : a -> List a -> Generator a` aus dem Modul `Random`.

``` elm
die : Random.Generator Side
die =
    Random.uniform One [ Two, Three, Four, Five, Six ]
```

Die Funktion `uniform` erhält einen Wert und eine Liste von Werten und liefert mit gleicher Wahrscheinlichkeit den Wert oder eines der Elemente der Liste.
An sich könnte die Funktion auch nur eine Liste erhalten.
In diesem Fall könnten wir die Funktion aber mit einer leeren Liste aufrufen.
Wenn wir an `uniform` eine leere Liste übergeben, kann der Generator aber keinen Wert erzeugen, da wir ihm gar keinen möglichen Wert zur Verfügung gestellt haben.
Daher erhält `uniform` noch ein zusätzliches Argument, um zu gewährleisten, dass die Funktion immer mindestens einen möglichen Wert erhält.
Alternativ könnte man die Funktion `uniform` als Argument auch einen Listendatentyp nehmen, bei dem die Liste nicht leer sein kann.

Mithilfe des Generators, der gleichverteilt Würfelseiten liefern kann, können wir nun die Funktion `update` wie folgt definieren.

``` elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RollDie ->
            ( model, Random.generate RolledDie die )

        RolledDie side ->
            ( Just side, Cmd.none )
```

Wenn der Benutzer auf den Knopf drückt, erhält die Anwendung die Nachricht `Roll`.
In diesem Fall lassen wir das Modell einfach wie es ist und fordern die Laufzeitumgebung auf, einen zufälligen Wert mit unserem Generator zu erzeugen.
Wenn dieser Wert erzeugt wurde, wird die Funktion `update` wieder aufgerufen, dieses Mal aber mit der Nachricht `Rolled`.
Der Konstruktor enthält die Seite, die gewürfelt wurde.
Wenn wir diese Nachricht erhalten, ersetzen wir den alten Zustand durch unsere neue Würfelseite und geben an, dass wir kein Kommando ausführen wollen.

Zu guter Letzt müssen wir unsere Anwendung nur noch wie folgt zusammenbauen.
Da wir zur Verwendung von Kommandos die Funktion `Browser.element` verwenden müssen, müssen wir dem Record auch ein Feld `subscriptions` übergeben.
Da wir in dieser Anwendung nicht über Ereignisse informiert werden möchten, nutzen wir die Konstante `Sub.none`, um zu signalisieren, dass wir keine Abonnements nutzen möchten.

``` elm
main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( init, Cmd.none )
        , subscriptions = \_ -> Sub.none
        , view = view
        , update = update
        }
```

Das Modul `Random` stellt ähnliche Funktionen zur Verfügung wie das Modul `Json.Decode` für die Definition von `Decoder`n.
Zum Einen stellt das Modul `Random` die Funktion `map : (a -> b) -> Generator a -> Generator b` zur Verfügung.
Mithilfe dieser Funktion können wir die Ergebnisse eines `Generator`s abändern.
Nehmen wir an, wir benötigen einen Zufallsgenerator, der Zahlen liefert anstelle des Datentyps `Side`.
In diesem Fall können wir wie folgt einen Generator definieren.

``` elm
pips : Random.Generator Int
pips =
    let
        toPips side =
            case side of
                One ->
                    1

                Two ->
                    2

                Three ->
                    3

                Four ->
                    4

                Five ->
                    5

                Six ->
                    6
    in
    Random.map toPips die
```

Das Modul `Random` stellt außerdem eine Funktion

```elm
map2 : (a -> b -> c) -> Generator a -> Generator b -> Generator c
```

zur Verfügung, mit der wir zwei Generatoren zu einem Generator
kombinieren können.
Wir können zum Beispiel wie folgt einen Generator definieren, der zufällig zwei Würfel würfelt und die Summe der Augenzahlen liefert.

``` elm
dice : Random.Generator Int
dice =
    Random.map2 (+) pips pips
```

Die Schreibweise `(+)` ist im Endeffekt eine Kurzform von `\x y -> x + y`.
Wenn man einen Infixoperator mit Klammern umschließt, kann man den eigentlich infix verwendeten Operator präfix schreiben.
Zum Beispiel kann man statt `1 + 2` auch `(+) 1 2` schreiben.
Das heißt, statt `Random.map2 (\x y -> x + y) pips pips` können wir auch `Random.map2 (\x y -> (+) x y) pips pips` schreiben.
Mittels Eta-Reduktion können wir diesen Ausdruck dann zu `Random.map2 (+) pips pips` vereinfachen.

HTTP-Anfragen
-------------

Als Abschluss dieses Kapitels wollen wir uns noch anschauen, wie man HTTP-Anfragen in Elm durchführen kann.
Eine HTTP-Anfrage folgt dem gleichen Muster wie das Erzeugen eines zufälligen Wertes.
Wir teilen dem System mit, welche Anfrage wir stellen möchten und das System ruft die Funktion `update` auf, wenn die Anfrage erfolgreich abgeschlossen ist.
Im Unterschied zum Erzeugen eines Zufallswertes, kann in diesem Fall aber auch ein Fehler bei der Abarbeitung der Aufgabe auftreten.
Um eine HTTP-Anfrage zu senden, müssen wir zunächst mit dem folgenden Kommando eine Bibliothek installieren.

```console
elm install elm/http
```


### Grundlegendes Beispiel

Wir wollen eine einfache Anwendung entwickeln, die eine bestehende API anfragt.
Die Route <a href="https://api.isevenapi.xyz/api/iseven/{number}" class="uri">https://api.isevenapi.xyz/api/iseven/{number}</a>[^1] liefert für jede Zahl `number`, ob die Zahl gerade ist.
Für die Zahl `3` erhalten wir als Ergebnis zum Beispiel das folgende JSON-Objekt.

```json
{
  "ad" : "Buy isEvenCoin, the hottest new cryptocurrency!",
  "iseven" : false
}
```

Wir modellieren diese Struktur erst einmal auf Elm-Ebene und definieren eine Funktion, um diese Informationen anzuzeigen.

``` elm
type alias IsEvenInfo =
    { isEven : Bool
    , advertisement : String
    }


viewIsEvenInfo : IsEvenInfo -> Html msg
viewIsEvenInfo info =
    div []
        [ p []
            [ text
                ("This number is "
                    ++ (if info.isEven then
                            "even"

                        else
                            "not even"
                        )
                )
            ]
        , p [] [ text info.advertisement ]
        ]
```

Nachdem wir das Resultat eines Requests modelliert haben, wollen wir einen Request durchführen.
Die Funktion

```elm
get : { url : String, expect : Expect msg } -> Cmd msg
```

aus dem Modul `Http` kann genutzt werden, um ein Kommando zu erzeugen, das eine _get_-Anfrage durchführt.
Dazu wird eine URL und ein Wert vom Typ `Expect msg` angegeben, mit dem wir spezifizieren, welche Art von Ergebnis wir als Resultat von der Anfrage erwarten.
Das Modul `Http` stellt zum Beispiel die Funktion

```elm
expectJson : (Result Error a -> msg) -> Decoder a -> Expect msg
```

zur Verfügung, um JSON zu verarbeiten, das von einer Anfrage zurückgeliefert wird.
Dazu müssen wir zum einen einen `Decoder` angeben, der die JSON-Struktur in eine Elm-Datenstruktur umwandelt.
Außerdem müssen wir eine Funktion angeben, die das Resultat des Decoders in eine Nachricht umwandeln kann.
Hierbei ist allerdings zu beachten, dass die Anfrage auch fehlschlagen kann.
Daher muss die Funktion auch in der Lage sein, einen möglichen Fehler zu verarbeiten.

Wir definieren im Datentyp `Msg` einfach einen Konstruktor, der später als erstes Argument von `expectJson` genutzt wird.
Neben diesem Konstruktor fügen wir noch Nachrichten hinzu, um einen Zähler hoch- und runterzuzählen.
Die Anwendung wird für den Zähler später die API anfragen, um zu prüfen, ob die Zahl gerade ist.

``` elm
type Msg
    = ChangeCounter Orientation
    | ReceivedResponse (Result Http.Error IsEven)


type Orientation
    = Increase
    | Decrease
```

Wir definieren nun zuerst einen `Decoder`, um die JSON-Struktur, die wir vom Server erhalten, in den Record `IsEven` umzuwandeln.

``` elm
isEvenDecoder : Decoder IsEvenInfo
isEvenDecoder =
    Decode.map2 IsEvenInfo
        (Decode.field "iseven" Decode.bool)
        (Decode.field "ad" Decode.string)
```

Mithilfe des Konstruktors `ReceivedResponse` des Datentyps `Msg` können wir die folgende Funktion definieren, die eine Zahl erhält und ein Kommando liefert, das eine entsprechende Anfrage stellt.
Statt die URL string-basiert zusammenzusetzen, nutzen wir die Funktionen aus dem Paket `elm/url`.
Daher installieren wir dieses Paket zunächst mittels `elm install elm/url`.
Wir importieren dann das Modul `Url.Builder`.
Dieses Modul stellt eine Funktion `crossOrigin : String -> List String -> List QueryParameter -> String` zur Verfügung.
Mit dieser Funktion können wir eine URL bauen.
Das erste Argument der Funktion `crossOrigin` ist die Basis-URL der Anfrage.
Um solche Informationen zu speichern, legen wir ein Modul `Env` an.
In diesem Modul können wir später zum Beispiel auch Informationen wie API-Schlüssel hinterlegen.
Wir fügen dieses Modul nicht zur Versionskontrolle hinzu.
Auf diese Weise können wir später auf dem Produktiv-Server andere Daten für diese Komponenten verwenden als in unserer Entwicklungsumgebung.
Als weiteren Benefit erhalten wir durch die Nutzung eines Elm-Moduls einen Fehler vom Compiler, wenn die Datei nicht existiert.
Das heißt, es kann nicht passieren, dass unsere Anwendung abstürzt, da die entsprechende Konfigurationsdatei fehlt.

```elm
module Env exposing (baseURL)


baseURL : String
baseURL =
    "https://api.isevenapi.xyz"
```

In unserer Anwendung können wir nun wie folgt eine URL für unsere Anfrage konstruieren.

``` elm
isEvenCmd : Int -> Cmd Msg
isEvenCmd number =
    Http.get
        { url = Url.Builder.crossOrigin Env.baseURL [ "api", "iseven", String.fromInt number ] []
        , expect = Http.expectJson ReceivedResponse isEvenDecoder
        }
```

Wir nutzen zur Modellierung des internen Zustands unserer Anwendung den folgenden Datentyp.

``` elm
type alias Model =
    { number : Int
    , data : Data IsEvenInfo
    }
```

Der Datentyp `Data` wird dabei genutzt, um die verschiedenen Zustände beim Ausführen einer HTTP-Anfrage zu modellieren.

```elm
type Data value
    = Loading
    | Failure Http.Error
    | Success value
```

Für den Datentyp `Data` nutzen wir außerdem die folgende Funktion.

``` elm
fromResult : Result Http.Error a -> Data a
fromResult result =
    case result of
        Err e ->
            Failure e

        Ok x ->
            Success x
```

Die folgende Funktion aktualisiert das Modell, wenn die Anfrage ein Ergebnis geliefert hat.
Wenn eine der Aktionen `Increase` und `Decrease` durchgeführt wird, wird eine neue Anfrage gestellt.

``` elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeCounter orientation ->
            let newCounter = updateCounter orientation model.number
            in
            ( { model | number = newCounter, data = Loading }
            , isEvenCmd newCounter )

        ReceivedResponse result ->
            ( { model | data = Data.fromResult result }
            , Cmd.none )


updateCounter : Orientation -> Int -> Int
updateCounter orientation counter =
    case orientation of
        Decrease ->
            counter - 1

        Increase ->
            counter + 1
```

Zu guter Letzt müssen wir nur noch Funktionen schreiben, die abhängig vom aktuellen Zustand eine entsprechende HTML-Seite anzeigen.
Außerdem stellen wir Knöpfe für die verschiedenen Aktionen zur Verfügung.

``` elm
view : Model -> Html Msg
view model =
    div []
        [ div []
            [ button [ onClick (Counter Decrease) ] [ text "-" ]
            , text (String.fromInt model.number)
            , button [ onClick (Counter Increase) ] [ text "+" ]
            ]
        , viewData model.data
        ]


viewData : Data IsEvenInfo -> Html msg
viewData data =
    case data of
        Loading ->
            text "Loading ..."

        Success info ->
            viewIsEvenInfo info

        Failure error ->
            text ("The following error occurred:\n" ++ Debug.toString error)


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( { number = 0, data = Loading }, isEvenCmd 0 )
        , subscriptions = \_ -> Sub.none
        , view = view
        , update = update
        }
```

Die Funktion `viewData` nutzt einfachheitshalber hier die Funktion `Debug.toString`.
Diese Funktion kann einen beliebigen Elm-Wert in einen `String` umwandeln und ist eigentlich nur zum Debugging einer Anwendung gedacht.


### Weitere Aspekte

In diesem Abschnitt wollen wir noch ein paar Aspekte diskutieren, die über eine erste Verwendung einer HTTP-Anfrage hinausgehen.
Die Funktion `get` in der Bibliothek `elm/http` ist wie folgt implementiert.

```elm
get : { url : String, expect : Expect msg } -> Cmd msg
get r =
  request
    { method = "GET"
    , headers = []
    , url = r.url
    , body = emptyBody
    , expect = r.expect
    , timeout = Nothing
    , tracker = Nothing
    }
```

Das heißt, `get` ruft eine allgemeinere Funktion `request` auf, die weitere Informationen erhält.
Der Funktion `request` können wir zum Beispiel noch _Request Header_ übergeben.
Wir wollen an dieser Stelle das Feld `timeout` näher betrachten.
Der Wert `Nothing` besagt, dass wir keinen _Timeout_ für die Anfrage setzen wollen.
Das heißt, wir sind grundsätzlich bereit, beliebig lange auf das Ergebnis der Anfrage zu warten.
In vielen Fällen sind wir das aber nicht.
Zum einen kann eine Anfrage, die nicht beantwortet wird, die gesamte Anwendung lahmlegen, da der Zustandsautomat der Elm-Anwendung nicht in den nächsten Zustand wechseln kann.
Außerdem bekommen Nutzer\*innen schnell den Eindruck, dass die Anwendung nicht mehr korrekt funktioniert, wenn im Hintergrund auf das Ergebnis einer Anfrage gewartet wird und ansonsten nichts weiter passiert.
Daher ist es in den allermeisten Fällen besser, einen _Timeout_ zu setzen.
Das Feld `timeout` erwartet einen Wert vom Typ `Maybe Float`, bei dem wir die Zeit in Millisekunden angeben, bis die Anfrage abgebrochen wird.

Wir ersetzen daher unser Kommando durch die folgende Definition.

``` elm
isEvenCmd : Int -> Cmd Msg
isEvenCmd no =
    Http.request
        { method = "GET"
        , headers = []
        , url = Url.Builder.crossOrigin Env.baseURL [ "api", "iseven", String.fromInt no ] []
        , body = Http.emptyBody
        , expect = Http.expectJson ReceivedResponse isEvenDecoder
        , timeout = Just 5000
        , tracker = Nothing
        }
```

Das heißt, unsere Anfrage wird spätestens nach 5 Sekunden beendet.
Die Funktionalität unserer gesamten Anwendung basiert auf der Anfrage.
Daher stellen wir Nutzer\*innen die Möglichkeit zur Verfügung, die Anfrage zu wiederholen, indem wir einen entsprechenden Knopf anzeigen.
Da der Datentyp `Error`, den wir von einer fehlschlagenden Anfrage zurückerhalten, einfach ein algebraischer Datentyp ist, können wir den Fall, dass ein _Timeout_ aufgetreten ist, wie folgt gesondert behandeln.

```elm
viewData : Data IsEvenInfo -> Html msg
viewData data =
    case data of
        Loading ->
            text "Loading ..."

        Success info ->
            viewIsEvenInfo info

        Failure Timeout ->
            div []
                [ text "The request did not finish in time."
                , button [ onClick TryAgain ] [ text "Try again" ]
                ]

        Failure error ->
            text ("The following error occurred:\n" ++ Debug.toString error)
```

Wenn die Anfrage mit einem _Timeout_ fehlschlägt, bieten wir Nutzer\*innen an, die Anfrage zu wiederholen.
Um die Anfrage zu wiederholen, müssen wir noch den entsprechenden Fall zum Datentyp `Msg` hinzufügen und in der `update`-Funktion behandeln.

``` elm
type Msg
    = ChangeCounter Orientation
    | ReceivedResponse (Result Http.Error IsEven)
    | RetryRequest


type Orientation
    = Increase
    | Decrease


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeCounter orientation ->
            let newCounter = updateCounter orientation model.number
            in
            ( { model | number = newCounter, data = Loading }
            , isEvenCmd newCounter )

        ReceivedResponse result ->
            ( { model | data = Data.fromResult result }
            , Cmd.none )

        RetryRequest ->
            ( model
            , isEvenCmd model.number )
```

Wenn wir die Nachricht `RetryRequest` erhalten, behalten wir das bestehende Modell bei und führen noch einmal die Anfrage mit der aktuellen Zahl durch.


[^1]: <https://github.com/public-apis/public-apis#science--math>

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="higher-order.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="folds.html">weiter</a></li>
    </ul>
</div>
