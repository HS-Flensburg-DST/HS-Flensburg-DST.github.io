---
layout: post
title: "Vorwort"
---

<figure class="float-right small" markdown="1">

![Elm logo](/assets/graphics/elm-logo.svg){: width="200px"}

<figcaption>Logo der Sprache Elm</figcaption>
</figure>

In dieser Vorlesung wollen wir uns **deklarative Technologien der Softwareentwicklung** anschauen.
**Deklarativ** bedeutet dabei, dass man die Lösung für ein Problem beschreibt.
Im Bereich der Programmiersprachen unterscheidet man zum Beispiel zwischen deklarativen und imperativen Programmiersprachen.
In den **deklarativen Sprachen** wird eher beschrieben, wie die Lösung eines Problems aussieht, während in den imperativen Sprachen eher Schritt für Schritt erläutert wird, wie die Lösung berechnet wird.
Dadurch liegt bei den imperativen Programmiersprachen mehr Verantwortung bei den Entwickler\*innen.
Gleichzeitig haben die Entwickler\*innen bei einer imperativen Programmiersprache aber auch mehr Freiheiten, da weniger Aufgaben vom Compiler übernommen werden.
Im Gegensatz dazu liegt die Verantwortung bei den deklarativen Sprachen eher beim Compiler und die Entwickler\*innen haben weniger Freiheiten.

Der Hauptvertreter der deklarativen Sprachen sind **funktionale Programmiersprachen**.
Daher werden wir in dieser Vorlesung auch eine funktionale Programmiersprache einsetzen.
Deklarative Software-Technologien sind aber keineswegs auf funktionale Sprachen beschränkt, sondern kommen heutzutage in allen Formen von Sprachen zum Einsatz, zum Beispiel auch in objektorientierten Sprachen.

In dieser Vorlesung werden wir zweierlei Arten von deklarativen Technologien betrachten.
Zum einen lernen wir deklarative Technologien kennen, die durch eine funktionale Programmiersprache zur Verfügung gestellt werden.
Ein imperatives Programm wird zum Beispiel ausgeführt, indem die Anweisungen des Programms Schritt für Schritt ausgeführt werden.
Im Gegensatz dazu gibt es in funktionalen Programmen gar keine Anweisungen.
In funktionalen Sprachen entspricht die Ausführung eines Programms der Auswertung eines Ausdrucks und nicht der Abarbeitung von Anweisungen wie in imperativen Sprachen.
Das heißt, die Reihenfolge, in der etwas ausgerechnet wird, wird nicht durch die Entwickler\*innen bestimmt, sondern ist durch die Programmiersprache festgelegt.
Auch in imperativen Programmiersprachen erhält man wartbareren Code, wenn der Code möglichst unabhängig von der Reihenfolge der Auswertung ist.
Andersherum ausgedrückt, kann Code, dessen Verhalten sehr stark von der Reihenfolge der Ausführung abhängt, sehr schwer verständlich sein.

<figure class="float-right small" markdown="1">
![Elm logo](/assets/graphics/haskell-logo.svg){: width="200px"}
<figcaption>Logo der Sprache Haskell</figcaption>
</figure>

