---
layout: post
title: "Design von Datentypen"
---

In diesem Kapitel wollen wir uns mit zwei _Best Practices_ beim Entwurf von Datentypen beschäftigen.
Diese _Best Practices_ lassen sich nicht nur auf Elm anwenden, sondern sind auf andere Programmiersprachen übertragbar.


## Boolean Blindness

Zuerst wollen wir einen Aspekt betrachten, der

> Boolean Blindness

genannt wird und vermutlich auf den Artikel [Boolean Blindness](https://existentialtype.wordpress.com/2011/03/15/boolean-blindness/) von Robert Harper zurückgeht.
Mit diesem Begriff bezeichnet man den Verlust von Information, wenn man einen booleschen Datentyp verwendet.
Genauer gesagt geht bei der Verwendung des Datentyps `Bool` die Information verloren, welche Bedeutung die beiden Fälle jeweils haben.
Im Grunde ist _Boolean Blindness_ eine Instanz eines allgemeineren Phänomens, wenn die Werte eines Datentyps nur mit zusätzlicher Information interpretiert werden können.
Dieses Phänomen tritt etwa bei der Kodierung von Fehlercodes als _Integer_ auf.

Als Beispiel für _Boolean Blindness_ betrachten wir die folgende Funktion in einer Elm-Anwendung, die einen _Button_ liefert.

```elm
mainButton : String -> Bool -> msg -> Html msg
mainButton label isDisabled onClick =
    button
        (buttonStyle ++ [ disabled isDisabled, Events.onClick onClick ])
        [ text label ]
```

Während wir in der Definition dieser Funktion identifizieren können, welche Bedeutung das Argument `isDisabled` hat, ist dies bei einem Aufruf der Form `mainButton "+" False IncreaseCounter` schwierig.
Im Abschnitt [Records](data-types.md#records) haben wir bereits einen Ansatz kennengelernt, um dieses Problem zu beheben.
Wir können einen Record verwenden, um den Argumenten einer Funktion sprechende Namen zuzuordnen.
Wir können die Funktion `mainButton` zum Beispiel wie folgt definieren.

```elm
mainButton : { label : String, isDisabled : Bool, onClick : msg } -> Html msg
mainButton { label, isDisabled, onClick } =
    button
        (buttonStyle ++ [ disabled isDisabled, Events.onClick onClick ])
        [ text label ]
```

Ein Aufruf dieser Funktion hat nun die Form `mainButton { label = "+", isDisabled = False, onClick = IncreaseCounter}` und ist damit sehr viel aussagekräftiger.

Wenn der boolesche Wert aber zum Beispiel nicht direkt im Argument der Funktion `mainButton` bestimmt wird, sondern zum Beispiel aus dem Zustand der Anwendung stammt, müssen an allen Stellen einen Record verwenden und diesen Record durch die Anwendung reichen.
Wenn der Record wie im Beispiel `mainButton` zwei Felder hat, können wir diesen Record nicht verwenden, um die Daten durch die Anwendung zu reichen, da die beiden Informationen aus unterschiedlichen Quellen stammen können.

Ein alternativer Ansatz, um die Interpretation von `False` und `True` explizit zu machen, ist die Verwendung von benutzerdefinierten Aufzählungstypen.
Das heißt, statt den Datentyp `Bool` zu verwenden, definieren wir uns einen Datentyp der folgenden Art.

```elm
type Interaction
    = Enabled
    | Disabled
```

Wenn wir diesen Datentyp für die Implementierung einer Funktion `mainButton` nutzen, erhalten wir einen Aufruf der Form `mainButton "+" Enabled IncreaseCounter`.
Bei diesem Aufruf können wir am Aufruf selbst bereits erkennen, dass der _Button_ deaktiviert wird.

In den Elm-Standardbibliotheken werden trotz der _Boolean Blindness_ häufig boolesche Werte verwendet.
Ein Beispiel für das Problem der _Boolean Blindness_ in den Standard-Bibliotheken ist die Funktion `filter`.
Wenn wir den Typ der Funktion `filter` betrachten

```elm
filter : (a -> Bool) -> List a -> List a
```

ist nicht klar, ob das Prädikat für diejenigen Elemente `True` liefert, die in der Liste verbleiben sollen, oder für die Elemente, die aus der Liste entfernt werden sollen.

Auch in diesem Beispiel können wir grundsätzlich einen Record verwenden, um dem booleschen Wert eine Semantik zuzuordnen.
Wir können zum Beispiel die folgenden Definition von `filter` nutzen, um die Bedeutung des Typs `Bool` zu signalisieren.
Hier erkennt man aber gut, dass dieser Ansatz seine Grenzen hat.

```elm
filter : (a -> { keep : Bool }) -> List a -> List a
```

Wenn wir stattdessen den folgenden Datentyp definieren

```elm
type Decision
    = Discard
    | Keep
```

und diesen in der Definition von `filter` nutzen

```elm
filter : (a -> Decision) -> List a -> List a
```

drückt das Ergebnis der Funktion, die wir an `filter` übergeben, sehr explizit aus, ob wir das Element behalten oder verwerfen möchten.
Zur Illustration betrachten wir ein Beispiel aus dem Kapitel [Funktionale Abstraktionen](functional-abstractions.md), um die Verwendung dieser Funktion zu illustrieren.

```elm
startWithA : List User -> List User
startWithA users =
    List.filter
        (\user ->
            if String.startsWith "A" user.firstName then
                Keep

            else
                Discard
        )
        users
```

In diesem Code ist sehr explizit, wann ein Element in der Liste verbleibt und wann es entfernt wird.
Das Beispiel illustriert aber auch gut die Grenzen dieses Ansatzes.
Durch die Verwendung von selbstdefinierten Aufzählungstypen müssen an vielen Stellen Umwandlungen zwischen diesen Typen implementiert werden.
Im Beispiel `startWithA` muss etwa der Typ `Bool`, den die Funktion `String.startsWith` liefert, in den Typ `Decision` der Funktion `filter` umgewandelt werden.
Das heißt, wie häufig in der Programmierung, gibt es einen _Tradeoff_  zwischen Explizitheit und Komplexität des Codes.

{% include callout-important.html content="
Man sollte dennoch bei jeder Verwendung des Typs `Bool` darüber nachdenken, ob ein selbstdefinierter Aufzählungstyp besser geeignet ist.
" %}

Insbesondere ist es bei einem Aufzählungstyp möglich, weitere Fälle hinzuzufügen.
Während es zu Anfang ggf. nur zwei Zustände gibt, kommt es häufig vor, dass im Laufe der Zeit weitere Zustände hinzukommen.


## Impossible States

Eine weitere _Best Practice_ wird im Kontext von Elm als

> Making Impossible States Impossible

bezeichnet und geht auf den Vortrag [Making Impossible States Impossible](https://www.youtube.com/watch?v=IcgmSRJHu_8) von Richard Feldman aus dem Jahr 2016 zurück.
Allgemeiner im Kontext funktionaler Programmierung wurde das gleiche Konzept unter dem Slogan

> Make Illegal States Unrepresentable

schon im Jahr 2010 von [Yaron Minsky](https://blog.janestreet.com/effective-ml-video/) postuliert.
Grundsätzlich ist aber anzunehmen, dass diese Idee noch sehr viel älter ist.

{% include callout-important.html content="
In der Programmierung in Elm aber auch ganz allgemein in anderen Programmiersprachen sollte man sich bemühen, Datentypen so zu strukturieren, dass nur valide Zustände modelliert werden können.
" %}

Um diesen Punkt zu illustrieren, betrachten wir das folgende Modell einer Elm-Anwendung.

``` elm
type State
    = Loading
    | Success
    | Failure


type alias Model =
    { state : State
    , error : Maybe Error
    , items : List Item
    , settings : Settings
    }
```

Dieses Modell wird in einer Anwendung genutzt, die Daten von einem Server lädt.
Das Feld `state` definiert, ob die Daten aktuell geladen werden, der Ladevorgang bereits beendet ist oder ein Fehler aufgetreten ist.
Der Typ `Error` modelliert verschiedene Arten von Fehlern, die in der Anwendung auftreten können.
Der Eintrag `items` enthält eine Liste von Daten, die in der Anwendung verarbeitet werden.
Der Eintrag `settings` enthält Informationen über die Konfiguration des _User Interface_, also etwa ob der _Light_ oder der _Dark Mode_ verwendet wird.

Wie der Slogan _Making Impossible States Impossible_ schon andeutet, hat die von uns gewählte Struktur den Nachteil, dass wir Zustände modellieren können, die es gar nicht gibt.
Das heißt, einige Ausprägungen des Datentyps sollten in der Anwendung gar nicht auftreten.
Treten sie doch auf, ist an irgendeiner Stelle ein Fehler in unserer Anwendung.
Die Frage wäre etwa, was es bedeutet, wenn unsere Anwendung im Zustand `Success` ist, aber ein Fehler vorhanden ist.
Alternativ könnte die Anwendung auch im Zustand `Loading` sein, es könnten aber Daten vorhanden sein.

Zusätzliche Regeln, die von einem Datentyp eingehalten werden müssen, bezeichnet man als **Invarianten**.
Grundsätzlich sind Invarianten ein wichtiges Konzept bei der Modellierung von Daten.
Wenn ein Datentyp Invarianten erfordert, müssen wir diese aber entweder zur Laufzeit überprüfen und einen Fehler werfen, wenn sie nicht eingehalten werden, oder wir müssen ignorieren, ob die Invarianten erfüllt sind oder nicht.
Außerdem müssen Entwickler\*innen beim Erstellen und Verändern von Daten darauf achten, dass die Invarianten eingehalten werden.
Daher sind Invarianten, die durch die Struktur der Datentypen ausgedrückt werden, ein großer Vorteil.
Das heißt, wir möchten den Datentyp gern so umstrukturieren, dass man möglichst wenige invalide Zustände erstellen kann und somit mit möglichst wenig impliziten Invarianten auskommt.

Zuerst einmal sollte es nur im Zustand `Success` auch Daten geben.
Daher verändern wir die Struktur des Datentyps so, dass der Wert vom Typ `List Item` ein Argument des Konstruktors `Success` ist.
Ein Fehler sollte wiederum nur auftreten, wenn wir im Zustand `Failure` sind.
Daher erhält der Konstruktor `Failure` als Argument einen `Error`.
In diesem Fall können wir den `Maybe`-Kontext entfernen, da wir auch immer eine Fehlermeldung vom Typ `Error` haben sollten, wenn ein Fehler aufgetreten ist.
Durch diese Umformungen erhalten wir die folgenden Datentypen.

``` elm
type Data
    = Loading
    | Failure Error
    | Success (List Item)


type Model
    { data : Data
    , settings : Settings
    }
```

Durch Verwendung dieses Datentyps können wir nur noch valide Zustände ausdrücken.
Wenn die Anwendung im Zustand `Loading` ist, sind weder Daten noch ein Fehler vorhanden.
Wenn die Anwendung im Zustand `Failure` ist, ist immer genau ein Fehler vorhanden.
Wenn die Anwendung im Zustand `Success` ist, ist eine Liste von geladenen Daten vorhanden.

Diese veränderte Form der Datentypen hat einen weiteren Vorteil.
Wenn wir auf die Daten in Form der `List Item` zugreifen möchten, müssen wir zuvor _Pattern Matching_ auf den Datentyp `Data` durchführen.
Das heißt, wir müssen explizit überprüfen, in welchem der Fälle wir uns befinden.
In der ursprünglichen Modellierung können Entwickler\*innen auf das Feld `items` direkt zugreifen und damit ggf. vergessen, zu überprüfen, wie der Zustand der Anwendung ist.
Dieser Aspekt wird auch in dem Blogartikel [How Elm Slays a UI Antipattern](http://blog.jenkster.com/2016/06/how-elm-slays-a-ui-antipattern.html) von Kris Jenkins hervorgehoben.
Dort wird illustriert, dass die ursprüngliche Modellierung des Datentyps zu einem verbreiteten Fehler in Anwendungen führt, bei dem Daten bereits angezeigt werden, obwohl die Anwendung sich noch im Ladezustand befindet.

Es gibt noch eine Vielzahl von anderen Beispielen für das Konzept _Making Impossible States Impossible_ etwa die [Modellierung von zwei Dropdows zur Wahl einer Stadt in einem Land](https://medium.com/elm-shorts/how-to-make-impossible-states-impossible-c12a07e907b5) oder die [Modellierung von Kontaktbucheinträgen](https://fsharpforfunandprofit.com/posts/designing-with-types-making-illegal-states-unrepresentable/).
Unter diesen Slogan oder dem Slogan _Make Illegal States Unrepresentable_ lassen sich auch Beispiele in anderen Programmiersprachen finden.


<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="architecture.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <!-- <li class="nav-item nav-right"><a href="structure.html">weiter</a></li> -->
        <li class="nav-item nav-right"></li>
    </ul>
</div>
