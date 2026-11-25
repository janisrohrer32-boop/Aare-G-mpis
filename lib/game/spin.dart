import 'dart:math' as math;

import '../models/trick.dart';

/// Realistische Drehung: Einmal angestoßen dreht der Körper weiter,
/// bis man gegensteuert. Gestreckt dreht man langsamer (wie beim
/// echten Turmspringen), zusammengerollt schneller.
class SpinState {
  /// Aktueller Winkel (0 = aufrecht). Positiv = vorwärts (im Uhrzeigersinn).
  double angle = 0;

  /// Drehimpuls in rad/s (bei zusammengerolltem Körper).
  double omega = 0;

  bool stretched = false;
  double _accumulated = 0;

  static const double impulse = 6.5;
  static const double brakeMin = 2.0;
  static const double maxOmega = 14;
  static const double stretchFactor = 0.3;

  /// Leichter Vorwärtsdrall beim Absprung.
  static const double jumpSpin = 0.6;

  double get effectiveOmega => omega * (stretched ? stretchFactor : 1);

  void reset() {
    angle = 0;
    omega = 0;
    stretched = false;
    _accumulated = 0;
  }

  /// Wisch: [direction] -1 = rückwärts, +1 = vorwärts.
  /// Wischen gegen die aktuelle Drehung bremst ab (bei wenig Drehung bis 0).
  void push(int direction) {
    final opposing = omega != 0 && omega.sign != direction.sign;
    // Nur echte Drehungen werden abgebremst; ein leichter Drall wird
    // einfach überstimmt.
    if (opposing && omega.abs() >= brakeMin && omega.abs() <= impulse * 1.2) {
      omega = 0;
    } else {
      omega = (omega + direction * impulse).clamp(-maxOmega, maxOmega);
    }
  }

  /// Gibt alle Saltos zurück, die in diesem Schritt fertig wurden.
  List<Trick> update(double dt) {
    final d = effectiveOmega * dt;
    angle += d;
    _accumulated += d;
    final done = <Trick>[];
    while (_accumulated <= -2 * math.pi) {
      _accumulated += 2 * math.pi;
      done.add(Trick.backflip);
    }
    while (_accumulated >= 2 * math.pi) {
      _accumulated -= 2 * math.pi;
      done.add(Trick.frontflip);
    }
    return done;
  }
}
