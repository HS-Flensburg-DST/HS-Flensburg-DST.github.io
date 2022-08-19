---
layout: post
title: "Kommandos"
---

In diesem Kapitel wollen wir uns anschauen, wie man den Datentyp `Cmd`
nutzt, den wir bisher ignoriert haben. Wir haben zuvor bereits gelernt,
dass Elm eine rein funktionale Programmiersprache ist und man daher
keine Seiteneffekte auführen kann. Einige Teile einer Frontend-Anwendung
benötigen aber natürlich Seiteneffekte. Als ein Beispiel für einen
solchen Seiteneffekt wollen wir uns das Würfeln einer Zufallszahl
anschauen. Um Seiteneffekte in Elm ausführen zu können und dennoch eine
referenziell transparente Anwendung zu behalten, wird die Durchführung
von Seiteneffekten von der Elm-Runtime übernommen. Genauer gesagt,
teilen wir Elm nur mit, dass wir einen Seiteneffekt durchführen möchten.
Elm führt dann diesen Seiteneffekt durch und informiert uns über das
Ergebnis. Auch die Kommandos sind wieder ein Beispiel für den
deklarativen Ansatz, da man nur beschreibt, dass ein Seiteneffekt
durchgeführt werden soll, man beschreibt aber nicht, wie dieser genau
ausgeführt wird.

Zufall
------

Wir wollen eine Anwendung schreiben, mit der man einen Würfel werfen
kann. Zuerst installieren wir das Paket `elm/random`. Als nächstes
modellieren wir die möglichen Ergebnisse eines Würfels.

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

Wir nutzen `Maybe`, da wir gern modellieren wollen, dass der Würfel noch
nicht geworfen wurde.

Nun definieren wir einen initialen Zustand. Neben dem Modell, können wir
auch ein Kommando angeben, das beim Start der Anwendung ausgeführt
werden soll. Das Modul `Cmd` stellt eine Konstante `none` zur Verfügung,
die angibt, dass kein Kommando durchgeführt werden soll.

``` elm
init : Model
init =
    Nothing
```

Als nächstes definieren wir die Nachrichten, die unsere Anwendung
verarbeiten kann. Die Anwendung soll nur in der Lage sein einen Würfel
zu würfeln, daher benötigen wir nur eine einzige Nachricht.

``` elm
type Msg
    = Roll
```

Mit Hilfe eines Buttons können wir diese Nachricht an die Anwendung
schicken.

``` elm
view : Model -> Html Msg
view model =
    div []
        [ case model of
              Nothing ->
                  "Please roll the die!"

              Just side ->
                  text (toString model)
        , button [ onClick Roll ] [ text "Roll" ]
        ]
```

Als nächstes benötigen wir die `update`-Funktion. Diese liefert neben
dem neuen Modell auch ein Kommando, das als nächstes ausgeführt werden
soll. Um dieses Kommando zu konstruieren, verwenden wir im Fall des
Zufalls die vordefinierte Funktion

`generate : (a -> msg) -> Generator a -> Cmd msg`

aus dem Modul `Random`. Diese Funktion nimmt einen Zufallsgenerator,
eine Funktion, die das Ergebnis des Zufallsgenerators in eine Nachricht
verpackt und liefert ein Kommando. Wir benötigen also noch eine
Nachricht und erweitern unseren Datentyp `Msg` wie folgt.

``` elm
type Msg
    = Roll
    | Rolled Side
```

Außerdem benötigen wir einen Generator, der zufällig eine Seite liefert.
Wir nutzen dafür die Funktion `uniform : a -> List a -> Generator a` aus
dem Modul `Random`.

``` elm
die : Random.Generator Side
die =
    Random.uniform One [ Two, Three, Four, Five, Six ]
```

Die Funktion `uniform` erhält einen Wert und eine Liste von Werten und
liefert mit gleicher Verteilung den Wert oder eines der Elemente der
Liste. An sich könnte die Funktion auch nur eine Liste erhalten. In
diesem Fall könnten wir die Funktion aber mit einer leeren Liste
aufrufen. Daher erhält `uniform` noch ein zusätzliches Argument, um zu
gewährleisten, dass die Funktion immer mindestens ein Argument erhält.
Alternativ könnte man die Funktion `uniform` als Argument auch einen
Listendatentyp nehmen, bei dem die Liste nicht leer sein kann.

Mit Hilfe des Generators, der gleichverteilt Würfelseiten liefern kann,
können nun die Funktion `update` wie folgt definieren.

``` elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Roll ->
            ( model, Random.generate Rolled die )

        Rolled side ->
            ( Just side, Cmd.none )
```

Wenn der Benutzer auf den Button klickt, erhalten wir die Nachricht
`Roll`. In diesem Fall lassen wir das Modell einfach wie es ist und
fordern die Laufzeitumgebung auf, einen zufälligen Wert mit unserem
Generator zu erzeugen. Wenn dieser Wert erzeugt wurde, wird die Funktion
`update` wieder aufgerufen, dieses Mal aber mit der Nachricht `Rolled`.
Der Konstruktor enthält die Seite, die gewürfelt wurde. Wenn wir diese
Nachricht erhalten, ersetzen wir den alten Zustand durch unsere neue
Würfelseite und geben an, dass wir kein Kommando ausführen wollen.

Zu guter Letzt müssen wir unsere Anwendung nur noch wie folgt
zusammenbauen. Da wir zur Verwendung von Komandos die Funktion
`Browser.element` verwenden müssen, müssen wir dem Record auch ein Feld
`subscriptions` übergeben. Da wir in dieser Anwendung nicht über
Ereignisse informiert werden möchten, nutzen wir die Konstante
`Sub.none`, um zu signalisieren, dass wir keine Abonnements nutzen
möchten.

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

Das Modul `Random` stellt ähnliche Funktionen zur Verfügung wie das
Modul `Json.Decode` für die Definition von `Decoder`n. Zum Einen stellt
das Modul `Random` die Funktion
`map : (a -> b) -> Generator a -> Generator b` zur Verfügung. Mit Hilfe
dieser Funktion können wir die Ergebnisse eines `Generator` abändern.
Nehmen wir an, wir benötigen einen Zufallsgenerator, der Zahlen liefert
an Stelle des Datentyps `Side`. In diesem Fall können wir wie folgt
einen Generator definieren.

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

`map2 : (a -> b -> c) -> Generator a -> Generator b -> Generator c`

zur Verfügung, mit der wir zwei Generatoren zu einem Generator
kombinieren können. Wir können zum Beispiel wie folgt einen Generator
definieren, der zufällig zwei Würfel würfelt und die Summe der
Augenzahlen liefert.

``` elm
dice : Random.Generator Int
dice =
    Random.map2 (+) pips pips
```

Die Schreibweise `(+)` ist im Endeffekt eine Kurzform von
`\x y -> x + y`. Wenn man einen Infixoperator mit Klammern umschließt,
kann man den eigentlich infix verwendeten Operator präfix schreiben. Zum
Beispiel kann man statt `1 + 2` auch `(+) 1 2` schreiben. Das heißt,
statt `Random.map2 (\x y -> x + y) pips pips` können wir auch
`Random.map2 (\x y -> (+) x y) pips pips` schreiben. Mittels
Eta-Reduktion können wir diesen Ausdruck dann zu
`Random.map2 (+) pips pips` vereinfachen.

HTTP-Anfragen
-------------

Als Abschluss dieses Kapitels wollen wir uns noch anschauen, wie man
HTTP-Anfragen in Elm durchführen kann. Eine HTTP-Anfrage folgt dem
gleichen Muster wie das Erzeugen eines zufälligen Wertes. Wir teilen dem
System mit, welche Anfrage wir stellen möchten und das System ruft die
Funktion `update` auf, wenn die Anfrage erfolgreich abgeschlossen ist.
Im Unterschied zum Erzeugen eines Zufallswertes, kann in diesem Fall
aber auch ein Fehler bei der Abarbeitung der Aufgabe auftreten. Um einen
HTTP-Anfrage zu senden, müssen wir zunächst mit dem folgenden Kommando
eine Bibliothek installieren.

    elm install elm/http

Wir wollen eine einfache Anwendung entwickeln, die eine bestehende API
anfragt. Die Route
<a href="https://api.isevenapi.xyz/api/iseven/{number}"
class="uri">https://api.isevenapi.xyz/api/iseven/{number}</a>[1] liefert
für jede Zahl `number`, ob die Zahl gerade ist. Für die Zahl `3`
erhalten wir als Ergebnis zum Beispiel das folgende JSON-Objekt.

    {
      "ad" : "Buy isEvenCoin, the hottest new cryptocurrency!",
      "iseven": false
    }

Wir modellieren diese Struktur erst einmal auf Elm-Ebene und definieren
eine Funktion, um diese Informationen anzuzeigen.

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

Nachdem wir das Resultat eines Requests modelliert haben, wollen wir
einen Request durchführen. Die Funktion

