---
layout: post
title: "Design von Datentypen"
---

In diesem Kapitel wollen wir uns mit zwei _Best Practices_ beim Entwurf von Datentypen beschäftigen.
Diese _Best Practices_ lassen sich nicht nur auf Elm anwenden, sondern sind auf andere Programmiersprachen übertragbar.
Außerdem wollen wir ein tieferes Verständnis dafür entwickeln, wann zwei Datentypen im Grunde die gleichen Möglichkeiten zur Verfügung stellen.


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
mainButton label isDisabled msg =
    button [ disabled isDisabled, onClick msg ] [ text label ]
```

Während wir in der Definition dieser Funktion identifizieren können, welche Bedeutung das Argument `isDisabled` hat, ist dies bei einem Aufruf der Form `mainButton "+" True IncreaseCounter` schwierig.
Im Abschnitt [Records](data-types.md#records) haben wir bereits einen Ansatz kennengelernt, um dieses Problem zu beheben.
Wir können einen Record verwenden, um den Argumenten einer Funktion sprechende Namen zuzuordnen.
Wir können die Funktion `mainButton` zum Beispiel wie folgt definieren.

```elm
mainButton : { label : String, isDisabled : Bool, msg : msg } -> Html msg
mainButton { label, isDisabled, msg } =
    button [ disabled isDisabled, onClick msg ] [ text label ]
```

Ein Aufruf dieser Funktion hat nun die Form `mainButton { label = "+", isDisabled = True, msg = IncreaseCounter }` und ist damit sehr viel aussagekräftiger.

Wenn der boolesche Wert aber zum Beispiel nicht direkt im Argument der Funktion `mainButton` bestimmt wird, sondern zum Beispiel aus dem Zustand der Anwendung stammt, müssen an allen Stellen einen Record verwenden und diesen Record durch die Anwendung reichen.
Wenn der Record wie im Beispiel `mainButton` mehrere Felder hat, können wir diesen Record nicht verwenden, um die Daten durch die Anwendung zu reichen, da die verschiedenen Informationen aus unterschiedlichen Quellen stammen können.

Ein alternativer Ansatz, um die Interpretation von `False` und `True` explizit zu machen, ist die Verwendung von benutzerdefinierten Aufzählungstypen.
Das heißt, statt den Datentyp `Bool` zu verwenden, definieren wir uns einen Datentyp der folgenden Art.

```elm
type Interaction
    = Enabled
    | Disabled
```

Wenn wir diesen Datentyp für die Implementierung einer Funktion `mainButton` nutzen, erhalten wir einen Aufruf der Form `mainButton "+" Disabled IncreaseCounter`.
Bei diesem Aufruf können wir am Aufruf selbst bereits erkennen, dass der _Button_ deaktiviert wird.

In den Elm-Standardbibliotheken werden trotz der _Boolean Blindness_ häufig boolesche Werte verwendet.
Ein Beispiel für das Problem der _Boolean Blindness_ in den Standard-Bibliotheken ist die Funktion `filter`.
Wenn wir den Typ der Funktion `filter` betrachten

```elm
filter : (a -> Bool) -> List a -> List a
```

ist nicht klar, ob das Prädikat für diejenigen Elemente `True` liefert, die in der Liste verbleiben sollen, oder für die Elemente, die aus der Liste entfernt werden sollen.

Auch in diesem Beispiel können wir grundsätzlich einen Record verwenden, um dem booleschen Wert eine Semantik zuzuordnen.
Wir können zum Beispiel die folgende Definition von `filter` nutzen, um die Bedeutung des Typs `Bool` zu signalisieren.
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
Zur Illustration betrachten wir das folgende Beispiel, das aus einer Liste von Nutzer\*innen diejenigen übernimmt, deren Vorname mit `"A"` anfängt.

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

Wir wollen die Strukturierung mithilfe eines algebraischen Datentyps noch an einem weiteren Beispiel aus dem Buch [Domain Modeling Made Functional](https://pragprog.com/titles/swdddf/domain-modeling-made-functional/) illustrieren.
Wir nehmen an, dass wir eine Art Web-Shop implementieren wollen.
Im Rahmen der Anwendung muss ein digitaler Einkaufswagen modelliert werden.
Dieser Einkaufswagen besitzt drei Zustände.
Der Einkaufswagen kann leer, aktiv und bezahlt sein.
Im Zustand aktiv ist der Einkaufswagen nicht leer, ist aber auch noch nicht bezahlt.
Wir modellieren den Zustand eines leeren Einkaufswagens durch einen zusätzlichen Konstruktor `EmptyCart` und nicht durch eine leere Liste, damit Entwickler\*innen gezwungen werden, diesen Fall explizit zu behandeln.

```elm
type Model
    = EmptyCart
    | ActiveCart ActiveShoppingCart
    | PaidCart PaidShoppingCart
