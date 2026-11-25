# Cliff Dive 🌊

2D-Stunt-Springen für iOS und Android, gebaut mit **Flutter** und der **Flame Engine**.
Spring vom Hochhaus-Balkon, mach in der Luft Saltos und lande in Superhelden-Pose.

## Stand

- **Endlos-Modus:** Absprung vom Balkon eines Hochhauses. Nach jeder Landung geht es 3 Stockwerke höher (Start im 8. Stock), mit Höhenbonus.
- Realistische Drehung: einmal angestossen dreht die Figur weiter, bis man gegensteuert
- Volle Umdrehungen zählen als Rückwärtssalto (+100) oder Vorwärtssalto (+80)
- Landung auf dem Asphalt: **Superhelden-Landung** (Risse im Boden), **Gelandet** oder **Bruchlandung**
- Style-Sterne (Start 3, max. 5): Superhelden-Landung +1, Bruchlandung -1. Bei 0 Sternen ist **Game Over**. Man sieht es der Figur an (Glanz und Glitzer oder zerzauste Haare, Schmutz, Pflaster).
- Hip-Hop-Soundtrack, Soundeffekte und Sprüche („Whoop whoop!“ / „Hell naaah!“), Ton-Schalter oben links
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

## Musik und Sounds

Alle Sounds in `assets/audio/` wurden für dieses Projekt per Code erzeugt (Musik und Effekte synthetisiert, Stimme mit der Open-Source-Sprachausgabe Piper). Sie können frei ausgetauscht werden.

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
- Echte Grafiken (Sprites) für einen fotorealistischeren Look
- Sound und Feinschliff
