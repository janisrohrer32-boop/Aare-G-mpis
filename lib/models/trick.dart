import 'dart:math' as math;

/// Ein Trick, den der Charakter in der Luft ausführen kann.
class Trick {
  const Trick({
    required this.id,
    required this.name,
    required this.basePoints,
    required this.rotation,
    required this.duration,
  });

  final String id;

  /// Anzeigename (wird animiert eingeblendet).
  final String name;

  /// Grundwert in Punkten.
  final int basePoints;

  /// Drehung in Radiant. Negativ = gegen den Uhrzeigersinn (rückwärts,
  /// weil der Charakter nach rechts springt).
  final double rotation;

  /// Wie lange der Trick dauert (Sekunden). Tricks brauchen Zeit!
  final double duration;

  static const backflip = Trick(
    id: 'backflip',
    name: 'Rückwärtssalto',
    basePoints: 100,
    rotation: -2 * math.pi,
    duration: 0.6,
  );

  static const frontflip = Trick(
    id: 'frontflip',
    name: 'Vorwärtssalto',
    basePoints: 80,
    rotation: 2 * math.pi,
    duration: 0.55,
  );
}
