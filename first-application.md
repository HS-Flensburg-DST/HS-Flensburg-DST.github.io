---
layout: post
title: "Eine Erste Anwendung"
---

In diesem Kapitel werden wir eine erste Frontend-Anwendung mit Elm entwickeln.

## _Hallo Welt_-Anwendung

Wir wollen mit einem _Hallo Welt_-Beispiel starten.
Zu diesem Zweck schreiben wir den folgenden Inhalt in eine Datei `HelloWorld.elm`.

``` elm
module HelloWorld exposing (main)

import Html exposing (Html, text)

main : Html msg
main =
    text "Hallo Welt"
```

{% include callout-important.html content="Um unsere Anwendung zu testen, können wir den Befehl `elm reactor` verwenden, der einen lokalen Webserver startet." %}

Unter der Adresse `localhost:8000` erhalten wir eine Auswahl aller Dateien, die sich in dem entsprechenden Verzeichnis befinden.
Wenn wir die Datei auswählen, die unser `HelloWorld`-Beispiel enthält, erhalten wir die entsprechende HTML-Seite.
Wenn wir die Seite im Browser neu laden, wird der Elm-Code neu in JavaScript-Code übersetzt und wir erhalten die aktualisierte Version der Anwendung.
Die Eigenschaft, Änderungen eines Systems nutzen zu können, ohne das System stoppen und wieder starten zu müssen, bezeichnet man als **_Hot Reload_**.

## Modulsystem

Im Modul `HelloWorld` wird ein Modul `Html` importiert.
Das Modul `Html`, stellt Funktionen zur Verfügung, um HTML-Seiten zu erzeugen.
Die Bedeutung des Typs `Html msg`, der in der Konstante `main` verwendet wird, werden wir uns später anschauen.
Die Funktion `text` ist im Modul `Html` definiert und nimmt einen `String` und liefert einen HTML-Textknoten.
Unter <https://package.elm-lang.org/packages/elm/html/latest/Html> findet sich eine Beschreibung des Moduls `Html`.

Wenn wir eine Definition aus dem Modul `Html` in unserem Modul verwenden wollen, müssen wir es in der Zeile `import Html exposing (Html, text)` in der Liste hinter `exposing` aufführen.
Das heißt, statt wie zuvor `exposing (..)` zu nutzen, um alle Definitionen aus einem Modul zu importieren, listen wir hier importierte Definitionen explizit auf.
Im obigen Beispiel importieren wir den Typ `Html` und die Funktion `text` aus dem Modul `Html`.

{% include callout-important.html content="Beim Import eines Datentyps kann man angeben, ob man nur den Typ oder auch die Konstruktoren importieren möchte." %}

Wenn wir so wie oben nur den Namen des Typs angeben, importieren wir nur den Typ, dürfen die Konstruktoren aber nicht verwenden.
Im Fall von `Html` importieren wir nur den Typ, da die Konstruktoren durch das Modul `Html` gar nicht exportiert werden.
Strukturen vom Typ `Html` werden immer durch Funktionen wie `text` erzeugt.
Wenn wir auch die Konstruktoren von einem Datentyp wie `Html` importieren möchten, müssen wir in der Liste nach `exposing` die Angabe `Html(..)` machen.
Auf diese Weise importieren wir den Typ und alle seine Konstruktoren.

Die gleichen Angaben, die wir beim Importieren eines Moduls machen, können wir auch verwenden, um Definitionen aus einem Modul zu exportieren.
Dazu wird die `exposing`-Anweisung genutzt, die hinter dem Namen des Moduls steht.
Hier exportiert das Modul `HelloWorld` zum Beispiel nur die Funktion `main`.
Das Hauptmodul einer Frontendanwendung muss nur die Funktion `main` exportieren.
Diese Funktion stellt den Einstiegspunkt dar, wenn die Anwendung ausgeführt wird.

Wenn wir ein Modul importieren, können wir eine Definition immer auch **qualifiziert** verwenden, das heißt, wir können zum Beispiel `Html.text` schreiben, um die Funktion `text` aus dem Modul `Html` zu verwenden.
Eigentlich ist es guter Stil, Definitionen qualifiziert zu verwenden, um explizit anzugeben, wo die Definition herkommt.
Im Fall des Moduls `Html` verzichtet man aber häufig darauf, um Programme übersichtlich zu halten.
Bei den Funktionen aus dem Modul `Html` ist im Kontext einer Frontend-Anwendung bereits aus dem Namen eindeutig, um welche Funktion es sich handelt.
Daher importiert man in Elm-Anwendungen die Definitionen aus dem Modul `Html` häufig unqualifiziert, also zum Beispiel mittels `Html exposing (Html, text)`.

