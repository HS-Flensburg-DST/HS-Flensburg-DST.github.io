---
layout: post
title: "Kommandos"
---

In diesem Kapitel wollen wir uns anschauen, wie man den Datentyp `Cmd` nutzt, den wir bisher ignoriert haben.
Wir haben zuvor bereits gelernt, dass Elm eine rein funktionale Programmiersprache ist und man daher
keine Seiteneffekte ausführen kann.
Einige Teile einer Frontend-Anwendung benötigen aber natürlich Seiteneffekte.
Ein Beispiel für einen Seiteneffekt, der in einer Frontend-Anwendung ist wichtig ist, ist das Durchführen von HTTP-Anfragen.
Um Seiteneffekte in Elm ausführen zu können und dennoch eine referenziell transparente Anwendung zu behalten, wird die Durchführung von Seiteneffekten von der Elm\-_Runtime_ übernommen.
Genauer gesagt, teilen wir Elm nur mit, dass wir einen Seiteneffekt durchführen möchten.
Elm führt dann diesen Seiteneffekt durch und informiert uns über das Ergebnis.
Auch die Kommandos sind wieder ein Beispiel für den deklarativen Ansatz, da man nur beschreibt, dass ein Seiteneffekt durchgeführt werden soll, man beschreibt aber nicht, wie dieser genau ausgeführt wird.


HTTP-Anfragen
-------------

Um eine HTTP-Anfrage zu stellen, teilen wir dem System mit, welche Anfrage wir stellen möchten und das System ruft die Funktion `update` auf, wenn die Anfrage erfolgreich abgeschlossen ist.
Im Unterschied zum Erzeugen eines Zufallswertes, kann in diesem Fall aber auch ein Fehler bei der Abarbeitung der Aufgabe auftreten.
Um eine HTTP-Anfrage zu senden, müssen wir zunächst mit dem folgenden Kommando eine Bibliothek installieren.

```console
elm install elm/http
```

Wir wollen eine einfache Anwendung entwickeln, die eine bestehende API anfragt.
Die Route <a href="https://api.isevenapi.xyz/api/iseven/{number}" class="uri">https://api.isevenapi.xyz/api/iseven/{number}</a>[^1] liefert für jede Zahl `number`, die Information, ob `number` gerade ist oder nicht.
Für die Zahl `3` erhalten wir als Ergebnis zum Beispiel das folgende JSON-Objekt.

```json
{
  "ad" : "Buy isEvenCoin, the hottest new cryptocurrency!",
  "iseven" : false
}
```

Wir modellieren diese Struktur erst einmal auf Elm-Ebene und definieren eine Funktion, um diese Informationen anzuzeigen.
Da die Parität -- also ob eine Zahl gerade oder ungerade ist -- ein elementarer Bestandteil unserer Anwendung sein wird, nutzen wir für die Modellierung dieser Information einen selbstdefinierten Aufzählungstyp.
Obwohl der Umfang der Anwendung, die wir hier entwickeln, sehr gering ist, legen wir ein eigenes Modul für den Datentyp `Parity` an, um zu illustrieren, wie eine reale Anwendung modularisiert wird.
Wir legen ein Verzeichnis `Api` an, in dem wir Module speichern, die für die Kommunikation mit der Schnittstelle genutzt werden.
Bei der Kommunikation nutzen wir möglichst stark getypte Daten.
Zum Beispiel könnte es sein, dass eine Schnittstelle Daten in Form eines `String` zur Verfügung stellt, die wir zur Nutzung in unserer Anwendung in einen Aufzählungstyp überführen.

``` elm
module Api.Parity exposing (Parity(..), toString)


type Parity
    = Even
    | Odd


toString : Parity -> String
toString : parity =
    case parity of
        Even ->
            "gerade"

        Odd ->
            "ungerade"
```

