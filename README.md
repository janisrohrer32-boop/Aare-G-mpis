# Cliff Dive 🌊

2D-Stunt-Springen für iOS und Android, gebaut mit **Flutter** und der **Flame Engine**.
Spring vom Hochhaus-Balkon, mach in der Luft Saltos und lande in Superhelden-Pose.

## Stand

- Absprung vom Balkon eines Hochhauses (8. Stock, 24 m) über einer Stadt-Skyline
- Realistische Drehung: einmal angestossen dreht die Figur weiter, bis man gegensteuert
- Volle Umdrehungen zählen als Rückwärtssalto (+100) oder Vorwärtssalto (+80)
- Landung auf dem Asphalt: **Superhelden-Landung** (Risse im Boden), **Gelandet** oder **Bruchlandung**
- Style-Level (0 bis 5 Sterne): gute Landungen lassen die Figur strahlen, Bruchlandungen hinterlassen Spuren (zerzauste Haare, Schmutz, Pflaster)
- Münzen pro Sprung, Shop mit 5 Charakteren und 6 Outfits (alles lokal gespeichert)

## Steuerung

| Wann | Geste | Wirkung |
|---|---|---|
| Auf dem Balkon | Finger halten, dann loslassen | Kraft aufladen und abspringen (die Anzeige pendelt) |
| In der Luft | Nach oben wischen | Rückwärts drehen |
| In der Luft | Nach unten wischen | Vorwärts drehen |
| In der Luft | Gegen die Drehung wischen | Drehung stoppen |
| In der Luft | Kurz tippen | Strecken (dreht viel langsamer) / wieder zusammenrollen |

Beim Absprung hat die Figur einen leichten Vorwärtsdrall. Wer nichts tut, kippt langsam nach vorne.
Für die Superhelden-Landung muss sie aufrecht und fast ohne Drehung unten ankommen.

## Selbst starten

1. [Flutter installieren](https://docs.flutter.dev/get-started/install)
2. Im Projektordner: `flutter pub get`
3. Handy anschließen oder Emulator starten, dann `flutter run`
   (im Browser: `flutter run -d chrome`)

Tests: `flutter test`

## Ordnerstruktur

```
lib/
  game/        Spiel-Logik (CliffDiveGame, Drehphysik, Gesten-Erkennung)
  components/  Spielobjekte (Figur, Hochhaus, Strasse, Skyline, Effekte)
  models/      Daten (Tricks, Landung, Charaktere und Outfits, Level)
  screens/     Bildschirme (Menü, Spiel, Shop)
  services/    Speichern (Münzen, Käufe, Highscore, Style)
```

Die Figur wird per Code gezeichnet (`components/woman_painter.dart`) und kann später durch echte Grafiken ersetzt werden.

## Nächste Schritte

- Kombo-Multiplikator und mehr Tricks (z. B. Schraube)
- Weitere Absprungorte und Freischaltung
- Sound und Feinschliff
