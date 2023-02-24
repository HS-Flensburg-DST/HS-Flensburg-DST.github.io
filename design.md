---
layout: post
title: "Design von Datentypen"
---

In diesem Kapitel wollen wir uns mit einer _Best Practice_ beim Entwurf von Datentypen beschäftigen.
Diese _Best Practice_ lässt sich nicht nur auf Elm anwenden, sondern ist auf andere Programmiersprachen übertragbar.
Im Kontext von Elm wird dieses Konzept als

> Making Impossible States Impossible

bezeichnet und geht auf den Vortrag [Making Impossible States Impossible](https://www.youtube.com/watch?v=IcgmSRJHu_8) von Richard Feldman aus dem Jahr 2016 zurück.
Allgemeiner im Kontext funktionaler Programmierung wurde das gleiche Konzept under dem Slogan

> Make Illegal States Unrepresentable

schon im Jahr 2010 von [Yaron Minsky](https://blog.janestreet.com/effective-ml-video/) postuliert.
Grundsätzlich ist aber anzunehmen, dass diese Idee noch sehr viel älter ist.

In der Programmierung in Elm aber auch ganz allgemein in anderen Programmiersprachen sollte man sich bemühen, Datentypen so zu strukturieren, dass nur valide Zustände modelliert werden können.
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
    , options : Options
    }
```

Dieses Modell wird in einer Anwendung genutzt, die Daten von einem Server lädt.
Das Feld `state` definiert, ob die Daten aktuell geladen werden, der Ladevorgang bereits beendet ist oder ein Fehler aufgetreten ist.
Der Typ `Error` modelliert verschiedene Arten von Fehlern, die in der Anwendung auftreten können.
Der Eintrag `items` enthält eine Liste von Daten, die in der Anwendung verarbeitet werden.
Der Eintrag `options` enthält Informationen über die Konfiguration des _User Interface_, also etwa ob der _Light_ oder der _Dark Mode_ verwendet wird.

Wie der Slogan _Making Impossible States Impossible_ schon andeutet, hat die von uns gewählte Struktur den Nachteil, dass wir Zustände modellieren können, die es gar nicht gibt.
Das heißt, einige Ausprägungen des Datentyps sollten in der Anwendung gar nicht auftreten.
Treten sie doch auf, ist an irgendeiner Stelle ein Fehler in unserer Anwendung.
Die Frage wäre etwa, was es bedeutet, wenn unsere Anwendung im Zustand `Success` ist, aber ein Fehler vorhanden ist.
Alternativ könnte die Anwendung auch im Zustand `Loading` sein, es könnten aber Daten vorhanden sein.

Zusätzliche Regeln, die von einem Datentyp eingehalten werden müssen, bezeichnet man als **Invarianten**.
Grundsätzlich sind Invarianten ein wichtiges Konzept bei der Modellierung von Daten.
Wenn ein Datentyp Invarianten erfordert, müssen wir diese aber entweder zur Laufzeit überprüfen und einen Fehler werfen, wenn sie nicht eingehalten werden oder wir müssen ignorieren, ob die Invarianten erfüllt sind oder nicht.
Außerdem müssen Entwickler\*innen beim Erstellen und Verändern von Daten darauf achten, dass die Invarianten eingehalten werden.
Daher sind Invarianten, die durch die Struktur der Datentypen ausgedrückt werden, ein großer Vorteil.
Das heißt, wir möchten den Datentyp gern so umstrukturieren, dass man möglichst wenige invalide Zustände erstellen kann und somit mit möglichst wenig Invarianten auskommt.

Zuerst einmal sollte es nur im Zustand `Success` auch Daten geben.
Daher verändern wir die Struktur des Datentyps so, dass die `List Item` ein Argument des Konstruktors `Success` ist.
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
    , options : Options
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
        <li class="nav-item nav-left"><a href="polymorphism.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="higher-order.html">weiter</a></li>
    </ul>
</div>