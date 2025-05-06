---
layout: post
title: "Testfälle"
---

Während zu Anfang der Vorlesung keine Testfälle zum Einsatz kommen, enthält der Code, der zur Verfügung gestellt wird, in einer der späteren Aufgaben ein paar Testfälle, um zu überprüfen, ob die Implementierung noch grundlegende Fehler enthält.
Die Testfälle sind im Grunde dazu gedacht, um zu überprüfen, ob in der Implementierung noch Fehler existieren und nicht unbedingt, um Feedback zu geben, was an der Implementierung falsch ist.
Dennoch soll hier anhand eines Beispiels illustriert werden, wie die Ausgabe der Testfälle interpretiert werden kann, um herauszufinden, in welcher Funktion das Problem bestehen könnte.

Einer der Testfälle könnte zum Beispiel die folgende Ausgabe liefern.

```
removeLast (Cons arg Nothing) = Nothing

Given False
```

Die Testfälle, die in der Vorlesung verwendet werden, nutzen ein Konzept das _Property-based Testing_ heißt.
Bei dieser Art des Testens wird eine Eigenschaft definiert und diese wird mit zufällig generierten Eingaben getestet.
Im obigen Beispiel wurde etwa getestet, ob für alle möglichen Werte für `arg` der Aufruf `removeLast (Cons arg Nothing)` das Ergebnis `Nothing` liefert.
Die möglichen Werte für `arg` werden beim _Property-based Testing_ zufällig generiert.
Die Zeile `Given False` gibt den konkreten Wert an, für den die Eigenschaft nicht erfüllt ist.
Das heißt, die Eigenschaft ist für `arg = False` nicht erfüllt.
Das heißt, der Aufruf `removeLast (Cons False Nothing)` liefert als Ergebnis nicht `Nothing`.

In diesem Beispiel sollte man also überprüfen, welches Ergebnis der Aufruf `removeLast (Cons False Nothing)` liefert und warum dieser Aufruf nicht `Nothing` liefert.

Wir wollen noch ein Beispiel betrachten, bei dem die Eigenschaft zwei Werte hat, die zufällig generiert sind.

```
toList (fromList { head = arg1, tail = arg2 }) = arg1 :: arg2

Given (False,[])
```

Diese Eigenschaft sagt, dass der Aufruf `toList (fromList { head = arg1, tail = arg2 })` nicht für alle möglichen Werte von `arg1` und `arg2` das Ergebnis `arg1 :: arg2` liefert.
Die Zeile `Given (False,[])` gibt wieder konkrete Werte an, für die die Eigenschaft nicht erfüllt ist.
In diesem Fall gibt die Zeile aber zwei Werte an, da die Eigenschaft mit `arg1` und `arg2` zwei Werte nutzt.
Das heißt, die gesamte Ausgabe sagt, dass die Eigenschaft für `arg1 = False` und `arg2 = []` nicht erfüllt ist.
Anders ausgedrückt, liefert der Aufruf `toList (fromList { head = False, tail = [] })` als Ergebnis nicht `False :: []`, obwohl dies von der Eigenschaft gefordert wird.

In diesem Beispiel sollte man also überprüfen, welches Ergebnis der Aufruf `toList (fromList { head = False, tail = [] })` liefert und warum dieser Aufruf nicht `False :: []` liefert.