Neben dem Datentyp `Parity` definieren wir noch einen Datentyp `ParityInfo`, der zusätzlich die Werbung zur Verfügung stellt.

```elm
module Api.ParityInfo exposing (ParityInfo)


type alias ParityInfo =
    { parity : Parity
    , advertisement : String
    }
```

Im Nächsten Schritt entwickeln wir die Logik zur Anzeige unserer Daten in der Anwendung.
Die folgende Funktion wird im Hauptmodul der Anwendung definiert.

```elm
viewParityInfo : ParityInfo -> Html msg
viewParityInfo info =
    div []
        [ p [] [ text ("Die Zahl ist " ++ Api.Parity.toString info.parity ++ ".") ]
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
Die Anwendung wird später für den aktuellen Wert des Zählers die API anfragen, um zu prüfen, ob die Zahl gerade ist oder nicht.

``` elm
type Msg
    = Number Change
    | ReceivedResult (Result Http.Error ParityInfo)


type Change
    = Increase
    | Decrease
```

Wir definieren nun zuerst einen `Decoder`, um die JSON-Struktur, die wir vom Server erhalten, in den Record `ParityInfo` umzuwandeln.
Dazu definieren wir die folgenden beiden `decoder` in den jeweiligen Modulen.

```elm
decoder : Decoder Parity
decoder =
    Decoder.map
        (\b ->
            if b then
                Even

            else
                Odd
        )
        Decoder.bool
```

``` elm
decoder : Decoder ParityInfo
decoder =
    Decoder.map2 ParityInfo
        (Decoder.field "iseven" Parity.decoder)
        (Decoder.field "ad" Decoder.string)
```

Als nächsten wollen wir ein Kommando definieren, das eine Anfrage an die API durchführt.
Statt die URL string-basiert zusammenzusetzen, nutzen wir die Funktionen aus dem Paket `elm/url`.
Daher installieren wir dieses Paket zunächst mithilfe des folgenden Kommandos.

```console
elm install elm/url
```

Wir importieren dann das Modul `Url.Builder`.
Dieses Modul stellt eine Funktion

```elm
crossOrigin : String -> List String -> List QueryParameter -> String
```

zur Verfügung.[^2]
Mit dieser Funktion können wir eine URL bauen.
Das erste Argument der Funktion `crossOrigin` ist die Basis-URL der Anfrage.
Um solche Informationen zu speichern, legen wir ein Modul `Api.Config` an.
In diesem Modul können wir später zum Beispiel auch Informationen wie API-Schlüssel hinterlegen.
In einem realen Projekt würden wir dieses Modul nicht zur Versionskontrolle hinzufügen.
Auf diese Weise können wir auf dem Produktiv-Server eine andere Konfiguration verwenden als in unserer Entwicklungsumgebung.
Als weiteren Benefit erhalten wir durch die Nutzung eines Elm-Moduls einen Fehler vom Compiler, wenn die Datei nicht existiert.
Das heißt, es kann nicht passieren, dass unsere Anwendung abstürzt, da die entsprechende Konfigurationsdatei fehlt.

```elm
module Api.Config exposing (baseURL)


baseURL : String
baseURL =
    "https://api.isevenapi.xyz/api"
```

Wir definieren das Kommando, das genutzt wird, um eine Anfrage durchzuführen in einem Modul `Api.ParityInfo`.
In diesem Modul kennen wir den Nachrichtendatentyp unserer Anwendung nicht.
Wir möchten an sich auch nicht, dass dieses Modul das Modul importiert, dass den Nachrichtentyp definiert, da wir dann eine Abhängigkeit zu diesem Modul einführen würden.
Daher übergeben wir an die Funktion `get` eine Funktion als Argument, die später dafür zuständig ist, die Daten in den Nachrichtendatentyp einzupacken.
Durch die Verwendung einer Funktion höherer Ordnung und von Polymorphismus erreichen wir also, dass das Modul `Api.ParityInfo` keine Abhängigkeit zum Nachrichtendatentyp hat.

``` elm
get : { number : Int, onResponse : Result Http.Error ParityInfo -> msg } -> Cmd msg
get { number, onResponse } =
    Http.get
        { url = Url.Builder.crossOrigin Api.Config.baseURL [ "iseven", String.fromInt number ] []
        , expect = Http.expectJson onResponse decoder
        }