`get : { url : String, expect : Expect msg } -> Cmd msg`

aus dem Modul `Http` kann genutzt werden, um ein Kommando zu erzeugen,
das eine *get*-Anfrage durchführt. Dazu wird eine URL und ein Wert vom
Typ `Expect msg` angegeben, mit dem wir spezifizieren, welche Art von
Ergebnis wir als Resultat von der Anfrage erwarten. Das Modul `Http`
stellt zum Beispiel die Funktion

`expectJson : (Result Error a -> msg) -> Decoder a -> Expect msg`

zur Verfügung, um JSON zu verarbeiten, das von einer Anfrage
zurückgeliefert wird. Dazu müssen wir zum einen einen `Decoder` angeben,
der die JSON-Struktur in eine Elm-Datenstruktur umwandelt. Außerdem
müssen wir eine Funktion angeben, die das Resultat des Decoders in eine
Nachricht umwandeln kann. Hierbei ist allerdings zu beachten, dass die
Anfrage auch fehlschlagen kann. Daher muss die Funktion auch in der Lage
sein, einen möglichen Fehler zu verarbeiten.

Wir definieren im Datentyp `Msg` einfach einen Konstruktor, der später
als erstes Argument von `expectJson` genutzt wird. Nebem diesem
Konstruktor fügen wir noch Nachrichten hinzu, um den Zähler hoch- und
runterzuzählen.

``` elm
type Msg
    = Increase
    | Decrease
    | Response (Result Http.Error IsEven)
```

Wir definieren nun zuerst einen Decoder, um die JSON-Struktur, die wir
vom Server erhalten, in den Record `IsEven` umzuwandeln.

``` elm
isEvenDecoder : Decoder IsEvenInfo
isEvenDecoder =
    Decode.map2 IsEvenInfo
        (Decode.field "iseven" Decode.bool)
        (Decode.field "ad" Decode.string)
```

Mit Hilfe des Konstruktors `Request` können wir die folgende Funktion
definieren, die eine Zahl erhält und ein Kommando liefert, das eine
entsprechende Anfrage stellt.

``` elm
getCmd : Int -> Cmd Msg
getCmd no =
    Http.get
        { url = "https://api.isevenapi.xyz/api/iseven/" ++ String.fromInt no
        , expect = Http.expectJson Response isEvenDecoder
        }
```

Wir nutzen zur Modellierung des internen Zustands unserer Anwendung die
folgenden Datentypen.

``` elm
type alias Model =
    { number : Int
    , data : Data IsEvenInfo
    }


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

Die folgende Funktion aktualisiert das Modell, wenn die Anfrage ein
Ergebnis geliefert hat. Wenn eine der Aktionen `Increase` und `Decrease`
durchgeführt wird, wird eine neue Anfrage gestellt.

``` elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Decrease ->
            updateNumber (model.number - 1) model

        Increase ->
            updateNumber (model.number + 1) model

        Response result ->
            ( { model | data = Data.fromResult result }, Cmd.none )


updateNumber : Int -> Model -> ( Model, Cmd Msg )
updateNumber number model =
    ( { model | number = number, data = Loading }, getCmd number )
```

Zu guter letzt müssen wir nur noch Funktionen schreiben, die abhängig
vom aktuellen Zustand eine entsprechende HTML-Seite anzeugen. Außerdem
stellen wir Knöpfe für die verschiedenen Aktionen zur Verfügung.

``` elm
view : Model -> Html Msg
view model =
    div []
        [ div []
            [ button [ onClick Decrease ] [ text "-" ]
            , text (String.fromInt model.number)
            , button [ onClick Increase ] [ text "+" ]
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
            text ("The following error occured:\n" ++ Debug.toString error)


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( { number = 0, response = Loading }, getCmd 0 )
        , subscriptions = \_ -> Sub.none
        , view = view
        , update = update
        }
```

Die Funktion `viewData` nutzt einfachheitshalber hier die Funktion
`Debug.toString`. Diese Funktion kann einen beliebigen Elm-Wert in einen
`String` umwandeln und ist eigentlich nur zum Debugging einer Anwendung
gedacht.

[1] <https://github.com/public-apis/public-apis>

<div style="display:table;width:100%">
    <ul style="display:table-row;list-style:none">
        <li style="display:table-cell;width:33%;text-align:left"><a href="subscriptions.html">zurück</a></li>
        <li style="display:table-cell;width:33%;text-align:center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li style="display:table-cell;width:33%;text-align:right"><a href="abstractions.html">weiter</a></li>
    </ul>
</div>