Die Programmiersprache [**Elm**](https://elm-lang.org) ist eine **rein funktionale Programmiersprache**.
Das heißt, die Ausführung eines Programms ist immer die Auswertung eines Ausdrucks.
Neben Elm gibt es eigentlich nur noch eine weitere rein funktionale Programmiersprache, die etwas verbreiteter ist, nämlich [Haskell](https://en.wikipedia.org/wiki/Haskell).
Die anderen rein funktionalen Programmiersprachen, die es gibt, wie [Rocq](https://en.wikipedia.org/wiki/Rocq_(software)) oder [Agda](https://en.wikipedia.org/wiki/Agda_(programming_language)), sind zwar schon vergleichsweise alt, ihre noch fortgeschritteneren Programmierkonzepte haben aber bisher noch keinen Einzug in Mainstream-Sprachen gefunden.

Neben den rein funktionalen Programmiersprachen gibt es aber noch eine ganze Reihe von Programmiersprachen, die grundlegend funktional sind, aber auch einzelne Sprachfeatures zur Verfügung stellen, die auf der Abarbeitung von Anweisungen basieren.
Zu diesen Sprachen gehören etwa [Clojure](https://en.wikipedia.org/wiki/Clojure), [Erlang](https://en.wikipedia.org/wiki/Erlang_(programming_language)), [Elixir](https://en.wikipedia.org/wiki/Elixir_(programming_language)) und [F#]().
Außerdem gibt es Hybridsprachen, welche die Ideen der funktionalen und der objektorientierten Sprachen kombinieren, etwa [Scala](https://en.wikipedia.org/wiki/Scala_(programming_language)), [Kotlin](https://en.wikipedia.org/wiki/Kotlin_(programming_language)) und [Swift](https://en.wikipedia.org/wiki/Swift_(programming_language)).

Während zu den funktionalen Programmiersprachen eine ganze Reihe von **dynamisch getypten Sprachen** wie [Clojure](https://en.wikipedia.org/wiki/Clojure), [Erlang](https://en.wikipedia.org/wiki/Erlang_(programming_language)) und [Elixir](https://en.wikipedia.org/wiki/Elixir_(programming_language)) gehören, sind die rein funktionalen Sprachen ausschließlich **statisch getypt** und weisen vergleichsweise **ausdrucksstarke Typsysteme** auf.
Statisch getypt bedeutet dabei, dass die Prüfung der Typkorrektheit eines Programms zur Kompilierzeit stattfindet.
Im Gegensatz dazu wird die Typkorrektheit bei einem dynamischen Typsystem erst zur Laufzeit des Programms überprüft.
Aus den rein funktionalen Sprachen stammen viele Konzepte, um **statische Garantien** für Eigenschaften von Programmen zu erhalten.
Wir werden uns in dieser Vorlesung daher auch immer wieder damit beschäftigen, wie wir statische Garantien über unsere Programme erhalten können.
Statische Garantien bedeuten dabei, dass ein erfolgreich kompilierendes Programm unter Garantie bestimmte Eigenschaften aufweist.
Zum Beispiel erhalten wir in einer statisch getypten Programmiersprache nie einen Typfehler zur Laufzeit, wenn das Programm erfolgreich kompiliert werden kann.[^1]

Neben diesen grundlegenden Ideen der funktionalen Programmierung, die es erlauben, deklarativ Software zu entwickeln, werden wir außerdem deklarative Technologien kennenlernen, die sich recht direkt auch im Kontext von imperativen oder objekt-orientierten Programmiersprachen umsetzen lassen.
Diese Technologien basieren zum Teil auch auf Konzepten, die früher nur in funktionalen Programmiersprachen zu finden waren, inzwischen aber auch Einzug in alle anderen Formen von Programmiersprachen gehalten haben, wie **Funktionen höherer Ordnung** bzw. **funktionale Argumente**.
Im Wesentlichen basieren diese Technologien immer auf einer gewissen Form von Abstraktion.
Ein Beispiel sind etwa Faltungen.
Faltungen werden genutzt, um wiederkehrende Muster von Schleifen zu abstrahieren.
Die eigentliche Schleifenlogik ist dann in Form der Faltung implementiert und Entwickler\*innen nutzen die Faltung, um eine konkrete Schleife auszudrücken.
Dadurch ist der eigentliche Code deklarativer, da die Faltung mit entsprechenden Parametern aufgerufen wird, um zu beschreiben, welche Schleife durchgeführt werden soll.
Es wird aber nicht mehr die Schleife selbst Schritt für Schritt beschrieben.

Bei einer Faltung besteht die Abstraktion nur aus einer einzigen Funktion bzw. Methode.
Bei anderen deklarativen Technologien wird eine ganze Gruppe von Funktionen bzw. Methoden genutzt, die sich kombinieren lassen, um eine Lösung für ein Problem zu beschreiben.
Im Grunde schreibt man in diesem Fall einfach eine Bibliothek, die dafür sorgt, dass man abstrakter beschreiben kann, wie ein Problem gelöst wird, da die konkreten Schritte zur Lösung durch die Bibliothek versteckt werden.
Man spricht in diesem Kontext auch von einer _embedded Domain-Specific Language_ (eDSL) bzw. einer **eingebetteten domänenspezifischen Sprache**.

Eine **domänenspezifische Sprache** ist eine Programmiersprache, die im Gegensatz zu einer *General-Purpose Language* nicht dazu gedacht ist, beliebige Arten von Programmen darin zu schreiben.
Stattdessen ist die Sprache für einen sehr speziellen Anwendungsfall gedacht.
Beispiele für domänenspezifische Sprachen sind etwa HTML, CSS oder SQL.
Eingebettete domänenspezifische Sprachen sind domänenspezifische Sprachen, die in einer *Host*-Sprache eingebettet sind und keinen eigenen Compiler oder Interpreter bieten.
Im Wesentlichen handelt es sich dabei um Bibliotheken, die als eine Art von kleiner Sprache aufgefasst werden können.
Hierzu gehören zum Beispiel Bibliotheken wie JUnit, jQuery oder [LINQ](https://en.wikipedia.org/wiki/Language_Integrated_Query).

Wir werden in dieser Vorlesung die Programmiersprache Elm nutzen.
Elm ist eine domänenspezifische Sprache zur Entwicklung von **Web-Frontend-Anwendungen** und eignet sich sehr gut, um alle Facetten von deklarativen Software-Technologien zu beleuchten.
Elm ist, wie bereits erwähnt, eine domänenspezifische Sprache.
Außerdem ist Elm eine funktionale Programmiersprache und bietet eine Reihe von eingebetteten domänenspezifischen Sprachen, zum Beispiel zur Definition von HTML oder um Daten im JSON-Format zu verarbeiten.
Zu guter Letzt nutzt Elm eine sehr deklarative Architektur, die sogenannte Elm-Architektur oder auch _Model-View-Update_-Architektur, um Web-Frontend-Anwendungen deklarativ zu formulieren.
Zum Beispiel wird in Elm nicht beschrieben, wie das HTML-Dokument sich durch Aktionen des Nutzers verändert.
Stattdessen wird nur zu jedem Zeitpunkt beschrieben, wie das HTML-Dokument aktuell aussieht und Elm berechnet mithilfe einer Technik, die als *Virtual DOM* bezeichnet wird, welche Operationen durchgeführt werden müssen, um von einem Zustand zum anderen zu gelangen.

Zu guter Letzt sei hier noch erwähnt, dass Elm in JavaScript übersetzt wird.
Wir können aus einer Elm-Anwendung entweder eine HTML-Seite inklusive JavaScript-Code erzeugen oder JavaScript-Code, den wir dann in eine bestehende Seite einbinden können.

[^1]: Diese Eigenschaft wird häufig durch das Zitat "Well-typed programs cannot 'go wrong'." von [Robin Milner](https://en.wikipedia.org/wiki/Robin_Milner) zusammengefasst.

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="basics.html">weiter</a></li>
    </ul>
</div>
