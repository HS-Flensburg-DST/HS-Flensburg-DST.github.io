---
layout: post
title: "Weitere Aspekte einer Web-Anwendung"
---

In diesem Kapitel werden weitere Themen im Kontext einer Web-Anwendung diskutiert.



Lokalisierte Zeit
-----------------

Im Kontext einer Web-Anwendung tritt immer wieder das Problem der korrekten Anzeige von Zeiten auf.
Hierbei führt vor allem die Darstellung einer Zeit in einer spezifischen Zeitzone wiederholt zu Problemen.

Selbst wenn eine Web-Anwendung nicht direkt mit Zeitdaten arbeitet, sind Zeitstempel häufig relevant, zum Beispiel um zu speichern, wann eine Änderung vorgenommen wurde.
Zur Darstellung dieser Zeitstempel wird im Backend häufig der Standard [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) verwendet.
Dieser Standard gibt ein Format an, in dem Zeit und Datum gespeichert werden können.
Dieses Format wird zum Beispiel von PostgreSQL genutzt, wenn man die Datentypen `timestamp` oder `timestamptz` für eine Spalte nutzt.
Der Typ `timestamptz` steht dabei für `timestamp with time zone`, was häufig zu Verwirrungen führt.
Dazu sei zuerst einmal gesagt, dass entgegen der Erwartungen, die der Name dieses Typs ggf. erzeugt, dieser Datentyp keine Zeitzone speichert.
Dieses Missverständnis sorgt häufig für Kritik an diesem Datentyp.
Es bedeutet aber nicht unbedingt, dass dieser Datentyp keine Berechtigung hat.
Grundsätzlich muss man bei lokalisierter Zeit zwei Anwendungsfälle unterscheiden, die zu unterschiedlichen Designs im Back- und Frontend führen.
Diese beiden Anwendungsfälle werden wir an dieser Stelle nacheinander diskutieren.

Zuerst ein wenig Begrifflichkeit.
Es gibt zwei unterschiedliche Bedeutungen für den Begriff Zeitzone.
Im Kontext von [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) ist mit dem Begriff Zeitzone ein _UTC offset_ gemeint, also eine Anzahl an Stunden, um die eine Zeit im Vergleich zur _Coordinated Universal Time (UTC)_ verschoben ist.
In der Sommerzeit ist Deutschland zum Beispiel in der Zeitzone `UTC+01:00`, in der Winterzeit aber in der Zeitzone `UTC+02:00`.
Hier wird auch schon der zweite Begriff von Zeitzone deutlich, nämlich die Regeln, nach denen ein bestimmter Bereich der Erde die Uhr stellt.
Die [IANA time zone database)](https://en.wikipedia.org/wiki/Tz_database) speichert diese Information zum Beispiel.
Das heißt, dort ist hinterlegt, an welchem Tag Deutschland von der Sommer- in die Winterzeit wechselt.
Diese Information ist dort auch historisch hinterlegt, dass der Wechsel zwischen Sommer- und Winterzeit erst im Jahre ??? eingeführt wurde.
Man sieht an diesem Beispiel schon, dass diese Information relativ komplex ist.
Die Verwechslung dieser beiden Begriffe von Zeitzone führt hauptsächlich zu den Problemen mit [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601).


### Anzeige in einer Zeitzone

Wenn wir in unserer Anwendung Zeitstempel immer in einer festen Zeitzone anzeigen werden, können wir gut den Datentyp `timestamptz` verwenden.
Als Beispiel wollen wir den Anwendungsfall betrachten, dass wir den aktuellen Zeitpunkt einer Änderung in der Datenbank speichern.
Wir nutzen dazu die SQL-Funktion `now()`.
Wenn wir für die Spalten den entsprechenden Datentyp wählen, liefert diese Funktion den aktuellen Zeitpunkt in der Zeitzone, die für den Server konfiguriert ist, auf dem die Datenbank läuft.
Wir gehen in unserem Beispiel davon aus, dass der Server die Zeitzone `Europe/Berlin` nutzt.
Der PostgreSQL-Server nutzt intern die [IANA time zone database)](https://en.wikipedia.org/wiki/Tz_database), das heißt, der Server weiß, wann Sommer- zu Winterzeit gewechselt wird.
Daher ist er in der Lage, die Uhrzeit in der Darstellung anzugeben, die wir auch bei uns auf der Uhr erwarten würde.
Wenn wir nur diese Information hätten könnten wir um die Zeitumstellung herum aber Zeitpunkt nicht mehr sequentiell zuordnen.







<div class="nav">
    <ul class="nav-row">
        <li class="nav-item nav-left"><a href="abstractions.html">zurück</a></li>
        <li class="nav-item nav-center"><a href="index.html">Inhaltsverzeichnis</a></li>
        <li class="nav-item nav-right"></li>
    </ul>
</div>
