# Cliff Dive 🌊

2D-Klippenspringen für iOS und Android, gebaut mit **Flutter** und der **Flame Engine**.
Springe von der Klippe, mach in der Luft Saltos und tauche sauber ins Wasser ein.

## Stand: Schritt 1 – spielbare Grundversion

- Eine Klippe (Bergsee, 5 m)
- Absprung mit Kraftanzeige (halten = aufladen, loslassen = springen)
- Zwei Tricks: Rückwärtssalto und Vorwärtssalto
- Landung wird bewertet: **Perfekt**, **Gut** oder **Bauchklatscher**
- Highscore wird lokal gespeichert

## Steuerung

| Wann | Geste | Wirkung |
|---|---|---|
| Auf der Klippe | Finger halten, dann loslassen | Kraft aufladen und abspringen (die Anzeige pendelt, triff den richtigen Moment) |
| In der Luft | Nach oben wischen | Rückwärtssalto (+100) |
| In der Luft | Nach unten wischen | Vorwärtssalto (+80) |
| In der Luft | Kurz tippen | Körper strecken für eine saubere Landung |

Ein Salto braucht etwa 0,6 Sekunden. Wer zu spät damit anfängt, klatscht quer aufs Wasser.
**Perfekt** gibt es nur, wenn man gerade und gestreckt eintaucht.

## Selbst starten

1. [Flutter installieren](https://docs.flutter.dev/get-started/install)
2. Im Projektordner: `flutter pub get`
3. Handy anschließen oder Emulator starten, dann `flutter run`
   (im Browser: `flutter run -d chrome`)

Tests: `flutter test`

## Ordnerstruktur

```
lib/
  game/        Spiel-Logik (CliffDiveGame, Gesten-Erkennung)
  components/  Spielobjekte (Springer, Klippe, Wasser, Hintergrund, Texte)
  models/      Daten (Tricks, Landungsbewertung, Klippen)
  screens/     Bildschirme (Menü, Spiel)
  services/    Speichern
```

Die Grafiken sind einfache, gezeichnete Platzhalter und können später durch Bilder ersetzt werden.

## Nächste Schritte

2. Punktesystem mit Kombo-Multiplikator
3. Weitere Klippen und Freischaltung
4. Shop und Charakter-Anpassung
5. Grafik, Sound und Feinschliff
