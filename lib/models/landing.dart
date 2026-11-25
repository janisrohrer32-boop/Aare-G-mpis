import 'dart:math' as math;

enum LandingQuality { perfect, good, crash }

class LandingResult {
  const LandingResult(this.quality, this.deviationDegrees);

  final LandingQuality quality;

  /// Abweichung von der aufrechten Haltung in Grad.
  final double deviationDegrees;

  String get label => switch (quality) {
        LandingQuality.perfect => 'Superhelden-Landung!',
        LandingQuality.good => 'Gelandet',
        LandingQuality.crash => 'Bruchlandung!',
      };

  /// Faktor für die Trickpunkte.
  double get multiplier => switch (quality) {
        LandingQuality.perfect => 1.5,
        LandingQuality.good => 1.0,
        LandingQuality.crash => 0.0,
      };

  int get bonus => switch (quality) {
        LandingQuality.perfect => 100,
        LandingQuality.good => 30,
        LandingQuality.crash => 0,
      };

  /// Wie sich das Style-Level der Figur verändert.
  int get styleChange => switch (quality) {
        LandingQuality.perfect => 1,
        LandingQuality.good => 0,
        LandingQuality.crash => -1,
      };
}

/// Bewertet die Landung auf dem Asphalt.
///
/// [angle]: Drehwinkel (0 = aufrecht, Füße unten).
/// [spin]: aktuelle Drehgeschwindigkeit (rad/s). Wer noch schnell dreht,
/// kann nicht sauber landen.
class LandingJudge {
  static const perfectMaxDeg = 25.0;
  static const goodMaxDeg = 55.0;
  static const perfectMaxSpin = 3.0;
  static const goodMaxSpin = 6.0;

  static LandingResult judge({required double angle, required double spin}) {
    final dev = deviation(angle);
    final s = spin.abs();
    if (dev <= perfectMaxDeg && s <= perfectMaxSpin) {
      return LandingResult(LandingQuality.perfect, dev);
    }
    if (dev <= goodMaxDeg && s <= goodMaxSpin) {
      return LandingResult(LandingQuality.good, dev);
    }
    return LandingResult(LandingQuality.crash, dev);
  }

  /// Abweichung von aufrecht in Grad (0..180).
  static double deviation(double angle) {
    var x = angle % (2 * math.pi);
    if (x > math.pi) x -= 2 * math.pi;
    return x.abs() * 180 / math.pi;
  }
}
