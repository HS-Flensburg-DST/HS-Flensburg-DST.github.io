---
layout: post
title: "Vorwort"
---

In dieser Vorlesung wollen wir uns deklarative Technologien der Softwareentwicklung anschauen.
Deklarativ bedeutet dabei, dass man die Lösung für ein Problem beschreibt.
Im Bereich der Programmiersprachen unterscheidet man zum Beispiel zwischen deklarativen und imperativen Programmiersprachen.
In den deklarativen Sprachen wird eher beschrieben, wie die Lösung eines Problems aussieht, während in den imperativen Sprachen eher Schritt für Schritt erläutert wird, wie die Lösung berechnet wird.
Dadurch liegt bei den imperativen Programmiersprachen mehr Verantwortung bei der Programmiererin, was ihr mehr Freiheiten gibt.
Im Gegensatz dazu liegt die Verantwortung bei den deklarativen Sprachen eher beim Kompiler und die Programmiererin hat weniger Freiheiten.

Der Hauptvertreter der deklarativen Sprachen sind funktionale Programmiersprachen.
Daher werden wir in dieser Vorlesung auch eine funktionale Programmiersprache einsetzen.
Deklarative Software-Technologien sind aber keineswegs auf funktionale Sprachen beschränkt, sondern kommen heutzutage in allen Formen von Sprachen zum Einsatz, zum Beispiel auch in objektorientierten Sprachen.

In dieser Vorlesung werden wir zweierlei Arten von deklarativen Technologien betrachten.
Zum einen lernen wir deklarative Technologien kennen, die durch eine funktionale Programmiersprache zur Verfügung gestellt werden.
Ein imperatives Programm wird zum Beispiel ausgeführt, indem die Anweisungen des Programms Schritt für Schritt ausgeführt werden.
Im Gegensatz dazu gibt es in funktionalen Programmen gar keine Anweisungen.
Das heißt, die Reihenfolge, in der etwas ausgerechnet wird, wird nicht durch die Programmiererin bestimmt, sondern ist durch die Programmiersprache festgelegt.

Neben diesen grundlegenden Ideen der funktionalen Programmierung, die es erlauben, deklarativ Software zu entwickeln, werden wir außerdem deklarative Technologien kennenlernen, die sich recht direkt auch im Kontext von imperativen oder objekt-orientierten Programmiersprachen umsetzen lassen.
Diese Technologien basieren zum Teil auch auf Konzepten, die früher nur in funktionalen Programmiersprachen zu finden waren, inzwischen aber auch Einzug in alle anderen Formen von Programmiersprachen gehalten haben, wie Funktionen höherer Ordnung bzw. funktionale Argumente.
Im Wesentlichen basieren diese Technologien immer auf einer gewissen Form von Abstraktion.
Ein Beispiel sind etwa Faltungen.
Faltungen werden genutzt, um wiederkehrende Muster von Schleifen zu abstrahieren.
Die eigentliche Schleifenlogik ist dann in Form der Faltung implementiert und die Programmiererin nutzt die Faltung, um eine konkrete Schleife auszudrücken.
Dadurch ist der eigentliche Code deklarativer, da die Faltung mit entsprechenden Parametern aufgerufen wird, um zu beschreiben, welche Schleife durchgeführt wird.
Es wird aber nicht mehr die Schleife selbst Schritt für Schritt beschrieben.

Bei einer Faltung besteht die Abstraktion nur aus einer einzigen Funktion bzw. Methode.
Bei anderen deklarativen Technologien wird eine ganze Gruppe von Funktionen bzw. Methoden genutzt, die sich kombinieren lassen, um eine Lösung für ein Problem zu beschreiben.
Im Grunde schreibt man in diesem Fall einfach eine Bibliothek, die dafür sorgt, dass man abstrakter beschreiben kann, wie ein Problem gelöst wird, da die konkreten Schritte zur Lösung durch die Bibliothek versteckt werden.
Man spricht in diesem Kontext auch von einer *embedded domain-specific language* (eDSL) bzw. einer eingebetteten domänenspezifischen Sprache.

Eine domänenspezifische Sprache ist eine Programmiersprache, die im Gegensatz zu einer *general-purpose language* nicht dazu gedacht ist, beliebige Arten von Programmen darin zu schreiben.
Stattdessen ist die Sprache für einen sehr speziellen Anwendungsfall gedacht.
Beispiele für domänenspezifische Sprachen sind etwa HTML, CSS oder SQL.
Eingebettete domänenspezifische Sprachen sind domänenspezifische Sprachen, die in einer *Host*-Sprache eingebettet sind und keinen eigenen Kompiler oder Interpreter bieten.
Im Wesentlichen handelt es sich dabei um Bibliotheken, die als eine Art von kleiner Sprache aufgefasst werden können.
Hierzu gehören zum Beispiel Bibliotheken wie JUnit, jQuery oder LINQ.

Wir werden in dieser Vorlesung die Programmiersprache Elm nutzen.
Elm ist eine domänenspezifische Sprache zur Entwicklung von Web-Frontend-Anwendungen und eignet sich sehr gut, um alle Facetten von deklarativen Software-Technologien zu beleuchten.
Elm ist, wie bereits erwähnt, eine domänenspezifische Sprache.
Außerdem ist Elm eine funktionale Programmiersprache und bietet eine Reihe von eingebetteten domänenspezifischen Sprachen, zum Beispiel zur Definition von HTML oder um Daten im JSON-Format zu verarbeiten.
Zu guter Letzt nutzt Elm eine
sehr deklarative Architektur, die sogenannte Elm-Architektur, um Web-Frontend-Anwendungen deklarativ zu formulieren.
Zum Beispiel wird in Elm nicht beschrieben, wie das HTML-Dokument sich durch Aktionen des Nutzers verändert.
Stattdessen wird nur zu jedem Zeitpunkt beschrieben, wie das HTML-Dokument aktuell aussieht und Elm berechnet mit Hilfe einer Technik, die als *virtual dom* bezeichnet wird, welche Operationen durchgeführt werden müssen, um von einem Zustand zum anderen zu gelangen.

Zu guter Letzt sei hier noch erwähnt, dass Elm in JavaScript übersetzt wird.
Wir können aus einer Elm-Anwendung entweder eine HTML-Seite inklusive JavaScript-Code erzeugen oder JavaScript-Code, den wir dann in eine bestehende Seite einbinden können.

<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"><a href="basics.html">weiter</a></li>
    </ul>
</div>