```

Um _impossible states_ zu vermeiden, müssen wir jetzt dafür sorgen, dass der `ActiveShoppingCart` und der `PaidShoppingCart` keine leere Liste von Gegenständen enthalten können.
Um dies zu erreichen erhalten beide Strukturen neben der `List Item` noch ein zusätzliches `Item`.
Auf diese Weise ist immer mindestens ein Gegenstand vorhanden.

```elm
type alias ActiveShoppingCart =
    { item : Item
    , items : List Item
    }


type alias PaidShoppingCart =
    { item : Item
    , items : List Item
    , payment : Float
    }
```

Für unser Modell wollen wir nun die folgende Logik umsetzen.
Wir können Gegenstände zu unserem Einkaufswagen hinzufügen und den Einkaufswagen bezahlen.
Einige Kombinationen aus `Model` und `Msg` sollten dabei nicht auftreten.
Zum Beispiel sollten wir keine Nachricht mehr erhalten, wenn wir uns im Zustand `PaidCart` befinden.

{% include callout-important.html content="
Wir sollten uns **nicht** nur darauf verlassen, dass solche Nachrichten durch deaktivierte Knöpfe oder ähnliches nicht an `update` verschickt werden.
" %}

Stattdessen sollten wir Kombinationen, die nicht auftreten dürfen auch in `update` ignorieren.
Diese Funktionsweise wird durch die folgende `update`-Funktion modelliert.

```elm
type Msg
    = AddItem Item
    | PayCart Float


update : Model -> Msg -> Model
update model msg =
    case model of
        EmptyCart ->
            case msg of
                AddItem newItem ->
                    ActiveCart { item = newItem, items = [] }

                _ ->
                    model

        ActiveCart { item, items } ->
            case msg of
                AddItem newItem ->
                    ActiveCart { item = newItem, items = item :: items }

                PayCart payment ->
                    PaidCart { item = item, items = items, payment = payment }

        PaidCart _ ->
            model
```

In diesem Beispiel ignorieren wir Kombinationen aus Nachrichten und Modellzuständen, die nicht auftreten sollten.
Zum Beispiel sollte es nicht möglich sein, den Einkaufswagen zu bezahlen, wenn er noch leer ist.
Leider ist es in Elm nicht möglich, einen Zusammenhang zwischen Modellzustand und Nachrichten im Typsystem auszudrücken und damit solche illegalen Zustände statisch zu verhindern.
Daher ignorieren wir hier illegale Kombinationen von Zustand und Nachricht.
Falls die Nachrichten durch die Interaktion von Nutzer\*innen verursacht wurden, sollten wir den Nutzer\*innen Feedback dazu geben, dass die Aktion aktuell nicht möglich ist.
Der Einfachheit halber verzichten wir in diesen Beispiel aber darauf.

{% include callout-important.html content="
Unabhängig davon, ob wir den Nutzer\*innen Feedback geben, sollten wir fehlerhafte Zustände aber auf jeden Fall an einen Logging-Server melden.
" %}

Eine entsprechende Implementierung können wir aber erst umsetzen, wenn wir im Abschnitt [HTTP-Anfragen](commands.md#http-anfragen) gelernt haben, wie man HTTP-Anfragen in Elm durchführt.
Wenn wir so weit sind, können wir in den Fällen, in denen wir aktuell `model` als Ergebnis zurückliefern, eine Nachricht an den Logging-Server senden, der es uns erlaubt, über den fehlerhaften Zustand informiert zu werden.
Wir haben dann die Möglichkeit, das Problem zu analysieren und zu beheben.

<!-- ## Isomorphe Datentypen

Im Kapitel [Algebraische Datentypen](https://hs-flensburg-gfp.github.io/algebraic-data-types.html) der Vorlesung Grundlagen der funktionalen Programmierung haben wir bereits angedeutet, dass algebraische Datentypen den Namen algebraisch tragen, da sie eine Algebra bilden und man somit mit ihnen Rechnen kann wie in einer Algebra.
Diesen Aspekt wollen wir an dieser Stelle noch einmal aufnehmen.

Die Algebra der Datentypen besteht aus Summen, Produkten, einer Eins und einer Null.
Summen werden dadurch gebildet, dass ein Datentyp verschiedene Fälle, also Konstruktoren, haben kann.
Produkte werden dadurch gebildet, dass ein Konstruktor mehrere Argumente haben kann.
Die Eins wird durch Datentypen dargestellt, die nur einen Konstruktor haben.
Die Null wird durch Datentypen dargestellt, die gar keinen Konstruktor haben.
Im Fall von Elm kann man Datentypen ohne Konstruktoren nicht selbst definieren, stattdessen stellt Elm einen Datentyp [`Never`](https://package.elm-lang.org/packages/elm/core/latest/Basics#Never) zur Verfügung, der keine Konstruktoren hat.

Die einfachste Möglichkeit zu illustrieren, dass algebraische Datentypen eine Algebra bilden, besteht darin, die Kardinalität von Datentypen zu betrachten.
Mit Kardinalität bezeichnet man die Anzahl der Werte, die ein Typ hat.
Der Datentyp `Bool` hat zum Beispiel die Kardinalität zwei, da der Typ `Bool` die Werte `True` und `False` hat.

Wir können nun das Produkt aus `()` und `()` bilden.
Wir bilden ein Produkt, indem wir die Datentypen als Argumente eines Konstruktors nutzen.

```elm
type Prod1
    = Prod1 () ()