```

{% include callout-important.html content="
Ein solches Vorgehen wird auch als **_Dependency Injection_** bezeichnet.
" %}

Bei einer _Dependency Injection_ wird einem Modul von außen eine Abhängigkeit zu einem anderen Modul injiziert.
In vielen imperativen Programmiersprachen werden aufwendige _Dependency Injection Frameworks_ genutzt, um eine Abhängigkeit auf ein anderes Modul im Nachhinein in ein Modul einzusetzen.
Ein ganz ähnliches Ergebnis lässt sich aber wie hier durch eine Funktion höherer Ordnung und Polymorphismus erreichen.

Wir nennen die oben definierte Funktion `get`, da sie das Kommando liefert, um eine GET-Anfrage durchzuführen.
Entsprechend würden wir eine Funktion `post` nennen, wenn sie das entsprechende Kommando für eine POST-Anfrage liefert.
Für GET-Anfragen, die eine Liste von Daten liefern, nutzen wir einen Namen wie `getAll`.
Falls die Anfrage nicht alle Daten liefert, sondern nur eine Teilmenge, können wir dies entsprechend in dem Suffix hinter `get` ausdrücken.

Wir nutzen zur Modellierung des internen Zustands unserer Anwendung den folgenden Datentyp.

``` elm
type alias Model =
    { number : Int
    , apiData : Api.Data ParityInfo
    }
```

Der Datentyp `Api.Data` wird dabei genutzt, um die verschiedenen Zustände beim Ausführen einer HTTP-Anfrage zu modellieren.
Der Datentyp wird hier in ein Modul `Api.Data` geschrieben.

```elm
type Data value
    = Loading
    | Failure Http.Error
    | Success value
```

Für den Datentyp `Data` nutzen wir außerdem die folgende Funktion.

``` elm
dataFromResult : Result Http.Error a -> Data a
dataFromResult result =
    case result of
        Err error ->
            Failure error

        Ok value ->
            Success value
```

Nun haben wir alle Komponenten zusammen, um die Funktion `update` für unsere Anwendung zu definieren.
Im Fall `Number` führen wir eine Anfrage an die API durch.
Im Fall `ReceivedResult` aktualisieren wir unser Modell mit den Daten der API.

``` elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Number change ->
            let newNumber = updateNumber change model.number
            in
            ( { model | number = newNumber, apiData = Api.Loading }
            , Api.ParityInfo.get { number = newNumber, onResponse = ReceivedResult } )

        ReceivedResult result ->
            ( { model | apiData = Api.dataFromResult result }
            , Cmd.none )


updateNumber : Change -> Int -> Int
updateNumber change number =
    case change of
        Decrease ->
            number - 1

        Increase ->
            number + 1
```

Zu guter Letzt müssen wir nur noch eine Funktion schreiben, die abhängig vom aktuellen Zustand eine entsprechende HTML-Seite erzeugt.
Außerdem stellen wir Knöpfe für die verschiedenen Aktionen zur Verfügung.

``` elm
view : Model -> Html Msg
view { number, apiData } =
    div []
        [ div []
            [ button [ onClick (Number Decrease) ] [ text "-" ]
            , text (String.fromInt number)
            , button [ onClick (Number Increase) ] [ text "+" ]
            ]
        , viewApiData apiData
        ]


viewApiData : Api.Data ParityInfo -> Html msg
viewApiData apiData =
    case apiData of
        Api.Loading ->
            text "Lade Daten ..."

        Api.Success info ->
            viewParityInfo info

        Api.Failure error ->
            text ("Der folgende Fehler ist aufgetreten:\n" ++ Debug.toString error)