{% include callout-important.html content="Wir werden die Definitionen aus dem Modul `Html` und ähnlichen Modulen auch immer unqualifiziert verwenden.
Das heißt, wir schreiben `text` und nicht `Html.text`.
Dagegen verwenden wir alle anderen importierten Definitionen immer qualifiziert." %}

Eine ähnliche Empfehlung wird auch im offiziellen [Elm Style Guide](https://elm-lang.org/docs/style-guide) gegeben.

> **Qualify variables.** Always prefer qualified names.
> Set.union is always preferable to union.
> In large files and in large projects, it becomes very very difficult to figure out where variables came from without this.

Unter <https://package.elm-lang.org/packages/elm/core/latest/> finden sich Module, die der Elm-Compiler direkt mitbringt.
Diese Module werden von jedem Elm-Modul implizit wie folgt importiert.

``` elm
import Basics exposing (..)
import List exposing (List, (::))
import Maybe exposing (Maybe(..))
import Result exposing (Result(..))
import String exposing (String)
import Char exposing (Char)
import Tuple

import Debug

import Platform exposing (Program)
import Platform.Cmd as Cmd exposing (Cmd)
import Platform.Sub as Sub exposing (Sub)
```

Das heißt zum Beispiel, dass alle Definitionen aus dem Modul `Basics` direkt zur Verfügung stehen und wir sie unqualifiziert verwenden können.
Im Modul `Basics` sind ganz grundlegende Definitionen aufgeführt, wie der Datentyp `Int` und Operatoren wie `+`.
Aus dem Modul `String` wird nur der Typ `String` importiert.
Das heißt, den Typ `String` können wir unqualifiziert verwenden.
Wenn wir allerdings eine andere Definition aus dem Modul `String` verwenden möchten, müssen wir diese Definition qualifiziert nutzen.
Zum Beispiel können wir `String.length` schreiben, um die Funktion zu nutzen, die die Länge einer Zeichenkette liefert.
Im Fall von `Maybe` werden durch die Angabe `Maybe(..)` auch die Konstruktoren importiert.
Einer der Konstruktoren des Datentyps `Maybe` heißt `Nothing`.
Das heißt, statt `Maybe.Nothing` zu schreiben, können wir die Konstruktoren unqualifiziert nutzen und einfach `Nothing` schreiben.
Das gleiche gilt für das Modul `Result`, auch hier werden der Typ `Result` und die Konstruktoren von `Result` unqualifiziert importiert.

Die Namen von Modulen können aus mehreren Komponenten bestehen, die durch Punkte getrennt werden.
Diese Art der Module werden als **hierarchische Module** bezeichnet.
In diesem Fall führt man in einigen Fällen kürzere Namen für diese Module ein.
Der Import `import Platform.Cmd as Cmd` bedeutet, dass das hierarchische Modul `Platform.Cmd` unter dem Namen `Cmd` importiert wird.
Das heißt, wir können die Definitionen aus dem Modul `Platform.Cmd` qualifiziert nutzen, müssen vor den Namen der Definition aber nicht den gesamten Modulnamen `Platform.Cmd` schreiben, sondern können stattdessen `Cmd` davorschreiben.

Bei einer Elm-Anwendung ist es guter Stil, Funktionen qualifiziert zu nutzen, also zum Beispiel `String.fromInt` und nicht nur `fromInt`.

{% include callout-important.html content="Wenn ein Modul einen Datentyp mit identischem Namen zur Verfügung stellt, sollte man den Datentyp (samt Konstruktoren) aber unqualifiziert nutzen." %}

Das heißt, wenn wir ein Modul `Color` in unserer Anwendung haben, das einen Datentyp `Color` definiert, sollten wir als Import `import Color exposing (Color(..))` nutzen.


Elm-Architektur
---------------

In diesem Kapitel wollen wir uns über die Architektur einer Elm-Anwendung unterhalten.
Eine Elm-Anwendung besteht immer aus den folgenden klar getrennten Teilen.

- **Model**: der Zustand der Anwendung

- **View**: eine Umwandlung des Zustandes in eine HTML-Seite

- **Update**: eine Möglichkeit, den Zustand zu aktualisieren

Eine typische Elm-Anwendung hat immer die folgende Struktur.

``` elm
module App exposing (main)

import Browser



-- Model


type alias Model = ...


init : Model
init = ...



-- Update


type Msg = ...


update : Msg -> Model -> Model
update msg model = ...



-- View


view : Model -> Html Msg
view model = ...



-- Main


main : Program () Model Msg
main =
    Browser.sandbox { init = init, view = view, update = update }
```

Wir haben einen Typ `Model`, der den internen Zustand unserer Anwendung repräsentiert.
Außerdem haben wir einen Typ `Msg`, der Interaktionen mit der Anwendung modelliert.
Diese Typen sind häufig einfach Synonyme für andere Typen, können aber auch direkt als Aufzählungstyp definiert sein.
Die Konstante `init` gibt an, mit welchem Zustand die Anwendung startet.
Die Funktion `update` nimmt eine Aktion und einen aktuellen Zustand und liefert einen neuen Zustand.
Die Funktion `view` nimmt einen Zustand und liefert eine HTML-Seite.
Außerdem stellt das Modul `Browser` eine Funktion `sandbox` zur Verfügung, deren Details wir erst im Kapitel [Modellierung der Elm-Architektur](architecture.md) diskutieren werden.
An dieser Stelle müssen wir nur wissen, dass wir der Funktion die Konstante `init` und die Funktionen `update` und `view`, wie oben angegeben, übergeben müssen.
Wir geben hier auch den Typ der Funktion `main` an, werden ihn aber ebenfalls erst im Kapitel [Modellierung der Elm-Architektur](architecture.md) diskutieren.
Im Unterschied zur *HalloWelt*-Anwendung ist der Typ der Konstante `view` nun `Html Msg` und nicht mehr `Html msg`.
Wir verweisen im `Html`-Typ also auf den Typ der Nachrichten, die wir an die Anwendung schicken können.
Warum genau wir den Typ der Nachrichten an den `Html`-Typ übergeben, werden wir im Kapitel [Modellierung der Elm-Architektur](architecture.md) lernen.
Was das kleingeschriebene `msg` bedeutet, werden wir im Kapitel [Polymorphismus](polymorphism.md) erfahren.

Wir wollen uns einmal ein sehr einfaches Beispiel für eine Anwendung ansehen.
Wir implementieren einen einfachen Zähler, den Nutzer\*innen hoch- und runterzählen können.

``` elm
module Counter exposing (main)

import Browser
import Html exposing (Html, text)



-- Model


type alias Model =
    Int


init : Model
init =
    0



-- Update


type Msg
    = IncreaseCounter
    | DecreaseCounter


update : Msg -> Model -> Model
update msg model =
    case msg of
        IncreaseCounter ->
            model + 1

        DecreaseCounter ->
            model - 1



-- View


view : Model -> Html Msg
view model =
    text (String.fromInt model)



-- Main


main : Program () Model Msg
main =
    Browser.sandbox { init = init, view = view, update = update }
```

Da wir einen Zähler implementieren wollen, ist unser Zustand vom Typ `Int`.
Initial hat unser Zustand den Wert `0`.
Um die Nachrichten darzustellen, die Nutzer\*innen auswählen können, definieren wir den Aufzählungstyp `Msg`.

{% include callout-important.html content="
Es ist gute Praxis für die Benennung der Nachrichten ein Verb im Imperativ und ein Nomen zu nutzen, um zu beschreiben, welche Aktion die Nachricht auslösen soll.
" %}

Die Funktion `update` verarbeitet einen Zustand und eine Nachricht und liefert einen neuen Zustand.
Die Funktion `view` liefert zu einem Zustand die HTML-Seite, die den Zustand repräsentiert.

{% include callout-important.html content="Es ist ein sehr probates Mittel, ein Elm-Modul mithilfe von Kommentaren zu strukturieren." %}

Wir werden uns später Gedanken darüber machen, wie man eine Elm-Anwendung in mehrere Module zerlegt.
Innerhalb eines Moduls kann man aber sehr gut Kommentare nutzen, um Gruppen von Funktionen zu bilden.
Dieses Konzept ist nicht auf die Elm-Architektur beschränkt, sondern lässt sich ganz allgemein anwenden, um Leser*innen Orientierung in einer Datei zu bieten.
Dies gilt ganz allgemein für alle Programmiersprachen.

Unserer Anwendung fehlt ein wichtiger Teil, nämlich die Möglichkeit, dass Nutzer\*innen mit der Anwendung interagieren.
Zu diesem Zweck müssen wir nur zwei Knöpfe zu unserer Seite hinzufügen, die die Nachrichten `IncreaseCounter` und `DecreaseCounter` an die Anwendung schicken.

``` elm
view : Model -> Html Msg
view model =
    div []
        [ text (String.fromInt model)
        , button [ onClick IncreaseCounter ] [ text "+" ]
        , button [ onClick DecreaseCounter ] [ text "-" ]
        ]
```

Die Funktion `button` kommt aus dem Modul `Html` und erzeugt einen Knopf in der HTML-Struktur.
Wir nutzen hier einen `div`-_Tag_, um den Zähler und die beiden Knöpfe zusammenzufassen.
Wie Funktionen wie `div` genau funktionieren, werden wir in Kürze diskutieren.
Das Modul `Html.Events` stellt die Funktion `onClick` zur Verfügung.
Wir übergeben der Funktion die Nachricht, die wir bei einem Klick an die Anwendung schicken wollen.
Wird der Knopf zum Erhöhen des Zählers verwendet, wird die Funktion `update` mit der Nachricht `IncreaseCounter` und dem aktuellen Zustand aufgerufen.
Nach der Aktualisierung wird die Funktion `view` aufgerufen und die entsprechende HTML-Seite angezeigt.

In diesem einfachen Beispiel können wir bereits den deklarativen Ansatz der Elm-Architektur erkennen.
Die Funktion `view` beschreibt, wie ein Modell als HTML-Struktur dargestellt wird.
Das heißt, wir beschreiben nur, was dargestellt werden soll, aber nicht wie die konkrete Darstellung durchgeführt wird.
Im Kontrast dazu, würde eine sehr klassische JavaScript-Anwendung beschreiben, wie die HTML-Struktur geändert wird.
Das heißt, der entsprechende HTML-Knoten wird aus der HTML-Struktur herausgesucht und der Knoten, der den Wert des Zählers anzeigt durch den veränderten Wert ersetzt.

Die Abbildung <a href="#sequence-diagram">Kommunikation einer Elm-Anwendung</a> illustriert noch einmal, wie die Komponenten der Elm-Architektur miteinander interagieren, wenn eine Anwendung mittels `Browser.sandbox` gestartet wurde.

<figure id="sequence-diagram" markdown="1">
![Sequenzdiagramm der Kommunikation einer Elm-Anwendung](/assets/graphics/sequence-diagram.svg){: width="100%" .centered}
<figcaption>Kommunikation einer Elm-Anwendung</figcaption>
</figure>

Wir übergeben das initiale Modell `init`, `update` und `view` mithilfe der Funktion `Browser.sandbox` an die Elm\-_Runtime_.
Die Elm\-_Runtime_ ruft zuerst die Funktion `view` mit dem initialen Modell `init` auf und zeigt die resultierende HTML-Struktur im Browser an.
Wenn nun Benutzer\*innen im UI des Browsers auf einen der Knöpfe drücken, wird eine entsprechende Nachricht an die Elm\-_Runtime_ geschickt.
Die Elm\-_Runtime_ ruft nun mit dieser Nachricht und dem aktuellen Modell die Funktion `update` auf und erhält ein neues Modell.
Die Elm\-_Runtime_ steckt dieses neue Modell dann in die Funktion `view` und zeigt die resultierende HTML-Struktur im Browser an.
Dabei wird aber nicht die komplette HTML-Struktur im Browser neu erzeugt.
Stattdessen berechnet die Elm\-_Runtime_ die Unterschiede zwischen der HTML-Struktur, die zuvor angezeigt wurde und der neuen HTML-Struktur.
Aus diesen Unterschieden ergeben sich die Änderungen, welche die Elm\-_Runtime_ an der HTML-Struktur vornimmt, die im Browser angezeigt wird.
Auf diese Weise können wir im Elm-Programm deklarativ beschreiben, wie die HTML-Struktur aussehen soll.
Die Anzeige der HTML-Struktur im Browser ist aber dennoch effizient, da die Elm\-_Runtime_ nur die Änderungen durchführt, die notwendig sind und nicht die komplette Seite neu zeichnet.


## HTML-Kombinatoren

Das Modul `Html` stellt eine ganze Reihe von Funktionen zur Verfügung, mit deren Hilfe man HTML-Seiten definieren kann.
Als weiteres Beispiel generieren wir einmal eine HTML-Seite mit einem `div`, das zwei Text-Knoten als Kinder hat.

``` elm
main : Html msg
main =
    div [] [ text "Hallo Welt", text (String.fromInt 23) ]
```

Die Funktion `div` nimmt zwei Argumente.
Das erste Argument ist eine Liste von Attributen, die das `div`-Element erhalten soll.
Das zweite Argument ist eine Liste von HTML-Kindelementen.
Wir könnten in der Liste der Kindelemente also zum Beispiel auch wieder ein `div`-Element verwenden.

Um die Funktionsweise von Attributen zu illustrieren, geben wir unserem `div`-Element einmal einen CSS-Stil.
Die Funktion `style` kommt aus dem Modul `Html.Attributes` und nimmt zwei Strings, nämlich den Namen des Stils und den entsprechenden Wert, den der Stil haben soll.
Analog zum Modul `Html` importieren wir alle Definitionen aus dem Modul `Html.Attributes` unqualifiziert.
Wir erhalten somit die folgenden Importe.

```elm
import Html exposing (Attribute, Html, button, div, text)
import Html.Attributes exposing (style)
```

Das Modul exportiert einen Typ `Attribute` und die Funktion `style`, die wir wie folgt nutzen können.

``` elm
mainContentStyle : List (Attribute msg)
mainContentStyle =
    [ style "background-color" "red", style "height" "90px" ]


main : Html msg
main =
    div mainContentStyle [ text "Hallo Welt", text (String.fromInt 23) ]
```

Statt eine CSS-Datei zu nutzen, kann man in Elm sehr gut _Inline_-Stile verwenden.
Da diese Stile in Elm selbst definiert werden und nicht in einer externen Datei, kann man die Sprachkonstrukte von Elm zur Strukturierung der Stile nutzen.

{% include callout-important.html content="Man sollte die Stil-Definitionen in Konstanten auslagern." %}

Das heißt, statt die Stile direkt als Liste an die HTML-Kombinatoren wie `div` zu übergeben, definiert man eine Konstante wie `mainContentStyle` und gibt ihr einen beschreibenden Namen.
Dadurch hat man ähnlich wie in CSS die Möglichkeit, Kombinationen von Stilen unter einem semantischen Namen zusammenzufassen und wiederzuverwenden.

Als weiteres Beispiel für die Verwendung von Attributen, wollen wir einen Link definieren.

``` elm
linkStyle : List (Attribute msg)
linkStyle =
    [ style "color" "red" ]


main : Html msg
main =
    a (href "https://hs-flensburg.de" :: linkStyle) [ text "Dies ist ein Link" ]
```

In diesem Beispiel kombinieren wir eine Konstante, die den Stil aller Links definiert mit einem Attribut, das für die Logik der Anwendung zuständig ist.
Die Funktion `href` nimmt einen `String` und konstruiert das gleichnamige HTML-Attribut.
Der Operator `::` hängt das Element `href "https://hs-flensburg.de"` vorne an die Liste `linkStyle`.

{% include callout-important.html content="Man sollte die Attribute, die zur visuellen Gestaltung der Elemente gehören von den Attributen trennen, die zur Logik der Web-Anwendung gehören." %}

Wir könnten ansonsten eine Konstante wie `linkStyle` nicht für alle Links der Web-Anwendung nutzen und würden visuelle Darstellung und Logik unnötig mischen.

Da wir zur Definition von Stilen die Elm-Sprach-Features zur Verfügung haben, können wir auch ganz einfach Stile definieren, die auf anderen Stilen basieren.
Wenn unsere Anwendung zum Beispiel eine _Navigation Bar_ enthält, bei der wir Links zusätzlich einen fetten Font verwenden sollen, können wir wie folgt einen Stil definieren. 

```elm
navBarLinkStyle : List (Attribute msg)
navBarLinkStyle =
    style "font-weight" "bold" :: linkStyle
```

{% include callout-important.html content="Die Verwendung einer eingebetteten domänenspezifischen Sprache (eDSL) zur Definition von HTML-Stilen bietet einige Vorteil im Vergleich zur Verwendung von CSS-Dateien." %}

1. **Engere Integration:**
    Bei der Verwendung einer CSS-Datei müssen die Stile in einer separaten Datei definiert werden.
    Die separater Definition hat den Vorteil, dass wir Darstellung von Struktur trennen.
    Es hat aber auch den Nachteil, dass wir den Stil in einer separaten Datei nachschauen müssen, um herauszufinden, wie ein HTML-Element dargestellt wird.
    Bei der Verwendung einer eDSL können wir selbst entscheiden, ob wir die Stile dort definieren, wo wir die HTML-Struktur erzeugen oder ob wir die Stile in ein separates Modul auslagern.

2. **Compilerunterstützung:**
    Bei der Verwendung einer CSS-Datei müssen Identifikatoren und Klassen verwendet werden, um Stile zu HTML-Elementen zuzuordnen.
    Wenn es einen Schreibfehler in den Namen von Identifikatoren oder Klassen gibt, fällt das nur durch eine fehlerhafte Darstellung im Browser auf.
    Bei der Verwendung einer eDSL erhalten wir dagegen einen Kompilierfehler, wenn wir zum Beispiel `navbarLinkStyle` schreiben statt `navBarLinkStyle`.
    Die Unterstützung des Compilers hilft insbesondere beim Refactoring der Stile, etwa wenn Stildefinitionen umbenannt werden sollen.

3. **Wiederverwendbarkeit:**
    Dadurch, dass wir bei einer eDSL die Sprachfeatures einer Programmiersprache zur Verfügung haben, können wir durch Konzepte wie Funktionen und Konstanten Stile sehr einfach wiederverwenden.
    Bei der Verwendung von CSS-Dateien ist dies nur durch zusätzliche Preprozessorsprachen wir [Less](https://en.wikipedia.org/wiki/Less_(style_sheet_language)) oder [Sass](https://en.wikipedia.org/wiki/Sass_(style_sheet_language)) möglich.
    Bei der Verwendung von Less oder Sass müssen Entwickler\*innen noch eine zusätzliche Syntax lernen.

4. **Dynamische Style:**
    In HTML können wir ein Kontrollelement wie einen Knopf deaktivieren, indem wir das Attribut `disabled` zu den Attributen des Kontrollelementes hinzufügen.
    Im Gegensatz dazu können wir das Deaktivieren eines Knopfes im Rahmen einer eDSL durch die dynamischen Features der Programmiersprache ausdrücken.
    Das Modul `Html.Attributes` stellt zum Beispiel die folgende Funktion zur Verfügung.
    
    ```elm
    disabled : Bool -> Attribute msg
    ```
    
    Das heißt, das Deaktivieren eines Knopfes ist durch eine dynamische Funktion abgebildet.
    Das heißt, wir können an die Funktion `disabled` einen booleschen Ausdruck übergeben und je nach dem, ob der Wert `True` oder `False` ist, wird das `disabled`-Attribut zu dem HTML-Knoten hinzugefügt oder nicht.

Neben der sehr einfachen Einbindung von Stilen durch die `style`-Funktion, gibt es für Elm noch eDSLs, die eine größere Typsicherheit bieten, etwa [elm-css](https://package.elm-lang.org/packages/rtfeldman/elm-css/latest/).
Während die Argumente von `style` vom Typ `String` sind, definiert elm-css Abstraktionen, die etwa einen `Int` als Argument erwarten.
Um diesen Aspekt der Programmierung im Rahmen der Vorlesung möglichst einfach zu halten, verwenden wir die vordefinierte `style`-Funktion und keine zusätzliche Bibliothek wie elm-css.


_Print Debugging_
-----------------

Zum Abschluss dieses Kapitels soll noch kurz eine Möglichkeit vorgestellt werden, mit der man in Elm einfaches *Print Debugging* machen kann.
Das Modul `Debug` stellt eine Funktion `log : String -> a -> a` zur Verfügung.
Wenn diese Funktion ausgewertet wird, schreibt sie ihr zweites Argument auf die Konsole.
Der `String` im ersten Argument wird dieser Ausgabe vorangestellt.
Wir nutzen in unserer einfachen Zähleranwendung zum Beispiel die folgende Definition von `update`.

``` elm
update : Msg -> Model -> Model
update msg model =
    case msg of
        IncreaseCounter ->
            Debug.log "Modell" (model + 1)

        DecreaseCounter ->
            model - 1
```

Wir führen die Anwendung nun aus und schauen uns die Entwicklerkonsole unseres Browsers an.
Wenn wir wiederholt auf den Knopf für das Erhöhen des Zählers drücken, erhalten wir die folgende Ausgabe.

    Modell: 1
    Modell: 2
    Modell: 3

Da wir an `Debug.log` den Wert `model + 1` übergeben, wird in der Konsole jeweils der Wert angezeigt, den der Zähler nach der Erhöhung hat.
Wenn wir auf den Knopf für das Verringern des Zählers drücken, erhalten wir keine Ausgabe, da der Aufruf von `Debug.log` nur ausgeführt wird, wenn die Nachricht `IncreaseCounter` lautet.

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="basics.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="data-types.html">weiter</a></li>
    </ul>
</div>
