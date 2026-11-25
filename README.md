# Cliff Dive 🌊

2D-Stunt-Springen für iOS und Android, gebaut mit **Flutter** und der **Flame Engine**.
Spring vom Hochhaus-Balkon, mach in der Luft Saltos und lande in Superhelden-Pose.

## Stand

- **Endlos-Modus:** Absprung vom Balkon eines Hochhauses. Nach jeder Landung geht es 3 Stockwerke höher (Start im 8. Stock), mit Höhenbonus.
- Realistische Drehung: einmal angestossen dreht die Figur weiter, bis man gegensteuert
- Volle Umdrehungen zählen als Rückwärtssalto (+100) oder Vorwärtssalto (+80)
- Landung auf dem Asphalt: **Superhelden-Landung** (Risse im Boden), **Gelandet** oder **Bruchlandung**
- Style-Sterne (Start 3, max. 5): Superhelden-Landung +1, Bruchlandung -1. Bei 0 Sternen ist **Game Over**. Man sieht es der Figur an (Glanz und Glitzer oder zerzauste Haare, Schmutz, Pflaster).
- **Durchgespielt** nach 10 guten Landungen in Folge: die Figur läuft zur Party
- 4 Soundtracks (Boom Bap, Lo-Fi, West Coast, Trap), Soundeffekte und Sprüche („Whoop whoop!“ / „Hell naaah!“) mit Frauen-, Männer- und Tierstimme, Ton-Schalter oben links
- Münzen pro Sprung, Shop mit 13 Figuren (Frauen, Männer, Tiere), 13 Outfits und Musik (alles lokal gespeichert)
- Kamera folgt der Figur auch bei grossen Höhen; im 5. Stock stehen drei Nachbarn auf dem Balkon

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

Zum Ausprobieren gibt es Test-Schalter, z. B. `flutter run -d chrome --dart-define=START_FLOOR=40 --dart-define=GOAL_STREAK=1 --dart-define=DEBUG_PERFECT=true`.

`--dart-define=DEBUG_FPS=true` schreibt alle 2 Sekunden die Bildrate in die Konsole. Im Browser lassen sich dann mit `?hide=clouds,street` einzelne Ebenen ausblenden, um zu sehen, was wie viel kostet (Namen: bg, clouds, sky0, haze, sky1, tower, men, street, shadow).

Damit das Spiel flüssig läuft, werden Hintergrund, Hochhaus und Strasse beim Start einmal als Bilder vorberechnet (`lib/components/raster.dart`), und im Browser wird höchstens mit doppelter Pixeldichte gezeichnet.

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
