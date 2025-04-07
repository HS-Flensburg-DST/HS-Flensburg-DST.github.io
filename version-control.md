---
layout: post
title: "Versionskontrolle"
---

Auf dieser Seite werden noch ein paar Regeln bei der Arbeit mit einer Versionskontrolle aufgeführt.


## Welche Dateien werden versioniert?

Bei der Verwendung einer Versionskontrolle sollte man darauf achten, welche Dateien man committet.
Es sollten nur Dateien committet werden, die von anderen Nutzer\*innen benötigt werden.
Man sollte zum Beispiel im Normalfall keine Dateien committen, die erzeugt werden.
In Elm sollte man zum Beispiel nicht die erzeugte HTML-Datei bzw. den JavaScript-Code zur Versionskontrolle hinzufügen.
Diese Dateien können von anderen Nutzer\*innen selbst erzeugt werden.
Wenn man Dateien dieser Art mit versioniert, führt das ggf. zu Inkonsistenzen zwischen den Quelldateien und den erzeugten Dateien, was die Fehlersuche ggf. erschwert.
Man sollte auch keine Konfigurationsdateien versionieren, die sich auf das lokale Setup beziehen.
Hierzu gehören zum Beispiel Konfigurationsdateien für den lokalen Editor.
Welche Dateien versioniert werden sollten, hängt dabei vom konkreten Projekt ab.
So kann es in einem Projekt mit mehreren Entwickler\*innen sinnvoll sein, eine Konfigurationsdatei für einen Editor zu versionieren, damit alle Personen die gleiche Konfiguration nutzen.
Im Kontext der Veranstaltung sollte man insbesondere darauf achten, dass Dateien nicht verändert werden, die zur Test-Infrastruktur gehören.
Wenn man einen Commit durchführt, sollte man zuvor immer die _Staged Changes_ überprüfen, also die Änderungen, die durch einen Commit zur Versionskontrolle hinzugefügt werden.
Nur wenn die _Staged Changes_ ausschließlich sinnvolle Dateien enthalten, sollte man den _Commit_ durchführen.


## Commit-Nachrichten

Commit-Nachrichten sollten einen konsistenten Stil verwenden.
Daher wird im Rahmen dieser Veranstaltung ein Stil für die Commit-Nachrichten vorgegeben.
Die Commit-Nachrichten sollten sich an die folgenden Regeln halten.

- Englische Sprache (**nicht** `Fehler behoben`)
- Startet mit einem großen Buchstaben (**nicht** `fix bug`)
- Nutzt den Imperativ (**nicht** `Fixed Bug`)
- Endet nicht mit einem Punkt (**nicht** `Fix bug.`)

Das heißt, eine Commit-Nachricht, die diesen Regeln entspricht wäre zum Beispiel `Fix bug`.
Im besten Fall drückt die Commit-Nachricht noch etwas stärker aus, welche Änderungen vorgenommen wurden.

Der Artikel [How to Write a Git Commit Message](https://cbea.ms/git-commit) gibt eine etwas ausführlichere Erklärung zum Stil von Commit-Nachrichten.