main : Program () Model Msg
main =
    Browser.element
        { init = \() -> ( { number = 0, apiData = Api.Loading }
                       , Api.ParityInfo.get { number = 0, onResponse = ReceivedResult } )
        , subscriptions = \_ -> Sub.none
        , view = view
        , update = update
        }
```

Die Funktion `viewApiData` nutzt zur Vereinfachung die Funktion `Debug.toString`.

{% include callout-important.html content="
Die Funktion `Debug.toString` kann einen beliebigen Elm-Wert in einen `String` umwandeln und ist eigentlich nur zum Debugging einer Anwendung gedacht.
" %}

Diese Funktion sollte in einer fertigen Anwendung nicht genutzt werden.
Wir nutzen in dieser Anwendung auch die Möglichkeit, direkt beim Start der Anwendung ein Kommando durchzuführen.
Zu diesem Zweck liefert die Funktion `init` in der zweiten Komponente des Paares ein Kommando für eine entsprechende HTTP-Anfrage.


<!-- ### Weitere Aspekte

In diesem Abschnitt wollen wir noch ein paar Aspekte diskutieren, die über eine erste Verwendung einer HTTP-Anfrage hinausgehen.
Die Funktion `get` in der Bibliothek `elm/http` ist wie folgt implementiert.

```elm
get : { url : String, expect : Expect msg } -> Cmd msg
get { url, expect } =
    request
        { method = "GET"
        , headers = []
        , url = url
        , body = emptyBody
        , expect = expect
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

Wir ersetzen daher die Implementierung der Funktion `get` im Modul `Api.ParityInfo` durch die folgende Implementierung.

``` elm
get : { number : Int, onResponse : ParityInfo -> msg } -> Cmd msg
get { number, onResponse } =
    Http.request
        { method = "GET"
        , headers = []
        , url = Url.Builder.crossOrigin Api.Config.baseURL [ "iseven", String.fromInt number ] []
        , body = Http.emptyBody
        , expect = Http.expectJson onResponse decoder
        , timeout = Just 5000
        , tracker = Nothing
        }
```

Das heißt, unsere Anfrage wird spätestens nach 5 Sekunden beendet.
Die Funktionalität unserer gesamten Anwendung basiert auf der Anfrage.
Daher stellen wir Nutzer\*innen die Möglichkeit zur Verfügung, die Anfrage zu wiederholen, indem wir einen entsprechenden Knopf anzeigen.
Da der Datentyp `Error`, den wir von einer fehlschlagenden Anfrage zurückerhalten, einfach ein algebraischer Datentyp ist, können wir den Fall, dass ein _Timeout_ aufgetreten ist, wie folgt gesondert behandeln.

```elm
viewApiData : Api.Data ParityInfo -> Html msg
viewApiData apiData =
    case apiData of
        Api.Loading ->
            text "Lade Daten ..."

        Api.Success info ->
            viewParityInfo info

        Api.Failure Http.Timeout ->
            div []
                [ text "Die Anfrage benötigte zu viel Zeit, vermutlich ist die Internetverbindung schlecht."
                , button [ onClick RetryRequest ] [ text "Noch einmal probieren" ]
                ]

        Api.Failure error ->
            text ("Der folgende Fehler ist aufgetreten:\n" ++ Debug.toString error)
```

Wenn die Anfrage mit einem _Timeout_ fehlschlägt, bieten wir Nutzer\*innen an, die Anfrage zu wiederholen.
Um die Anfrage zu wiederholen, müssen wir noch den entsprechenden Fall zum Datentyp `Msg` hinzufügen und in der `update`-Funktion behandeln.

``` elm
type Msg
    = Number Change
    | ReceivedResult (Result Http.Error ParityInfo)
    | RetryRequest


type Change
    = Increase
    | Decrease


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Number change ->
            let newNumber = updateNumber change model.number
            in
            ( { model | number = newNumber, apiData = Api.Loading }
            , Api.ParityInfo.get { number = newNumber, onResponse = ReceivedResult } )

        ReceivedResult result ->
            ( { model | apiData = Api.dataFromResult result }
            , Cmd.none )

        RetryRequest ->
            ( { model | apiData = Api.Loading }
            , Api.ParityInfo.get { number = model.number, onResponse = ReceivedResult } )
```

Wenn wir die Nachricht `RetryRequest` erhalten, behalten wir den aktuellen Zahlenwert bei und führen noch einmal die Anfrage mit der aktuellen Zahl durch.
Wir setzen aber den Eintrag `responseData` auf `Loading`, um anzuzeigen, dass wir eine HTTP-Anfrage durchführen.

In unserem Beispiel führen wir zu Anfang direkt eine HTTP-Anfrage durch.
Es gibt aber zahlreiche Anwendungsfälle, in denen die Anfrage erst durch die Aktion von Nutzer\*innen ausgelöst werden.
In diesen Fällen ist es sinnvoll, zum Datentyp `ResponseData` einen Fall `NotStarted` hinzuzufügen.
Dieser Fall wird verwendet, um zu signalisieren, dass noch keine Anfrage durchgeführt wurde. -->

<!-- Zu guter Letzt wollen wir noch zwei Varianten illustrieren, mit denen mehrere HTTP-Anfragen ausgeführt werden können.
Zwei HTTP-Anfragen können dabei entweder sequentiell, also nacheinander, oder parallel ausgeführt werden.
Zuerst betrachten wir die Möglichkeit, zwei HTTP-Anfragen parallel zu bearbeiten. -->


Zufall
------

Als zweiten Anwendungsfall von Kommandos wollen wir die Generierung von Zufallszahlen anschauen.
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
Diese Funktion nimmt einen Zufallsgenerator, eine Funktion, die das Ergebnis des Zufallsgenerators in eine Nachricht verpackt, und liefert ein Kommando.
Wir benötigen also noch eine weitere Nachricht und erweitern daher unseren Datentyp `Msg` wie folgt.

``` elm
type Msg
    = RollDie
    | Rolled Side
```

Außerdem benötigen wir einen `Generator`, der zufällig eine Würfelseite liefert.
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
Alternativ hätte man der Funktion `uniform` auch nur eine nicht-leeren Liste übergeben können.

Mithilfe des Generators, der gleichverteilt Würfelseiten liefern kann, können wir nun die Funktion `update` wie folgt definieren.

``` elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RollDie ->
            ( model, Random.generate Rolled die )

        Rolled side ->
            ( Just side, Cmd.none )
```

Wenn der Benutzer auf den Knopf drückt, erhält die Anwendung die Nachricht `RollDie`.
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
        { init = \() -> ( init, Cmd.none )
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

{% include callout-important.html content="
Wenn man einen Infixoperator mit Klammern umschließt, kann man den eigentlich infix verwendeten Operator präfix schreiben.
" %}

Zum Beispiel kann man statt `1 + 2` auch `(+) 1 2` schreiben.
Das heißt, statt `Random.map2 (\x y -> x + y) pips pips` können wir auch `Random.map2 (\x y -> (+) x y) pips pips` schreiben.
Mittels zwei Anwendungen von Eta-Reduktion können wir diesen Ausdruck dann zu `Random.map2 (+) pips pips` vereinfachen.

[^1]: <https://github.com/public-apis/public-apis#science--math>

[^2]: Das Modul `Url.Builder` stellt auch Funktionen `string : String -> String -> QueryParameter` und `int : String -> Int -> QueryParameter` zur Verfügung, mit denen `QueryParameter` gebaut werden können.

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="json.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="structure.html">weiter</a></li>
    </ul>
</div>