```

Die Kardinalität eines Produkttyps ist das Produkt der Kardinalitäten der Komponenten des Produkttyps.
Das heißt, die Kardinalität von `Prod1` ist die Kardinalität von `()` multipliziert mit der Kardinalität von `()`.
Die Kardinalität von `()` ist eins, die Kardinalität von `Prod1` sollte also ebenfalls eins sein.
Tatsächlich hat der Typ `Prod1` nur einen einzigen Wert, nämlich `Prod1 () ()`.

Während das Produkt dadurch modelliert wird, dass ein Konstruktor mehrere Argumente hat, wird die Summe dadurch modelliert, dass es mehrere Konstruktoren gibt.

```elm
type Sum1
    = Inl1 ()
    | Inr1 ()
```

Die Kardinalität des Datentyps `Sum1` ist die Summe der Kardinalitäten der Typen `()` und `()`.
Der Datentyp `Sum1` hat also eine Kardinalität von `1 + 1 = 2`.
Tatsächlich hat der Typ `Sum1` zwei Werte, nämlich `Inl1 ()` und `Inr1 ()`.

Als komplexeres Beispiel betrachten wird den folgenden Datentyp.

```elm
type Prod2
    = Prod2 Sum1 Sum1
```

Da `Prod2` ein Produkt von `Sum1` und `Sum1` ist, sollte seine Kardinalität vier sein, da `2 * 2 = 4` gilt.
Und tatsächlich gibt es vier Werte vom Typ `Prod2`, nämlich `Prod2 (Inl1 ()) (Inl1 ())`, `Prod2 (Inl1 ()) (Inr1 ())`, `Prod2 (Inr1 ()) (Inl1 ())` und `Prod2 (Inr1 ()) (Inr1 ())`.

Wir können die algebraischen Gesetze aber nicht nur bezüglich der Kardinalität observieren.
Es gelten auch die typischen algebraischen Gesetze, die wir auch von `+` und `*` auf Zahlen kennen.
Wenn wir algebraische Gesetze anwenden erhalten wir allerdings nicht identische Datentypen, sondern isomorphe.
Zwei Datentypen sind dabei isomorph, wenn es eine bijektive Abbildung zwischen ihnen gibt.
Eine solche bijektive Abbildung ordnet jedem Wert des einen Typs genau einen Wert des anderen Typs zu und umgekehrt.
Umgangssprachlich haben zwei Typen die isomorph sind die gleichen Fähigkeiten, die einzelnen Werte sehen nur unterschiedlich aus.

Wir starten mit der Tatsache, dass die Eins das neutrale Element der Multiplikation ist.
Das heißt, wir haben `x * 1 = x` für alle Zahlen `x`.
Analog gilt, dass wir einen isomorphen Datentyp erhalten, wenn wir einen Datentyp mit einem Datentyp multiplizieren, der nur einen Konstruktor hat.
So ist der Datentyp `Prod1` zum Beispiel isomorph zum Datentyp `()`.
Das heißt, der Datentyp `Prod1` enthält genau so viele Informationen wie `()`.

In einer funktionalen Programmiersprache kann man die Tatsache, dass es einen Isomorphismus gibt, auch explizit darstellen.
Wir definieren zu diesem Zweck einfach zwei Funktionen, um die beiden Datentypen in Verbindung zu setzen.
Die folgenden beiden Funktionen illustrieren zum Beispiel den Isomorphismus zwischen `Prod1` und `()`.

```elm
to : Prod1 -> ()
to prod =
    case prod of
        Prod1 () unit ->
            unit
