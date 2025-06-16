---
layout: post
title: "Umgang mit Fehlern"
---

In diesem Kapitel wollen wir einen Blick darauf werfen, wie wir in einer Anwendung mit Fehlern umgehen sollten.


## Fehlerzustände in der MVU-Architektur

Zuerst wollen wir uns damit beschäftigen, wie wir damit umgehen, wenn `update` mit einer Kombination aus `Msg` und `Model` aufgerufen wird, die nicht erlaubt ist.
Im Kapitel [_Impossible States_](design.md#impossible-states) haben wir gelernt, dass man durch die Modellierung des Datentyps `Model` versuchen sollte, Zustände auszuschließen, die invalide sind.
In Elm ist es aber leider nicht möglich, bestimmte Kombinationen aus `Model` und `Msg` auszuschließen, daher müssen wir uns um solche unerlaubten Zustände in `update` kümmern.
Wir betrachten noch einmal das Beispiel aus dem Abschnitt [_Impossible States_](design.md#impossible-states).
Dort haben wir die folgende `update`-Funktion implementiert

```elm
type Model
    = EmptyCart
    | ActiveCart ActiveShoppingCart
    | PaidCart PaidShoppingCart


type alias ActiveShoppingCart =
    { item : Item
    , items : List Item
    }


type alias PaidShoppingCart =
    { item : Item
    , items : List Item
    , payment : Float
    }


type Msg
    = AddItem Item
    | PayCart Float


update : Model -> Msg -> Model
update model msg =
    case msg of
        AddItem newItem ->
            case model of
                EmptyCart ->
                    ActiveCart { item = newItem, items = [] }

                ActiveCart { item, items } ->
                    ActiveCart { item = newItem, items = item :: items }

                PaidCart _ ->
                    model

        PayCart payment ->
            case model of
                EmptyCart ->
                    model

                ActiveCart { item, items } ->
                    PaidCart { item = item, items = items, payment = payment }

                PaidCart _ ->
                    model
```

Die Funktion `update` sollte zum Beispiel nie mit der Nachricht `AddItem` im Zustand `PaidCart` aufgerufen werden.
Bisher haben wir solche fehlerhaften Kombinationen einfach ignoriert.
In einer produktiven Anwendung möchten wir aber gern über solche Zustände informiert werden, um den Fehler beheben zu können.
Zu diesem Zweck wollen wir die Information über den fehlerhaften Zustand an einen Logging-Server schicken.

Wir gehen dazu davon aus, dass das Modul `Api.Logging` eine Funktion

```elm
log : { msg : String, onResponse : msg } -> Cmd msg
```

zur Verfügung stellt, die eine Nachricht an den Logging-Server schickt.
Außerdem gehen wir davon aus, dass es eine Funktion

```elm
errorMessage : Msg -> Model -> String
```

gibt, die in der Lage ist, aus einer Nachricht und dem aktuellen Modellzustand einen `String` zu erzeugen, den wir nutzen können, um den Zustand der Anwendung später aus den Log-Nachrichten zu rekonstruieren.

Falls die HTTP-Anfrage an den Logging-Server fehlschlägt, bleibt uns leider nichts anderes übrig, als diese Information zu verwerfen, da die einzige Alternative wäre, einen weiteren Logging-Server für Probleme mit dem ersten Logging-Server zur Verfügung zu stellen.
Eine HTTP-Anfrage in Elm schickt aber immer eine Nachricht an die `update`-Funktion.
Daher fügen wir zu unserem Datentyp `Msg` einen Konstruktor `LoggedMessage` hinzu, der für die Antwort vom Logging-Server verwendet und in der `update`-Funktion ignoriert wird.

```elm
type Msg
    = AddItem Item
    | Pay Float
    | LoggedMessage


update : Model -> Msg -> ( Model, Cmd Msg)
update model msg =
    case msg of
        AddItem newItem ->
            case model of
                EmptyCart ->
                    ( ActiveCart { item = newItem, items = [] }
                    , Cmd.none )

                ActiveCart { item, items } ->
                    ( ActiveCart { item = newItem, items = item :: items }
                    , Cmd.none )
        
                PaidCart _ ->
                    ( model
                    , Api.Logging.log { msg = errorMessage msg model, onResponse = LoggedMessage } )

        PayCart payment ->
            case model of
                EmptyCart ->
                    ( model
                    , Api.Logging.log { msg = errorMessage msg model, onResponse = LoggedMessage } )

                ActiveCart { item, items } ->
                    ( PaidCart { item = item, items = items, payment = payment }
                    , Cmd.none )

                PaidCart _ ->
                    ( model
                    , Api.Logging.log { msg = errorMessage msg model, onResponse = LoggedMessage } )

        LoggedMessage ->
            ( model
            , Cmd.none )
```

In den Fällen, in denen Nutzer\*innen durch eine Aktion die Nachricht an die `update`-Funktion ausgelöst hat, sollten wir den Nutzer\*innen auch eine Rückmeldung geben, dass die Aktion nicht erfolgreich war.
Wenn die Nachricht `PayCart` zum Beispiel durch einen Knopf angestoßen wird, sollten wir in den Zuständen `EmptyCart` und `PaidCart` Nutzer\*innen die Information geben, dass ein interner Fehler aufgetreten ist und die Aktion leider nicht durchgeführt werden kann.
Ansonsten entsteht schnell Verwirrung, warum die Anwendung auf eine Aktion wie einen Knopfdruck nicht reagiert.
Um dieses Verhalten zu implementieren, können wir zum Beispiel eine Fehlermeldung in Form eines _Notification Banners_ anzeigen.


## _Code Smell_ in der Fehlerbehandlung

An dieser Stelle wird ein _Code Smell_[^1] vorgestellt, der bei Anfänger\*innen in der funktionalen Programmierung häufig auftritt.
Wir haben im Kapitel [Polymorphismus](polymorphism.md) gelernt, dass man einen fehlenden Wert in der funktionalen Programmierung durch den Datentyp `Maybe` modellieren sollte.
Zum Beispiel könnte es sein, dass unser Modell einen Wert vom Typ `Maybe Int` enthält.
Wenn dieser Wert nun benötigt wird, tendieren viele Anfänger\*innen dazu, die Funktion `Maybe.withDefault` (oder eine entsprechende Logik mittels _Pattern Matching_) zu nutzen, um auf jeden Fall einen Wert zur Verfügung zu haben.
Einen fehlenden Wert durch einen _Default_-Wert zu ersetzen ist aber nur in wenigen Fällen sinnvoll.
Wir wollen an dieser Stelle ein paar Klassen von Fällen diskutieren, in denen wir ggf. mit einem `Maybe`-Datentyp arbeiten.

### Fehlerhafte Nutzereingabe

Es kann vorkommen, dass die Eingabe von Nutzer\*innen nicht den Erwartungen entspricht.
Dieser Fall tritt vor allem auf, wenn Eingaben über ein Textfeld getätigt werden können.
Falls die Eingabe nicht den Anforderungen entspricht, sollte ein erklärender Fehler angezeigt und zu einer erneuten Eingabe aufgefordert werden.
Das heißt, die Information, dass ein Wert nicht vorhanden ist, sollte bis zur Nutzerschnittstelle propagiert werden.
Somit sollte der `Maybe`-Wert nicht verworfen, sondern bis zur `view`-Funktion propagiert werden.

Der folgende Ausschnitt aus einer Elm-Anwendung illustriert ein Beispiel für den Umgang mit einer fehlerhaften Nutzereingabe.

{% include callout-important.html content="
Dieses Beispiel illustriert einen _Code Smell_.
Die Funktion `Maybe.withDefault` sollte nicht auf diese Weise in einer Anwendung verwendet werden.
" %}

```elm
type alias Model =
    { chosenNumber : Float }


type Msg
    = UpdateInput String


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateInput input ->
            { chosenNumber = String.toFloat input |> Maybe.withDefault 0.0 }
```

Hier wird die Information, dass die Eingabe keine Zahl war einfach verworfen und durch einen _Default_-Wert ersetzt.
Daher kann diese Information auch niemals an die Nutzerschnittstelle gelangen.
Das heißt, wir sind auf jeden Fall nicht in der Lage Nutzer\*innen über die fehlerhafte Eingabe zu informieren.
Statt einen Wert vom Typ `Float` im Modell zu halten, sollte also in irgendeiner Weise kodiert werden, dass die Eingabe möglicherweise nicht den Anforderungen entsprach.
Eine einfache Möglichkeit wäre, einen Wert vom Typ `Maybe Float` zu speichern und im Fall von `Nothing` in der `view`-Funktion anzuzeigen, dass die Eingabe nicht valide war.
Da es häufig verschiedene Gründe gibt, warum eine Eingabe nicht valide ist, wird an dieser Stelle auch häufig ein Wert vom Typ `Result` mit einem entsprechenden Fehlerdatentyp verwendet.


### Fehlgeschlagene Anfrage

Die Anfrage an eine externe Ressource kann aus verschiedenen Gründen fehlschlagen.
Beispiele sind etwa, dass das Netz kurzzeitig nicht zur Verfügung steht oder dass es einen _Timeout_ bei einer Anfrage gab.
In diesem Fall sollte auf jeden Fall darauf hingewiesen werden, dass Informationen nicht angezeigt werden können.
Daher muss die Information über den fehlenden Wert hier ebenfalls bis zur `view`-Funktion propagiert werden.
Es muss unterschieden werden, ob die fehlenden Daten für die weitere Funktionalität der Anwendung wichtig sind.
Falls die Anwendung nicht sinnvoll fortgeführt werden kann, sollte es eine Möglichkeit geben, die Anfrage zu wiederholen.
Das heißt, es gibt zum Beispiel einen Knopf, der dafür sorgt, dass die Anfrage erneut durchgeführt wird.

Der folgende Ausschnitt aus einer Elm-Anwendung illustriert noch einmal das Beispiel.
Im Fall einer fehlgeschlagenen Anfrage wird in den meisten Fällen der Typ `Result` und nicht `Maybe` verwendet, da die Bibliothek `elm/http` diesen zur Verfügung stellt.

{% include callout-important.html content="
Dieses Beispiel illustriert einen _Code Smell_.
Die Funktion `Result.withDefault` sollte nicht auf diese Weise in einer Anwendung verwendet werden.
" %}

```elm
type Parity
    = Even
    | Odd


type alias Model =
    { number : Int
    , parity : Parity
    }


type Msg
    = CheckNumber
    | ReceivedResponse (Result Http.Error Parity)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CheckNumber ->
            ( model
            , Api.Parity.get model.number )

        ReceivedResponse result ->
            ( { model | parity = result |> Result.withDefault Even }
            , Cmd.none )
```

In diesem Beispiel wird die Information, dass die HTTP-Anfrage nicht erfolgreich war, einfach verworfen.
Daher kann diese Information bei einer solchen Implementierung nicht angezeigt werden.
Stattdessen sollte der Wert vom Typ `Result` im Modell gespeichert werden.
Im Abschnitt [HTTP-Anfragen](commands.md#http-anfragen) haben wir den Datentyp `ResponseData` kennengelernt, der genutzt werden kann, um das Ergebnis einer HTTP-Anfrage in einem Modell zu speichern.
Das heißt, in vielen Fällen wird gar nicht der Wert vom Typ `Result` selbst im Modell gespeichert, sondern nur ein Wert, der die gleichen Informationen enthält.


### Nicht-erfüllte Invarianten

In einer Anwendung gibt es häufig Invarianten, bei deren Nicht-Erfüllung die Anwendung nicht sinnvoll fortgeführt werden kann.
Dies kann zum Beispiel passieren, wenn in einer Liste ein Element mit einer bestimmten Eigenschaft gesucht, aber nicht gefunden wird.
Wenn eine solche Invariante nicht erfüllt ist, bedeutet das in den allermeisten Fällen, dass ein Bug in der Anwendung vorliegt.
Auch in diesem Fall sollte die Information, dass es einen internen Fehler gibt, an die Nutzerschnittstelle propagiert werden.
In einer produktiven Anwendung sollte die Information außerdem an einen Logging-Server weitergegeben werden, damit das Problem untersucht werden kann.

Der folgende Ausschnitt aus einer Elm-Anwendung illustriert noch einmal das Beispiel.

{% include callout-important.html content="
Dieses Beispiel illustriert einen _Code Smell_.
Die Funktion `Maybe.withDefault` sollte nicht auf diese Weise in einer Anwendung verwendet werden.
" %}

```elm
type alias User =
    { id : Int
    , name : String
    }


findById : Int -> List User -> User
findById targetId users =
    List.head (List.filter (\user -> user.id == targetId) users)
        |> Maybe.withDefault { id = -1, name = "" }
```

Hier wird die Information, dass der `User` nicht gefunden wurde, "weit unten" in der Anwendung verworfen.
Daher kann diese Information nie an die Nutzerschnittstelle gelangen.
Wenn die Aktion, die zu einer nicht-erfüllten Invariante geführt hat, durch Nutzer\*innen ausgelöst wurde, sollte auf jeden Fall eine Information angezeigt werden, dass die Aktion nicht erfolgreich war.
Man sollte die Information über Invarianten, die nicht erfüllt sind, außerdem auf jeden Fall an einen Logging-Server weitergeben, damit das Problem untersucht werden kann.

<!-- 
Es gibt einen Fall, in dem es schwierig ist, unerfüllte Invarianten zum Benutzer zu propagieren.
Dieses Problem tritt auf, wenn eine Invariante im `view`-Code nicht erfüllt ist.
Um ein solches Problem an den Logging-Server weiterzugeben, muss die Information über die fehlerhaften Daten in das Modell verschoben werden.
Hierbei tritt aber der _Trade Off_ auf, ob 

```elm
colorByIndex : Int -> Color
colorByIndex index =
    List.head (List.drop (index - 1) colors) |> Maybe.withDefault Red
```
-->

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="structure.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="other-elm-topics.html">weiter</a></li>
    </ul>
</div>

[^1]: [Wikipedia-Artikel zum Thema _Code Smell_](https://de.wikipedia.org/wiki/Code-Smell)
