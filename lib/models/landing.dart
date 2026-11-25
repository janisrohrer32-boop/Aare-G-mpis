import 'dart:math' as math;

enum LandingQuality { perfect, good, bellyFlop }

class LandingResult {
  const LandingResult(this.quality, this.deviationDegrees);

  final LandingQuality quality;

  /// Abweichung vom senkrechten Eintauchen in Grad.
  final double deviationDegrees;

  String get label => switch (quality) {
        LandingQuality.perfect => 'Perfekt!',
        LandingQuality.good => 'Gut',
        LandingQuality.bellyFlop => 'Bauchklatscher!',
      };

  /// Faktor, mit dem die Trickpunkte multipliziert werden.
  double get multiplier => switch (quality) {
        LandingQuality.perfect => 1.5,
        LandingQuality.good => 1.0,
        LandingQuality.bellyFlop => 0.0,
      };

  /// Bonuspunkte für die Landung selbst.
  int get bonus => switch (quality) {
        LandingQuality.perfect => 50,
        LandingQuality.good => 20,
        LandingQuality.bellyFlop => 0,
      };
}

/// Bewertet das Eintauchen ins Wasser.
///
/// [angle] ist der Drehwinkel des Körpers (0 = aufrecht, Füße unten).
/// Senkrecht mit den Füßen (0) oder mit dem Kopf voraus (π) ist sauber.
class LandingJudge {
  static const perfectMaxDeg = 15.0;
  static const goodMaxDeg = 45.0;

  static LandingResult judge({
    required double angle,
    required bool stretched,
    required bool trickInProgress,
  }) {
    final a = _normalize(angle).abs(); // 0..π
    final dev = math.min(a, math.pi - a) * 180 / math.pi;

    if (dev > goodMaxDeg) {
      return LandingResult(LandingQuality.bellyFlop, dev);
    }
    if (!trickInProgress && stretched && dev <= perfectMaxDeg) {
      return LandingResult(LandingQuality.perfect, dev);
    }
    return LandingResult(LandingQuality.good, dev);
  }

  static double _normalize(double a) {
    var x = a % (2 * math.pi);
    if (x > math.pi) x -= 2 * math.pi;
    return x;
  }
}