```

```elm
from : () -> Prod1
from unit =
    Prod1 () unit
```

Damit `to` und `from` einen Isomorphismus bilden muss für alle `x : Prod1` die Gleichung `from (to x) = x` gelten.
Außerdem muss für alle `y : ()` die Gleichung `to (from y) = y` gelten.
Das heißt, wenn wir die beiden Funktionen nacheinander anwenden, sollten wir wieder das ursprüngliche Argument erhalten.

{% include evaluation.html config=site.data.iso1 %}

Analog können wir auch zeigen, dass für alle `y` vom Typ `()` die Gleichung `to (from y) = y` erfüllt ist.

Als komplexeres Beispiel betrachten wir das Distributivgesetz.
Das Gesetz besagt, dass `x * (y + z) = x * y + x * z` gilt.
Wir können dieses Gesetz auf den Datentyp `Prod2` anwenden, da der Konstruktor `Prod2` ein Produkt aus `Sum1` und `Sum1` bildet und `Sum1` eine Summe ist.
Der Datentyp `Prod2` hat also die Form `x * (y + z)`.
Wir erhalten den folgenden Datentyp durch Anwendung des Distributivgesetzes.

```elm
type Sum2
    = Inl2 Prod3
    | Inr2 Prod3
```

```elm
type Prod3
    = Prod3 Sum1 ()
```

Die Typen `Prod2` und `Sum2` sind isomorph.
Um dies zu ziegen Definieren wir Funktionen `to` und `from`.

```elm
to : Prod2 -> Sum2
to prod =
    case prod of
        Prod2 sum (Inl1 ()) ->
            Inl2 (Prod3 sum ())

        Prod2 sum (Inr1 ()) ->
            Inr2 (Prod3 sum ())
```

```elm
from : Sum2 -> Prod2
from sum =
    case sum of
        Inl2 (Prod3 sum ()) ->
            Prod2 sum (Inl1 ())

        Inr2 (Prod3 sum ()) ->
            Prod2 sum (Inr1 ())
```

Wir zeigen nun, dass `to` und `from` einen Isomorphismus bilden.

{% include evaluation.html config=site.data.iso2 %}

Wir können an dieser Stelle mit den Umformungen nicht fortfahren, da wir wissen müssen, welche Form der Wert in Variable `sum2` hat.
Um fortzufahren, führen wir einfach eine Fallunterscheidung über die möglichen Werte von `sum2` durch.

1. Fall: `sum2 = Inl1 ()`

{% include evaluation.html config=site.data.iso21 %}

2. Fall : `sum2 = Inr1 ()`

Diesen Fall können wir analog zeigen.

Neben den hier vorgestellten Konzepten geht die Analogie zwischen Arithmetik auf Zahlen und der Struktur von algebraischen Datentypen aber noch weiter.
So stellt der Funktionstyp die Exponentiation im Bereich der Datentypen dar.
Außerdem kann man nicht nur üblichen Regeln zu `+` und `*` im Bereich der Datentypen anwenden, man kann sogar Ableitungen von algebraischen Datentypen bilden.

Das Konzept, dass Datentypen isomorph sein können, wirkt auf den ersten Blick sehr abstrakt und theoretisch.
Dieses Konzept hilft aber zum Beispiel dabei, über mögliche Varianten von Datentypimplementierungen zu diskutieren.


So handelt es sich bei der _Boolean Blindness_ zum Beispiel um isomorphe Datentypen.
Im Gegensatz dazu, gibt es bei _Impossible States_ darum, einen Datentyp so umzuwandeln, dass er nicht isomorph ist.
Schließlich soll die optimierte Darstellung weniger Fälle aufweisen als die ursprüngliche Variante, schließlich wollen wir Fälle vermeiden.

Grundsätzlich ist es gut, ein Verständnis davon zu haben, dass Datentypen isomorph sind, um alternative Designs zu diskutieren. -->

{% include bottom-nav.html previous="architecture.html" next="json.html" %}
